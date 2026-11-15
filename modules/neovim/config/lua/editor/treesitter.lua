vim.filetype.add({
  extension = {
    sv = "systemverilog",
    svh = "systemverilog",
  },
})
vim.treesitter.language.register("systemverilog", { "systemverilog" })

-- Nix supplies parsers and queries; Neovim starts highlighting directly.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("editor-treesitter", { clear = true }),
  pattern = { "c", "cpp", "systemverilog" },
  callback = function(event)
    vim.treesitter.start(event.buf)
  end,
})
