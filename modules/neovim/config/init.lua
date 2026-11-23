-- Packages are installed by Nix; each module below configures one concern.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("editor.options")
require("editor.snacks")
require("editor.theme")
require("editor.treesitter")
require("editor.keymaps")
require("editor.which-key")
require("editor.diffview")
require("editor.gitsigns")
require("editor.lsp")
