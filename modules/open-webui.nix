{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.openWebUI;
in {
  options.services.aira.openWebUI = {
    enable = mkEnableOption "Open WebUI";
    
    package = mkOption {
      type = types.package;
      # Open WebUI from nixpkgs if available, otherwise placeholder
      default = pkgs.open-webui or (pkgs.writeShellScriptBin "open-webui" ''
        echo "Open WebUI starting on port ${toString cfg.port}..."
        echo "Connecting to Ollama at ${cfg.ollamaUrl}"
        # Placeholder - in production this would be the actual Open WebUI
        exec ${pkgs.python3}/bin/python3 -m http.server ${toString cfg.port}
      '');
      description = "The Open WebUI package to use";
    };
    
    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Host to bind Open WebUI";
    };
    
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port for Open WebUI";
    };
    
    ollamaUrl = mkOption {
      type = types.str;
      default = "http://127.0.0.1:11434";
      description = "URL to Ollama API";
    };
    
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/open-webui";
      description = "Directory for Open WebUI data";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    
    systemd.services.open-webui = {
      description = "Open WebUI - Web Interface for LLMs";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "ollama.service" ];
      wants = [ "ollama.service" ];
      
      environment = {
        HOME = "/var/lib/open-webui";
        OLLAMA_BASE_URL = cfg.ollamaUrl;
        WEBUI_HOST = cfg.host;
        WEBUI_PORT = toString cfg.port;
        DATA_DIR = cfg.dataDir;
      };
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/open-webui serve";
        Restart = "always";
        RestartSec = 3;
        StateDirectory = "open-webui";
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
