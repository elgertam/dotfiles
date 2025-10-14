{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (builtins.elem "personal" config.machine.roles) {
    homebrew.casks = [
      # Personal productivity
      "anytype"
      "dropbox"
      "selfcontrol"

      # Media & Entertainment
      "minecraft"
      "pandora"
      "transmission"
      "vlc"

      # Personal utilities
      "anydesk"
      "basictex"
      "macs-fan-control"
      "signal"
      "splashtop-business"
      "tabula"
      "vuescan"
    ] ++ optionals (!builtins.elem "legacy-macos" config.machine.taints) [
      # Modern apps that require newer macOS
      "claude"
      "macgpt"
      "protonvpn"
      "utm"
      "windows-app"
    ] ++ optionals (config.machine.profile != "minimal") [
      # Additional personal apps for standard/full profiles
      "logi-options-plus"
    ];

    homebrew.masApps = {
      "1Password for Safari" = 1569813296;
      "Brother iPrint&Scan" = 1193539993;
      "DaisyDisk" = 411643860;
      "Flow" = 1423210932;
      "GarageBand" = 682658836;
      "iMovie" = 408981434;
      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Prime Video" = 545519333;
    };

    # Personal-focused system settings
    system.defaults.dock = {
      # More personal-friendly dock settings
      magnification = true;
    };

    # Lighter package set for personal use
    home-manager.users."${config.system.primaryUser}".home.packages = with pkgs;
      # Essential tools only
      [ coreutils man git vim curl wget ]
      ++ optionals (config.machine.profile == "standard" || config.machine.profile == "full") [
        # Standard personal tools
        tmux
        tree
        htop
        bat
        jq
      ]
      ++ optionals (config.machine.profile == "full") [
        # Full personal development environment
        python313
        nodejs
      ];
  };
}
