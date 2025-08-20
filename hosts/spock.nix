{ ... }:

{
  imports = [ ./shared.nix ];

  machine = {
    roles = [ "personal" "developer" "cad" ];
    taints = [ ]; # No restrictions
    profile = "full";
    hardware = {
      arch = "aarch64";
      gpu = "apple";
      storage = "large";
    };
  };

  networking.computerName = "spock";

  # Host-specific configuration for development + CAD workstation
  # ARM-specific optimizations could go here
}
