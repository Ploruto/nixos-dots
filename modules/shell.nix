{ config, lib, ... }:
let
  d = config.desktop;
  mod = d.keyboard.modifier;
  target = "wayland-session@hyprland.desktop.target";
  ipc = mode: [
    "qs"
    "-c"
    "desktop"
    "ipc"
    "call"
    "desktop"
    "toggle"
    mode
  ];
  shortcuts = lib.mapAttrsToList (id: s: {
    inherit id;
    inherit (s)
      description
      keys
      command
      dispatcher
      confirm
      ;
  }) (lib.filterAttrs (_: s: s.enable) d.shortcuts);
in
{
  desktop.shortcuts = {
    "shell.launcher" = {
      description = "Applications and commands";
      keys = [
        mod
        "Space"
      ];
      command = ipc "launcher";
    };
    "shell.controls" = {
      description = "Desktop controls";
      keys = [
        mod
        "C"
      ];
      command = ipc "controls";
    };
    "shell.shortcuts" = {
      description = "Search keyboard shortcuts";
      keys = [
        mod
        "slash"
      ];
      command = ipc "shortcuts";
    };
    "shell.notifications" = {
      description = "Notification history";
      keys = [
        mod
        "N"
      ];
      command = ipc "notifications";
    };
    "shell.clipboard" = {
      description = "Clipboard history";
      keys = [
        mod
        "V"
      ];
      command = ipc "clipboard";
    };
    "shell.session" = {
      description = "Session and power menu";
      keys = [
        mod
        "SHIFT"
        "Escape"
      ];
      command = ipc "session";
    };
    "shell.restart" = {
      description = "Restart desktop shell";
      command = [
        "systemctl"
        "--user"
        "restart"
        "quickshell.service"
      ];
    };
    "shell.do-not-disturb" = {
      description = "Toggle do not disturb";
      command = [
        "qs"
        "-c"
        "desktop"
        "ipc"
        "call"
        "desktop"
        "dnd"
      ];
    };
  };

  flake.modules.homeManager.shell =
    { config, pkgs, ... }:
    let
      shell = pkgs.runCommand "desktop-shell" { } ''
        mkdir -p "$out"
        cp -r ${../shell}/. "$out/"
        cp ${pkgs.writeText "Config.qml" ''
          pragma Singleton
          import QtQuick
          QtObject {
            readonly property var settings: (${
              builtins.toJSON {
                colors = d.theme.colors;
                fonts = d.fonts;
                geometry = d.geometry;
                bar = d.shell.bar;
                wallpaper = if d.wallpaper == null then "" else "file://${d.wallpaper}";
                notifications = d.shell;
                inherit shortcuts;
              }
            })
          }
        ''} "$out/Config.qml"
      '';
      clipboard = pkgs.writeShellApplication {
        name = "desktop-clipboard";
        runtimeInputs = [
          pkgs.cliphist
          pkgs.wl-clipboard
        ];
        text = ''
          if [[ ! "''${1:-}" =~ ^[0-9]+$ ]]; then
            echo "Expected a clipboard entry ID" >&2
            exit 1
          fi
          printf '%s\n' "$1" | cliphist decode | wl-copy
        '';
      };
    in
    {
      home.packages = [
        pkgs.cliphist
        clipboard
      ];
      programs.quickshell = {
        enable = true;
        activeConfig = "desktop";
        configs.desktop = shell;
        systemd = {
          enable = true;
          inherit target;
        };
      };
      systemd.user.services.quickshell = {
        Unit.PartOf = [ target ];
        Service = {
          RestartSec = 2;
          Environment = [
            "QT_QUICK_CONTROLS_STYLE=Basic"
            "PATH=${config.home.profileDirectory}/bin:/run/wrappers/bin:/run/current-system/sw/bin"
          ];
          # Ensure a change to generated settings restarts the running shell.
        };
        Unit.X-Restart-Triggers = [ "${shell}" ];
      };
      systemd.user.services.desktop-clipboard = {
        Unit = {
          Description = "Clipboard history (text only)";
          PartOf = [ target ];
          After = [ target ];
        };
        Service = {
          ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
          Restart = "on-failure";
        };
        Install.WantedBy = [ target ];
      };
    };
}
