{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/ollama.nix
    ./modules/agent-gateway.nix
    ./modules/open-webui.nix
    ./modules/aichat.nix
    ./modules/mcp-servers/filesystem.nix
    ./modules/mcp-servers/nix.nix
    ./modules/mcp-servers/systemd.nix
    ./modules/mcp-servers/shell.nix
  ];

  # Boot configuration
  boot.loader.grub.enable = lib.mkDefault true;
  boot.loader.grub.device = lib.mkDefault "/dev/vda";

  # Filesystem configuration (required by NixOS)
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
    autoResize = true;
  };
  
  # Networking
  networking.hostName = "aira";
  networking.useDHCP = false;
  networking.interfaces.ens3.useDHCP = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 8080 11434 ];

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Users
  users.users.aira = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    password = "aira"; # Change this in production!
    description = "AIRA User";
  };

  # Allow sudo without password for wheel group (for development)
  security.sudo.wheelNeedsPassword = false;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    tmux
    jq
    tree
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Time zone and locale
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Minimal system without GUI
  services.xserver.enable = false;
  
  # Enable services
  services.aira = {
    ollama.enable = true;
    agentGateway.enable = true;
    openWebUI.enable = true;
    aichat.enable = true;
    mcp = {
      filesystem.enable = true;
      nix.enable = true;
      systemd.enable = true;
      shell.enable = true;
    };
  };

  system.stateVersion = "24.05";
}
