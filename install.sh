#!/bin/bash

ln -s ~/.dotfiles/bashrc ~/.bashrc
ln -s ~/.dotfiles/vimrc ~/.vimrc

if [ $(uname) == 'Darnwin' ]; then
    ln -s ~/.dotfiles/profile ~/.profile
fi

