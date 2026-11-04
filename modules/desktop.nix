{ inputs, config, ... }:
let
  modules = config.flake.modules;
  desktop = config.desktop;
in
{
  flake.modules.nixos.desktop = { pkgs, ... }: {
    imports = [
      inputs.home-manager.nixosModules.home-manager
      modules.nixos.hyprland
      modules.nixos.session
    ];
    fonts.packages = [
      pkgs.maple-mono.NF
      pkgs.noto-fonts
      pkgs.noto-fonts-color-emoji
    ];
    programs.git.enable = true;
    services.upower.enable = true;
    # Standalone desktop services previously enabled by the GNOME module.
    services.power-profiles-daemon.enable = true;
    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.garou = {
        imports = [
          modules.homeManager.hyprland
          modules.homeManager.terminal
          modules.homeManager.neovim
          modules.homeManager.browser
          modules.homeManager.session
          modules.homeManager.shell
        ];
        home = {
          username = "garou";
          homeDirectory = "/home/garou";
          stateVersion = "26.05";
          sessionVariables = {
            EDITOR = "nvim";
            NIXOS_OZONE_WL = "1";
          };
        };
        home.pointerCursor = {
          package = pkgs.bibata-cursors;
          name = desktop.cursor.theme;
          size = desktop.cursor.size;
          x11.enable = true;
        };
        fonts.fontconfig.enable = true;
        xdg.enable = true;
        # Avoid replacing existing GNOME GTK files or Firefox profiles.
        dconf.settings."org/gnome/desktop/interface" = {
          cursor-theme = desktop.cursor.theme;
          cursor-size = desktop.cursor.size;
          color-scheme = "prefer-dark";
        };
      };
    };
  };
}
