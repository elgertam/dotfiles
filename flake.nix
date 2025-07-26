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
        "anydesk"
        "anytype"
        "appcleaner"
        "bartender"
        "basictex"
        "blockblock"
        "brave-browser"
        "chromium"
        "claude"
        "creality-print"
        "creality-slicer"
        "dash"
        "db-browser-for-sqlite"
        "dbeaver-community"
        "detectx-swift"
        "dhs"
        "diffusionbee"
        "docker-desktop"
        "dropbox"
        "firefox"
        "figma"
        "fork"
        "geogebra"
        "gimp"
        "hammerspoon"
        "inkscape"
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
        "microsoft-edge"
        "microsoft-office"
        "microsoft-teams"
        "notion"
        "netiquette"
        "pandora"
        "podman-desktop"
        "postman"
        "powerphotos"
        "prusaslicer"
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
        "reikey"
        "scriptql"
        "selfcontrol"
        "slack"
        "syntax-highlight"
        "stats"
        "suspicious-package"
        "tabula"
        "taskexplorer"
        "the-unarchiver"
        "transmission"
        "ultimaker-cura"
        "utm"
        "visual-studio-code"
        "whatsyoursign"
        "windows-app"
        "xquartz"
        "zoom"
      ] ++ (
        if (pkgs.system == "aarch64-darwin") then [
          "chatgpt"
        ] else []
      );

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
      programs.zsh.enableCompletion = true;

      programs.direnv.enable = true;

      programs.nix-index.enable = true;

      security.pam.services.sudo_local.touchIdAuth = true;
      security.pam.services.sudo_local.reattach = true;

      services.postgresql = {
        enable = true;
        package = (pkgs.postgresql.withPackages (p: [ p.postgis ]) );
        dataDir = "/var/log/postgres/data";
      };
      services.redis = {
        enable = true;
        bind = "127.0.0.1";
        dataDir = "/var/log/redis/data";
      };

      launchd.user.agents = {
        postgresql.serviceConfig = {
          StandardErrorPath = "/var/log/postgres/postgres.error.log";
          StandardOutPath = "/var/log/postgres/postgres.out.log";
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

      system.primaryUser = "ame";

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

      home.file.".npmrc".text = ''
        prefix=$HOME/.npm-global
      '';

      home.stateVersion = "24.11";

      home.packages = with pkgs; [
        coreutils man git jq vim bat
        tmux tree direnv htop silver-searcher
        curl wget
        ruby python313 nodejs openjdk17
        poetry yarn nodePackages.npm rustup uv
        nix-index nixd nil
        ngrok
        redis postgresql podman
      ];

      home.sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.npm-global/bin"
      ];

      home.sessionVariables = {
        EDITOR = "vim";
        VIRTUAL_ENV_DISABLE_PROMPT = 1;
        SVN_EDITOR = "vim";
        GIT_EDITOR = "vim";
        PIPENV_VENV_IN_PROJECT = 1;
        NPM_CONFIG_PREFIX = "$HOME/.npm-global";
        DOCKER_HOST = "unix:///tmp/podman/podman-machine-default-api.sock";
      };

      home.shellAliases = {
        brew = if pkgs.system == "aarch64-darwin" then "/opt/homebrew/bin/brew" else "/usr/local/omebrew/bin/brew";
        claude = "/Users/ame/.claude/local/claude --dangerously-skip-permissions";
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
      programs.git.extraConfig = {
        core.excludesfile = "${home}/.gitignore_global";
        init.defaultBranch = "master";
        push.autoSetupRemote = true;
        pull.rebase = true;
      };
      programs.git.ignores = [
        ".direnv/"
      ];
      programs.git.lfs.enable = true;
      programs.git.userEmail = "andrew.elgert@gmail.com";
      programs.git.userName = "Andrew Mark Elgert";

      programs.home-manager.enable = true;

      programs.htop.enable = true;

      programs.nix-index.enable = true;
      programs.nix-index.enableZshIntegration = true;

      programs.zsh.enable = true;
      programs.zsh.enableCompletion = true;

      programs.zsh.initContent = ''
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

    darwinConfigBuilder = { hostname, system, username }:
      darwinSystem {
        modules = builtins.attrValues self.darwinModules ++ [
          configuration
          {
            networking.computerName = hostname ;
            users.users.${username}.home = "/Users/${username}";
          }
          home-manager.darwinModules.home-manager
          {
            nixpkgs = nixpkgsConfig;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = home-configuration;
          }
        ];
        system = system;
      };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake ./modules/examples#simple \
    #       --override-input darwin .

    darwinConfigurations.laforge = darwinConfigBuilder {
      hostname = "laforge";
      system = "x86_64-darwin";
      username = "ame";
    };

    darwinConfigurations.spock = darwinConfigBuilder {
      hostname = "spock";
      system = "aarch64-darwin";
      username = "ame";
    };

    darwinConfigurations.riker = darwinConfigBuilder {
      hostname = "riker";
      system = "aarch64-darwin";
      username = "ame";
    };

    darwinPackages = self.darwinConfigurations.laforge.pkgs;

    darwinModules = { };

    overlays = { };

  };
}
