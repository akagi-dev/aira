{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.agentGateway;
  
  # Agent Gateway configuration file
  configFile = pkgs.writeText "agent-gateway-config.json" (builtins.toJSON {
    ollama = {
      host = config.services.aira.ollama.host;
      port = config.services.aira.ollama.port;
    };
    mcp = {
      servers = cfg.mcpServers;
    };
    gateway = {
      host = cfg.host;
      port = cfg.port;
      websocket = cfg.enableWebSocket;
    };
  });
  
in {
  options.services.aira.agentGateway = {
    enable = mkEnableOption "Agent Gateway MCP Router";
    
    package = mkOption {
      type = types.package;
      # For now, we'll create a placeholder since agent-gateway isn't in nixpkgs
      default = pkgs.writeShellScriptBin "agent-gateway" ''
        # Placeholder for Agent Gateway
        # In production, this would be the actual agent-gateway binary
        echo "Agent Gateway starting..."
        echo "Config: ${configFile}"
        exec ${pkgs.python3}/bin/python3 -m http.server ${toString cfg.port}
      '';
      description = "The Agent Gateway package to use";
    };
    
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host to bind Agent Gateway";
    };
    
    port = mkOption {
      type = types.port;
      default = 8081;
      description = "Port for Agent Gateway API";
    };
    
    enableWebSocket = mkOption {
      type = types.bool;
      default = true;
      description = "Enable WebSocket support";
    };
    
    mcpServers = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "List of MCP servers to connect";
    };
    
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/agent-gateway";
      description = "Directory for Agent Gateway data";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    
    systemd.services.agent-gateway = {
      description = "Agent Gateway MCP Router";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "ollama.service" ];
      wants = [ "ollama.service" ];
      
      environment = {
        HOME = "/var/lib/agent-gateway";
        GATEWAY_CONFIG = configFile;
        GATEWAY_HOST = cfg.host;
        GATEWAY_PORT = toString cfg.port;
      };
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/agent-gateway";
        Restart = "always";
        RestartSec = 3;
        StateDirectory = "agent-gateway";
        DynamicUser = true;
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
      };
    };
  };
}
