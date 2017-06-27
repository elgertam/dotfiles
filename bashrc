if $(python -c "import os; exit(0) if '/usr/local/bin' in os.environ.get('PATH') else exit(1)") ; then
    true;
else
    export PATH="/usr/local/bin:$PATH"
fi

if ! shopt -q login_shell; then
    . /etc/bashrc
fi

__venv_ps1() {
    if python -c 'import sys; import platform; version = platform.python_version(); exit(0) \
                  if (hasattr(sys, "real_prefix") and version.startswith("2")) \
                    or (getattr(sys, "base_prefix", object()) != getattr(sys, "prefix", object()) \
                      and version.startswith("3")) \
                  else exit(1)'; then
        venv_name="$(basename $VIRTUAL_ENV)"
        if [ "$venv_name" = 'env' \
             -o "$venv_name" = '.env' \
             -o "$venv_name" = 'venv' \
             -o "$venv_name" = '.venv' ]; then
            venv_name="$(basename "$(dirname $VIRTUAL_ENV)")"
        fi
        printf "$1" "$venv_name"
    else
        printf ''
    fi
}

git_prompt='\[\033[0;35m\]$(__git_ps1 "(b:%s) ")\[\033[0m\]'
venv_prompt='\[\033[0;33m\]$(__venv_ps1 "(v:%s) ")\[\033[0m\]'
main_prompt="\[\033[0;34m\]$PS1\[\033[0m\]"
export PS1=${venv_prompt}${git_prompt}${main_prompt}

export CLASSPATH=".:/usr/local/lib/antlr-4.6-complete.jar:$CLASSPATH"

set -o vi

alias ll='ls -lAG'
alias ls='ls -G'
alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.6-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java org.antlr.v4.gui.TestRig'
export SVN_EDITOR=vim
export EDITOR=vim
export NVM_DIR=~/.nvm
export PIPENV_VENV_IN_PROJECT=1
. "$(brew --prefix nvm)"/nvm.sh

if [ -f "$(brew --prefix)"/etc/bash_completion ]; then
    . "$(brew --prefix)"/etc/bash_completion
fi

