#!/bin/sh

install_nix() {
  if [ ! -d /nix/ ]; then
    echo Installing from Determinate Systems installer
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    echo Done installing Nix
  else
    echo Nix is already installed.
  fi
}

boostrap_nix_darwin() {
  if [ -f /etc/synthetic.conf ]; then
    sudo cp /etc/synthetic.conf /etc/synthetic.conf.before-nix-darwin
    if grep '^run\tprivate/var/run$' /etc/synthetic.conf > /dev/null; then
      touch /dev/null
    else
      printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
      sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
    fi
  else
    printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
    sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
  fi

  echo 'Building system flake.'

  nix build .\#darwinConfigurations.$(hostname -s).system

  sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
  sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
  sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin

  if [ -f /etc/zshenv ]; then
    sudo mv /etc/zshenv /etc/zshenv.before-nix-darwin
  fi

  echo 'Bootstrapping system.'

  ./result/sw/bin/darwin-rebuild switch --flake .
}

cleanup_bootstrap() {
  rm -rf result
}

run_installation() {
  if which darwin-rebuild > /dev/null ; then
    echo Nix-darwin already installed.
  else
    install_nix
    bootstrap_nix_darwin
    cleanup_boostrap
  fi
}

run_installation
