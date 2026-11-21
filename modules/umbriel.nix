{ inputs, ... }:
let
  # Reuse upstream's complete starting bindings and integration rules.
  defaults = builtins.fromTOML (builtins.readFile "${inputs.umbriel}/examples/config.toml");
in
{
  imports = [ inputs.umbriel.homeModules.default ];
  programs.umbriel = {
    enable = true;
    # Installed system-wide by the NixOS module.
    package = null;
    settings = {
      include.optional.files = [ "noctalia.toml" ];
      layout = {
        mode = "scrolling";
        gap = 6;
      };
      appearance = {
        prefer_no_csd = true;
        border_width = 4;
        corner_radius = 12;
        opaque_fullscreen = true;
        blur = {
          enabled = true;
          optimized = true;
          passes = 3;
          radius = 5;
        };
      };
      input.keyboard.layout = "us";
      keybinds = builtins.removeAttrs defaults.keybinds [ "Mod+Q" ] // {
        "Mod+W" = {
          action = "window-close";
          repeat = false;
        };
        "Mod+Space" = "spawn noctalia msg panel-toggle launcher";
        "Mod+V" = "spawn noctalia msg panel-toggle clipboard";
        "Mod+Shift+L" = "spawn noctalia msg session lock";
        "Mod+B" = "spawn firefox";
        "Mod+Alt+W" = "spawn noctalia msg panel-toggle wallpaper";
        "Mod+Alt+N" = "spawn noctalia msg wallpaper-next";
        "Mod+Alt+Shift+N" = "spawn noctalia msg wallpaper-previous";
        "Print" = "spawn noctalia msg screenshot-region";
        "Alt+Print" = "spawn noctalia msg plugin noctalia/screen_recorder:service all toggle";
      };
      layer_rule = defaults.layer_rule;
      window_rule = defaults.window_rule ++ [
        {
          match.is_focused = false;
          opacity = 0.92;
        }
      ];
    };
  };
  # The compositor publishes the Wayland environment before starting this target.
  wayland.systemd.target = "umbriel-session.target";
}
