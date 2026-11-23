# Neovim

Home Manager installs the editor, plugins and tools in `default.nix`; Lua lives
in `config/`. There is no runtime plugin installer. Apply changes with the usual
NixOS rebuild, then restart Neovim.

## Plugins

- A small built-in colorscheme generated from Noctalia's current wallpaper palette.
  Changing wallpapers refreshes open Neovim instances.
- nvim-lspconfig: language-server definitions (the LSP client is built into Neovim).
- which-key: delayed shortcut hints and named groups.
- Snacks: file explorer, file/text/buffer/help/keybinding and Git pickers,
  input prompts, notifications, terminals, large-file handling, and smooth scrolling.
- Diffview: side-by-side review of a whole changeset with a changed-file panel.
- nvim-web-devicons: file icons for the explorer, pickers, and review panel.
- LazyGit: terminal Git interface opened through Snacks.
- Gitsigns: changed-line markers, hunk navigation/preview and line blame.
- Tree-sitter parsers for C, C++, and Verilog/SystemVerilog; Typst CLI and
  Tinymist language server are installed.

`init.lua` lists each Lua module in loading order. General mappings live in
`keymaps.lua`; plugin and LSP mappings live beside their configuration.

## Keys

Space is the leader. Press it and wait for hints; Escape dismisses the menu.

| Keys | Action |
| --- | --- |
| Space f f | Find files under the current directory |
| Space f g | Search text under the current directory |
| Space f b | Find open buffers |
| Space f h | Search help |
| Space f k | Search all keybindings |
| Space e | Toggle file explorer |
| Space f t | Toggle terminal |
| Space g s | Find changed files (including untracked files) |
| Space g d | Find Git diff hunks |
| Space g r | Review working-tree changes against HEAD |
| Space g q | Close changeset review |
| Space g g | Open LazyGit |
| Space g y | Copy current file:line to the clipboard |
| Space ? | Show buffer keybindings |
| gd / gD | Definition / declaration (LSP) |
| grr | References (LSP) |
| K | Hover documentation (LSP) |
| Space c a | Code actions (LSP) |
| Space c r | Rename symbol (LSP) |
| Space c f | Format buffer (manual) |
| Space c d | Diagnostic details |
| Space g p | Preview Git hunk |
| Space g b | Blame current line |
| Space g n / Space g N | Next / previous Git hunk |
| Escape | Clear search highlighting |

LSP mappings attach only to buffers with a language server. Gitsigns mappings
attach only to tracked buffers. Ctrl+O returns after a definition jump. Native
Neovim also provides `[d` / `]d` to move between diagnostics and `grn` / `gra`
for rename/code actions. In insert mode use Ctrl+X Ctrl+O for LSP completion,
Ctrl+N/P to select, Ctrl+Y to accept and Ctrl+E to dismiss. No automatic popups
or automatic formatting on save are configured. Normal yanks, deletes, and pastes
use the system clipboard (`clipboard=unnamedplus`).

## Reviewing agent changes

Start with Space g s for the changed-file list or Space g d to preview diff hunks.
Space g r opens Diffview against HEAD, showing staged and unstaged edits together,
plus untracked files. Tab / Shift+Tab cycle through changed files; `[c` / `]c`
move between hunks in diff panes. Space g q closes the review. Use the existing
Space g p and Space g n / Space g N bindings for hunk previews and navigation
while editing. Space g g opens LazyGit for staging and committing.

For committed agent work on a branch, use `:DiffviewOpen origin/main...HEAD`
(substitute your base branch). Use `:DiffviewOpen` to review against the index
with staged changes listed separately. `:DiffviewRefresh` refreshes an open review
after external edits. Space g y copies the current path relative to Neovim's
working directory with its line number for feedback to an agent.

Searches start in Neovim's current directory; `:cd` changes it. Explorer `H` / `I`
toggle hidden / ignored files. Scroll animations are short and disabled in diff
panes. After rebuilding, `:checkhealth snacks` checks optional integrations.

## Languages

Nix uses nil with nixfmt; Lua uses lua-language-server and StyLua. nil provides
language navigation/diagnostics, but this setup does not yet evaluate NixOS or
Home Manager options to provide option-aware completion.

Typst uses Tinymist, C/C++ uses clangd, and Rust uses rust-analyzer.
For C/C++ projects, provide a `compile_commands.json` with the project's build
flags and include paths. Debugger plugins are not configured.
