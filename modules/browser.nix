{ config, ... }:
{
  desktop.shortcuts."browser.open" = {
    description = "Open Firefox";
    keys = [
      config.desktop.keyboard.modifier
      "B"
    ];
    command = [ "firefox" ];
  };
  flake.modules.homeManager.browser = { ... }: {
    # Firefox is installed by the host; keep its existing profile.
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    };
  };
}
