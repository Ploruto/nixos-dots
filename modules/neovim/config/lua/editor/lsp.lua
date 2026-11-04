vim.diagnostic.config({ severity_sort = true, virtual_text = false, float = { border = "single" } })
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("editor-lsp", { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end
    local map = function(keys, action, description)
      vim.keymap.set("n", keys, action, { buffer = event.buf, desc = description })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gD", vim.lsp.buf.declaration, "Go to declaration")
    map("grr", vim.lsp.buf.references, "Show references")
    map("K", vim.lsp.buf.hover, "Show hover documentation")
    map("<leader>ca", vim.lsp.buf.code_action, "Code actions")
    map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>cd", vim.diagnostic.open_float, "Show diagnostic details")
    map("<leader>cf", function()
      -- nil delegates to nixfmt; Lua uses the explicit StyLua command below.
      if vim.bo.filetype == "lua" then
        local result = vim.system({ "stylua", "--stdin-filepath", vim.api.nvim_buf_get_name(0), "-" }, {
          stdin = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n") .. "\n",
          text = true,
        }):wait()
        if result.code ~= 0 then
          vim.notify(result.stderr, vim.log.levels.ERROR)
          return
        end
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout:gsub("\n$", ""), "\n"))
      else
        vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
      end
    end, "Format buffer")
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = false })
    end
  end,
})
vim.lsp.config("nil_ls", { settings = { ["nil"] = { formatting = { command = { "nixfmt" } } } } })
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
      telemetry = { enable = false },
    },
  },
})
vim.lsp.enable({ "nil_ls", "lua_ls" })
