{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    # Core system packages that replace Homebrew functionality on Linux
    environment.systemPackages = with pkgs; [
      # Productivity & Utilities (Linux equivalents of macOS apps)
      _1password-gui
      bleachbit # Replaces AppCleaner
      caffeine-ng # Replaces KeepingYouAwake
      p7zip # Replaces Keka
      unrar # Replaces The Unarchiver

      # Browsers (same as macOS)
      brave
      chromium
      firefox
      microsoft-edge

      # Communication
      slack
      zoom-us

      # Office & Documents
      libreoffice # Alternative to Microsoft Office
      notion-app-enhanced

      # Media & Graphics
      gimp
      inkscape

      # System & Security Tools (Linux equivalents)
      clamav # Antivirus
      rkhunter # Rootkit detection
      lynis # Security auditing

      # Development Tools
      git
      vim
      htop
      curl
      wget

      # System monitoring (replaces Stats on macOS)
      htop
      iotop
      nethogs

      # Window management (replaces Hammerspoon functionality)
      wmctrl
      xdotool

      # Archive tools
      file-roller

      # System utilities
      usbutils
      pciutils
      lshw
    ] ++ (
      # Architecture-specific packages
      if (pkgs.system == "x86_64-linux") then [
        # x86_64 specific packages
      ] else if (pkgs.system == "aarch64-linux") then [
        # ARM64 specific packages
      ] else [ ]
    );

    # Enable Flatpak for additional app support
    services.flatpak.enable = true;

    # Font configuration
    fonts.packages = with pkgs; [
      fira-code
      jost
      powerline-fonts
      # Additional Linux fonts
      liberation_ttf
      dejavu_fonts
      noto-fonts
      noto-fonts-emoji
    ];

    # Services that might be needed
    services.openssh.enable = mkDefault true;
    services.avahi.enable = mkDefault true; # Network discovery

    # Hardware support
    hardware.bluetooth.enable = mkDefault true;
    hardware.pulseaudio.enable = mkDefault false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = mkDefault true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
