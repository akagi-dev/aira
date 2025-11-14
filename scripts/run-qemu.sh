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

# Configuration
MEMORY=${MEMORY:-4096}        # 4GB RAM
CORES=${CORES:-4}             # 4 CPU cores
GRAPHICS=${GRAPHICS:-true}    # Enable graphics by default

echo "🤖 Starting AIRA VM..."
echo "   Memory: ${MEMORY}MB"
echo "   Cores: ${CORES}"
echo "   Graphics: ${GRAPHICS}"
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

# QEMU options
QEMU_OPTS=(
    -m "$MEMORY"
    -smp "$CORES"
    -enable-kvm
    -cpu host
    -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:8080,hostfwd=tcp::11434-:11434
    -device virtio-net-pci,netdev=net0
)

# Add graphics options
if [ "$GRAPHICS" = "true" ]; then
    QEMU_OPTS+=(
        -vga virtio
        -display gtk
    )
else
    QEMU_OPTS+=(
        -nographic
    )
fi

# Run the VM
exec "$(readlink -f result)/bin/run-nixos-vm" "${QEMU_OPTS[@]}"
