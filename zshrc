# If you come from bash you might have to change your $PATH.
if which direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi
if [[ -o login ]]; then
  # export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:$PATH";
  export PATH="/usr/local/bin:/usr/local/sbin:$PATH";
  if which anyenv > /dev/null; then
    eval "$(anyenv init - zsh)";
  fi
  export PATH="$HOME/.local/bin:$PATH";
fi;

# Path to your oh-my-zsh installation.
export ZSH="/Users/ame/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git git-prompt direnv python pyenv virtualenv ag safe-paste)
plugins=(git-prompt)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

export VIRTUAL_ENV_DISABLE_PROMPT=1

autoload -Uz compinit && compinit
set -o vi

alias ll='ls -lAG'
alias ls='ls -G'
# alias grun='java org.antlr.v4.gui.TestRig'
export SVN_EDITOR=vim
export GIT_EDITOR=vim
export EDITOR=vim
export PIPENV_VENV_IN_PROJECT=1

eval $(thefuck --alias)

# Overrides for the agnoster theme
# NOTE: This should keep the theme working as I like
# while allowing me to update without an annoying
# git stash every time

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
[ -f "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env" ] && source "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/env"

alias now='date +%Y%m%d%H%M%S'
export HOMEBREW_GITHUB_API_TOKEN=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
