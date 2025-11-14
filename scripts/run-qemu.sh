#!/usr/bin/env bash
# Run QEMU VM for AIRA
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Check if VM is built
if [ ! -L result ]; then
    echo "❌ VM not built yet. Run 'make vm' first."
    exit 1
fi

echo "🤖 Starting AIRA VM..."
echo ""
echo "Port forwarding:"
echo "   SSH:        localhost:2222 → VM:22"
echo "   Open WebUI: localhost:8080 → VM:8080"
echo "   Ollama API: localhost:11434 → VM:11434"
echo ""
echo "To connect via SSH:"
echo "   ssh aira@localhost -p 2222"
echo "   Password: aira"
echo ""

# Run the VM
# The Nix-generated script already includes all necessary QEMU options
# from the configuration in images/qemu.nix
exec "$(readlink -f result)/bin/run-nixos-vm"
