{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    ../configuration.nix
  ];

  # Override boot configuration for ISO
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.grub.device = lib.mkForce "nodev";

  # ISO doesn't need persistent root FS
  fileSystems."/" = lib.mkForce {
    device = "tmpfs";
    fsType = "tmpfs";
  };

  # ISO specific configuration
  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
    
    # Volume label
    volumeID = "AIRA-${config.system.nixos.label}";
    
    # ISO contents
    contents = [
      {
        source = pkgs.writeText "README.txt" ''
          AIRA - AI-powered NixOS System
          
          This ISO contains a minimal NixOS installation with:
          - Ollama (Local LLM engine)
          - Agent Gateway (MCP Router)
          - Open WebUI (Web interface)
          - aichat (TUI client)
          - MCP Servers (filesystem, nix, systemd, shell)
          
          Installation:
          1. Boot from this ISO
          2. Follow the NixOS installation guide
          3. Copy /etc/nixos/configuration.nix from this system
          4. Run: nixos-install
          
          For more information, visit:
          https://github.com/akagi-dev/aira
        '';
        target = "/README.txt";
      }
    ];
  };

  # Include installation tools
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    parted
    gptfdisk
  ];

  # Enable SSH for remote installation
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Set root password for live system
  users.users.root.password = "aira";
}
