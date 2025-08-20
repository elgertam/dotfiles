{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    homebrew.enable = true;
    homebrew.global.brewfile = true;
    homebrew.caskArgs.no_quarantine = true;

    # Base applications for all machines
    homebrew.casks = [
      # Productivity & Utilities
      "1password"
      "appcleaner"
      "bartender"
      "keepingyouawake"
      "keka"
      "stats"
      "the-unarchiver"
      
      # Browsers
      "brave-browser"
      "chromium"
      "firefox"
      "microsoft-edge"
      
      # Communication
      "messenger"
      "slack"
      "zoom"
      
      # Office & Documents
      "microsoft-office"
      "notion"
      
      # Media & Graphics
      "gimp"
      "inkscape"
      
      # System & Security
      "blockblock"
      "detectx-swift"
      "dhs"
      "knockknock"
      "lulu"
      "netiquette"
      "reikey"
      "suspicious-package"
      "taskexplorer"
      "whatsyoursign"
      
      # QuickLook Plugins
      "jupyter-notebook-ql"
      "qlcolorcode"
      "quickgeojson"
      "qlimagesize"
      "qlmarkdown"
      "qlmobi"
      "qlprettypatch"
      "qlstephen"
      "qlswift"
      "qlvideo"
      "quicklook-csv"
      "quicklook-json"
      "scriptql"
      "syntax-highlight"
      
      # System Tools
      "hammerspoon"
      "xquartz"
    ] ++ (
      # Architecture-specific applications
      if (pkgs.system == "aarch64-darwin") then [
        "chatgpt"
      ] else []
    );

    fonts.packages = with pkgs; [
      fira-code
      jost
      powerline-fonts
    ];
  };
}