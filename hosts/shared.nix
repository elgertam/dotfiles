{ ... }:

{
  # Import all core modules
  imports = [
    ../modules/core/roles.nix
    ../modules/core/nix.nix
    ../modules/system/darwin-defaults.nix
    ../modules/system/homebrew.nix
    ../modules/system/legacy-macos.nix
    ../modules/roles/developer.nix
    ../modules/roles/cad.nix
    ../modules/roles/personal.nix
    ../modules/podman-darwin.nix
  ];

  # Shared configuration for all hosts
  environment.systemPackages = [ ];
  
  # Make nix tools available to GUI applications
  environment.systemPath = [ 
    "/nix/var/nix/profiles/default/bin"
    "/run/current-system/sw/bin"
  ];
  
  # Create symlinks for tools that GUI apps expect in standard locations
  system.activationScripts.applications.text = ''
    # Create symlink for podman so GUI apps can find it (if it exists)
    podman_path="$(readlink -f /etc/profiles/per-user/*/bin/podman 2>/dev/null | head -1)"
    if [ -n "$podman_path" ] && [ -f "$podman_path" ]; then
      mkdir -p /usr/local/bin
      ln -sf "$podman_path" /usr/local/bin/podman
    fi
  '';

  system.stateVersion = 6;
}
