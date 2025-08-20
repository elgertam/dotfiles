{ lib, pkgs, ... }:

{
  config = {
    nix.enable = true;

    nix.optimise.automatic = true;

    nix.package = pkgs.nixVersions.stable;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-platforms = lib.mkIf (pkgs.system == "aarch64-darwin") [ "x86_64-darwin" "aarch64-darwin" ];
    };

    nixpkgs.config = { allowUnfree = true; };

    # Enable useful system programs
    programs.zsh.enable = true;
    programs.zsh.enableCompletion = true;
    programs.direnv.enable = true;
    programs.nix-index.enable = true;
  };
}
