#!/bin/bash

export PATH="$HOME/.local/bin:/usr/local/texlive/2014/bin/universal-darwin:/Applications/Postgres.app/Contents/Versions/9.4/bin:/usr/local/heroku/bin:/usr/local/sbin:/usr/local/opt/go/libexec/bin:$PATH"

. ~/.bashrc

if which pyenv > /dev/null; then
  eval "$(pyenv init -)";
fi

