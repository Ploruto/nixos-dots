{
  description = "Garou's NixOS machines — Umbriel and Noctalia";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia/v5.4.1";
      inputs.nixpkgs.follows = "unstable";
    };
    umbriel = {
      url = "github:noctalia-dev/umbriel/e0da106317b10831e709618f52cc00bd7a9dc793";
      inputs.nixpkgs.follows = "unstable";
    };
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter/v1.7.0";
      inputs.nixpkgs.follows = "unstable";
    };
    wallpapers.url = "github:evgen2571/wallpapers";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    {
      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/laptop/configuration.nix ];
      };
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/desktop/configuration.nix ];
      };
      checks.x86_64-linux = import ./modules/checks.nix { inherit inputs; };
    };
}
