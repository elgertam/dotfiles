# Andrew's dotfiles

## Setup

Git clone or download this repository into ~/.dotfiles, e.g.

```sh
git clone https://github.com/elgertam/dotfiles ~/.dotfiles
```

Ensure that the script files in `.dotfiles` are executable:

```sh
chmod u+x ~/.dotfiles/*.sh
```

## Install

From `~/.dotfiles`, run `./reload.sh`, which will bootstrap your system with Nix, nix-darwin and home-manager and then will set up your system using `flake.nix`.

## Updating

If you make a change to your flake configuration, run `~/.dotfiles/reload.sh` to reload the system with the new configuration.

If you would like to update your system to the latest package sources, run `~/.dotfiles/update.sh`.

## Removing

If you'd like to uninstall, run `/nix/nix-installer uninstall`. You may need to fix some of the files at the following locations:

```sh
/etc/zshrc
/etc/bashrc
/etc/zshenv
```

## Troubleshooting

You may run into various errors relating to files that already exist on the disk. If you see them, follow the included instructions and try the command again. Nix tends to be highly repeatable build system, so the chances of blowing your whole system up are small.

## Acknowledgements

Inspired by <https://github.com/ameske/.dot_files>
