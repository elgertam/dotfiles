{ config, lib, ... }:

with lib;

{
  config = mkIf (builtins.elem "legacy-macos" config.machine.taints) {
    # Disable features that require newer macOS versions
    system.defaults.NSGlobalDomain = {
      # More conservative settings for older macOS
      ApplePressAndHoldEnabled = mkForce true;
    };

    # Override to exclude packages that don't work on legacy macOS
    # This will filter the final cask list from all modules
    homebrew.casks = mkForce (
      builtins.filter
        (pkg: !(builtins.elem pkg [
          "microsoft-office" # Requires newer macOS
          "chatgpt" # Requires newer macOS
          # "claude"            # May require newer macOS
          "diffusionbee" # Requires Apple Silicon or newer macOS
          # "utm"               # May have issues on older Intel Macs
          # "windows-app"       # Microsoft's newer virtualization
          "macgpt" # Likely requires newer macOS
          "protonvpn" # May require newer macOS features
        ]))
        config.homebrew.casks
    );

    # Use older nixpkgs for better compatibility
    nixpkgs.config = {
      allowUnfree = true;
      # Add any legacy compatibility options here
    };

    # Disable services that may not work on older macOS
    services = mkIf (builtins.elem "legacy-macos" config.machine.taints) {
      # Disable modern container services
    };

    assertions = [
      {
        assertion = !(builtins.elem "legacy-macos" config.machine.taints) ||
          (builtins.elem "no-containers" config.machine.taints);
        message = "Legacy macOS systems should have no-containers taint";
      }
    ];
  };
}
