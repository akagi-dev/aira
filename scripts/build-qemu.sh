#!/usr/bin/env bash
# Build QEMU VM image for AIRA
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "🤖 Building AIRA QEMU VM image..."
echo "   This may take several minutes..."

# Build the VM image
nix build .#qemu-vm --impure --show-trace

if [ -L result ]; then
    echo "✅ Build successful!"
    echo "   VM image: $(readlink -f result)"
    echo ""
    echo "To run the VM:"
    echo "   make run"
    echo "   or: ./scripts/run-qemu.sh"
else
    echo "❌ Build failed!"
    exit 1
fi
