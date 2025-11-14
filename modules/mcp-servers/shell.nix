{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.mcp.shell;
  
  # MCP Shell Server with whitelisted commands
  mcpShellServer = pkgs.writeShellScriptBin "mcp-shell-server" ''
    #!/usr/bin/env bash
    # MCP Shell Server
    # Provides safe shell command execution with whitelist
    
    # Whitelist of allowed commands
    ALLOWED_COMMANDS="${concatStringsSep " " cfg.allowedCommands}"
    
    check_command_allowed() {
      local cmd=$1
      for allowed in $ALLOWED_COMMANDS; do
        if [[ "$cmd" == "$allowed" ]]; then
          return 0
        fi
      done
      return 1
    }
    
    # JSON-RPC 2.0 handler
    while IFS= read -r line; do
      method=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.method')
      
      case "$method" in
        "list_tools")
          echo '{"jsonrpc":"2.0","result":[
            {"name":"execute_command","description":"Execute whitelisted shell command","parameters":{"command":"string","args":"array"}},
            {"name":"list_allowed_commands","description":"List allowed commands","parameters":{}}
          ]}'
          ;;
        "execute_command")
          command=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.params.command')
          if check_command_allowed "$command"; then
            args=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.params.args | join(" ")')
            output=$(timeout ${toString cfg.commandTimeout}s $command $args 2>&1)
            exit_code=$?
            echo "{\"jsonrpc\":\"2.0\",\"result\":{\"output\":\"$output\",\"exit_code\":$exit_code}}"
          else
            echo '{"jsonrpc":"2.0","error":{"code":-32001,"message":"Command not whitelisted"}}'
          fi
          ;;
        "list_allowed_commands")
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$ALLOWED_COMMANDS\"}"
          ;;
        *)
          echo '{"jsonrpc":"2.0","error":{"code":-32601,"message":"Method not found"}}'
          ;;
      esac
    done
  '';
  
in {
  options.services.aira.mcp.shell = {
    enable = mkEnableOption "MCP Shell Server";
    
    allowedCommands = mkOption {
      type = types.listOf types.str;
      default = [
        "ls" "cat" "echo" "date" "uptime" "whoami"
        "df" "free" "ps" "top" "htop"
        "git" "nix" "systemctl"
      ];
      description = "Whitelist of allowed shell commands";
    };
    
    commandTimeout = mkOption {
      type = types.int;
      default = 30;
      description = "Timeout for command execution in seconds";
    };
    
    port = mkOption {
      type = types.port;
      default = 9004;
      description = "Port for MCP Shell Server";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mcp-shell = {
      description = "MCP Shell Command Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${mcpShellServer}/bin/mcp-shell-server";
        Restart = "always";
        RestartSec = 3;
        DynamicUser = true;
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        
        # Sandbox execution
        PrivateDevices = true;
        ProtectKernelTunables = true;
        ProtectControlGroups = true;
      };
    };
  };
}
