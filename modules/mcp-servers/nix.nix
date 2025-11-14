{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.mcp.nix;
  
  # MCP Nix Operations Server
  mcpNixServer = pkgs.writeShellScriptBin "mcp-nix-server" ''
    #!/usr/bin/env bash
    # MCP Nix Server
    # Provides tools: rebuild_system, rollback, search_packages, show_config
    
    # JSON-RPC 2.0 handler
    while IFS= read -r line; do
      method=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.method')
      
      case "$method" in
        "list_tools")
          echo '{"jsonrpc":"2.0","result":[
            {"name":"rebuild_system","description":"Rebuild NixOS system","parameters":{}},
            {"name":"rollback","description":"Rollback to previous generation","parameters":{}},
            {"name":"search_packages","description":"Search for packages","parameters":{"query":"string"}},
            {"name":"show_config","description":"Show current configuration","parameters":{}}
          ]}'
          ;;
        "rebuild_system")
          output=$(sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch 2>&1)
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$output\"}"
          ;;
        "rollback")
          output=$(sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --rollback 2>&1)
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$output\"}"
          ;;
        "search_packages")
          query=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.params.query')
          output=$(${pkgs.nix}/bin/nix search nixpkgs "$query" 2>&1)
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$output\"}"
          ;;
        "show_config")
          output=$(cat /etc/nixos/configuration.nix 2>&1)
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$output\"}"
          ;;
        *)
          echo '{"jsonrpc":"2.0","error":{"code":-32601,"message":"Method not found"}}'
          ;;
      esac
    done
  '';
  
in {
  options.services.aira.mcp.nix = {
    enable = mkEnableOption "MCP Nix Operations Server";
    
    port = mkOption {
      type = types.port;
      default = 9002;
      description = "Port for MCP Nix Server";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mcp-nix = {
      description = "MCP Nix Operations Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${mcpNixServer}/bin/mcp-nix-server";
        Restart = "always";
        RestartSec = 3;
        User = "root"; # Needs root for nixos-rebuild
        
        # Security hardening (limited due to root requirement)
        NoNewPrivileges = false;
        PrivateTmp = true;
      };
    };
  };
}
