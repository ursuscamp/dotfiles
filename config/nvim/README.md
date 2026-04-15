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
  - an `fzf-lua` colorscheme picker with live preview while you navigate
- Editing helpers:
  - `mini.pairs`
  - `mini.surround` using `gs` as the prefix
  - `mini.diff`
  - yank highlighting on save
  - tree-sitter folds
  - word-wrap toggle
- File and buffer tools:
  - `fzf-lua`
  - `mini.files`
  - `mini.bufremove`
  - `buffer_manager.nvim`
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
  - `fzf-lua` pickers for references, implementations, type definitions, diagnostics, and symbols

## Key mappings

- `<leader>ff` and `<leader><leader>`: find files
- `<leader>fb`: find buffers
- `<C-b>`: open Buffer Manager
- `<leader>fh`: find help
- `<leader>fg`: live grep
- `<leader>fe` and `<leader>e`: open `mini.files`
- `<leader>gg`: open LazyGit
- `<leader>fc`: pick a colorscheme
- `<leader>w`: save buffer
- `<leader>W`: save all buffers
- `<leader>sh` / `<leader>sv`: split horizontally and vertically
- `<leader>bd`: delete current buffer
- `]b` / `[b`: next and previous buffer in Buffer Manager order
- `<leader>q`: quit current window
- `<leader>tw`: toggle word wrap
- `<C-q>`: quit without saving
- `U`: normal undo
- `s` / `S` / `r` / `R` / `<C-s>`: Flash motions
- `<Tab>` / `<S-Tab>`: jump through snippet stops
- `<C-y>` in insert mode: accept completion, or choose the first completion item if nothing is selected
- `J` / `K` in Buffer Manager: move current or selected entries down and up
- `grr`: LSP references in `fzf-lua`
- `gri`: LSP implementations in `fzf-lua`
- `grt`: LSP type definitions in `fzf-lua`
- `grd`: current-buffer diagnostics in `fzf-lua`
- `grD`: workspace diagnostics in `fzf-lua`
- `grs`: document symbols in `fzf-lua`
- `grS`: workspace symbols in `fzf-lua`
- `gra`, `grn`, `grx`: native LSP code actions, rename, and code lens
- In Mermaid and Markdown buffers:
  - `<leader>mp`: open the current Mermaid file or fenced Mermaid block in `mermaid.live`
  - `<leader>mP`: open a local HTML Mermaid preview in your browser

## Notes

- The built-in package manager installs plugins on demand.
- `fzf-lua` is also wired into `vim.ui.select()`, so selection prompts use it automatically.
- Mermaid files and Mermaid code blocks can be opened in a browser with `:MermaidLive` or `:MermaidPreview`.
- `../../scripts/clear-nvim-state.sh` clears `~/.cache/nvim`, `~/.local/state/nvim`, and `~/.local/share/nvim` for a fresh Neovim start.
