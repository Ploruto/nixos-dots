{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "desktop";
  system.stateVersion = "26.05";
  home-manager.users.garou.home.stateVersion = "26.05";

  home-manager.users.garou.programs.noctalia.settings.bar.default.end = lib.mkForce [
    "tray"
    "cpu"
    "ram"
    "notifications"
    "session"
  ];
}
