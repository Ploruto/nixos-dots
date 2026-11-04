{ ... }:
{
  flake.modules.homeManager.neovim = { pkgs, ... }: {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = false;
      withRuby = false;
      initLua = builtins.readFile ./config/init.lua;
      plugins = with pkgs.vimPlugins; [
        catppuccin-nvim
        nvim-lspconfig
        which-key-nvim
        telescope-nvim
        plenary-nvim # Telescope dependency.
        gitsigns-nvim
      ];
      extraPackages = with pkgs; [
        nil
        nixfmt
        lua-language-server
        stylua
        ripgrep
        fd
        git
      ];
    };
    xdg.configFile."nvim/lua".source = ./config/lua;
  };
}
