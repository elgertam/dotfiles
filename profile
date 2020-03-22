#!/bin/bash

export PATH="/usr/local/sbin:$PATH"

if which direnv > /dev/null; then
    eval "$(direnv hook bash)"
fi

if which anyenv > /dev/null; then
  eval "$(anyenv init -)";
fi

export PATH="$HOME/.poetry/bin:$HOME/.cabal/bin:$HOME/.ghcup/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$HOME/.local/bin:$PATH"

. ~/.bashrc

