require("which-key").setup({
  preset = "classic",
  icons = { mappings = false },
  spec = {
    { "<leader>f", group = "Find" },
    { "<leader>c", group = "Code" },
    { "<leader>g", group = "Git" },
  },
})
