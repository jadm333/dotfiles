# Start a detached Claude Code session with Remote Control enabled,
# named after the current folder, so it can be driven from the phone app.
# Local TUI stays detached; reattach with: tmux attach -t <folder>
function claudio --description 'Detached Claude Code remote-control session named after the current folder'
    # tmux session names can't contain '.' or ':' - sanitize to '-'
    set -l name (basename $PWD | string replace -ra '[.:]' '-')
    tmux new-session -d -s $name "claude --remote-control $name"
    echo "Claude remote session '$name' started detached. Connect from the app, or attach locally: tmux attach -t $name"
end
