{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ../configuration.nix
  ];

  # QEMU VM configuration
  virtualisation = {
    memorySize = 4096; # 4GB RAM
    cores = 4;         # 4 CPU cores
    diskSize = 20480;  # 20GB disk
    
    # Graphics and display
    graphics = true;
    
    # Port forwarding
    forwardPorts = [
      { from = "host"; host.port = 2222; guest.port = 22; }    # SSH
      { from = "host"; host.port = 8081; guest.port = 8080; }  # Open WebUI
      { from = "host"; host.port = 11434; guest.port = 11434; } # Ollama
    ];
    
    # QEMU options
    qemu = {
      options = [
        "-enable-kvm"  # Enable KVM acceleration if available
        "-cpu host"    # Use host CPU features
      ];
    };
    
    # Shared directories (optional)
    sharedDirectories = {
      aira-shared = {
        source = "/tmp/aira-shared";
        target = "/mnt/shared";
      };
    };
  };

  # Enable QEMU guest agent
  services.qemuGuest.enable = true;

  # Additional packages useful in VM
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    tmux
    curl
    wget
  ];
}
