{ config, lib, pkgs, ... }:

with lib;

{
  config = mkIf (builtins.elem "developer" config.machine.roles) {
    homebrew.casks = [
      "android-studio"
      "dash"
      "db-browser-for-sqlite"
      "dbeaver-community"
      "figma"
      "fork"
      "kdiff3"
      "meld"
      "postman"
      "raspberry-pi-imager"
      "silicon-labs-vcp-driver"
      "visual-studio-code"
    ] ++ optionals (!builtins.elem "no-containers" config.machine.taints) [
      "docker-desktop"
      "podman-desktop"
    ] ++ optionals (!builtins.elem "no-microsoft" config.machine.taints) [
      "microsoft-teams"
    ];

    homebrew.masApps = {
      "Developer" = 640199958;
      "Tailscale" = 1475387142;
      "TestFlight" = 899247664;
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
    };

    home-manager.users."${config.system.primaryUser}".home.packages = with pkgs; [
      # Core development tools
      git
      jq
      vim
      bat
      curl
      wget
      tree
      direnv
      htop
      silver-searcher

      # Programming languages & runtimes
      nodejs
      python313
      ruby
      openjdk17
      rustup

      # Package managers & build tools
      poetry
      yarn
      nodePackages.npm
      uv

      # Nix development
      nixd
      nil
      nix-index

      # Development utilities
      ngrok
    ] ++ optionals (!builtins.elem "no-containers" config.machine.taints) [
      podman
      podman-compose
    ] ++ optionals (!builtins.elem "limited-storage" config.machine.taints) [
      # Heavy development tools
    ];

    # Development services (only if not tainted)
    services = mkIf (!builtins.elem "no-services" config.machine.taints) {
      postgresql = {
        enable = true;
        package = (pkgs.postgresql.withPackages (p: [ p.postgis ]));
        dataDir = "/var/log/postgres/data";
      };
      redis = {
        enable = true;
        bind = "127.0.0.1";
        dataDir = "/var/log/redis/data";
      };
      podman = {
        enable = true;
        containers = mkIf (!builtins.elem "no-containers" config.machine.taints) {
          # SQL Server
          rms-sql = {
            image = "mcr.microsoft.com/mssql/server:2022-latest";
            ports = [ "1433:1433" ];
            volumes = [
              "rms-sqldata:/var/opt/mssql/data"
              "/Users/${config.system.primaryUser}/workspace/com.schoolcrossing/test-rig/backups:/var/opt/mssql/backups:ro"
            ];
            environment = {
              ACCEPT_EULA = "Y";
              SA_PASSWORD = "DevStore123!";
            };
            autoStart = true;
          };

          # Syndicate broker
          syndicate-broker = {
            image = "leastfixedpoint/syndicate-server";
            ports = [ "8001:8001" "9001:9001" ];
            volumes = [
              "/Users/${config.system.primaryUser}/workspace/org.syndicate-lang/syndicate-py/chat.server-config.pr:/config.pr:ro"
            ];
            cmd = [ "/syndicate-server" "-c" "/config.pr" ];
            autoStart = true;
          };
        };
      };
    };

    # Development-optimized system settings
    system.defaults.NSGlobalDomain = {
      ApplePressAndHoldEnabled = false; # Better for coding
      InitialKeyRepeat = 35;
      KeyRepeat = 2;
    };

    # Launchd configuration for postgresql
    launchd.user.agents = mkIf config.services.postgresql.enable {
      postgresql.serviceConfig = {
        StandardErrorPath = "/var/log/postgres/postgres.error.log";
        StandardOutPath = "/var/log/postgres/postgres.out.log";
      };
    };
  };
}
