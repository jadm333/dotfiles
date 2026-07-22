# Global Preferences

- IMPORTANT: Never commit or push in git, any other git action is permitted.
- No emojis
- Always get straight to the point and omit indulgent answers.
- When working with Python, use the astral skills for uv, ty, and ruff if available (`/astral:<skill>` in Claude Code) to ensure best practices are followed.
- When writing Markdown files, never hard-wrap lines at a fixed column width. Write each paragraph as a single long line and let editors soft-wrap. Hard-wrapped lines break copy-paste.
- When output is meant to be copied elsewhere (PR summaries, commit messages, issue bodies, Slack messages, etc.), never print it in the console — terminal copy loses newlines and formatting. Write it to a file in the session scratchpad directory (the temp dir listed in the system prompt; will be erased on reboot), copy it to the clipboard with `pbcopy < file`, and report the full file path.
- Humor style: dry, dark, and slightly edgy. Deadpan delivery. Existential dread is fair game. No sugarcoating.
- I use Podman. `docker` and `docker compose` are aliases for Podman, so before running container commands, only check whether `podman machine start` has already been run; do not install or configure Docker.
- Do not require a shell environment variable to be exported manually before running a CLI, such as `export ENVAR=foo` followed by `python script.py`. Put required variables in an environment file and load them automatically, using the repository's existing environment-file mechanism or `direnv` when appropriate.
- Available CLI tooling on this machine is declared in the chezmoi-managed `Brewfile`. Consult it before assuming a tool is missing or installing anything. Find it at `$(chezmoi source-path)/Brewfile` — it lives in the chezmoi source directory, not under `$HOME`, and is not a managed target.
- Before choosing tools or proposing installations, inspect the chezmoi folder and its `Brewfile` for already-installed libraries and utilities that can help code agents, especially `ripgrep`, `fd`, `uv`, `direnv`, `gh`, and related CLI tooling.

## Coding Style

- No emojis anywhere: code, comments, commit messages, logs, identifiers, or generated docs.
- Comments only for constraints the code cannot express (invariants, gotchas, non-obvious why). Never narrate what a line does, restate the change, or leave notes addressed to the reviewer. If code needs a comment to be understood, rewrite the code instead.
- Delete dead code; never leave commented-out code or placeholder/TODO scaffolding unless explicitly asked.
- Match the surrounding codebase: naming, idiom, formatting, comment density. Do not introduce a new style into an existing file.
- Prefer small, direct implementations. No speculative abstractions, config options, or helper layers for a single call site.
- Names say what a thing is. Avoid vague filler like `data`, `utils`, `manager`, `helper` when something specific fits.
- Prefer early returns and guard clauses over deep nesting.
- Fail loudly and specifically; do not swallow exceptions or log-and-continue unless the surrounding code already does.
- Never reference files the reader may not have (e.g., "as for REFACTOR_PLAN.md section 3...") in PR bodies, commit messages, docs, or code comments. Scratch plans and local notes do not exist outside this machine; verify a file is tracked in the repo before citing it.
