# Contributing to AIRA

Thank you for your interest in contributing to AIRA! This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- Linux system (x86_64)
- Nix with flakes enabled
- Git
- Basic understanding of NixOS
- 8GB+ RAM recommended for development

### Development Setup

1. **Clone the repository**:
```bash
git clone https://github.com/akagi-dev/aira.git
cd aira
```

2. **Enter development shell** (with direnv):
```bash
direnv allow
```

Or manually:
```bash
nix develop
```

3. **Make your changes** to the relevant files

4. **Test your changes**:
```bash
make vm      # Build VM
make run     # Test the VM
make test    # Run integration tests
```

## Project Structure

```
aira/
├── flake.nix              # Nix flake configuration (inputs/outputs)
├── flake.lock             # Locked dependency versions
├── configuration.nix      # Base NixOS system configuration
├── modules/               # NixOS service modules
│   ├── ollama.nix         # Ollama LLM service
│   ├── agent-gateway.nix  # Agent Gateway MCP router
│   ├── open-webui.nix     # Web UI service
│   ├── aichat.nix         # TUI client
│   └── mcp-servers/       # MCP protocol servers
├── images/                # Image builders
│   ├── qemu.nix          # QEMU VM configuration
│   └── iso.nix           # ISO installer configuration
├── scripts/               # Build and test scripts
└── tests/                 # Integration tests
```

## Development Workflow

### 1. Creating a New Feature

1. Create a feature branch:
```bash
git checkout -b feature/my-feature
```

2. Make your changes following the coding standards

3. Test locally:
```bash
make clean
make vm
make run
```

4. Run tests:
```bash
make test
```

5. Commit with a descriptive message:
```bash
git commit -m "feat: add new MCP server for Docker"
```

6. Push and create a pull request

### 2. Modifying Existing Services

When modifying services in `modules/`:

1. Update the `.nix` module file
2. Test the configuration:
```bash
nix eval .#nixosConfigurations.aira.config.system.stateVersion --impure
```
3. Build and test in VM
4. Update relevant documentation

### 3. Adding New MCP Servers

To add a new MCP server:

1. Create `modules/mcp-servers/yourserver.nix`:
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.mcp.yourserver;
in {
  options.services.aira.mcp.yourserver = {
    enable = mkEnableOption "Your MCP Server";
    # Add your options here
  };

  config = mkIf cfg.enable {
    # Your service configuration
  };
}
```

2. Import it in `configuration.nix`:
```nix
imports = [
  # ...
  ./modules/mcp-servers/yourserver.nix
];
```

3. Enable it in configuration:
```nix
services.aira.mcp.yourserver.enable = true;
```

4. Add integration test in `tests/integration/test_yourserver.sh`

### 4. Updating Dependencies

To update flake inputs:

```bash
nix flake update
```

To update specific input:
```bash
nix flake lock --update-input nixpkgs
```

## Coding Standards

### Nix Code Style

- Use 2 spaces for indentation
- Follow [Nixpkgs coding conventions](https://nixos.org/manual/nixpkgs/stable/#chap-conventions)
- Use `lib.mkIf`, `lib.mkEnableOption`, etc. from nixpkgs
- Add descriptions to all options
- Include security hardening in systemd services

Example:
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.aira.myservice;
in {
  options.services.aira.myservice = {
    enable = mkEnableOption "My Service";
    
    port = mkOption {
      type = types.port;
      default = 8000;
      description = "Port for the service";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.myservice = {
      description = "My Service";
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        ExecStart = "${pkgs.myservice}/bin/myservice";
        DynamicUser = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
      };
    };
  };
}
```

### Shell Script Style

- Use `#!/usr/bin/env bash` shebang
- Use `set -euo pipefail` for safety
- Add comments for complex logic
- Make scripts executable: `chmod +x script.sh`

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Test additions/changes
- `chore:` - Build/tooling changes

Examples:
```
feat: add Docker MCP server
fix: correct Ollama port configuration
docs: update README with ARM support info
refactor: simplify Agent Gateway module
test: add tests for filesystem MCP server
chore: update nixpkgs to 24.05
```

## Testing

### Running Tests

```bash
# All tests
make test

# Individual test
bash tests/integration/test_ollama.sh
```

### Writing Tests

Integration tests should:
- Check if services are running
- Verify API endpoints respond
- Test core functionality
- Be idempotent (can run multiple times)

Example test structure:
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "Testing My Service..."

# Check service is running
if systemctl is-active --quiet myservice; then
    echo "✅ Service is running"
else
    echo "❌ Service is not running"
    exit 1
fi

# Test API
if curl -s http://localhost:8000/health > /dev/null; then
    echo "✅ API is responding"
else
    echo "❌ API is not responding"
    exit 1
fi

echo "✅ Tests completed"
```

## Documentation

### README Updates

When adding features, update:
- Feature list in README.md
- Architecture diagram if needed
- Configuration examples
- Usage examples

### Inline Documentation

- Add comments to complex Nix expressions
- Document module options with `description`
- Include example configurations

## CI/CD

All changes are automatically tested via GitHub Actions:

1. **Build workflow** - Builds QEMU and ISO images
2. **Test workflow** - Runs integration tests
3. **Release workflow** - Creates releases on tags

Ensure your changes pass CI before requesting review.

### GitHub Secrets

The CI/CD pipeline requires the following secrets to be configured in the repository settings:

- **CACHIX_AUTH_TOKEN**: Authentication token for Cachix binary cache
  - Used to cache Nix build artifacts and speed up CI builds
  - Obtain from [cachix.org](https://cachix.org) after creating an account
  - Add to repository secrets at: Settings → Secrets and variables → Actions → New repository secret
  - The cache name is `aira` (configured in `.github/workflows/build.yml`)

## Security

### Security Considerations

- Use minimal systemd service privileges
- Enable security hardening options
- Whitelist allowed directories for MCP servers
- Sandbox command execution
- Never commit secrets or passwords

### Reporting Security Issues

Please report security vulnerabilities privately to the maintainers.

## Getting Help

- **Issues**: Open a GitHub issue for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check README.md and inline code comments

## Code Review

Pull requests require:
- Passing CI checks
- Clear description of changes
- Updated documentation
- Test coverage for new features

Maintainers will review and provide feedback. Be patient and responsive to comments.

## License

By contributing to AIRA, you agree that your contributions will be licensed under the project's license.

---

Thank you for contributing to AIRA! 🤖
