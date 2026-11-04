require("telescope").setup({})
local builtin = require("telescope.builtin")
local map = function(keys, action, description)
  vim.keymap.set("n", keys, action, { desc = description })
end
map("<leader>ff", builtin.find_files, "Find files")
map("<leader>fg", builtin.live_grep, "Search project text")
map("<leader>fb", builtin.buffers, "Find open buffers")
map("<leader>fh", builtin.help_tags, "Search help")
map("<leader>fk", builtin.keymaps, "Search all keybindings")
-- Searches start in Neovim's current directory; :cd changes it.
