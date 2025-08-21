{ ... }:

{
  imports = [ ./shared.nix ];

  machine = {
    roles = [ "personal" ];
    taints = [ "no-services" "no-containers" ]; # Lightweight setup
    profile = "minimal";
    hardware = {
      arch = "aarch64";
      gpu = "apple";
      storage = "standard";
    };
  };

  networking.computerName = "riker";

  # Host-specific user configuration
  system.primaryUser = "ame";
  users.users.ame.home = "/Users/ame";

  # Minimal personal machine configuration
  # Focus on essential apps and lightweight setup
}
