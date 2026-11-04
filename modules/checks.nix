{ config, lib, ... }:
let
  laptop = config.flake.nixosConfigurations.laptop;
  control = builtins.head (
    builtins.filter (
      package: package.name == "desktop-control"
    ) laptop.config.home-manager.users.garou.home.packages
  );
  defaults =
    (lib.evalModules {
      modules = [ ./desktop-options.nix ];
    }).config.desktop;
  overridden =
    (lib.evalModules {
      modules = [
        ./desktop-options.nix
        {
          desktop.theme.colors.accent = "#89b4fa";
          desktop.fonts.sizes.terminal = 16;
          desktop.fonts.scale = 1.25;
          desktop.display.scale = 1.5;
        }
      ];
    }).config.desktop;
in
{
  perSystem = { pkgs, ... }: {
    checks.brightness-control =
      pkgs.runCommand "brightness-control-check"
        {
          nativeBuildInputs = [
            pkgs.python3
            pkgs.coreutils
          ];
        }
        ''
          python3 ${../tests/brightness.py} ${control}/bin/desktop-control
          touch "$out"
        '';
    checks.desktop-settings =
      assert overridden.theme.colors.accent == "#89b4fa";
      assert overridden.theme.colors.activeBorder == "#89b4fa";
      assert overridden.theme.colors.background == defaults.theme.colors.background;
      assert overridden.theme.colors.text == defaults.theme.colors.text;
      assert overridden.fonts.sizes.terminal == 16;
      assert overridden.fonts.sizes.bar == defaults.fonts.sizes.bar;
      assert defaults.display.scale == "auto";
      assert defaults.fonts.effectiveSizes.terminal == defaults.fonts.sizes.terminal;
      assert overridden.display.scale == 1.5;
      assert overridden.fonts.effectiveSizes.terminal == 20;
      assert overridden.fonts.effectiveSizes.bar == defaults.fonts.sizes.bar * 1.25;
      assert overridden.geometry.padding == defaults.geometry.padding;
      assert overridden.geometry.borderWidth == defaults.geometry.borderWidth;
      pkgs.runCommand "desktop-settings-check" { } "touch $out";

    checks.hyprland-config =
      pkgs.runCommand "hyprland-config-check"
        {
          nativeBuildInputs = [ laptop.pkgs.hyprland ];
        }
        ''
          export HOME="$TMPDIR/home"
          export XDG_RUNTIME_DIR="$TMPDIR/runtime"
          mkdir -p "$HOME" "$XDG_RUNTIME_DIR"
          chmod 700 "$XDG_RUNTIME_DIR"
          Hyprland --verify-config -c ${
            laptop.config.home-manager.users.garou.xdg.configFile."hypr/hyprland.lua".source
          }
          touch "$out"
        '';
  };
}
