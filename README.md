# AIRA - AI-powered NixOS System

```
        *
       /|
      / |
     /  |
    *   *       _    ___ ____      _    
   /|  /|      / \  |_ _|  _ \    / \   
  / | / |     / _ \  | || |_) |  / _ \  
 /  |/  |    / ___ \ | ||  _ <  / ___ \ 
*---*---*   /_/   \_\___|_| \_\/_/   \_\
```

**Autonomous Intelligent Robot Agent** - A complete AI-powered system built on NixOS with local LLM capabilities, MCP protocol support, and modern tooling.

[![Build](https://github.com/akagi-dev/aira/actions/workflows/build.yml/badge.svg)](https://github.com/akagi-dev/aira/actions/workflows/build.yml)
[![License](https://img.shields.io/github/license/akagi-dev/aira)](LICENSE)

## 🚀 Overview

AIRA is a fully reproducible, declarative NixOS system that provides:

- 🤖 **Ollama** - Local LLM engine with llama3.2:3b model
- 🌐 **Agent Gateway** - MCP Router for tool orchestration  
- 💻 **Open WebUI** - Modern web interface for LLM interaction
- 🖥️ **aichat** - Terminal UI client for chat
- 🔧 **MCP Servers** - Filesystem, Nix, systemd, and shell tool servers
- 📦 **QEMU/ISO Images** - Ready-to-use VM and installation images

## ✨ Features

### Core Components

| Component | Description | Port/Access |
|-----------|-------------|-------------|
| Ollama | Local LLM inference engine | `localhost:11434` |
| Agent Gateway | MCP protocol router | `localhost:8081` |
| Open WebUI | Web-based chat interface | `localhost:8080` |
| aichat | Terminal UI client | CLI tool |

### MCP Servers

- **Filesystem** - Safe file operations with directory whitelisting
- **Nix** - System configuration and package management
- **Systemd** - Service control and monitoring
- **Shell** - Sandboxed command execution

## 🎯 Quick Start

### Prerequisites

- Linux system (x86_64)
- [Nix](https://nixos.org/download.html) with flakes enabled
- 4GB+ RAM
- 20GB+ free disk space

### Installation

1. **Install Nix** (if not already installed):
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

2. **Clone the repository**:
```bash
git clone https://github.com/akagi-dev/aira.git
cd aira
```

3. **Build the QEMU VM**:
```bash
make vm
```

4. **Run the VM**:
```bash
make run
```

5. **Access the system**:
   - **Open WebUI**: http://localhost:8080
   - **SSH**: `ssh aira@localhost -p 2222` (password: `aira`)
   - **Ollama API**: http://localhost:11434

### Using the ISO

Build and burn the ISO for bare-metal installation:

```bash
make iso
# Result will be in result/iso/
```

## 📖 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         AIRA System                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐        ┌──────────────┐                   │
│  │  Open WebUI  │◄──────►│  aichat TUI  │                   │
│  └──────┬───────┘        └──────┬───────┘                   │
│         │                       │                            │
│         └───────────┬───────────┘                            │
│                     ▼                                        │
│            ┌─────────────────┐                               │
│            │ Agent Gateway   │                               │
│            │  (MCP Router)   │                               │
│            └────────┬────────┘                               │
│                     │                                        │
│         ┌───────────┴───────────┐                            │
│         ▼                       ▼                            │
│  ┌─────────────┐        ┌─────────────┐                     │
│  │   Ollama    │        │ MCP Servers │                     │
│  │   (LLM)     │        │  • filesystem│                     │
│  │             │        │  • nix       │                     │
│  └─────────────┘        │  • systemd   │                     │
│                         │  • shell     │                     │
│                         └─────────────┘                      │
│                                                               │
│                      NixOS 25.05                             │
└─────────────────────────────────────────────────────────────┘
```

## 🛠️ Development

### Available Make Targets

```bash
make vm            # Build QEMU VM image
make iso           # Build ISO installer
make run           # Run VM with graphics
make run-headless  # Run VM in headless mode
make test          # Run integration tests
make clean         # Clean build artifacts
make update        # Update flake inputs
make check         # Check flake validity
make dev           # Enter development shell
```

### Project Structure

```
aira/
├── flake.nix              # Nix flake configuration
├── configuration.nix      # Base NixOS configuration
├── modules/               # Service modules
│   ├── ollama.nix
│   ├── agent-gateway.nix
│   ├── open-webui.nix
│   ├── aichat.nix
│   └── mcp-servers/       # MCP protocol servers
│       ├── filesystem.nix
│       ├── nix.nix
│       ├── systemd.nix
│       └── shell.nix
├── images/                # Image builders
│   ├── qemu.nix          # VM image
│   └── iso.nix           # ISO image
├── scripts/               # Helper scripts
│   └── test-system.sh
└── tests/                 # Integration tests
    └── integration/
```

### Modifying the Configuration

The system is fully declarative. To modify:

1. Edit `configuration.nix` or module files
2. Rebuild inside the VM:
```bash
sudo nixos-rebuild switch
```

Or rebuild the entire VM:
```bash
make clean && make vm && make run
```

## 🧪 Testing

Run integration tests:

```bash
make test
```

Individual test scripts are in `tests/integration/`:
- `test_ollama.sh` - Ollama service tests
- `test_agent_gateway.sh` - Agent Gateway tests
- `test_mcp_servers.sh` - MCP server tests

## 🔧 Configuration

### Changing the LLM Model

Edit `configuration.nix`:

```nix
services.aira.ollama.model = "llama3.1:8b";  # or any other model
```

### Adjusting VM Resources

Edit `images/qemu.nix`:

```nix
virtualisation = {
  memorySize = 8192;  # 8GB RAM
  cores = 8;          # 8 CPU cores
  diskSize = 40960;   # 40GB disk
};
```

### MCP Server Permissions

Control filesystem access in `modules/mcp-servers/filesystem.nix`:

```nix
services.aira.mcp.filesystem.allowedDirectories = [
  "/home"
  "/tmp"
  "/your/custom/path"
];
```

## 📚 Usage Examples

### Using Open WebUI

1. Access http://localhost:8080
2. Create an account (local only)
3. Start chatting with the LLM
4. Use MCP tools for system operations

### Using aichat CLI

SSH into the VM and run:

```bash
aichat
> Hello! Can you help me list files?
```

### Using Ollama API

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.2:3b",
  "prompt": "Explain NixOS in one sentence",
  "stream": false
}'
```

## 🔒 Security

- Default password is `aira` - **CHANGE IT IN PRODUCTION**
- MCP servers use whitelists and sandboxing
- Services run with minimal privileges
- Firewall enabled with only necessary ports open

For production use:

1. Change user password
2. Disable password authentication for SSH
3. Configure proper firewall rules
4. Review MCP server permissions
5. Use secrets management for sensitive data

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📋 System Requirements

### Minimum
- CPU: 2 cores, 1.4 GHz
- RAM: 4GB
- Disk: 20GB
- KVM support (optional but recommended)

### Recommended
- CPU: 4+ cores, 2.0+ GHz
- RAM: 8GB+
- Disk: 40GB+
- KVM acceleration enabled

## 📝 License

This project is licensed under the terms specified in the [LICENSE](LICENSE) file.

## 🔗 Links

- [NixOS](https://nixos.org/)
- [Ollama](https://ollama.ai/)
- [Agent Gateway](https://agentgateway.dev/)
- [MCP Protocol](https://modelcontextprotocol.io/)
- [Open WebUI](https://github.com/open-webui/open-webui)

## 💬 FAQ

**Q: Why NixOS?**  
A: NixOS provides reproducible, declarative system configuration. Every component is version-controlled and can be rolled back.

**Q: Can I use different LLM models?**  
A: Yes! Change the `services.aira.ollama.model` option to any model supported by Ollama.

**Q: Does this work on ARM/Apple Silicon?**  
A: Currently only x86_64 is supported. ARM support is planned.

**Q: How much RAM do I really need?**  
A: 4GB minimum for llama3.2:3b, but 8GB+ recommended for larger models and better performance.

**Q: Can I deploy this to a server?**  
A: Yes! Build the ISO and install on bare metal, or use the configuration directly with NixOS.

## 🎯 Roadmap

- [ ] ARM/aarch64 support
- [ ] Additional MCP servers (git, docker, etc.)
- [ ] Web-based configuration UI
- [ ] Multi-model support
- [ ] Clustering and distributed inference
- [ ] Integration with external services

---

**Built with ❤️ using NixOS**
