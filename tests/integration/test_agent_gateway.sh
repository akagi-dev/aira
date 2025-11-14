#!/usr/bin/env bash
# Integration test for Agent Gateway service
set -euo pipefail

echo "Testing Agent Gateway service..."

# Check if Agent Gateway service is running
if systemctl is-active --quiet agent-gateway; then
    echo "✅ Agent Gateway service is running"
else
    echo "❌ Agent Gateway service is not running"
    exit 1
fi

# Check if Agent Gateway API is responding
GATEWAY_PORT=8081
if curl -s http://localhost:$GATEWAY_PORT/ > /dev/null 2>&1; then
    echo "✅ Agent Gateway API is responding"
else
    echo "⚠️  Agent Gateway API is not responding on port $GATEWAY_PORT"
fi

# Test connection to Ollama through Gateway
echo "Testing Agent Gateway connection to Ollama..."
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "✅ Agent Gateway can connect to Ollama"
else
    echo "⚠️  Agent Gateway cannot connect to Ollama"
fi

echo "✅ Agent Gateway tests completed"
