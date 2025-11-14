# AIRA - AI-powered NixOS System
# Makefile for building and managing AIRA VM images

.PHONY: all vm iso run test clean help

# Default target
all: help

# Build QEMU VM image
vm:
	@echo "🤖 Building AIRA QEMU VM image..."
	@echo "   This may take several minutes..."
	@nix build .#qemu-vm --impure --show-trace
	@if [ -L result ]; then \
		echo "✅ Build successful!"; \
		echo "   VM image: $$(readlink -f result)"; \
		echo ""; \
		echo "To run the VM:"; \
		echo "   make run"; \
	else \
		echo "❌ Build failed!"; \
		exit 1; \
	fi

# Build ISO image
iso:
	@echo "💿 Building ISO image..."
	@nix build .#iso --impure --show-trace
	@echo "✅ ISO built: $$(readlink -f result)"

# Run QEMU VM
run:
	@if [ ! -L result ]; then \
		echo "❌ VM not built yet. Run 'make vm' first."; \
		exit 1; \
	fi
	@echo "🤖 Starting AIRA VM..."
	@echo ""
	@echo "Port forwarding:"
	@echo "   SSH:        localhost:2222 → VM:22"
	@echo "   Open WebUI: localhost:8080 → VM:8080"
	@echo "   Ollama API: localhost:11434 → VM:11434"
	@echo ""
	@echo "To connect via SSH:"
	@echo "   ssh aira@localhost -p 2222"
	@echo "   Password: aira"
	@echo ""
	@exec $$(readlink -f result)/bin/run-aira-vm

# Run in headless mode
run-headless:
	@if [ ! -L result ]; then \
		echo "❌ VM not built yet. Run 'make vm' first."; \
		exit 1; \
	fi
	@echo "🤖 Starting AIRA VM (headless)..."
	@echo ""
	@echo "Port forwarding:"
	@echo "   SSH:        localhost:2222 → VM:22"
	@echo "   Open WebUI: localhost:8080 → VM:8080"
	@echo "   Ollama API: localhost:11434 → VM:11434"
	@echo ""
	@echo "To connect via SSH:"
	@echo "   ssh aira@localhost -p 2222"
	@echo "   Password: aira"
	@echo ""
	@exec $$(readlink -f result)/bin/run-aira-vm -nographic

# Run tests
test:
	@echo "🧪 Running integration tests..."
	@./scripts/test-system.sh

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf result result-*
	@rm -f *.qcow2 *.qcow2.tmp
	@echo "✅ Clean complete"

# Rebuild configuration (inside VM)
rebuild:
	@echo "🔄 Rebuilding NixOS configuration..."
	@sudo nixos-rebuild switch

# Update flake inputs
update:
	@echo "⬆️  Updating flake inputs..."
	@nix flake update

# Check flake
check:
	@echo "🔍 Checking flake..."
	@nix flake check

# Format Nix files
fmt:
	@echo "📝 Formatting Nix files..."
	@nix fmt

# Development shell
dev:
	@echo "🛠️  Entering development shell..."
	@nix develop

# Help
help:
	@echo "AIRA - AI-powered NixOS System"
	@echo ""
	@echo "Available targets:"
	@echo "  vm            - Build QEMU VM image"
	@echo "  iso           - Build ISO installer image"
	@echo "  run           - Run QEMU VM (with graphics)"
	@echo "  run-headless  - Run QEMU VM (headless mode)"
	@echo "  test          - Run integration tests"
	@echo "  clean         - Remove build artifacts"
	@echo "  rebuild       - Rebuild NixOS config (inside VM)"
	@echo "  update        - Update flake inputs"
	@echo "  check         - Check flake validity"
	@echo "  fmt           - Format Nix files"
	@echo "  dev           - Enter development shell"
	@echo "  help          - Show this help message"
	@echo ""
	@echo "Quick start:"
	@echo "  1. make vm      # Build the VM"
	@echo "  2. make run     # Start the VM"
	@echo "  3. Access Open WebUI at http://localhost:8080"
	@echo ""
