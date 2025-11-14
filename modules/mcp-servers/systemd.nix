{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.mcp.systemd;
  
  # MCP Systemd Server
  mcpSystemdServer = pkgs.writeShellScriptBin "mcp-systemd-server" ''
    #!/usr/bin/env bash
    # MCP Systemd Server
    # Provides tools: start_service, stop_service, restart_service, status_service, list_services
    
    # JSON-RPC 2.0 handler
    while IFS= read -r line; do
      method=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.method')
      
      case "$method" in
        "list_tools")
          echo '{"jsonrpc":"2.0","result":[
            {"name":"start_service","description":"Start a systemd service","parameters":{"service":"string"}},
            {"name":"stop_service","description":"Stop a systemd service","parameters":{"service":"string"}},
            {"name":"restart_service","description":"Restart a systemd service","parameters":{"service":"string"}},
            {"name":"status_service","description":"Get service status","parameters":{"service":"string"}},
            {"name":"list_services","description":"List all services","parameters":{}}
          ]}'
          ;;
        "start_service")
          service=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.params.service')
          output=$(sudo ${pkgs.systemd}/bin/systemctl start "$service" 2>&1)
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$output\"}"
          ;;
        "stop_service")
          service=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.params.service')
          output=$(sudo ${pkgs.systemd}/bin/systemctl stop "$service" 2>&1)
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$output\"}"
          ;;
        "restart_service")
          service=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.params.service')
          output=$(sudo ${pkgs.systemd}/bin/systemctl restart "$service" 2>&1)
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$output\"}"
          ;;
        "status_service")
          service=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.params.service')
          output=$(${pkgs.systemd}/bin/systemctl status "$service" 2>&1)
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$output\"}"
          ;;
        "list_services")
          output=$(${pkgs.systemd}/bin/systemctl list-units --type=service 2>&1)
          echo "{\"jsonrpc\":\"2.0\",\"result\":\"$output\"}"
          ;;
        *)
          echo '{"jsonrpc":"2.0","error":{"code":-32601,"message":"Method not found"}}'
          ;;
      esac
    done
  '';
  
in {
  options.services.aira.mcp.systemd = {
    enable = mkEnableOption "MCP Systemd Server";
    
    port = mkOption {
      type = types.port;
      default = 9003;
      description = "Port for MCP Systemd Server";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mcp-systemd = {
      description = "MCP Systemd Management Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${mcpSystemdServer}/bin/mcp-systemd-server";
        Restart = "always";
        RestartSec = 3;
        User = "root"; # Needs root for systemctl operations
        
        # Security hardening (limited due to root requirement)
        NoNewPrivileges = false;
        PrivateTmp = true;
      };
    };
  };
}
