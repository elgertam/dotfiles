{ config, lib, ... }:

with lib;

{
  config = mkIf (builtins.elem "legacy-macos" config.machine.taints) {
    # Disable features that require newer macOS versions
    system.defaults.NSGlobalDomain = {
      # More conservative settings for older macOS
      ApplePressAndHoldEnabled = mkForce true;
    };

    # Legacy-incompatible packages are excluded at the source:
    # - personal.nix excludes claude, macgpt, protonvpn, utm, windows-app
    # - cad.nix excludes diffusionbee
    # - homebrew.nix excludes microsoft-office (below)
    # - chatgpt is only added on aarch64-darwin

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
