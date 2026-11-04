{ inputs, config, ... }:
{
  imports = [ ../hosts/laptop/desktop.nix ];
  flake.packages.x86_64-linux.desktop-shell =
    config.flake.nixosConfigurations.laptop.config.home-manager.users.garou.programs.quickshell.configs.desktop;
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };

    modules = [
      ../hosts/laptop/configuration.nix
      config.flake.modules.nixos.desktop
    ];

  };
}
