# Flake-parts module: shared desktop overrides for this configuration.
{ ... }:
{
  desktop = {
    wallpaper = ../../images/saitama-background.png;
    shell.bar = {
      position = "bottom";
      persistentWorkspaces = [
        1
        2
        3
        4
        5
      ];
    };
    fonts.sizes = {
      terminal = 20;
      interface = 16;
      bar = 14;
      notification = 16;
      launcher = 20;
      heading = 22;
    };
    geometry = {
      borderWidth = 4;
      radius = 8;
      gap = 8;
      outerGap = 12;
      terminalPadding = 12;
      spacing = 0;
    };
    windows = {
      activeOpacity = 0.96;
      inactiveOpacity = 0.90;
      fullscreenOpacity = 1.0;
      blur = {
        enable = true;
        size = 4;
        passes = 3;
      };
    };
    # theme.colors.accent = "#89b4fa";
    # With lib in this module's arguments:
    # shortcuts."terminal.open".keys = lib.mkForce [ "SUPER" "Return" ];
  };
}
