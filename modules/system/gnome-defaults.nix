{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf config.services.xserver.desktopManager.gnome.enable {
    # GNOME configuration equivalent to macOS darwin-defaults

    # Enable GNOME desktop
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    # GNOME Shell extensions for improved functionality
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
      gnomeExtensions.dash-to-dock # Similar to macOS dock
      gnomeExtensions.hot-edge # Hot corners like macOS
      gnomeExtensions.caffeine # Prevent sleep
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.system-monitor
    ];

    # Default GNOME settings (equivalent to darwin defaults)
    # These would typically be set via dconf/gsettings in user space
    # but can be configured system-wide via NixOS

    # Enable fractional scaling
    services.xserver.displayManager.gdm.wayland = true;

    # Configure default applications
    environment.sessionVariables = {
      # Default browser
      BROWSER = "firefox";
    };

    # Enable location services for automatic timezone/theme switching
    services.geoclue2.enable = true;

    # Power management similar to macOS
    services.tlp = {
      enable = true;
      settings = {
        # Laptop power management
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # Similar to macOS energy saver settings
        STOP_CHARGE_THRESH_BAT0 = 80;
        START_CHARGE_THRESH_BAT0 = 75;
      };
    };

    # Networking equivalent to macOS
    networking.networkmanager.enable = true;

    # Sound configuration
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # File manager settings (equivalent to Finder settings)
    # Note: These are typically user-specific and would go in home-manager
    # but listed here for reference

    # Security settings equivalent to macOS
    security.sudo.wheelNeedsPassword = false; # Similar to TouchID for sudo

    # Firewall (equivalent to macOS built-in firewall)
    networking.firewall.enable = true;
  };
}
