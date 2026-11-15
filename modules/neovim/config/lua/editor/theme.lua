local M = {}
local theme_path = vim.fn.stdpath("state") .. "/noctalia-colors.lua"

local function apply()
  local ok, colors = pcall(dofile, theme_path)
  if not ok or type(colors) ~= "table" then
    return
  end

  vim.api.nvim_set_hl(0, "Normal", { fg = colors.fg, bg = colors.bg })
  vim.api.nvim_set_hl(0, "NormalFloat", { fg = colors.fg, bg = colors.bg_alt })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.fg_muted, bg = colors.bg_alt })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = colors.bg_alt })
  vim.api.nvim_set_hl(0, "LineNr", { fg = colors.fg_muted })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = colors.accent, bold = true })
  vim.api.nvim_set_hl(0, "Visual", { bg = colors.bg_highlight })
  vim.api.nvim_set_hl(0, "Search", { fg = colors.bg, bg = colors.tertiary })
  vim.api.nvim_set_hl(0, "IncSearch", { fg = colors.bg, bg = colors.accent, bold = true })
  vim.api.nvim_set_hl(0, "Comment", { fg = colors.fg_muted, italic = true })
  vim.api.nvim_set_hl(0, "Constant", { fg = colors.tertiary })
  vim.api.nvim_set_hl(0, "String", { fg = colors.secondary })
  vim.api.nvim_set_hl(0, "Function", { fg = colors.accent })
  vim.api.nvim_set_hl(0, "Statement", { fg = colors.tertiary })
  vim.api.nvim_set_hl(0, "Keyword", { fg = colors.tertiary, italic = true })
  vim.api.nvim_set_hl(0, "Type", { fg = colors.secondary })
  vim.api.nvim_set_hl(0, "Identifier", { fg = colors.fg })
  vim.api.nvim_set_hl(0, "PreProc", { fg = colors.accent })
  vim.api.nvim_set_hl(0, "Special", { fg = colors.secondary })
  vim.api.nvim_set_hl(0, "Error", { fg = colors.error, bold = true })
  vim.api.nvim_set_hl(0, "DiagnosticError", { fg = colors.error })
  vim.api.nvim_set_hl(0, "DiagnosticWarn", { fg = colors.tertiary })
  vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.accent })
  vim.api.nvim_set_hl(0, "DiagnosticHint", { fg = colors.secondary })
  vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = colors.bg_highlight, bold = true })
  vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = colors.accent, bold = true })
  vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
  vim.api.nvim_set_hl(0, "@string", { link = "String" })
  vim.api.nvim_set_hl(0, "@constant", { link = "Constant" })
  vim.api.nvim_set_hl(0, "@function", { link = "Function" })
  vim.api.nvim_set_hl(0, "@keyword", { link = "Keyword" })
  vim.api.nvim_set_hl(0, "@type", { link = "Type" })
  vim.api.nvim_set_hl(0, "@variable", { link = "Identifier" })
end

vim.cmd("syntax enable")
apply()

local signal = vim.uv.new_signal()
signal:start("sigusr1", vim.schedule_wrap(apply))
M.signal = signal

return M
