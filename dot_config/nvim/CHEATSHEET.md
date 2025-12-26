# Neovim Configuration Cheatsheet

> Leader key: `,` (comma)

## Mac Key Reference

| Symbol | Key |
|--------|-----|
| `Ctrl` | Control (^) |
| `Cmd` | Command |
| `Opt` | Option/Alt |
| `Shift` | Shift |

> Note: Neovim uses `Ctrl` not `Cmd` for most shortcuts

---

## Navigation & File Management

| Key | Action |
|-----|--------|
| `Ctrl+n` | Toggle file tree |
| `<leader>e` | Focus file tree |
| `Ctrl+h/j/k/l` | Navigate between windows (also in terminal) |

## Buffer Management

| Key | Action |
|-----|--------|
| `Shift+h` | Previous buffer |
| `Shift+l` | Next buffer |
| `[b` / `]b` | Previous / Next buffer |
| `[B` / `]B` | Move buffer left / right |
| `<leader>bp` | Pin buffer |
| `<leader>bP` | Delete non-pinned buffers |
| `<leader>br` | Delete buffers to the right |
| `<leader>bl` | Delete buffers to the left |

## Search & Navigation (Flash)

| Key | Mode | Action |
|-----|------|--------|
| `s` | n/v/o | Flash jump |
| `S` | n/v/o | Flash Treesitter (structural) |
| `r` | o | Remote Flash |
| `R` | o/v | Treesitter search |
| `Ctrl+s` | c | Toggle Flash in search |
| `Ctrl+Space` | n | Treesitter incremental selection |

## Search & Replace

| Key | Action |
|-----|--------|
| `<leader>sr` | Open Grug-Far (search & replace) |

## Terminal (Snacks)

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl+/` | n | Toggle floating terminal |
| `Ctrl+h/j/k/l` | t | Navigate to other windows |
| `q` | t | Close/hide terminal |
| `gf` | t | Open file under cursor |
| `Esc Esc` | t | Exit insert mode in terminal |

---

## Git Operations

### Hunk Navigation

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / Previous hunk |
| `]H` / `[H` | Last / First hunk |

### Hunk Operations

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ghs` | n/v | Stage hunk |
| `<leader>ghr` | n/v | Reset hunk |
| `<leader>ghS` | n | Stage buffer |
| `<leader>ghu` | n | Undo stage hunk |
| `<leader>ghR` | n | Reset buffer |
| `<leader>ghp` | n | Preview hunk inline |
| `<leader>ghb` | n | Blame line |
| `<leader>ghB` | n | Blame buffer |
| `<leader>ghd` | n | Diff this |
| `<leader>ghD` | n | Diff this ~ |
| `ih` | o/v | Select hunk (text object) |

---

## Diagnostics & Symbols (Trouble)

| Key | Action |
|-----|--------|
| `<leader>xx` | Toggle diagnostics |
| `<leader>xX` | Toggle buffer diagnostics |
| `<leader>cs` | Toggle symbols |
| `<leader>cS` | Toggle LSP references/definitions |
| `<leader>xL` | Toggle location list |
| `<leader>xQ` | Toggle quickfix list |
| `[q` / `]q` | Previous / Next trouble item |

---

## Claude Code (AI)

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ac` | n | Toggle Claude |
| `<leader>af` | n | Focus Claude |
| `<leader>ar` | n | Resume Claude |
| `<leader>aC` | n | Continue Claude |
| `<leader>am` | n | Select Claude model |
| `<leader>ab` | n | Add current buffer |
| `<leader>as` | v | Send selection to Claude |
| `<leader>aa` | n | Accept diff |
| `<leader>ad` | n | Deny diff |

---

## Noice (Messages & Commands)

| Key | Mode | Action |
|-----|------|--------|
| `Shift+Enter` | c | Redirect cmdline |
| `<leader>snl` | n | Last message |
| `<leader>snh` | n | Message history |
| `<leader>sna` | n | All messages |
| `<leader>snd` | n | Dismiss all |
| `<leader>snt` | n | Noice picker (Telescope) |
| `Ctrl+f` / `Ctrl+b` | i/n/s | Scroll forward / backward |

## Notifications

| Key | Action |
|-----|--------|
| `<leader>n` | Notification history |
| `<leader>un` | Dismiss all notifications |

---

## Code Generation

| Key | Action |
|-----|--------|
| `<leader>a` | Add docstring (Neogen) |

## Which-Key

| Key | Action |
|-----|--------|
| `<leader>` | Show available keymaps |

---

## Installed Plugins

### UI & Theme
| Plugin | Purpose |
|--------|---------|
| Catppuccin | Color scheme |
| Lualine | Status line |
| Bufferline | Buffer tabs |
| Nvim-tree | File explorer |
| Noice | Enhanced UI for messages/cmdline |
| Which-key | Keybinding hints |
| Mini.icons | File icons |
| Snacks | Utilities (indent, notifications, terminal) |

### Editor
| Plugin | Purpose |
|--------|---------|
| Flash | Enhanced navigation/search |
| Grug-far | Search & replace |
| Gitsigns | Git integration |
| Trouble | Diagnostics panel |
| Treesitter | Syntax highlighting & parsing |
| Indent-blankline | Rainbow indent guides |
| Mini.pairs | Auto bracket pairs |
| TS-comments | Smart commenting |
| Precognition | Movement hints |
| Neogen | Docstring generation |
| Puppeteer | Python f-string helper |

### LSP & Development
| Plugin | Purpose |
|--------|---------|
| Mason | LSP installer |
| Ruff | Python linting/formatting |
| Ty | Python type checking (Astral) |

### AI
| Plugin | Purpose |
|--------|---------|
| Claude Code | AI assistant integration |

---

## Python-Specific Features

- **Auto-formatting**: PEP8 standards (4 spaces)
- **Auto-capitalize**: `true`/`false` -> `True`/`False`, `none` -> `None`
- **Ruff LSP**: Linting and formatting
- **Ty LSP**: Fast type checking
- **Puppeteer**: Auto f-string conversion when typing `{}`

---

## Editor Settings

| Setting | Value |
|---------|-------|
| Line numbers | Relative |
| Mouse | Enabled |
| 24-bit colors | Enabled |
| Folding | Disabled |
| Theme | Catppuccin |

---

## Mode Legend

| Abbrev | Mode |
|--------|------|
| n | Normal |
| v | Visual |
| i | Insert |
| o | Operator-pending |
| c | Command-line |
| s | Select |

---

## Quick Reference

```
,e       -> File tree
,sr      -> Search & replace
,xx      -> Diagnostics
,ac      -> Toggle Claude AI
,gh...   -> Git hunk operations
s/S      -> Flash jump/treesitter
]h/[h    -> Next/prev git hunk
]q/[q    -> Next/prev trouble item
Shift+hl -> Switch buffers
Ctrl+hjkl -> Navigate windows
Ctrl+/    -> Toggle terminal
```
