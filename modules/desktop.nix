{ inputs, pkgs, ... }:
let
  desktopPackages = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.umbriel.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  programs.umbriel = {
    enable = true;
    package = desktopPackages.umbriel;
    portalPackage = desktopPackages.xdg-desktop-portal-umbriel;
  };
  services.displayManager.noctalia-greeter = {
    enable = true;
    package = desktopPackages.noctalia-greeter;
    passwordless-sync-users = [ "garou" ];
    settings = {
      session.default = "umbriel";
      user.default = "garou";
      appearance.font_family = "Inter";
      cursor = {
        theme = "Bibata-Modern-Ice";
        size = 24;
        path = pkgs.bibata-cursors;
      };
      keyboard.layout = "us";
    };
  };

  fonts.packages = with pkgs; [
    inter
    maple-mono.NF
    noto-fonts
    noto-fonts-color-emoji
  ];
  programs.git.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.garou = {
      imports = [
        ./umbriel.nix
        ./shell.nix
        ./terminal.nix
        ./development.nix
        ./neovim
        ./browser.nix
        ./thunderbird.nix
      ];
      home = {
        username = "garou";
        homeDirectory = "/home/garou";
        sessionVariables.EDITOR = "nvim";
        packages = with pkgs; [
          nautilus
          pavucontrol
          wl-clipboard
          libnotify
          spotify
        ];
      };
      home.pointerCursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 24;
        x11.enable = true;
      };
      fonts.fontconfig.enable = true;
      xdg.enable = true;
      programs.imv.enable = true;
    };
  };
}
