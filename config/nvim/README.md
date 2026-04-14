# nvim-next

Modular Neovim config for Neovim 0.12+ using the built-in package manager.

## What it includes

- Core editor defaults:
  - clipboard, indentation, search, split, and window settings
  - relative and absolute line numbers
  - persistent undo
  - rounded completion popup borders
  - a global statusline
- Theme and UI:
  - `catppuccin`
  - `tokyonight`
  - `mini.statusline`
  - `mini.notify`
  - `mini.icons`
  - `mini.clue`
  - `mini.indentscope` with a solid bar and no animation
  - a Mini Pick colorscheme picker with live preview while you navigate
- Editing helpers:
  - `mini.pairs`
  - `mini.surround` using `gs` as the prefix
  - `mini.diff`
  - yank highlighting on save
  - tree-sitter folds
  - word-wrap toggle
- File and buffer tools:
  - `mini.pick`
  - `mini.files`
  - `mini.bufremove`
  - `mini.extra`
  - `lazygit.nvim`
- Completion and snippets:
  - `mini.completion`
  - `mini.snippets`
  - `friendly-snippets`
  - `<C-y>` selection behavior that chooses the first completion item when nothing is selected
  - `Tab` / `Shift-Tab` snippet-stop navigation
- Navigation:
  - `flash.nvim` for jump/search motions
  - quick file, buffer, and help pickers
- LSP:
  - native Neovim LSP setup with `nvim-lspconfig`
  - Mason-managed installation of common servers
  - shared server list for both install and enable
  - `rust_analyzer` included
  - `mini.completion` wired into LSP completion
  - `mini.extra` pickers for references, implementations, type definitions, diagnostics, and symbols

## Key mappings

- `<leader>ff` and `<leader><leader>`: find files
- `<leader>fb`: find buffers
- `<leader>fh`: find help
- `<leader>fg`: live grep
- `<leader>fe` and `<leader>e`: open `mini.files`
- `<leader>gg`: open LazyGit
- `<leader>fc`: pick a colorscheme
- `<leader>w`: save buffer
- `<leader>W`: save all buffers
- `<leader>bd`: delete current buffer
- `<leader>q`: quit current window
- `<leader>tw`: toggle word wrap
- `<C-q>`: quit without saving
- `U`: normal undo
- `s` / `S` / `r` / `R` / `<C-s>`: Flash motions
- `<Tab>` / `<S-Tab>`: jump through snippet stops
- `<C-y>` in insert mode: accept completion, or choose the first completion item if nothing is selected
- `<C-d>` in the buffers picker: delete marked buffers, or the current buffer if none are marked
- `grr`: LSP references in Mini Pick
- `gri`: LSP implementations in Mini Pick
- `grt`: LSP type definitions in Mini Pick
- `grd`: current-buffer diagnostics in Mini Pick
- `grD`: workspace diagnostics in Mini Pick
- `grs`: document symbols in Mini Pick
- `grS`: workspace symbols in Mini Pick
- `gra`, `grn`, `grx`: native LSP code actions, rename, and code lens

## Notes

- The built-in package manager installs plugins on demand.
- `mini.pick` is also wired into `vim.ui.select()`, so selection prompts use it automatically.
