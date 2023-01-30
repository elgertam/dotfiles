{
  description = "AME's darwin system";

  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-22.11";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, darwin, home-manager, ... }@inputs:
  let
    inherit (darwin.lib) darwinSystem;

    nixpkgs = inputs.nixpkgs-unstable;

    configuration = { pkgs, lib, ... }: {

      environment.systemPackages = with pkgs; [ ];

      fonts.fontDir.enable = true;
      fonts.fonts = with pkgs; [
        fira-code
        powerline-fonts
      ];

      homebrew.enable = true;
      homebrew.global.brewfile = true;

      homebrew.taps = [
        "homebrew/core"
        "homebrew/cask"
      ];

      homebrew.casks = [
        "1password"
        "appcleaner"
        "bartender"
        "blockblock"
        "brave-browser"
        "chromium"
        "dash"
        "db-browser-for-sqlite"
        "detectx-swift"
        "dhs"
        "docker"
        "dropbox"
        "firefox"
        "fork"
        "gimp"
        "hammerspoon"
        "inkscape"
        "ipfs"
        "jupyter-notebook-ql"
        "kdiff3"
        "keepingyouawake"
        "knockknock"
        "lulu"
        "macs-fan-control"
        "macsvg"
        "basictex"
        "meld"
        "netiquette"
        "pandora"
        "postman"
        "ql-ansilove"
        "qlcolorcode"
        "qlimagesize"
        "qlmarkdown"
        "qlrest"
        "qlstephen"
        "quicklook-csv"
        "quicklook-json"
        "reikey"
        "selfcontrol"
        "slack"
        "stats"
        "suspicious-package"
        "taskexplorer"
        "the-unarchiver"
        "visual-studio-code"
        "whatsyoursign"
        "xquartz"
        "zoom"
      ];

      nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

      nix.package = pkgs.nixVersions.stable;

      nix.settings = {
        auto-optimise-store = true;
        experimental-features = [ "nix-command" "flakes" ];
        extra-platforms = lib.mkIf (pkgs.system == "aarch64-darwin") [ "x86_64-darwin" "aarch64-darwin"];
      };

      nixpkgs.config = { allowUnfree = true; };

      # needed to enable Zsh system-side including in /etc
      programs.zsh.enable = true;

      security.pam.enableSudoTouchIdAuth = true;

      services.nix-daemon.enable = true;

      system.defaults.dock = {
        autohide = true;
      };

      system.defaults.NSGlobalDomain = {
        InitialKeyRepeat = 35;
        KeyRepeat = 2;
        ApplePressAndHoldEnabled = false;
      };

      system.defaults.trackpad = {
        Clicking = true;
        TrackpadRightClick= true;
        TrackpadThreeFingerDrag = true;
      };
    };

    nixpkgsConfig = {
      config.allowUnfree = true;
      overlays = builtins.attrValues self.overlays;
    };

    home-configuration = { config, pkgs, lib, ... }: {
      home.stateVersion = "23.05";

      home.packages = with pkgs; [
        coreutils man git jq vim bat tmux tree direnv htop silver-searcher
        curl wget
        ruby python310 nodejs
        poetry yarn nodePackages.npm rustup
        rnix-lsp nix-index
        ngrok
      ];

      home.sessionPath = [
        "$HOME/.local/bin"
      ];

      home.sessionVariables = {
        EDITOR = "vim";
        VIRTUAL_ENV_DISABLE_PROMPT = 1;
        SVN_EDITOR = "vim";
        GIT_EDITOR = "vim";
        PIPENV_VENV_IN_PROJECT = 1;
      };

      home.shellAliases = {
        ll = "ls -lAG";
        ls = "ls -G";
        now = "date +%Y%m%d%H%M%S";
      };

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
      };

      nixpkgs.config = { allowUnfree = true; };

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      programs.direnv.enableZshIntegration = true;

      programs.nix-index.enable = true;
      programs.nix-index.enableZshIntegration = true;

      programs.zsh.enable = true;
      programs.zsh.enableCompletion = true;

      programs.zsh.initExtra = ''
      prompt_dir() {
        prompt_segment blue $CURRENT_FG '%1~'
      }

      prompt_virtualenv() {
        local virtualenv_path="$VIRTUAL_ENV"
        if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
          # prompt_segment blue black "(`basename $virtualenv_path`)"
          local base_env="$(basename $virtualenv_path)"
          if [ $base_env = '.venv' ]; then
            base_env="$(basename "$(dirname $virtualenv_path)")"
          fi;
          prompt_segment cyan black "v:$base_env"
        fi
      }

      build_prompt() {
        RETVAL=$?
        prompt_status
        prompt_context
        prompt_aws
        prompt_dir
        prompt_virtualenv
        # prompt_git
        prompt_bzr
        prompt_hg
        prompt_end
      }

      set -o vi
      '';

      programs.zsh.envExtra = ''
      if which cargo > /dev/null; then
        . "$HOME/.cargo/env"
      fi

      if which thefuck > /dev/null; then
        eval "$(thefuck --alias)"
      fi

      if which anyenv > /dev/null; then
        eval "$(anyenv init - zsh)";
      fi
      '';

      programs.zsh.oh-my-zsh.enable = true;
      programs.zsh.oh-my-zsh.plugins = [ "git-prompt" ];
      programs.zsh.oh-my-zsh.theme = "agnoster";
    };

  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake ./modules/examples#simple \
    #       --override-input darwin .
    darwinConfigurations.laforge = darwinSystem {
      modules = builtins.attrValues self.darwinModules ++ [
        configuration
        home-manager.darwinModules.home-manager
        {
          nixpkgs = nixpkgsConfig;
          # home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ame = home-configuration;
        }
      ];
      system = "x86_64-darwin";
    };

    darwinConfigurations.sulu = darwinSystem {
      modules = builtins.attrValues self.darwinModules ++ [
        configuration
        home-manager.darwinModules.home-manager
        {
          nixpkgs = nixpkgsConfig;
          # home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ame = home-configuration;
        }
      ];
      system = "aarch64-darwin";
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations.laforge.pkgs;

    darwinModules = { };

    overlays = { };

  };
}
