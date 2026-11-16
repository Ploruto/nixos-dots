{ lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/desktop.nix
  ];

  networking.hostName = "desktop";
  system.stateVersion = "26.05";
  home-manager.users.garou.home.stateVersion = "26.05";

  # Desktop monitor; keep login-screen and session scaling in sync.
  services.displayManager.noctalia-greeter.settings.output.scales = "DP-3:1.5";
  home-manager.users.garou.programs.umbriel.settings.output.DP-3 = {
    scale = 1.5;
    mode = "2560x1440@144";
  };

  home-manager.users.garou.home.packages = [ pkgs.libsecret ];
  home-manager.users.garou.programs.noctalia.settings = {
    plugins.enabled = [ "ayagmar/headroom" ];
    plugin_settings."ayagmar/headroom" = {
      provider_claude = "off";
      provider_codex = "bar";
      provider_antigravity = "bar";
      max_providers = 2;
      bar_style = "value";
      display = "used";
      window = "tightest";
    };
    widget.headroom.type = "ayagmar/headroom:usage";
  };

  home-manager.users.garou.programs.noctalia.settings.bar.default.end = lib.mkForce [
    "tray"
    "cpu"
    "ram"
    "headroom"
    "notifications"
    "session"
  ];
}
