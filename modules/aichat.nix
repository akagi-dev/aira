{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.aichat;
  
  # aichat configuration file
  aichatConfig = pkgs.writeText "aichat-config.yaml" ''
    model: ${cfg.defaultModel}
    
    clients:
      - type: ollama
        api_base: ${cfg.ollamaUrl}
        models:
          - name: ${cfg.defaultModel}
            max_tokens: 4096
    
    # Use Ollama as default provider
    default_client: ollama
  '';
  
in {
  options.services.aira.aichat = {
    enable = mkEnableOption "aichat TUI client";
    
    package = mkOption {
      type = types.package;
      default = pkgs.aichat or (pkgs.writeShellScriptBin "aichat" ''
        echo "aichat TUI - AI Chat Interface"
        echo "Using model: ${cfg.defaultModel}"
        echo "Ollama URL: ${cfg.ollamaUrl}"
        # Placeholder for aichat
        exec ${pkgs.bash}/bin/bash
      '');
      description = "The aichat package to use";
    };
    
    defaultModel = mkOption {
      type = types.str;
      default = config.services.aira.ollama.model or "llama3.2:3b";
      description = "Default model to use in aichat";
    };
    
    ollamaUrl = mkOption {
      type = types.str;
      default = "http://127.0.0.1:11434";
      description = "URL to Ollama API";
    };
    
    configDir = mkOption {
      type = types.path;
      default = "/etc/aichat";
      description = "Directory for aichat configuration";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    
    # Install aichat configuration globally
    environment.etc."aichat/config.yaml" = {
      source = aichatConfig;
      mode = "0644";
    };
    
    # Set environment variable for aichat config location
    environment.variables = {
      AICHAT_CONFIG_DIR = cfg.configDir;
    };
  };
}
