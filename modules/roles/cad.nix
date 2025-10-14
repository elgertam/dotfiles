{ config, lib, ... }:

with lib;

{
  config = mkIf (builtins.elem "cad" config.machine.roles) {
    assertions = [
      {
        assertion = config.machine.hardware.gpu != "none";
        message = "CAD role requires dedicated GPU";
      }
      {
        assertion = config.machine.hardware.storage != "limited";
        message = "CAD role requires standard or large storage";
      }
    ];

    homebrew.casks = [
      # 3D Printing & CAD
      "autodesk-fusion"
      "bambu-studio"
      "creality-print"
      "creality-slicer"
      "freecad"
      "openscad"
      "prusaslicer"
      "ultimaker-cura"

      # Mathematical & Design Tools
      "geogebra"
      "macsvg"

      # Additional design tools already in base homebrew
      # "inkscape" "gimp" are in base homebrew.nix

      # Media editing (only on modern macOS)
    ] ++ optionals (!builtins.elem "legacy-macos" config.machine.taints) [
      "diffusionbee" # Requires newer macOS or Apple Silicon
    ] ++ optionals (config.machine.hardware.gpu == "apple") [
      # Apple Silicon optimized CAD tools
    ] ++ optionals (!builtins.elem "no-fusion360" config.machine.taints) [
      # Future: Add Fusion 360 or other professional CAD when available
    ] ++ optionals (config.machine.profile == "full") [
      # Professional media tools for full installations
      "powerphotos"
    ];

    # CAD-specific system optimizations
    system.defaults.NSGlobalDomain = {
      "com.apple.mouse.tapBehavior" = 1; # Better for precision work
    };

    # More aggressive performance settings for CAD work
    nix.settings.cores = mkDefault 0; # Use all cores for builds
    nix.settings.max-jobs = mkDefault "auto";
  };
}
