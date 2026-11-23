require("diffview").setup({})

-- HEAD includes staged and unstaged edits in a single review against the last commit.
vim.keymap.set("n", "<leader>gr", "<cmd>DiffviewOpen HEAD<cr>", { desc = "Review changes against HEAD" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close changeset review" })
