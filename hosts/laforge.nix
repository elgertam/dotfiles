{ ... }:

{
  imports = [ ./shared.nix ];

  machine = {
    roles = [ "developer" ];
    taints = [ ]; # No restrictions
    profile = "full";
    hardware = {
      arch = "x86_64";
      gpu = "intel";
      storage = "large";
    };
  };

  networking.computerName = "laforge";

  # Host-specific configuration can go here
  # For example, x86-specific homebrew casks or system settings
}
