export CLICOLOR=1

if ! shopt -q login_shell; then
    . /etc/bashrc
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1

VENV_PROMPT_PYSCRIPT=$(cat <<- EOF
import sys
import platform
version = platform.python_version()
real_prefix = hasattr(sys, "real_prefix") 
base_prefix = getattr(sys, "base_prefix", object())
prefix = getattr(sys, "prefix", object())
if (real_prefix and version.startswith("2")) or ((base_prefix != prefix) and version.startswith("3")):
    print("succeeded", version, real_prefix, base_prefix, prefix)
    exit(0)
else:
    print("failed v:{} rp:{} bp:{} p:{} eq?:{}".format(version, real_prefix, base_prefix, prefix, base_prefix == prefix))
    exit(1)
EOF 
)

__venv_ps1() {
    if python -c "$VENV_PROMPT_PYSCRIPT" > /tmp/output; then
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
export PS1="${venv_prompt}${git_prompt}${main_prompt}"

set -o vi

alias ll='ls -lAG'
alias ls='ls -G'
# alias grun='java org.antlr.v4.gui.TestRig'
export SVN_EDITOR=vim
export GIT_EDITOR=vim
export EDITOR=vim
export PIPENV_VENV_IN_PROJECT=1

if [ -f "$(brew --prefix)"/etc/bash_completion ]; then
    . "$(brew --prefix)"/etc/bash_completion
fi

eval $(thefuck --alias)


# added by travis gem
[ -f /Users/ame/.travis/travis.sh ] && source /Users/ame/.travis/travis.sh

