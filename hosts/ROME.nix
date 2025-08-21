{ ... }:

{
  imports = [ ./shared.nix ];

  machine = {
    roles = [ "personal" "developer" ];
    taints = [ ]; # No restrictions
    profile = "full";
    hardware = {
      arch = "x86_64";
      gpu = "intel";
      storage = "large";
    };
  };

  networking.computerName = "ROME";

  # Host-specific configuration can go here
  # For example, x86-specific homebrew casks or system settings
}
