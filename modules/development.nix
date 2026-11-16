{ inputs, pkgs, ... }:
let
  unstable = import inputs.unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
in
{
  programs.gh.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
    silent = true;
  };
  programs.mise = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    unstable.devenv
    just
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    clang
    clang-tools
    cmake
    ninja
    pkg-config
    unstable.antigravity-cli
    unstable.antigravity-ide
  ];
}
