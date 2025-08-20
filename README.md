# Andrew's dotfiles

Cross-platform dotfiles supporting both macOS and Linux using Nix flakes, nix-darwin, and home-manager.

## Quick Start

### macOS

```sh
git clone https://github.com/elgertam/dotfiles ~/.dotfiles
cd ~/.dotfiles
chmod u+x *.sh
./reload.sh
```

### Linux

#### Option 1: NixOS (Full System Configuration)
```bash
git clone https://github.com/elgertam/dotfiles ~/.dotfiles
cd ~/.dotfiles
# Edit hosts/linux-desktop.nix for your hardware
sudo nixos-rebuild switch --flake .#linux-desktop
```

#### Option 2: Home Manager Only (Any Linux Distribution)
```bash
# Install Nix first
curl -L https://nixos.org/nix/install | sh
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Install Home Manager
nix run home-manager/master -- init --switch

# Clone and apply dotfiles
git clone https://github.com/elgertam/dotfiles ~/.dotfiles
home-manager switch --flake ~/.dotfiles#ame
```

## Platform Support

This configuration provides:

### macOS (via nix-darwin)
- **Package Management**: Homebrew casks for GUI apps
- **System Settings**: macOS defaults (dock, finder, etc.)
- **Window Management**: Hammerspoon for automation
- **Container Runtime**: Podman with launchd services

### Linux (via NixOS)
- **Package Management**: Native Nix packages + Flatpak
- **Desktop Environment**: GNOME (default), KDE, or i3
- **System Settings**: GNOME/desktop environment defaults
- **Container Runtime**: Podman with systemd services

### Shared Features
- **Shell**: Zsh with Oh My Zsh
- **Development Tools**: Git, Vim, direnv, nix-index
- **Language Support**: Node.js, Python environments
- **Cross-platform aliases** and environment variables

## Configuration Structure

```
├── flake.nix                 # Main entry point
├── hosts/
│   ├── shared.nix           # macOS shared config
│   ├── linux-shared.nix     # Linux shared config
│   ├── linux-desktop.nix    # Example Linux host
│   ├── laforge.nix          # macOS hosts
│   ├── spock.nix
│   └── riker.nix
├── modules/
│   ├── core/                # Core Nix configuration
│   ├── roles/               # User roles (developer, personal, etc.)
│   ├── system/
│   │   ├── darwin-defaults.nix     # macOS system settings
│   │   ├── gnome-defaults.nix      # Linux/GNOME settings
│   │   ├── homebrew.nix            # macOS package management
│   │   └── linux-packages.nix     # Linux package management
│   ├── podman-darwin.nix    # macOS container services
│   └── podman-linux.nix     # Linux container services
├── users/ame/               # User-specific configuration
└── rc/                      # Configuration files
    ├── hammerspoon/         # macOS window management
    └── vim/                 # Editor configuration
```

## Management Commands

### macOS
```sh
# Apply configuration changes
~/.dotfiles/reload.sh

# Update package sources
~/.dotfiles/update.sh
```

### Linux (NixOS)
```bash
# Apply configuration changes
sudo nixos-rebuild switch --flake ~/.dotfiles#your-hostname

# Update and rebuild
sudo nixos-rebuild switch --upgrade --flake ~/.dotfiles#your-hostname
```

### Linux (Home Manager)
```bash
# Apply user configuration changes
home-manager switch --flake ~/.dotfiles#ame

# Update packages
nix flake update ~/.dotfiles
home-manager switch --flake ~/.dotfiles#ame
```

## Linux-Specific Configuration

### Desktop Environment Options
Edit `hosts/linux-desktop.nix` to choose your desktop environment:

```nix
# GNOME (default)
services.xserver.desktopManager.gnome.enable = true;

# KDE Plasma  
services.xserver.desktopManager.plasma5.enable = true;

# i3 Window Manager
services.xserver.windowManager.i3.enable = true;
```

### Graphics Drivers
Uncomment appropriate drivers in your Linux host configuration:

```nix
# NVIDIA
services.xserver.videoDrivers = [ "nvidia" ];

# AMD
services.xserver.videoDrivers = [ "amdgpu" ];
```

### Adding New Linux Hosts
1. Copy `hosts/linux-desktop.nix` to `hosts/your-hostname.nix`
2. Run `nixos-generate-config` and copy hardware configuration
3. Customize bootloader and system settings
4. Add to `flake.nix` nixosConfigurations
5. Build with: `sudo nixos-rebuild switch --flake .#your-hostname`

## Platform Differences

### Package Management
- **macOS**: 72 Homebrew casks for GUI applications
- **Linux**: Native Nix packages + Flatpak for additional apps

### System Configuration  
- **macOS**: Darwin defaults control dock, finder, trackpad, etc.
- **Linux**: Desktop environment settings (GNOME/KDE) or window manager configs

### Window Management
- **macOS**: Hammerspoon for advanced automation and window control
- **Linux**: Native window managers (i3, GNOME Shell, KDE) with extensions

### Container Services
- **macOS**: Podman machine with launchd services  
- **Linux**: Native Podman with systemd services

### Cross-Platform Features
- **Aliases**: `pbcopy`/`pbpaste` → `xclip` equivalents on Linux
- **Paths**: `/Users/ame` → `/home/ame`, different socket locations
- **Commands**: Platform-specific variations (e.g., `ls -G` vs `ls --color=auto`)

## Troubleshooting

### General Issues
You may encounter errors about existing files. Follow the included instructions and retry - Nix's reproducible builds minimize system damage risk.

### Linux-Specific Issues

**Missing Packages**: Some macOS apps lack direct Linux equivalents. Check `modules/system/linux-packages.nix` for alternatives.

**Hardware Problems**: Run `nixos-generate-config` to generate proper hardware configuration.

**Graphics Issues**: Ensure correct drivers are enabled in your host configuration.

**Container Problems**: Linux uses systemd instead of launchd. Use `systemctl` commands.

## Removal

**macOS/Linux**: Run `/nix/nix-installer uninstall`. You may need to restore these files:
```sh
/etc/zshrc
/etc/bashrc  
/etc/zshenv
```

## TODO

Move vimrc & tmux.conf into the flake

## Further References

- Zero to Nix <https://zero-to-nix.com>
- Nix Pills <https://nixos.org/guides/nix-pills/>
- Intro to the Nix language, derivations and nixpkgs (video) <https://www.youtube.com/watch?v=9DJtHIpdp0Y>
- home-manager options <https://nix-community.github.io/home-manager/options.html>
- nix-darwin options <https://daiderd.com/nix-darwin/manual/index.html#sec-options>

## Acknowledgements

Inspired by <https://github.com/ameske/.dot_files>
