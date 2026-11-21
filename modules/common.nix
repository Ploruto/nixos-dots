{ config, pkgs, inputs, ... }:
let
  unstable = import inputs.unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = config.nixpkgs.config;
  };
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Run generic Linux binaries downloaded by IDEs, such as Antigravity's backend.
  programs.nix-ld.enable = true;

  programs.steam.enable = true;

  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.xkb.layout = "us";

  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.garou = {
    isNormalUser = true;
    description = "garou";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.firefox = {
    enable = true;
    policies.ExtensionSettings."78272b6fa58f4a1abaac99321d503a20@proton.me" = {
      installation_mode = "normal_installed";
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/proton-pass/latest.xpi";
    };
  };

  environment.systemPackages = [
    pkgs.wget
    unstable.codex
  ];
}
