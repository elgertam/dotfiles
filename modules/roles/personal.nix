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
      "pandora"
      "transmission"

      # Personal utilities
      "anydesk"
      "basictex"
      "claude"
      # "macgpt"
      "macs-fan-control"
      # "protonvpn"
      "tabula"
      "utm"
      "windows-app"
    ] ++ optionals (config.machine.profile != "minimal") [
      # Additional personal apps for standard/full profiles
      # "logi-options-plus"
    ];

    # Personal-focused system settings
    system.defaults.dock = {
      # More personal-friendly dock settings
      magnification = true;
    };

    # Lighter package set for personal use
    home-manager.users."andrew.elgert".home.packages = with pkgs;
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
