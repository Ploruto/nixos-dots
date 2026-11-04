{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  color = types.strMatching "#[0-9a-fA-F]{6}";
  size = types.addCheck types.number (n: n > 0);
  opacity = types.addCheck types.number (n: n >= 0 && n <= 1);
  palette = config.desktop.theme.palette;
  namedDefaults =
    type: values:
    types.submodule {
      freeformType = types.attrsOf type;
      options = lib.mapAttrs (
        _: value:
        mkOption {
          inherit type;
          default = value;
        }
      ) values;
    };
in
{
  options.desktop = {
    theme.palette = mkOption {
      description = "Named palette; colors include their # prefix.";
      default = { };
      type = namedDefaults color {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };
    theme.colors = mkOption {
      description = "Semantic color roles consumed by apps and shell.";
      default = { };
      type = namedDefaults color {
        background = palette.base;
        panel = palette.mantle;
        surface = palette.surface0;
        selection = palette.surface1;
        text = palette.text;
        muted = palette.subtext0;
        accent = palette.mauve;
        border = palette.surface2;
        activeBorder = config.desktop.theme.colors.accent;
        inactiveBorder = config.desktop.theme.colors.border;
        success = palette.green;
        warning = palette.yellow;
        error = palette.red;
      };
    };
    display.scale = mkOption {
      type = types.either (types.enum [ "auto" ]) size;
      default = "auto";
      description = "Hyprland monitor scale: auto or a positive multiplier. Scales the entire desktop.";
    };
    fonts.scale = mkOption {
      type = size;
      default = 1.0;
      description = "Font multiplier for the terminal, shell and lock screen; does not change application-wide font settings.";
    };
    fonts.effectiveSizes = mkOption {
      type = types.attrsOf size;
      readOnly = true;
      default = lib.mapAttrs (_: value: value * config.desktop.fonts.scale) config.desktop.fonts.sizes;
      description = "Computed font sizes after applying fonts.scale. Set fonts.sizes to change the base sizes.";
    };
    fonts.barFamily = mkOption {
      type = types.str;
      default = "Noto Sans";
      description = "Font used only by the desktop bar.";
    };
    fonts.interfaceFamily = mkOption {
      type = types.str;
      default = "Sans Serif";
      description = "Font for the desktop shell and lock screen.";
    };
    fonts.family = mkOption {
      type = types.str;
      default = "Maple Mono NF";
    };
    fonts.sizes = mkOption {
      description = "Font sizes in points. Terminal Neovim inherits the terminal size.";
      default = { };
      type = namedDefaults size {
        terminal = 16;
        interface = 14;
        bar = 12;
        notification = 14;
        launcher = 16;
        heading = 22;
      };
    };
    geometry = {
      borderWidth = mkOption {
        type = types.ints.unsigned;
        default = 0;
      };
      radius = mkOption {
        type = types.ints.unsigned;
        default = 0;
      };
      gap = mkOption {
        type = types.ints.unsigned;
        default = 0;
      };
      outerGap = mkOption {
        type = types.ints.unsigned;
        default = config.desktop.geometry.gap;
        description = "Space between windows and screen edges, in logical pixels.";
      };
      spacing = mkOption {
        type = types.ints.unsigned;
        default = 0;
      };
      padding = mkOption {
        type = types.ints.unsigned;
        default = 12;
      };
      terminalPadding = mkOption {
        type = types.ints.unsigned;
        default = 0;
      };
      barHeight = mkOption {
        type = types.ints.positive;
        default = 34;
      };
      panelWidth = mkOption {
        type = types.ints.positive;
        default = 720;
      };
      panelHeight = mkOption {
        type = types.ints.positive;
        default = 560;
      };
      notificationWidth = mkOption {
        type = types.ints.positive;
        default = 420;
      };
      rowHeight = mkOption {
        type = types.ints.positive;
        default = 44;
      };
    };
    windows = {
      activeOpacity = mkOption {
        type = opacity;
        default = 1.0;
      };
      inactiveOpacity = mkOption {
        type = opacity;
        default = 1.0;
      };
      fullscreenOpacity = mkOption {
        type = opacity;
        default = 1.0;
      };
      blur = {
        enable = mkOption {
          type = types.bool;
          default = false;
        };
        size = mkOption {
          type = types.ints.positive;
          default = 4;
        };
        passes = mkOption {
          type = types.ints.positive;
          default = 2;
        };
      };
    };
    cursor = {
      theme = mkOption {
        type = types.str;
        default = "Bibata-Modern-Ice";
      };
      size = mkOption {
        type = types.ints.positive;
        default = 24;
      };
    };
    keyboard = {
      modifier = mkOption {
        type = types.str;
        default = "SUPER";
      };
      layout = mkOption {
        type = types.str;
        default = "us";
      };
      options = mkOption {
        type = types.str;
        default = "";
      };
      repeatRate = mkOption {
        type = types.ints.positive;
        default = 35;
      };
      repeatDelay = mkOption {
        type = types.ints.unsigned;
        default = 250;
      };
    };
    session.lockAfterSeconds = mkOption {
      type = types.ints.positive;
      default = 300;
    };
    brightness = {
      stepPercent = mkOption {
        type = types.ints.between 1 100;
        default = 5;
      };
      fineStepPercent = mkOption {
        type = types.ints.between 1 100;
        default = 1;
      };
      fineThresholdPercent = mkOption {
        type = types.ints.between 1 100;
        default = 10;
      };
      minimumPercent = mkOption {
        type = types.ints.between 1 100;
        default = 1;
      };
    };
    wallpaper = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Desktop wallpaper, cropped to fill each screen.";
    };
    shell = {
      bar = {
        position = mkOption {
          type = types.enum [
            "top"
            "bottom"
          ];
          default = "top";
        };
        persistentWorkspaces = mkOption {
          type = types.listOf types.ints.positive;
          default = [ ];
          description = "Workspace buttons shown even when empty.";
        };

      };
      notificationTimeoutMs = mkOption {
        type = types.ints.positive;
        default = 6000;
      };
      notificationHistoryLimit = mkOption {
        type = types.ints.positive;
        default = 100;
      };
    };
    shortcuts = mkOption {
      default = { };
      description = "Global actions keyed by stable IDs, e.g. terminal.open.";
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
            };
            description = mkOption { type = types.str; };
            keys = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Modifiers followed by a key; empty means palette-only.";
            };
            command = mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            dispatcher = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Trusted Hyprland Lua dispatcher expression, exclusive with command.";
            };
            repeat = mkOption {
              type = types.bool;
              default = false;
            };
            locked = mkOption {
              type = types.bool;
              default = false;
            };
            confirm = mkOption {
              type = types.bool;
              default = false;
            };
          };
        }
      );
    };
  };
}
