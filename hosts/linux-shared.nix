{ ... }:

{
  # Import Linux-specific core modules
  imports = [
    ../modules/core/roles.nix
    ../modules/core/nix.nix
    ../modules/system/gnome-defaults.nix
    ../modules/system/linux-packages.nix
    ../modules/roles/developer.nix
    ../modules/roles/cad.nix
    ../modules/roles/personal.nix
    ../modules/podman-linux.nix
  ];

  # Shared configuration for all Linux hosts
  environment.systemPackages = [ ];

  # Enable NetworkManager for desktop systems
  networking.networkmanager.enable = true;

  # System configuration
  system.stateVersion = "24.11";

  # User configuration
  users.users.ame = {
    isNormalUser = true;
    home = "/home/ame";
    extraGroups = [ "wheel" "networkmanager" "docker" "podman" ];
    shell = "/run/current-system/sw/bin/zsh";
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Timezone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable CUPS for printing
  services.printing.enable = true;

  # Enable automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
