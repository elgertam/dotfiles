if ! shopt -q login_shell; then
    . /etc/bashrc
fi

__venv_ps1() {
    if [ $VIRTUAL_ENV ]; then
        venv_name=$(basename $VIRTUAL_ENV)
        printf "$1" $venv_name
    else
        printf ''
    fi
}

git_prompt='\[\033[0;35m\]$(__git_ps1 "(b:%s) ")\[\033[0m\]'
venv_prompt='\[\033[0;33m\]$(__venv_ps1 "(v:%s) ")\[\033[0m\]'
main_prompt="\[\033[0;34m\]$PS1\[\033[0m\]"
export PS1=${venv_prompt}${git_prompt}${main_prompt}

set -o vi

alias ll='ls -lAG'
alias ls='ls -G'
export SVN_EDITOR=vim
export EDITOR=vim
export WORKON_HOME=~/.virtualenvs
export NVM_DIR=~/.nvm
. $(brew --prefix nvm)/nvm.sh

if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi


