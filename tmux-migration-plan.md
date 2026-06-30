# tmux Migration Plan

Long-standing goal: start using tmux. **Scope for now: move only the Claude Code panel out of nvim and into a tmux pane.** Everything else (full tmux-as-daily-driver, session management, theming) is deferred.

This is a base doc to return to. Nothing here is implemented yet.

## Why

Vertical monitor makes the in-nvim Claude split awkward. tmux lets me stack panes freely (true portrait layout). The catch: the nvim Claude keybindings are the *IDE integration*, not terminal shortcuts — they must keep working after the move.

## Key fact (don't forget this)

[`coder/claudecode.nvim`](https://github.com/coder/claudecode.nvim) runs a **WebSocket server inside nvim** (same protocol as the VSCode extension). `<leader>as`, diffs, file mentions all travel over that socket. They work regardless of where Claude's terminal renders — **as long as nvim stays open to host the server.** Kill nvim and the tmux Claude becomes a plain CLI with no selection-sending or nvim diffs.

Current config: [dot_config/nvim/lua/plugins/ai.lua](dot_config/nvim/lua/plugins/ai.lua)

# Guidelines
- This is my chezmoi dot files
- I will manually do chezmoi apply


## Phase 1 — Move the Claude panel (this scope)

### Steps

1. **Set the plugin to host the server but not manage a split.**
   In [ai.lua](dot_config/nvim/lua/plugins/ai.lua), set:
   ```lua
   opts = {
     terminal = { provider = "none" },
     -- keep diff_opts and keys as-is
   }
   ```
   `provider = "none"` keeps the WebSocket server + tools; drops the in-nvim terminal UI.

2. **Launch Claude in a tmux pane and connect to nvim.**
   ```sh
   claude --ide          # or: run `claude`, then /ide
   ```
   nvim writes `~/.claude/ide/<port>.lock` (port + auth token). `--ide`/`/ide` picks it up.
   Verify with `:ClaudeCodeStatus` in nvim.

3. **Seamless nav between nvim windows and the tmux Claude pane.**
   Add [`smart-splits.nvim`](https://github.com/mrjones2014/smart-splits.nvim) (or vim-tmux-navigator) so `<C-h/j/k/l>` crosses the nvim<->tmux boundary instead of stopping at nvim's edge.

### What keeps working unchanged (still pressed in nvim)

- `<leader>as` — send visual selection with context
- `<leader>ab` / `<leader>as` (tree) — add buffer / add file
- `<leader>aa` / `<leader>ad` — accept / deny diffs (render as nvim diffs)

### What changes / what I lose

- `<leader>ac` toggle, `<leader>ar` resume, `<leader>aC` continue — these launched/managed the *in-nvim* terminal. With `provider = "none"` there's no panel to toggle; **tmux now owns the Claude pane lifecycle** (start/stop/resume via tmux). Decide whether to rebind these to tmux commands or drop them.
- Workflow itself is unchanged: I already select in nvim and press `<leader>as` — cursor is in the editor, not the Claude terminal. tmux just relocates where output renders.

### Open questions for Phase 1

- [ ] Auto-launch: should opening nvim in a project auto-spawn the tmux Claude pane + `--ide`, or stay manual?
A: No autospawn
- [ ] Keep nvim as the server host always — confirm I never want Claude running without nvim.
A: No really
- [ ] Rebind or remove `<leader>ac/ar/aC`?
A: Rebind

## Deferred (later phases — not now)

- tmux as primary multiplexer (sessions, windows, status line, theme).
- tmux + nvim keybinding cohesion (prefix choice, copy-mode, vi keys).
- Persistent sessions (tmux-resurrect / tmux-continuum).
- Migrate more plugins there, I want as much as posible.

## References

- Plugin: <https://github.com/coder/claudecode.nvim>
- External terminal setup: <https://github.com/coder/claudecode.nvim/blob/main/README.md>
- Cross-boundary nav: <https://github.com/mrjones2014/smart-splits.nvim>
