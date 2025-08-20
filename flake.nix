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

    nixpkgs = inputs.nixpkgs-unstable;

    nixpkgsConfig = {
      config.allowUnfree = true;
      overlays = builtins.attrValues self.overlays;
    };

    mkDarwinSystem = { hostname, system }:
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
      };

      spock = mkDarwinSystem {
        hostname = "spock";
        system = "aarch64-darwin";
      };

      riker = mkDarwinSystem {
        hostname = "riker";
        system = "aarch64-darwin";
      };
    };

    darwinPackages = self.darwinConfigurations.laforge.pkgs;

    darwinModules = {
      podman-darwin = import ./modules/podman-darwin.nix;
    };

    overlays = { };
  };
}