#!/usr/bin/env bash
# Integration test for MCP servers
set -euo pipefail

echo "Testing MCP servers..."

# Test MCP Filesystem Server
if systemctl is-active --quiet mcp-filesystem; then
    echo "✅ MCP Filesystem server is running"
else
    echo "❌ MCP Filesystem server is not running"
    exit 1
fi

# Test MCP Nix Server
if systemctl is-active --quiet mcp-nix; then
    echo "✅ MCP Nix server is running"
else
    echo "❌ MCP Nix server is not running"
    exit 1
fi

# Test MCP Systemd Server
if systemctl is-active --quiet mcp-systemd; then
    echo "✅ MCP Systemd server is running"
else
    echo "❌ MCP Systemd server is not running"
    exit 1
fi

# Test MCP Shell Server
if systemctl is-active --quiet mcp-shell; then
    echo "✅ MCP Shell server is running"
else
    echo "❌ MCP Shell server is not running"
    exit 1
fi

echo "✅ All MCP servers are running"
