{ config, lib, ... }:
let
  d = config.desktop;
  c = d.theme.colors;
  mod = d.keyboard.modifier;
  lua = lib.generators.toLua { };
  inline = lib.generators.mkLuaInline;
  enabled = lib.filterAttrs (_: s: s.enable) d.shortcuts;
  bound = lib.filterAttrs (_: s: s.keys != [ ]) enabled;
  signature =
    s:
    lib.concatStringsSep "+" (
      (lib.sort builtins.lessThan (map lib.toUpper (lib.init s.keys)))
      ++ [ (lib.toUpper (lib.last s.keys)) ]
    );
  signatures = map signature (lib.attrValues bound);
  duplicates = lib.filter (key: lib.count (x: x == key) signatures > 1) (lib.unique signatures);
  directions = {
    H = "left";
    J = "down";
    K = "up";
    L = "right";
  };
  movement = lib.concatMapAttrs (key: direction: {
    "window.focus-${direction}" = {
      description = "Focus ${direction}";
      keys = [
        mod
        key
      ];
      dispatcher = "hl.dsp.focus({ direction = ${lua direction} })";
    };
    "window.move-${direction}" = {
      description = "Move window ${direction}";
      keys = [
        mod
        "SHIFT"
        key
      ];
      dispatcher = "hl.dsp.window.move({ direction = ${lua direction} })";
    };
  }) directions;
  workspaces = lib.mergeAttrsList (
    lib.genList (
      index:
      let
        n = index + 1;
        key = toString (lib.mod n 10);
      in
      {
        "workspace.focus-${toString n}" = {
          description = "Go to workspace ${toString n}";
          keys = [
            mod
            key
          ];
          dispatcher = "hl.dsp.focus({ workspace = ${toString n} })";
        };
        "workspace.move-${toString n}" = {
          description = "Send window to workspace ${toString n}";
          keys = [
            mod
            "SHIFT"
            key
          ];
          dispatcher = "hl.dsp.window.move({ workspace = ${toString n} })";
        };
      }
    ) 10
  );
in
{
  desktop.shortcuts =
    movement
    // workspaces
    // {
      "window.fullscreen" = {
        description = "Toggle fullscreen";
        keys = [
          mod
          "F"
        ];
        dispatcher = "hl.dsp.window.fullscreen({ mode = 'fullscreen', action = 'toggle' })";
      };
      "window.close" = {
        description = "Close window";
        keys = [
          mod
          "Q"
        ];
        dispatcher = "hl.dsp.window.close()";
      };
      "window.float" = {
        description = "Toggle floating window";
        keys = [
          mod
          "SHIFT"
          "Space"
        ];
        dispatcher = "hl.dsp.window.float({ action = 'toggle' })";
      };
      "window.scratchpad" = {
        description = "Toggle scratchpad";
        keys = [
          mod
          "S"
        ];
        dispatcher = "hl.dsp.workspace.toggle_special('scratchpad')";
      };
      "window.to-scratchpad" = {
        description = "Send window to scratchpad";
        keys = [
          mod
          "SHIFT"
          "S"
        ];
        dispatcher = "hl.dsp.window.move({ workspace = 'special:scratchpad' })";
      };
      "window.resize-left" = {
        description = "Shrink window horizontally";
        keys = [
          mod
          "CTRL"
          "H"
        ];
        repeat = true;
        dispatcher = "hl.dsp.window.resize({ x = -30, y = 0, relative = true })";
      };
      "window.resize-right" = {
        description = "Grow window horizontally";
        keys = [
          mod
          "CTRL"
          "L"
        ];
        repeat = true;
        dispatcher = "hl.dsp.window.resize({ x = 30, y = 0, relative = true })";
      };
      "window.resize-up" = {
        description = "Shrink window vertically";
        keys = [
          mod
          "CTRL"
          "K"
        ];
        repeat = true;
        dispatcher = "hl.dsp.window.resize({ x = 0, y = -30, relative = true })";
      };
      "window.resize-down" = {
        description = "Grow window vertically";
        keys = [
          mod
          "CTRL"
          "J"
        ];
        repeat = true;
        dispatcher = "hl.dsp.window.resize({ x = 0, y = 30, relative = true })";
      };
    };

  flake.modules.nixos.hyprland = { ... }: {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };
    assertions = [
      {
        assertion = duplicates == [ ];
        message = "Duplicate desktop shortcuts: ${lib.concatStringsSep ", " duplicates}";
      }
    ]
    ++ lib.mapAttrsToList (id: s: {
      assertion = (s.command != [ ]) != (s.dispatcher != null);
      message = "desktop.shortcuts.${id}: provide exactly one of command or dispatcher.";
    }) enabled;
  };

  flake.modules.homeManager.hyprland = { pkgs, ... }: {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      configType = "lua";
      # UWSM owns environment import and the session lifecycle.
      systemd.enable = false;
      settings = {
        on._args = [
          "hyprland.start"
          (inline ''
            function()
                      hl.exec_cmd("${pkgs.hyprland}/bin/hyprctl setcursor ${d.cursor.theme} ${toString d.cursor.size}")
                      if os.getenv("UWSM_FINALIZE_VARNAMES") then
                        hl.exec_cmd("${pkgs.uwsm}/bin/uwsm finalize")
                      end
                    end'')
        ];
        monitor = {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = d.display.scale;
        };
        config = {
          general = {
            gaps_in = d.geometry.gap;
            gaps_out = d.geometry.outerGap;
            border_size = d.geometry.borderWidth;
            layout = "dwindle";
            col = {
              active_border = c.activeBorder;
              inactive_border = c.inactiveBorder;
            };
          };
          decoration = {
            rounding = d.geometry.radius;
            active_opacity = d.windows.activeOpacity;
            inactive_opacity = d.windows.inactiveOpacity;
            fullscreen_opacity = d.windows.fullscreenOpacity;
            blur = {
              enabled = d.windows.blur.enable;
              size = d.windows.blur.size;
              passes = d.windows.blur.passes;
            };
            shadow.enabled = false;
          };
          cursor.enable_hyprcursor = false;
          animations.enabled = false;
          input = {
            kb_layout = d.keyboard.layout;
            kb_options = d.keyboard.options;
            repeat_rate = d.keyboard.repeatRate;
            repeat_delay = d.keyboard.repeatDelay;
            follow_mouse = 0;
            touchpad = {
              natural_scroll = true;
              tap_to_click = true;
            };
          };
          dwindle.preserve_split = true;
          misc = {
            disable_hyprland_logo = true;
            force_default_wallpaper = 0;
          };
        };
        bind =
          lib.mapAttrsToList (_: s: {
            _args = [
              (lib.concatStringsSep " + " s.keys)
              (inline (
                if s.dispatcher != null then
                  s.dispatcher
                else
                  "hl.dsp.exec_cmd(${lua (lib.escapeShellArgs s.command)})"
              ))
              {
                repeating = s.repeat;
                locked = s.locked;
              }
            ];
          }) bound
          ++ [
            {
              _args = [
                "${mod} + mouse:272"
                (inline "hl.dsp.window.drag()")
                { mouse = true; }
              ];
            }
            {
              _args = [
                "${mod} + mouse:273"
                (inline "hl.dsp.window.resize()")
                { mouse = true; }
              ];
            }
          ];
      };
    };
  };
}
