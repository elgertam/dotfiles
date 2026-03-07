{ ... }:

{
  imports = [ ./shared.nix ];

  machine = {
    roles = [ "developer" "cad" ];
    taints = [
      "no-containers" # Older Mac may struggle with containers
      "legacy-macos" # Can't upgrade to newer macOS versions
    ];
    profile = "standard"; # Not full due to older hardware
    hardware = {
      arch = "x86_64";
      gpu = "amd"; # Mac Pro has AMD FirePro D700
      storage = "standard"; # Conservative estimate
    };
  };

  networking.computerName = "ROME";

  # Host-specific user configuration
  system.primaryUser = "andrew.elgert";
  users.users."andrew.elgert".home = "/Users/andrew.elgert";

  # Host-specific configuration can go here
  # For example, x86-specific homebrew casks or system settings
}
