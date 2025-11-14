# Changelog

All notable changes to the AIRA project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Consolidated `build-qemu.sh` and `run-qemu.sh` into Makefile targets for simpler project structure

### Complete MVP Refactoring

#### Added
- Modern NixOS 24.11 flake-based configuration
- Ollama LLM service with llama3.2:3b model
- Agent Gateway for MCP protocol routing
- Open WebUI web interface on port 8080
- aichat TUI client for terminal interaction
- MCP Filesystem Server with directory whitelisting
- MCP Nix Server for system configuration operations
- MCP Systemd Server for service management
- MCP Shell Server with command sandboxing
- QEMU VM image builder with 4GB RAM, 4 cores, 20GB disk
- ISO installer image with pre-configured system
- Integration tests for all services
- GitHub Actions CI/CD pipeline (build, test, release)
- Comprehensive README.md with architecture documentation
- CONTRIBUTING.md with development guidelines
- Makefile with convenient commands

#### Changed
- Migrated from old airapkgs submodule to standalone flakes
- Updated build system from Travis CI to GitHub Actions
- Replaced old OVA images with QEMU and ISO images
- Rewrote documentation with modern architecture

#### Removed
- `.gitmodules` and `airapkgs` submodule
- `.travis.yml` Travis CI configuration
- Old `Makefile` for OVA builds
- Old documentation in `docs/` directory
- Legacy Robonomics-specific components

#### Security
- Implemented systemd service hardening (NoNewPrivileges, PrivateTmp, etc.)
- Added MCP server directory whitelisting
- Implemented command execution sandboxing
- Configured minimal service privileges
- Enabled firewall with only necessary ports

## [0.x.x] - Historical

Previous versions used different architecture with Robonomics integration.
See git history for details.

---

## Future Plans

### v2.0.0 (Planned)
- ARM/aarch64 architecture support
- Additional MCP servers (git, docker, kubernetes)
- Web-based configuration interface
- Multi-model support (simultaneous multiple LLMs)
- Distributed inference clustering
- Integration with external AI services

### v2.1.0 (Planned)
- GPU acceleration support (CUDA, ROCm)
- Model fine-tuning capabilities
- Advanced prompt engineering tools
- RAG (Retrieval-Augmented Generation) support
- Vector database integration

### v2.2.0 (Planned)
- Mobile application support
- Voice interface integration
- Multi-language support
- Advanced monitoring and observability
- Performance optimization

---

[Unreleased]: https://github.com/akagi-dev/aira/compare/v0.0.0...HEAD
