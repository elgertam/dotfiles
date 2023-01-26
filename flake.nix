{
  description = "AME's darwin system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-unstable.url = github:NixOS/nixpkgs/nixpkgs-unstable;

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
  let
    inherit (darwin.lib) darwinSystem;

    configuration = { pkgs, ... }: {
      nix.package = pkgs.nixVersions.stable;

      programs.zsh.enable = true;
      programs.zsh.enableCompletion = true;

      fonts.fontDir.enable = true;
      fonts.fonts = with pkgs; [
        fira-code
      ];

      services.nix-daemon.enable = true;

      environment.systemPackages = with pkgs; [ ];
      security.pam.enableSudoTouchIdAuth = true;

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

    home-configuration = { config, pkgs, lib, ... }: {
      home.stateVersion = "22.11";

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

      programs.direnv.enable = true;
      programs.direnv.nix-direnv.enable = true;
      programs.direnv.enableZshIntegration = true;

      programs.zsh.enable = true;

      # programs.zsh.initExtraFirst = ''
      # if which anyenv > /dev/null; then
      #   eval "$(anyenv init - zsh)";
      # fi
      # '';

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

      # programs.htop.enable = true;
      # programs.htop.settings.show_program_path = true;

      home.packages = with pkgs; [
        coreutils man git jq vim bat tmux tree direnv htop silver-searcher
        curl wget
        ruby python310 nodejs
        poetry yarn nodePackages.npm
        rnix-lsp
      ];
    };

    nixpkgsConfig = {
      config = { allowUnfree = true; };
      overlays = builtins.attrValues self.overlays;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake ./modules/examples#simple \
    #       --override-input darwin .
    darwinConfigurations.laforge = darwinSystem {
      # modules = [ configuration darwin.darwinModules.simple ];
      modules = builtins.attrValues self.darwinModules ++ [
        configuration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
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
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ame = home-configuration;
        }
      ];
      system = "aarch64-darwin";
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations.laforge.pkgs;

    darwinModules = {
      programs-nix-index =
        # Additional configuration for `nix-index` to enable `command-not-found` functionality with Fish.
        { config, lib, pkgs, ... }:

        {
          config = lib.mkIf config.programs.nix-index.enable {
            programs.fish.interactiveShellInit = ''
              function __fish_command_not_found_handler --on-event="fish_command_not_found"
                ${if config.programs.fish.useBabelfish then ''
                command_not_found_handle $argv
                '' else ''
                ${pkgs.bashInteractive}/bin/bash -c \
                  "source ${config.programs.nix-index.package}/etc/profile.d/command-not-found.sh; command_not_found_handle $argv"
                ''}
              end
            '';
            };
        };

      ame-homebrew =
        {config, lib, ...}:
        {
          homebrew.enable = true;
          # onActivation.cleanup = "zap";
          homebrew.global.brewfile = true;

          homebrew.taps = [
            "homebrew/core"
            "homebrew/cask"
            # "homebrew/cask-fonts"
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
            "ngrok"
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
        };
    };

    overlays = {};

  };
}
