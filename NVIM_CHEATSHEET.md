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
| `Ctrl+h/j/k/l` | Navigate between windows |

### File Tree Operations

When in the file tree (nvim-tree):

| Key | Action |
|-----|--------|
| `a` | Create new file/directory (add `/` at end for directory) |
| `d` | Delete file/directory |
| `r` | Rename file/directory |
| `x` | Cut file/directory |
| `c` | Copy file/directory |
| `p` | Paste file/directory |
| `y` | Copy name to clipboard |
| `Y` | Copy relative path to clipboard |
| `gy` | Copy absolute path to clipboard |
| `g?` | Show help/keybindings |

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

## Telescope (Fuzzy Finder)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<leader>fo` | Recent files |

---

## Git Operations

### Lazygit (Full Git UI)

| Key | Action |
|-----|--------|
| `<leader>gg` | Open Lazygit in floating window |

**Inside Lazygit:**
- `?` - Show help/keybindings
- `q` - Quit/close Lazygit
- `1-5` - Switch between panels (Status/Files/Branches/Commits/Stash)
- `Space` - Stage/unstage files
- `c` - Commit
- `P` - Push
- `p` - Pull
- `Enter` - View details/diff
- `a` - Stage all
- `A` - Amend commit
- `d` - View diff options
- `x` - Open command menu

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

## Completion (Blink.cmp)

| Key | Mode | Action |
|-----|------|--------|
| `Enter` | i | Accept completion |
| `Tab` | i | Next completion item |
| `Shift+Tab` | i | Previous completion item |
| `Ctrl+k` | i | Toggle documentation window |
| `Ctrl+Space` | i | Show completion menu |
| `Ctrl+e` | i | Close completion menu |
| `Ctrl+n` / `Down` | i | Next item (alternative) |
| `Ctrl+p` / `Up` | i | Previous item (alternative) |
| `Ctrl+f` / `Ctrl+b` | i | Scroll documentation window down / up |

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
| Everforest | Color scheme |
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
| Theme | Everforest |

---

## Ghostty Terminal (macOS)

### Window Management

| Key | Action |
|-----|--------|
| `Cmd+n` | New window |
| `Cmd+Shift+w` | Close window |
| `Cmd+Shift+Opt+w` | Close all windows |
| `Cmd+Enter` | Toggle fullscreen |
| `Cmd+Ctrl+f` | Toggle fullscreen (alternative) |
| `Cmd+q` | Quit Ghostty |

### Tab Management

| Key | Action |
|-----|--------|
| `Cmd+t` | New tab |
| `Cmd+w` | Close tab |
| `Cmd+Shift+[` | Previous tab |
| `Cmd+Shift+]` | Next tab |
| `Cmd+1-8` | Go to tab 1-8 |
| `Cmd+9` | Go to last tab |

### Split/Pane Management

| Key | Action |
|-----|--------|
| `Cmd+d` | New split (right) |
| `Cmd+Shift+d` | New split (down) |
| `Cmd+[` | Focus previous split |
| `Cmd+]` | Focus next split |
| `Cmd+Opt+↑/↓/←/→` | Focus split directionally |
| `Cmd+Shift+Enter` | Toggle split zoom |
| `Cmd+Ctrl+↑/↓/←/→` | Resize splits |
| `Cmd+Ctrl+=` | Equalize splits |

### Text & Display

| Key | Action |
|-----|--------|
| `Cmd+c` | Copy |
| `Cmd+v` | Paste |
| `Cmd+Home/End` | Scroll to top/bottom |
| `Cmd+k` | Clear screen |
| `Cmd++` | Increase font size |
| `Cmd+-` | Decrease font size |
| `Cmd+0` | Reset font size |

### Configuration

| Key | Action |
|-----|--------|
| `Cmd+,` | Open config |
| `Cmd+Shift+,` | Reload config |
| `Cmd+Opt+i` | Toggle inspector |

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
,gg      -> Lazygit (full git UI)
,sr      -> Search & replace
,xx      -> Diagnostics
,ac      -> Toggle Claude AI
,gh...   -> Git hunk operations
s/S      -> Flash jump/treesitter
]h/[h    -> Next/prev git hunk
]q/[q    -> Next/prev trouble item
Shift+hl -> Switch buffers
Ctrl+hjkl -> Navigate windows
```
