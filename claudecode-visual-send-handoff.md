# claudecode.nvim `<leader>as` visual-mode send — debugging handoff

> Status: **NOT fixed.** Root cause strongly narrowed but not 100% confirmed by a clean repro.
> Written for a fresh agent to catch up and finish. Start at "Leading hypothesis" and "The one test that confirms it".

## Problem
Leader = `,`. In the TUI/GUI nvim, `,as` in visual mode (`v` and `V`) does **not** send the
selection reference to the Claude chat. It **works in neo-tree**. It is **not shown in the
which-key popup** in visual mode. Reportedly a regression (worked before).

Relevant config:
- `dot_config/nvim/lua/plugins/ai.lua` — claudecode.nvim spec (the `,as` mappings)
- `dot_config/nvim/lua/plugins/ui.lua:137-159` — which-key spec (note the custom triggers)
- `dot_config/nvim/lua/plugins/editor.lua:238-256` — flash.nvim (maps `s` in visual)

## Environment / versions
- nvim 0.12.3
- claudecode.nvim @ `288c9bf` (2026-06-23)
- which-key.nvim @ `3aab214` (2025-10-28, v3)
- claudecode loaded eagerly via `event = "VeryLazy"` (intentional — see comment in ai.lua)

## CONFIRMED WORKING — do not re-investigate these
1. **Mapping is correctly registered.** `maparg(",as","x")` in the live session returns
   `<cmd>ClaudeCodeSend<cr>` (a real mapping, NOT a lazy stub). Plugin is loaded.
2. **claudecode + the WebSocket connection work.** Driving the send while genuinely in visual mode
   delivers correctly. Verified in the live session:
   - `vim.api.nvim_feedkeys(replace_termcodes("Vjj,as"), "x", false)` →
     `send_at_mention_for_visual_selection(2,4)` was called → returned `true` →
     `@cctest.txt#L2-L4` was delivered to the connected Claude.
   - This holds for BOTH charwise (`v`) and linewise (`V`).
3. **Claude is connected** (`require("claudecode").is_claude_connected() == true`, server up).
4. The claudecode visual path itself is fine:
   `<cmd>ClaudeCodeSend` → `visual_commands.create_visual_command_wrapper` → (visual mode detected)
   → `exit_visual_and_schedule` (feeds `<Esc>`, `vim.schedule`) → `handle_send_visual` → reads
   `'<` / `'>` marks → `send_at_mention_for_visual_selection(line1,line2)`.

**Conclusion: the bug is NOT in claudecode, the mapping, the range logic, or the connection.**

## The actual failure (the delta)
The send only fails on **real interactive typing**. The single distinguishing factor:

- `feedkeys(..., "x")` flushes the whole typeahead atomically → Vim resolves the longest-match
  mapping `,as` BEFORE which-key's `,` trigger can fire → `<cmd>ClaudeCodeSend` runs in visual
  mode → **works**.
- Real interactive typing → **which-key** has installed a `,` trigger in visual mode (which-key v3
  installs visual-mode triggers on `ModeChanged`). which-key intercepts `,`, takes over key
  collection, and then fails to execute claudecode's visual `<cmd>` mapping. Observed end-state in a
  live `nvim_input` run: **insert/normal mode, no send**. Likely because which-key exits visual mode
  before executing, and a mode-`x` (`<cmd>`) mapping can't run from normal mode → send never fires.

This matches every symptom: "not recognized in which-key" (visual), "works in neo-tree" (that
mapping is a NORMAL-mode buffer-local `,as` → `ClaudeCodeTreeAdd`, a different path), and
"feedkeys works but typing doesn't."

## LEADING HYPOTHESIS + fix candidates (try in this order — keep it simple)

### Candidate B (try FIRST — simplest, most suspicious)
`ui.lua:143-158` overrides the leader with a **non-standard** which-key trigger:
```lua
keys = {
  { "<leader>",      function() require("which-key").show({ global = false }) end, desc = "..." },
  { "<localleader>", function() require("which-key").show({ global = false }) end, desc = "..." },
}
```
`show({ global = false })` shows only buffer-local maps and is an unusual override that may be
corrupting which-key's normal trigger behavior. **Remove these two `keys` entries** (let which-key
use its default auto-triggers), full-restart, test.

