{
  description = "nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        inputs.flake-parts.flakeModules.modules
        ./modules/laptop.nix
        ./modules/desktop-options.nix
        ./modules/desktop.nix
        ./modules/hyprland.nix
        ./modules/terminal.nix
        ./modules/browser.nix
        ./modules/session.nix
        ./modules/shell.nix
        ./modules/checks.nix
      ];
    };
}
