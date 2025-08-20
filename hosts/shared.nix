{ config, lib, pkgs, ... }:

{
  # Import all core modules
  imports = [
    ../modules/core/roles.nix
    ../modules/core/nix.nix
    ../modules/system/darwin-defaults.nix
    ../modules/system/homebrew.nix
    ../modules/roles/developer.nix
    ../modules/roles/cad.nix
    ../modules/roles/personal.nix
    ../modules/podman-darwin.nix
  ];

  # Shared configuration for all hosts
  environment.systemPackages = [ ];

  system.primaryUser = "ame";
  system.stateVersion = 6;

  # Users configuration will be handled by home-manager
  users.users.ame.home = "/Users/ame";
}