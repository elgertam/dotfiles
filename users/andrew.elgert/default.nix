{ lib, pkgs, ... }:

{
  home.file = {
    hammerspoon = lib.mkIf pkgs.stdenvNoCC.isDarwin {
      source = ../../rc/hammerspoon;
      target = ".hammerspoon";
      recursive = true;
    };

    vimrc = {
      source = ../../rc/vim/vimrc;
      target = ".vimrc";
    };

    ".npmrc" = {
      text = ''
        prefix=$HOME/.npm-global
      '';
    };
  } // (lib.optionalAttrs pkgs.stdenvNoCC.isLinux {
    # Linux-specific dotfiles can be added here
    # For example, window manager configs:
    # ".config/i3/config" = {
    #   source = ../../rc/i3/config;
    # };
  });

  home.stateVersion = "24.11";

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
  } // (lib.optionalAttrs pkgs.stdenvNoCC.isDarwin {
    # macOS-specific: Podman machine socket
    DOCKER_HOST = "unix:///tmp/podman/podman-machine-default-api.sock";
  }) // (lib.optionalAttrs pkgs.stdenvNoCC.isLinux {
    # Linux-specific: Native podman socket
    DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
  });

  home.shellAliases = {
    ll = if pkgs.stdenvNoCC.isDarwin then "ls -lAG" else "ls -lA --color=auto";
    ls = if pkgs.stdenvNoCC.isDarwin then "ls -G" else "ls --color=auto";
    now = "date +%Y%m%d%H%M%S";
  } // (lib.optionalAttrs pkgs.stdenvNoCC.isDarwin {
    # macOS-specific aliases
    brew = if pkgs.system == "aarch64-darwin" then "/opt/homebrew/bin/brew" else "/usr/local/homebrew/bin/brew";
    claude = "/Users/andrew.elgert/.claude/local/claude --dangerously-skip-permissions";
  }) // (lib.optionalAttrs pkgs.stdenvNoCC.isLinux {
    # Linux-specific aliases
    claude = "$HOME/.claude/local/claude --dangerously-skip-permissions";
    # Add clipboard utilities
    pbcopy = "xclip -selection clipboard";
    pbpaste = "xclip -selection clipboard -o";
  });

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
    core.excludesfile = if pkgs.stdenvNoCC.isDarwin then "/Users/andrew.elgert/.gitignore_global" else "/home/andrew.elgert/.gitignore_global";
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
}
