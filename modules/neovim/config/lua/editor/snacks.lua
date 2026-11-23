local snacks = require("snacks")

-- Set up early so directory buffers and large files are handled on startup.
snacks.setup({
  bigfile = { enabled = true },
  explorer = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true },
  picker = { enabled = true },
  terminal = { enabled = true },
  scroll = {
    enabled = true,
    animate = { duration = { step = 10, total = 150 }, easing = "outQuad" },
    -- Keep side-by-side review panes aligned without scroll animations.
    filter = function(buf)
      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if vim.wo[win].diff then
          return false
        end
      end
      return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and vim.bo[buf].buftype ~= "terminal"
    end,
  },
})

local map = function(keys, action, description)
  vim.keymap.set("n", keys, action, { desc = description })
end

map("<leader>e", function()
  snacks.explorer()
end, "File explorer")
map("<leader>ff", function()
  snacks.picker.files()
end, "Find files")
map("<leader>fg", function()
  snacks.picker.grep()
end, "Search project text")
map("<leader>fb", function()
  snacks.picker.buffers()
end, "Find open buffers")
map("<leader>fh", function()
  snacks.picker.help()
end, "Search help")
map("<leader>fk", function()
  snacks.picker.keymaps()
end, "Search all keybindings")
map("<leader>gs", function()
  snacks.picker.git_status()
end, "Find changed files")
map("<leader>gd", function()
  snacks.picker.git_diff()
end, "Find Git diff hunks")
map("<leader>gg", function()
  snacks.lazygit()
end, "Open LazyGit")
map("<leader>ft", function()
  snacks.terminal()
end, "Toggle terminal")
map("<leader>gy", function()
  local path = vim.fn.expand("%:.")
  if path == "" or vim.bo.buftype ~= "" then
    vim.notify("Open a file to copy its location", vim.log.levels.WARN)
    return
  end
  local location = path .. ":" .. vim.api.nvim_win_get_cursor(0)[1]
  vim.fn.setreg("+", location)
  vim.notify("Copied " .. location)
end, "Copy file:line to clipboard")
