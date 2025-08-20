{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    machine = {
      roles = mkOption {
        type = types.listOf (types.enum [ 
          "developer" "cad" "media" "server" "gaming" "work" "personal" 
        ]);
        default = [];
        description = "Roles assigned to this machine";
        example = [ "developer" "cad" ];
      };

      taints = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Taints/restrictions for this machine";
        example = [ "no-gaming" "corporate" "limited-storage" "no-services" "no-containers" ];
      };

      profile = mkOption {
        type = types.enum [ "minimal" "standard" "full" ];
        default = "standard";
        description = "Installation profile level";
      };

      hardware = {
        arch = mkOption {
          type = types.enum [ "x86_64" "aarch64" ];
          description = "CPU architecture";
        };
        
        gpu = mkOption {
          type = types.enum [ "intel" "amd" "nvidia" "apple" "none" ];
          default = "none";
          description = "GPU type for graphics-intensive roles";
        };

        storage = mkOption {
          type = types.enum [ "limited" "standard" "large" ];
          default = "standard";
          description = "Available storage capacity";
        };
      };
    };
  };

  config = {
    # Add role info to system for runtime queries
    environment.etc."machine-roles".text = concatStringsSep "\n" config.machine.roles;
    environment.etc."machine-taints".text = concatStringsSep "\n" config.machine.taints;
    environment.etc."machine-profile".text = config.machine.profile;
  };
}