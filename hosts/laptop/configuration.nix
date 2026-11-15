{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "nixos";
  system.stateVersion = "26.05";
  home-manager.users.garou.home.stateVersion = "26.05";

  # Laptop-only display settings; external monitors use compositor defaults.
  services.displayManager.noctalia-greeter.settings.output.scales = "eDP-1:2";
  home-manager.users.garou.programs.umbriel.settings.output.eDP-1 = {
    scale = 2.0;
    workspaces = 5;
  };
}
