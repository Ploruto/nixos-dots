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
    gnumake
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
    (unstable.t3code.overrideAttrs (old: {
      # The native speech worker needs these libraries at runtime.
      buildCommand = old.buildCommand + ''
        for program in t3 t3code-desktop; do
          wrapProgram "$out/bin/$program" --prefix LD_LIBRARY_PATH : ${
            unstable.lib.makeLibraryPath [
              unstable.stdenv.cc.cc.lib
              unstable.vulkan-loader
            ]
          }
        done
      '';
    }))
  ];
}
