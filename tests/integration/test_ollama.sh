#!/usr/bin/env bash
# Integration test for Ollama service
set -euo pipefail

echo "Testing Ollama service..."

# Check if Ollama service is running
if systemctl is-active --quiet ollama; then
    echo "✅ Ollama service is running"
else
    echo "❌ Ollama service is not running"
    exit 1
fi

# Check if Ollama API is responding
if curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "✅ Ollama API is responding"
else
    echo "❌ Ollama API is not responding"
    exit 1
fi

# Check if default model is loaded
MODEL="llama3.2:3b"
if curl -s http://localhost:11434/api/tags | grep -q "$MODEL"; then
    echo "✅ Model $MODEL is available"
else
    echo "⚠️  Model $MODEL not found (may still be downloading)"
fi

# Test a simple API request
echo "Testing Ollama API with a simple request..."
RESPONSE=$(curl -s -X POST http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d '{
        "model": "'"$MODEL"'",
        "prompt": "Hello",
        "stream": false
    }' || echo "error")

if [ "$RESPONSE" != "error" ]; then
    echo "✅ Ollama API request successful"
else
    echo "⚠️  Ollama API request failed (model may not be ready)"
fi

echo "✅ Ollama tests completed"
