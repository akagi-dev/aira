{
  description = "AIRA - AI-powered NixOS system with Ollama and Agent Gateway";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (nixpkgs) lib;
      
      # System configuration
      nixosSystem = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          {
            system.stateVersion = "24.11";
            nixpkgs.hostPlatform = "x86_64-linux";
          }
        ];
      };
      
    in {
      # NixOS configuration
      nixosConfigurations.aira = nixosSystem;
      
      # Packages for x86_64-linux
      packages.x86_64-linux = 
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in {
          # QEMU VM image
          qemu-vm = (nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./images/qemu.nix
              {
                system.stateVersion = "24.11";
                nixpkgs.hostPlatform = "x86_64-linux";
              }
            ];
          }).config.system.build.vm;
          
          # ISO image
          iso = (nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              ./images/iso.nix
            ];
          }).config.system.build.isoImage;
          
          default = self.packages.x86_64-linux.qemu-vm;
        };
      
      # Development shell
      devShells.x86_64-linux.default =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };
        in pkgs.mkShell {
          name = "aira-dev";
          buildInputs = with pkgs; [
            nixos-rebuild
            qemu
            qemu_kvm
            git
            bash
            jq
            curl
          ];
          
          shellHook = ''
            echo "🤖 AIRA Development Environment"
            echo "Available commands:"
            echo "  make vm      - Build QEMU VM image"
            echo "  make iso     - Build ISO image"
            echo "  make run     - Run QEMU VM"
            echo "  make test    - Run integration tests"
            echo ""
          '';
        };
    };
}
