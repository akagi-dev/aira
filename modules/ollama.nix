{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.ollama;
in {
  options.services.aira.ollama = {
    enable = mkEnableOption "Ollama LLM service";
    
    package = mkOption {
      type = types.package;
      default = pkgs.ollama;
      description = "The Ollama package to use";
    };
    
    model = mkOption {
      type = types.str;
      default = "llama3.2:3b";
      description = "Default model to download and use";
    };
    
    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host to bind Ollama API";
    };
    
    port = mkOption {
      type = types.port;
      default = 11434;
      description = "Port for Ollama API";
    };
    
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/ollama";
      description = "Directory for Ollama data and models";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    
    systemd.services.ollama = {
      description = "Ollama LLM Service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      environment = {
        OLLAMA_HOST = "${cfg.host}:${toString cfg.port}";
        OLLAMA_MODELS = "${cfg.dataDir}/models";
      };
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/ollama serve";
        Restart = "always";
        RestartSec = 3;
        StateDirectory = "ollama";
        DynamicUser = true;
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      };
    };
    
    # Service to pull the default model on first boot
    systemd.services.ollama-pull-model = {
      description = "Pull Ollama default model";
      after = [ "ollama.service" ];
      wants = [ "ollama.service" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "ollama-pull-model" ''
          set -e
          # Wait for Ollama to be ready
          for i in {1..30}; do
            if ${pkgs.curl}/bin/curl -s http://${cfg.host}:${toString cfg.port}/api/tags > /dev/null 2>&1; then
              break
            fi
            sleep 2
          done
          
          # Pull the model if not already present
          if ! ${cfg.package}/bin/ollama list | grep -q "${cfg.model}"; then
            ${cfg.package}/bin/ollama pull ${cfg.model}
          fi
        '';
      };
    };
  };
}
