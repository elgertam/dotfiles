#!/bin/bash

export PATH="/usr/local/sbin:$PATH"

if which pyenv > /dev/null; then
  eval "$(pyenv init -)";
fi

export PATH="$HOME/.local/bin:$HOME/.cabal/bin:$HOME/.ghcup/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

. ~/.bashrc

