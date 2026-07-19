# Open nvim inside tmux. If already in a tmux session, just run nvim;
# otherwise attach to (or create) a session named "main" and launch nvim there.
# Ensures the claudecode.nvim -> tmux integration always has a session to split.
function nv --description 'Open nvim inside tmux'
    if set -q TMUX
        nvim $argv
    else
        tmux new-session -A -s main "nvim $argv"
    end
end
