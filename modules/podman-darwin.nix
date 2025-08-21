# modules/podman-darwin.nix
# Adapted from home-manager's podman module to work with launchd instead of systemd

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.podman;

  # Taken from home-manager's podman module
  containerOptions = { ... }: {
    options = {
      image = mkOption {
        type = types.str;
        description = lib.mdDoc "OCI image to run.";
        example = "docker.io/library/hello-world";
      };

      imageFile = mkOption {
        type = with types; nullOr package;
        default = null;
        description = lib.mdDoc ''
          Path to an image file to load instead of pulling from a registry.
          If defined, do not pull from registry.

          You still need to set the `image` attribute, as it
          will be used as the image name for docker to start a container.
        '';
        example = literalExpression "pkgs.dockerTools.buildImage {...};";
      };

      login = {
        username = mkOption {
          type = with types; nullOr str;
          default = null;
          description = lib.mdDoc "Username for login.";
        };

        passwordFile = mkOption {
          type = with types; nullOr str;
          default = null;
          description = lib.mdDoc "Path to file containing password.";
          example = "/etc/nixos/dockerhub-password.txt";
        };

        registry = mkOption {
          type = types.str;
          default = "https://index.docker.io/v1/";
          description = lib.mdDoc "Address of the registry.";
        };
      };

      entrypoint = mkOption {
        type = with types; nullOr str;
        description = lib.mdDoc "Override the default entrypoint of the image.";
        default = null;
        example = "/bin/my-app";
      };

      cmd = mkOption {
        type = with types; listOf str;
        description = lib.mdDoc "Override the default command of the image.";
        default = [ ];
        example = literalExpression ''["--port" "9000"]'';
      };

      environment = mkOption {
        type = with types; attrsOf str;
        default = { };
        description = lib.mdDoc "Environment variables to set for this container.";
        example = literalExpression ''
          {
            PATH = "/some/path/bin";
            HOME = "/home/alice";
          }
        '';
      };

      environmentFiles = mkOption {
        type = with types; listOf path;
        default = [ ];
        description = lib.mdDoc "Environment files for this container.";
        example = literalExpression ''
          [
            /path/to/env/file
          ]
        '';
      };

      labels = mkOption {
        type = with types; attrsOf str;
        default = { };
        description = lib.mdDoc "Labels to attach to the container at runtime.";
        example = literalExpression ''
          {
            "traefik.enable" = "true";
            "traefik.http.routers.my-app.rule" = "Host(`my-app.my-domain.com`)";
          }
        '';
      };

      ports = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = lib.mdDoc "Network ports to publish from the container to the host.";
        example = literalExpression ''
          [
            "8080:9000"
          ]
        '';
      };

      user = mkOption {
        type = with types; nullOr str;
        default = null;
        description = lib.mdDoc "Override the username or UID (and optionally groupname or GID) used in the container.";
        example = "1000:1000";
      };

      volumes = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = lib.mdDoc "List of volumes to attach to this container.";
        example = literalExpression ''
          [
            "volume_name:/path/inside/container"
            "/path/on/host:/path/inside/container"
          ]
        '';
      };

      workdir = mkOption {
        type = with types; nullOr str;
        default = null;
        description = lib.mdDoc "Override the default working directory for the container.";
        example = "/var/lib/hello_world";
      };

      extraOptions = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = lib.mdDoc "Extra options for {command}`podman run`.";
        example = literalExpression ''
          [
            "--network=host"
          ]
        '';
      };

      autoStart = mkOption {
        type = types.bool;
        default = true;
        description = lib.mdDoc "When enabled, the container is automatically started on boot.";
      };

      dependsOn = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = lib.mdDoc "Define which other containers this one depends on.";
        example = literalExpression ''["nextcloud-db"]'';
      };
    };
  };

  # Convert container config to podman run arguments
  containerToArgs = name: container:
    let
      escapedName = escapeShellArg name;
    in
    [
      "--name=${escapedName}"
      "--log-driver=journald"
      "--cidfile=/tmp/podman-${name}.ctr-id"
    ]
    ++ optionals (container.entrypoint != null) [ "--entrypoint=${escapeShellArg container.entrypoint}" ]
    ++ optionals (container.user != null) [ "--user=${escapeShellArg container.user}" ]
    ++ optionals (container.workdir != null) [ "--workdir=${escapeShellArg container.workdir}" ]
    ++ map (p: "--publish=${escapeShellArg p}") container.ports
    ++ map (v: "--volume=${escapeShellArg v}") container.volumes
    ++ map (e: "--env-file=${escapeShellArg e}") container.environmentFiles
    ++ mapAttrsToList (n: v: "--env=${escapeShellArg n}=${escapeShellArg v}") container.environment
    ++ mapAttrsToList (n: v: "--label=${escapeShellArg n}=${escapeShellArg v}") container.labels
    ++ map escapeShellArg container.extraOptions
    ++ [ container.image ]
    ++ map escapeShellArg container.cmd;
