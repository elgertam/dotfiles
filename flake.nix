{
  description = "AME's darwin system";

  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, darwin, home-manager, ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs-unstable.lib) nixosSystem;

      nixpkgs = inputs.nixpkgs-unstable;

      nixpkgsConfig = {
        config.allowUnfree = true;
        overlays = builtins.attrValues self.overlays;
      };

      mkDarwinSystem = { hostname, system, username }:
        darwinSystem {
          inherit system;
          modules = [
            # Host-specific configuration (includes shared.nix)
            ./hosts/${hostname}.nix

            # Set nixPath for compatibility
            {
              nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            }

            # Home manager integration
            home-manager.darwinModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              home-manager.useUserPackages = true;
              home-manager.users."${username}" = import ./users/${username};
            }
          ];
        };

      mkNixosSystem = { hostname, system }:
        nixosSystem {
          inherit system;
          modules = [
            # Host-specific configuration (includes shared.nix)
            ./hosts/${hostname}.nix

            # Set nixPath for compatibility
            {
              nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            }

            # Home manager integration
            home-manager.nixosModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              home-manager.useUserPackages = true;
              home-manager.users.ame = import ./users/ame;
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        laforge = mkDarwinSystem {
          hostname = "laforge";
          system = "x86_64-darwin";
          username = "ame";
        };
        
        "ROME" = mkDarwinSystem {
          hostname = "ROME";
          system = "x86_64-darwin";
          username = "andrew.elgert";
        };

        spock = mkDarwinSystem {
          hostname = "spock";
          system = "aarch64-darwin";
          username = "ame";
        };

        riker = mkDarwinSystem {
          hostname = "riker";
          system = "aarch64-darwin";
          username = "ame";
        };
      };

      nixosConfigurations = {
        # Example Linux desktop configuration
        linux-desktop = mkNixosSystem {
          hostname = "linux-desktop";
          system = "x86_64-linux";
        };
      };

      darwinPackages = self.darwinConfigurations.laforge.pkgs;

      darwinModules = {
        podman-darwin = import ./modules/podman-darwin.nix;
      };

      nixosModules = {
        podman-linux = import ./modules/podman-linux.nix;
        gnome-defaults = import ./modules/system/gnome-defaults.nix;
        linux-packages = import ./modules/system/linux-packages.nix;
      };

      overlays = { };
    };
}
