{ pkgs, ... }:
let
  treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    p.c
    p.cpp
    p.systemverilog
  ]);
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = false;
    withRuby = false;
    initLua = builtins.readFile ./config/init.lua;
    plugins = with pkgs.vimPlugins; [
      nvim-lspconfig
      which-key-nvim
      telescope-nvim
      plenary-nvim # Telescope dependency.
      gitsigns-nvim
      treesitter
    ];
    extraPackages = with pkgs; [
      nil
      nixfmt
      lua-language-server
      stylua
      ripgrep
      fd
      git
      iverilog
      verilator
      typst
      tinymist
      clang-tools
      rust-analyzer
    ];
  };
  home.packages = [
    pkgs.typst
    pkgs.tinymist
  ];
  # Keep the directory symlink layout to avoid Home Manager upgrade collisions.
  xdg.configFile."nvim/lua".source = ./config/lua;
}
