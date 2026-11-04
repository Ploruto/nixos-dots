-- Packages are installed by Nix; each module below configures one concern.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("editor.options")
require("editor.keymaps")
require("editor.theme")
require("editor.which-key")
require("editor.telescope")
require("editor.gitsigns")
require("editor.lsp")
