{ inputs, pkgs, ... }:
let
  unstable = import inputs.unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = pkgs.config;
  };
in
{
  programs.gh.enable = true;
  programs.mise = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
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
