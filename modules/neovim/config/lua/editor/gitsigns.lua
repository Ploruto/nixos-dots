require("gitsigns").setup({
  on_attach = function(buffer)
    local gs = require("gitsigns")
    local map = function(keys, action, description)
      vim.keymap.set("n", keys, action, { buffer = buffer, desc = description })
    end
    map("<leader>gp", gs.preview_hunk, "Preview Git hunk")
    map("<leader>gb", gs.blame_line, "Show Git blame for line")
    map("<leader>gn", function() gs.nav_hunk("next") end, "Next Git hunk")
    map("<leader>gN", function() gs.nav_hunk("prev") end, "Previous Git hunk")
  end,
})
