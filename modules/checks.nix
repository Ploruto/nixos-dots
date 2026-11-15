{ inputs }:
let
  pkgs = inputs.unstable.legacyPackages.x86_64-linux;
  system = inputs.self.nixosConfigurations.laptop;
  home = system.config.home-manager.users.garou;
in
{
  desktop-config =
    pkgs.runCommand "desktop-config-check"
      {
        nativeBuildInputs = [
          pkgs.umbriel
          pkgs.bash
          pkgs.gawk
        ];
      }
      ''
        export HOME="$TMPDIR/home"
        export XDG_RUNTIME_DIR="$TMPDIR/runtime"
        mkdir -p "$HOME" "$XDG_RUNTIME_DIR"
        chmod 700 "$XDG_RUNTIME_DIR"
        umbriel config validate -c ${home.xdg.configFile."umbriel/config.toml".source}
        # This source is validated by Noctalia's upstream Home Manager module.
        test -s ${home.xdg.configFile."noctalia/config.toml".source}
        test -f ${home.xdg.configFile."nvim/lua".source}/editor/options.lua
        # Theme hooks must accept the read-only Home Manager base configurations.
        export XDG_CONFIG_HOME="$TMPDIR/config"
        mkdir -p "$XDG_CONFIG_HOME/umbriel" "$XDG_CONFIG_HOME/kitty/themes"
        ln -s ${home.xdg.configFile."umbriel/config.toml".source} "$XDG_CONFIG_HOME/umbriel/config.toml"
        ln -s ${home.xdg.configFile."kitty/kitty.conf".source} "$XDG_CONFIG_HOME/kitty/kitty.conf"
        touch "$XDG_CONFIG_HOME/kitty/themes/noctalia.conf"
        bash ${inputs.noctalia}/assets/templates/umbriel/apply.sh
        # Kitty uses the upstream color template with a reload-only hook,
        # because the built-in apply hook touches this read-only file.
        grep -Fx 'include themes/noctalia.conf' "$XDG_CONFIG_HOME/kitty/kitty.conf"
        touch "$out"
      '';
}
