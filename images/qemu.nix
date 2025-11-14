{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ../configuration.nix
  ];

  # QEMU VM specific configuration
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096; # 4GB RAM
      cores = 4;         # 4 CPU cores
      diskSize = 20480;  # 20GB disk
      
      # Graphics and display
      graphics = true;
      
      # Port forwarding
      forwardPorts = [
        { from = "host"; host.port = 2222; guest.port = 22; }    # SSH
        { from = "host"; host.port = 8080; guest.port = 8080; }  # Open WebUI
        { from = "host"; host.port = 11434; guest.port = 11434; } # Ollama
      ];
      
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
  };

  # QEMU VM build configuration
  virtualisation = {
    memorySize = 4096;
    cores = 4;
    diskSize = 20480;
    graphics = true;
    
    qemu = {
      options = [
        "-enable-kvm"  # Enable KVM acceleration if available
        "-cpu host"    # Use host CPU features
      ];
      
      networkingOptions = [
        "-net nic,netdev=user.0,model=virtio"
        "-netdev user,id=user.0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:8080,hostfwd=tcp::11434-:11434"
      ];
    };
  };

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
