{ config, ... }:
let
  d = config.desktop;
  mod = d.keyboard.modifier;
  target = "wayland-session@hyprland.desktop.target";
in
{
  desktop.shortcuts = {
    "session.lock" = {
      description = "Lock screen";
      keys = [
        mod
        "Escape"
      ];
      command = [ "desktop-lock" ];
    };
    "session.suspend" = {
      description = "Suspend laptop";
      command = [
        "systemctl"
        "suspend"
      ];
      confirm = true;
    };
    "session.logout" = {
      description = "Log out of Hyprland";
      command = [
        "uwsm"
        "stop"
      ];
      confirm = true;
    };
    "session.reboot" = {
      description = "Restart computer";
      command = [
        "systemctl"
        "reboot"
      ];
      confirm = true;
    };
    "session.shutdown" = {
      description = "Shut down computer";
      command = [
        "systemctl"
        "poweroff"
      ];
      confirm = true;
    };
    "audio.raise" = {
      description = "Raise volume";
      keys = [ "XF86AudioRaiseVolume" ];
      command = [
        "desktop-control"
        "volume-up"
      ];
      repeat = true;
      locked = true;
    };
    "audio.lower" = {
      description = "Lower volume";
      keys = [ "XF86AudioLowerVolume" ];
      command = [
        "desktop-control"
        "volume-down"
      ];
      repeat = true;
      locked = true;
    };
    "audio.mute" = {
      description = "Toggle audio mute";
      keys = [ "XF86AudioMute" ];
      command = [
        "desktop-control"
        "mute"
      ];
      locked = true;
    };
    "audio.microphone" = {
      description = "Toggle microphone mute";
      keys = [ "XF86AudioMicMute" ];
      command = [
        "desktop-control"
        "mic"
      ];
      locked = true;
    };
    "brightness.raise" = {
      description = "Raise brightness";
      keys = [ "XF86MonBrightnessUp" ];
      command = [
        "desktop-control"
        "brightness-up"
      ];
      repeat = true;
      locked = true;
    };
    "brightness.lower" = {
      description = "Lower brightness";
      keys = [ "XF86MonBrightnessDown" ];
      command = [
        "desktop-control"
        "brightness-down"
      ];
      repeat = true;
      locked = true;
    };
    "media.play-pause" = {
      description = "Play or pause media";
      keys = [ "XF86AudioPlay" ];
      command = [
        "playerctl"
        "play-pause"
      ];
    };
    "media.next" = {
      description = "Next track";
      keys = [ "XF86AudioNext" ];
      command = [
        "playerctl"
        "next"
      ];
    };
    "media.previous" = {
      description = "Previous track";
      keys = [ "XF86AudioPrev" ];
      command = [
        "playerctl"
        "previous"
      ];
    };
    "network.settings" = {
      description = "Network connections";
      command = [
        "kitty"
        "--"
        "nmtui"
      ];
    };
    "bluetooth.settings" = {
      description = "Bluetooth devices";
      command = [ "blueman-manager" ];
    };
    "audio.settings" = {
      description = "Audio devices and application volumes";
      command = [ "pavucontrol" ];
    };
    "files.open" = {
      description = "Open file manager";
      keys = [
        mod
        "E"
      ];
      command = [ "nautilus" ];
    };
    "screenshot.region" = {
      description = "Annotate screenshot of selected region";
      keys = [ "Print" ];
      command = [ "desktop-screenshot" ];
    };
  };

  flake.modules.nixos.session = { ... }: {
    programs.hyprlock.enable = true;
  };

  flake.modules.homeManager.session =
    { pkgs, lib, ... }:
    let
      hex = value: "rgb(${lib.removePrefix "#" value})";
      lock = pkgs.writeShellApplication {
        name = "desktop-lock";
        runtimeInputs = [
          pkgs.procps
          pkgs.hyprlock
        ];
        text = ''
          if ! pgrep -u "$UID" -x hyprlock >/dev/null; then
            exec hyprlock
          fi
        '';
      };
      control = pkgs.writeShellApplication {
        name = "desktop-control";
        runtimeInputs = [
          pkgs.wireplumber
          pkgs.brightnessctl
          pkgs.quickshell
          pkgs.coreutils
        ];
        text = ''
          case "''${1:-}" in
            volume-up) wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+; value=$(wpctl get-volume @DEFAULT_AUDIO_SINK@) ;;
            volume-down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; value=$(wpctl get-volume @DEFAULT_AUDIO_SINK@) ;;
            mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; value=$(wpctl get-volume @DEFAULT_AUDIO_SINK@) ;;
            mic) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; value="Microphone: $(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)" ;;
            brightness-up)
              brightnessctl --class=backlight -q set +${toString d.brightness.stepPercent}%
              value="Brightness: $(brightnessctl --class=backlight -m | cut -d, -f4)"
              ;;
            brightness-down)
              current=$(brightnessctl --class=backlight get)
              maximum=$(brightnessctl --class=backlight max)
              percentage=$(( (current * 100 + maximum / 2) / maximum ))
              threshold=$(( (maximum * ${toString d.brightness.fineThresholdPercent} + 99) / 100 ))
              minimum=$(( (maximum * ${toString d.brightness.minimumPercent} + 99) / 100 ))
              if (( percentage > ${toString d.brightness.fineThresholdPercent} )); then
                step=$(( (maximum * ${toString d.brightness.stepPercent} + 99) / 100 ))
                target=$(( current - step ))
                # Land on the threshold rather than skipping the fine range.
                if (( target < threshold )); then target=$threshold; fi
              else
                step=$(( (maximum * ${toString d.brightness.fineStepPercent} + 99) / 100 ))
                target=$(( current - step ))
              fi
              if (( target < minimum )); then target=$minimum; fi
              # A down press must never brighten a display already below the minimum.
              if (( target > current )); then target=$current; fi
              brightnessctl --class=backlight -q set "$target"
              value="Brightness: $(brightnessctl --class=backlight -m | cut -d, -f4)"
              ;;
            *) echo "Unknown desktop control" >&2; exit 1 ;;
          esac
          qs -c desktop ipc call desktop osd "$value" >/dev/null 2>&1 || true
        '';
      };
      screenshot = pkgs.writeShellApplication {
        name = "desktop-screenshot";
        runtimeInputs = [
          pkgs.grim
          pkgs.slurp
          pkgs.wl-clipboard
          pkgs.satty
          pkgs.coreutils
        ];
        text = ''
          region=$(slurp) || exit 0
          mkdir -p "$HOME/Pictures/Screenshots"
          grim -g "$region" -t ppm - | satty --filename - \
            --copy-command "wl-copy --type image/png" \
            --output-filename "$HOME/Pictures/Screenshots/screenshot-%Y-%m-%d_%H-%M-%S.png" \
            --actions-on-enter save-to-clipboard,exit \
            --actions-on-escape exit \
            --corner-roundness ${toString d.geometry.radius}
        '';
      };
    in
    {
      home.packages = with pkgs; [
        lock
        control
        screenshot
        satty
        brightnessctl
        playerctl
        pavucontrol
        nautilus
        networkmanager
        blueman
        wl-clipboard
        libnotify
      ];
      programs.imv = {
        enable = true;
        settings.options.background = lib.removePrefix "#" d.theme.colors.background;
      };
      xdg.mimeApps = {
        enable = true;
        defaultApplications = lib.genAttrs [
          "image/png"
          "image/jpeg"
          "image/webp"
          "image/gif"
          "image/bmp"
          "image/tiff"
          "image/svg+xml"
          "image/avif"
        ] (_: [ "imv.desktop" ]);
      };
      services.hypridle = {
        enable = true;
        systemdTarget = target;
        settings = {
          general = {
            lock_cmd = "${lock}/bin/desktop-lock";
            before_sleep_cmd = "${lock}/bin/desktop-lock";
            after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
          };
          listener = [
            {
              timeout = d.session.lockAfterSeconds;
              on-timeout = "${lock}/bin/desktop-lock";
            }
          ];
        };
      };
      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            ignore_empty_input = true;
          };
          background = [
            {
              monitor = "";
              color = hex d.theme.colors.background;
            }
          ];
          input-field = [
            {
              monitor = "";
              size = "320, 56";
              position = "0, -40";
              font_family = d.fonts.interfaceFamily;
              font_color = hex d.theme.colors.text;
              inner_color = hex d.theme.colors.surface;
              outer_color = hex d.theme.colors.accent;
              outline_thickness = d.geometry.borderWidth;
              rounding = d.geometry.radius;
              placeholder_text = "Password";
              fade_on_empty = false;
            }
          ];
          label = [
            {
              monitor = "";
              text = "$USER";
              font_family = d.fonts.interfaceFamily;
              font_size = builtins.floor (d.fonts.effectiveSizes.heading + 0.5);
              color = hex d.theme.colors.text;
              position = "0, 70";
            }
          ];
        };
      };
      systemd.user.services.desktop-polkit = {
        Unit = {
          Description = "Desktop authentication agent";
          PartOf = [ target ];
          After = [ target ];
        };
        Service = {
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
        };
        Install.WantedBy = [ target ];
      };
    };
}
