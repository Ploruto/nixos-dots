{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.wallpapers.homeManagerModules.default
  ];
  wallpapers = {
    enable = true;
    directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
  };
  home.file."Pictures/Wallpapers/saitama-background.png".source = ../images/saitama-background.png;
  programs.noctalia = {
    enable = true;
    package = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.noctalia;
    systemd.enable = true;
    checkConfig = true;
    settings = {
      accessibility.ui_scale = 1.5;
      shell = {
        font_family = "Inter";
        polkit_agent = true;
        card_borders = false;
        input_borders = false;
        animation.speed = 2.1;
        panel.transparency_mode = "glass";
        greeter_sync.auto_sync = true;
      };
      theme = {
        source = "wallpaper";
        mode = "dark";
        templates.builtin_ids = [
          "umbriel"
          "gtk3"
          "gtk4"
          "qt"
          "kcolorscheme"
        ];
        # The built-in Kitty hook touches kitty.conf, which is read-only under
        # Home Manager. Render the same upstream template and only reload Kitty.
        templates.user.kitty = {
          input_path = "${inputs.noctalia}/assets/templates/kitty/kitty.conf";
          output_path = "${config.xdg.configHome}/kitty/themes/noctalia.conf";
          post_hook = "${pkgs.procps}/bin/pkill -USR1 -x kitty || true";
        };
        templates.user.neovim = {
          input_path = ./neovim/noctalia-template.lua;
          output_path = "${config.xdg.stateHome}/nvim/noctalia-colors.lua";
          post_hook = "${pkgs.procps}/bin/pkill -USR1 -x nvim || true";
        };
      };
      wallpaper = {
        directory = "${config.home.homeDirectory}/Pictures/Wallpapers";
        default.path = "${config.home.homeDirectory}/Pictures/Wallpapers/saitama-background.png";
      };
      bar.default = {
        position = "top";
        scale = 1.4;
        thickness = 35;
        margin_edge = 0;
        margin_ends = 0;
        radius = 0;
        background_opacity = 0.65;
        compositor_blur = true;
        capsule = false;
        shadow = false;
        padding = 10;
        widget_spacing = 8;
        start = [
          "control-center"
          "clock"
          "media"
        ];
        center = [ "workspaces" ];
        end = [
          "tray"
          "cpu"
          "ram"
          "battery"
          "notifications"
          "session"
        ];
      };
      widget = {
        workspaces = {
          label_source = "name";
          show_labels = true;
          active_pill_size = 2.4;
          pill_scale = 1.0;
        };
        media = {
          max_length = 140;
          hide_when_no_media = true;
        };
        cpu = {
          type = "sysmon";
          stat = "cpu_usage";
          visualization = "gauge";
          show_value = true;
        };
        ram = {
          type = "sysmon";
          stat = "ram_pct";
          visualization = "gauge";
          show_value = true;
        };
        tray.drawer = true;
      };
      lockscreen = {
        blurred_desktop = true;
        lock_before_suspend = true;
      };
      idle.behavior = {
        lock = {
          enabled = true;
          timeout = 300;
          action = "lock";
        };
        screen-off = {
          enabled = true;
          timeout = 360;
          action = "screen_off";
        };
      };
    };
  };
  systemd.user.services.noctalia.Service.Environment = [
    "PATH=${config.home.profileDirectory}/bin:/run/wrappers/bin:/run/current-system/sw/bin"
  ];
  # Saved GUI values take precedence over the declarative configuration.
  # Archive the previous desktop once; subsequent GUI edits remain untouched.
  home.activation.migrateNoctaliaToUmbriel = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    stateDir="${config.xdg.stateHome}/noctalia"
    if [ -z "''${DRY_RUN_CMD:-}" ] && [ ! -e "$stateDir/umbriel-migration-complete" ]; then
      run mkdir -p "$stateDir"
      if [ -f "$stateDir/settings.toml" ]; then
        backupDir=$(mktemp -d "$stateDir/before-umbriel.XXXXXXXX")
        run mv "$stateDir/settings.toml" "$backupDir/settings.toml"
      fi
      run touch "$stateDir/umbriel-migration-complete"
    fi
  '';
}