### Candidate A
Exclude visual mode from which-key triggers so native key resolution handles `,as`
(native resolution is PROVEN to work via the feedkeys test):
```lua
opts = { preset = "modern", triggers = { { "<auto>", mode = "nso" } } }  -- drop "x"
```
Cost: no which-key popup hint when pressing `,` in visual mode (acceptable).

### Other angles
- Why can which-key v3 (recent) not execute this visual `<cmd>` mapping when stock LazyVim configs
  do? Compare against a minimal which-key config. Check `timeoutlen` / which-key `delay`.
- Worst case: bind the visual send to a key/path that bypasses the leader entirely.

## THE ONE TEST THAT CONFIRMS THE CAUSE (this is what's missing)
We never captured a clean trace of a *real* keypress because automated input simulation is
unreliable here (see "Tooling traps"). Do this:

1. In the EXACT instance the user types in, run (`:luafile` or paste):
```lua
local LOG = "/tmp/cc_trace.log"
local function W(s) local h=io.open(LOG,"a"); h:write(os.date("%H:%M:%S ")..s.."\n"); h:close() end
local vc  = require("claudecode.visual_commands")
local sel = require("claudecode.selection")
local evs = vc.exit_visual_and_schedule
vc.exit_visual_and_schedule = function(cb,...) W("[EVS] mode="..vim.api.nvim_get_mode().mode); return evs(cb,...) end
local snd = sel.send_at_mention_for_visual_selection
sel.send_at_mention_for_visual_selection = function(a,b) W("[SEND] "..tostring(a)..","..tostring(b)); return snd(a,b) end
W("armed")
```
2. Select 2-3 lines, press `,as`. Then `cat /tmp/cc_trace.log`:
   - **Neither `[EVS]` nor `[SEND]` logs** → the command never fired interactively → which-key /
     key-resolution ate it → hypothesis confirmed → apply Candidate B or A, restart, retest.
   - **`[EVS]`/`[SEND]` log but Claude shows nothing** → look downstream (connection / at-mention).
3. To confirm which-key specifically: apply Candidate A/B in config + **full restart** (runtime
   `which-key.setup({triggers=...})` does NOT cleanly re-install triggers — don't trust it), retest.

## Tooling traps (things that wasted time — avoid)
- `nvim_input` / `--remote-send` over the RPC socket only processes keystrokes when that instance's
  UI is actively pumping. In `--headless` it does nothing (`V` won't even enter visual mode,
  `on_key` sees nothing) → **false negatives**. Confirmed unreliable.
- `feedkeys(..., "x")` flushes atomically and **bypasses which-key** → **false positives** (always
  works). Useful only to prove the plugin works, not to test the interactive path.
- => The only trustworthy signal for the interactive bug is a **real human keypress** with the
  trace above armed in the right instance.
- Query a live instance and get a value back:
  `nvim --server <sock> --remote-expr "luaeval(\"loadfile('/path/x.lua')()\")"`, where `x.lua` ends
  with `return "<string>"`. Find sockets: `find /private/var/folders -path "*nvim.antoniosofia*" -name "nvim.*.0"`.

## Multiple nvim instances (caused real confusion — read this)
User runs `nvim .` in a **Ghostty** terminal (via fish). That instance spawns a child
`nvim --embed .` (same files open). Chain: `ghostty → fish → nvim . → nvim --embed .`.
- This `--embed` child is **NOT VSCode** and **NOT vscode-neovim** (an earlier claim of mine that it
  was vscode-neovim was WRONG — the user has no vim plugin in VSCode). Its spawner is unidentified;
  most likely a plugin using `jobstart(..., {rpc=true})`. Probably a red herring for this bug, but:
- **Make sure you instrument and the user tests the SAME instance.** PIDs/sockets change on every
  restart. The user's manual test once landed in the wrong window.

## Cleanup already done
- Removed injected instrumentation from the reachable live instance: restored the wrapped
  `exit_visual_and_schedule` / `send_at_mention_for_visual_selection`, cleared `on_key` watchers
  (namespaces `cc_probe`, `cc_probe2`, `cc_keylog`).
- During testing, 3 which-key autocmds were deleted at runtime in one instance — a **full nvim
  restart** restores clean state.
- A few `cctest.txt#L2-L4` at-mentions were delivered to the Claude prompt during testing; clear if
  unwanted.
- All temp/log files were in the Claude scratchpad (session-isolated), nothing written to the repo
  except this handoff file.
