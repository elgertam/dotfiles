{ config, lib, pkgs, ... }:

{
  imports = [ ./shared.nix ];

  machine = {
    roles = [ "personal" ];
    taints = [ "no-services" "no-containers" ];  # Lightweight setup
    profile = "minimal";
    hardware = {
      arch = "aarch64";
      gpu = "apple";
      storage = "standard";
    };
  };

  networking.computerName = "riker";
  
  # Minimal personal machine configuration
  # Focus on essential apps and lightweight setup
}