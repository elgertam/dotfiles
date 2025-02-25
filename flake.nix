{
  description = "AME's darwin system";

  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = { self, darwin, home-manager, ... }@inputs:
  let
    inherit (darwin.lib) darwinSystem;

    home = "/Users/ame";

    nixpkgs = inputs.nixpkgs-unstable;

    configuration = { pkgs, lib, ... }: {

      environment.systemPackages = [ ];

      fonts.packages = with pkgs; [
        fira-code
        jost
        powerline-fonts
      ];

      homebrew.enable = true;
      homebrew.global.brewfile = true;
      homebrew.caskArgs.no_quarantine = true;

      homebrew.casks = [
        "1password"
        "anaconda"
        "anydesk"
        "anytype"
        "appcleaner"
        "bartender"
        "basictex"
        "blockblock"
        "brave-browser"
        "chromium"
        "creality-print"
        "creality-slicer"
        "dash"
        "db-browser-for-sqlite"
        "dbeaver-community"
        "detectx-swift"
        "dhs"
        "diffusionbee"
        "docker"
        "dropbox"
        "firefox"
        "figma"
        "fork"
        "geogebra"
        "gimp"
        "hammerspoon"
        "inkscape"
        "ipfs"
        "jupyter-notebook-ql"
        "keka"
        "kdiff3"
        "keepingyouawake"
        "knockknock"
        "logi-options-plus"
        "lulu"
        "macgpt"
        "macs-fan-control"
        "macsvg"
        "meld"
        "messenger"
        "microsoft-teams"
        "notion"
        "netiquette"
        "pandora"
        "postman"
        "powerphotos"
        "prusaslicer"
        # "ql-ansilove"
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
        "transmission"
        "ultimaker-cura"
        "visual-studio-code"
        "whatsyoursign"
        "windows-app"
        "xquartz"
        "zoom"
      ];

      # needed for compatibility
      ids.gids.nixbld = 30000;

      nix.enable = true;

      nix.nixPath = [ "nixpkgs=${nixpkgs}" ];

      nix.optimise.automatic = true;

      nix.package = pkgs.nixVersions.stable;

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        extra-platforms = lib.mkIf (pkgs.system == "aarch64-darwin") [ "x86_64-darwin" "aarch64-darwin"];
      };

      nixpkgs.config = { allowUnfree = true; };

      # needed to enable Zsh system-side including in /etc
      programs.zsh.enable = true;

      security.pam.services.sudo_local.touchIdAuth = true;

      services.postgresql = {
        enable = true;
        package = (pkgs.postgresql.withPackages (p: [ p.postgis ]) );
        dataDir = "${home}/.postgres/data";
      };
      services.redis = {
        enable = true;
        bind = "127.0.0.1";
        dataDir = "${home}/.redis/data";
      };

      launchd.user.agents = {
        postgresql.serviceConfig = {
          StandardErrorPath = "${home}/.postgres/postgres.error.log";
          StandardOutPath = "${home}/.postgres/postgres.log";
        };
      };

      system.defaults.dock = {
        autohide = true;
        wvous-tr-corner = 2;
        wvous-br-corner = 3;
        magnification = true;
      };

      system.defaults.finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXPreferredViewStyle = "clmv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      system.defaults.menuExtraClock = {
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 1;
        ShowDayOfWeek = true;
        ShowDayOfMonth = true;
        ShowSeconds = true;
      };

      system.defaults.NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 35;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        "com.apple.swipescrolldirection" = false;
        "com.apple.mouse.tapBehavior" = 1;
      };

      system.defaults.trackpad = {
        Clicking = true;
        TrackpadRightClick= true;
        TrackpadThreeFingerDrag = true;
      };

      system.stateVersion = 6;
    };

    nixpkgsConfig = {
      config.allowUnfree = true;
      overlays = builtins.attrValues self.overlays;
    };

    home-configuration = { pkgs, lib, ... }: {
      home.file = {
        hammerspoon = lib.mkIf pkgs.stdenvNoCC.isDarwin {
          source = ./rc/hammerspoon;
          target = ".hammerspoon";
          recursive = true;
        };

        vimrc  = {
          source = ./rc/vim/vimrc;
          target = ".vimrc";
        };
      };

      home.stateVersion = "24.11";

      home.packages = with pkgs; [
        coreutils man git jq vim bat tmux tree direnv htop silver-searcher
        curl wget
        ruby python310 nodejs
        poetry yarn nodePackages.npm rustup uv
        nix-index nixd nil
        ngrok
        redis postgresql
        thefuck
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
      programs.direnv.stdlib = ''
      export_function() {
        local name=$1
        local alias_dir=$PWD/.direnv/aliases
        mkdir -p "$alias_dir"
        PATH_add "$alias_dir"
        local target="$alias_dir/$name"
        if declare -f "$name" >/dev/null; then
          echo "#!/usr/bin/env bash" > "$target"
          declare -f "$name" >> "$target" 2>/dev/null
          echo "$name" >> "$target"
          chmod +x "$target"
        fi
      }
      '';

      programs.git.enable = true;
      programs.git.userEmail = "andrew.elgert@gmail.com";
      programs.git.userName = "Andrew Mark Elgert";
      programs.git.ignores = [
        ".direnv/"
      ];
      programs.git.lfs.enable = true;
      programs.git.extraConfig = {
        core.excludesfile = "${home}/.gitignore_global";
        init.defaultBranch = "master";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };

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

      # !! Contents within this block are managed by 'conda init' !!
      __conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
      if [ $? -eq 0 ]; then
          eval "$__conda_setup"
      else
          if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
              . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
          else
              export PATH="/opt/homebrew/anaconda3/bin:$PATH"
          fi
      fi
      unset __conda_setup
      # <<< conda initialize <<<
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
        {
          users.users.ame.home = home;
        }
        home-manager.darwinModules.home-manager
        {
          nixpkgs = nixpkgsConfig;
          home-manager.useUserPackages = true;
          home-manager.users.ame = home-configuration;
        }
      ];
      system = "x86_64-darwin";
    };

    darwinConfigurations.spock = darwinSystem {
      modules = builtins.attrValues self.darwinModules ++ [
        configuration
        {
          users.users.ame.home = home;
        }
        home-manager.darwinModules.home-manager
        {
          nixpkgs = nixpkgsConfig;
          home-manager.useUserPackages = true;
          home-manager.users.ame = home-configuration;
        }
      ];
      system = "aarch64-darwin";
    };

    darwinConfigurations.riker = darwinSystem {
      modules = builtins.attrValues self.darwinModules ++ [
        configuration
        {
          users.users.ame.home = home;
        }
        home-manager.darwinModules.home-manager
        {
          nixpkgs = nixpkgsConfig;
          home-manager.useUserPackages = true;
          home-manager.users.ame = {pkgs, ...}: {
            imports = [
              home-configuration
              ({...}: { programs.git.userEmail = pkgs.lib.mkForce "aelgert@wrangle.io"; })
            ];
          };
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
