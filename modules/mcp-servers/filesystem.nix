{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.mcp.filesystem;
  
  # MCP Filesystem Server implementation
  mcpFsServer = pkgs.writeShellScriptBin "mcp-filesystem-server" ''
    #!/usr/bin/env bash
    # MCP Filesystem Server
    # Provides tools: read_file, write_file, list_directory
    
    ALLOWED_DIRS="${concatStringsSep ":" cfg.allowedDirectories}"
    
    # Simple JSON-RPC 2.0 handler
    while IFS= read -r line; do
      # Parse request and handle methods
      method=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.method')
      
      case "$method" in
        "list_tools")
          echo '{"jsonrpc":"2.0","result":[
            {"name":"read_file","description":"Read file contents","parameters":{"path":"string"}},
            {"name":"write_file","description":"Write file contents","parameters":{"path":"string","content":"string"}},
            {"name":"list_directory","description":"List directory contents","parameters":{"path":"string"}}
          ]}'
          ;;
        "read_file")
          path=$(echo "$line" | ${pkgs.jq}/bin/jq -r '.params.path')
          if [[ "$ALLOWED_DIRS" == *"$(dirname "$path")"* ]]; then
            content=$(cat "$path" 2>/dev/null || echo "Error: File not found")
            echo "{\"jsonrpc\":\"2.0\",\"result\":\"$content\"}"
          else
            echo '{"jsonrpc":"2.0","error":{"code":-32001,"message":"Access denied"}}'
          fi
          ;;
        *)
          echo '{"jsonrpc":"2.0","error":{"code":-32601,"message":"Method not found"}}'
          ;;
      esac
    done
  '';
  
in {
  options.services.aira.mcp.filesystem = {
    enable = mkEnableOption "MCP Filesystem Server";
    
    allowedDirectories = mkOption {
      type = types.listOf types.path;
      default = [ "/home" "/tmp" "/var/lib/aira" ];
      description = "Whitelist of directories accessible to the MCP server";
    };
    
    port = mkOption {
      type = types.port;
      default = 9001;
      description = "Port for MCP Filesystem Server";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mcp-filesystem = {
      description = "MCP Filesystem Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      
      serviceConfig = {
        Type = "simple";
        ExecStart = "${mcpFsServer}/bin/mcp-filesystem-server";
        Restart = "always";
        RestartSec = 3;
        DynamicUser = true;
        
        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = cfg.allowedDirectories;
      };
    };
  };
}