in
{
  options.services.podman = {
    enable = mkEnableOption (lib.mdDoc "Podman containers");

    containers = mkOption {
      default = { };
      type = types.attrsOf (types.submodule containerOptions);
      description = lib.mdDoc "OCI (Docker) containers to run as systemd services.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.enable -> config.homebrew.brews != null || any (p: p.pname or p.name == "podman") config.environment.systemPackages;
        message = "Podman must be installed either via homebrew.brews or environment.systemPackages";
      }
    ];

    # Create user launchd agents for Podman machine and containers
    launchd.user.agents = {
      # Podman machine startup service
      podman-machine = {
        serviceConfig = {
          ProgramArguments = [
            "/bin/bash"
            "-c"
            ''
              # Start podman machine if not already running
              if ! ${pkgs.podman}/bin/podman machine list --format json | ${pkgs.jq}/bin/jq -r '.[].Running' | grep -q true; then
                ${pkgs.podman}/bin/podman machine start
              fi
            ''
          ];
          RunAtLoad = true;
          KeepAlive = false;
          StandardOutPath = "/tmp/podman-machine.log";
          StandardErrorPath = "/tmp/podman-machine.log";
          EnvironmentVariables = {
            PATH = "/usr/local/bin:/usr/bin:/bin:/nix/var/nix/profiles/default/bin";
            HOME = "/Users/${config.system.primaryUser}";
          };
        };
      };
    } // (mapAttrs
      (name: container:
        let
          podmanArgs = containerToArgs name container;
          preStart = optionalString (container.imageFile != null) ''
            ${pkgs.podman}/bin/podman load <${container.imageFile}
          '' + optionalString (container.login.username != null && container.login.passwordFile != null) ''
            ${pkgs.podman}/bin/podman login \
              --username=${escapeShellArg container.login.username} \
              --password-stdin \
              ${escapeShellArg container.login.registry} <${container.login.passwordFile}
          '';
        in
        {
          serviceConfig = {
            ProgramArguments = [
              "/bin/bash"
              "-c"
              ''
                # Wait for podman machine to be ready
                while ! ${pkgs.podman}/bin/podman machine list --format json | ${pkgs.jq}/bin/jq -r '.[].Running' | grep -q true; do
                  sleep 2
                done
                ${preStart}
                # Start the container
                exec ${pkgs.podman}/bin/podman run --rm ${concatStringsSep " " podmanArgs}
              ''
            ];
            KeepAlive = true;
            RunAtLoad = container.autoStart;
            StandardOutPath = "/tmp/podman-${name}.log";
            StandardErrorPath = "/tmp/podman-${name}.log";
            EnvironmentVariables = {
              PATH = "/usr/local/bin:/usr/bin:/bin:/nix/var/nix/profiles/default/bin";
              HOME = "/Users/${config.system.primaryUser}";
            };
          };
        }
      )
      (filterAttrs (name: container: container.autoStart) cfg.containers));

    # Create user-accessible control scripts
    environment.systemPackages =
      let
        controlScript = pkgs.writeShellScriptBin "podman-containers" ''
          set -euo pipefail

          containers=(${concatStringsSep " " (mapAttrsToList (name: _: name) cfg.containers)})

          start_container() {
            local name="$1"
            case "$name" in
              ${concatStringsSep "\n" (mapAttrsToList (name: container:
                "${name}) ${pkgs.podman}/bin/podman run -d ${concatStringsSep " " (containerToArgs name container)} ;;"
              ) cfg.containers)}
              *) echo "Unknown container: $name" >&2; exit 1 ;;
            esac
          }

          stop_container() {
            local name="$1"
            ${pkgs.podman}/bin/podman stop "$name" 2>/dev/null || true
            ${pkgs.podman}/bin/podman rm "$name" 2>/dev/null || true
          }

          case "''${1:-}" in
            start)
              if [[ -n "''${2:-}" ]]; then
                start_container "$2"
              else
                for container in "''${containers[@]}"; do
                  start_container "$container"
                done
              fi
              ;;
            stop)
              if [[ -n "''${2:-}" ]]; then
                stop_container "$2"
              else
                for container in "''${containers[@]}"; do
                  stop_container "$container"
                done
              fi
              ;;
            restart)
              if [[ -n "''${2:-}" ]]; then
                stop_container "$2"
                start_container "$2"
              else
                for container in "''${containers[@]}"; do
                  stop_container "$container"
                  start_container "$container"
                done
              fi
              ;;
            status)
              ${pkgs.podman}/bin/podman ps -a --filter name="^($(IFS='|'; echo "''${containers[*]}"))$"
              ;;
            logs)
              if [[ -z "''${2:-}" ]]; then
                echo "Usage: $0 logs <container-name>" >&2
                exit 1
              fi
              ${pkgs.podman}/bin/podman logs -f "$2"
              ;;
            *)
              echo "Usage: $0 {start|stop|restart|status|logs} [container-name]"
              echo "Available containers: ''${containers[*]}"
              exit 1
              ;;
          esac
        '';
      in
      mkIf (cfg.containers != { }) [ controlScript ];
  };
}
