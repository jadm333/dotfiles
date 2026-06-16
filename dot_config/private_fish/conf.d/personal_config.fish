if status is-interactive
    # Commands to run in interactive sessions can go here

    # Set cursor to blinking vertical bar (pipe)
    # \e[5 q = blinking vertical bar
    # \e[6 q = steady vertical bar

    # Set cursor on shell init
    echo -ne "\e[5 q"

    # Set cursor before every prompt to ensure it persists
    function set_cursor_bar --on-event fish_prompt
        echo -ne "\e[5 q"
    end
end

# Lazygit config location
set -gx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml"

alias tf='terraform'
alias cmoi='chezmoi'
alias srpi='ssh rpi'
alias docker='podman'

# Start a detached Claude Code session with Remote Control enabled,
# named after the current folder, so it can be driven from the phone app.
# Local TUI stays detached; reattach with: tmux attach -t <folder>
function claudio --description 'Detached Claude Code remote-control session named after the current folder'
    # tmux session names can't contain '.' or ':' - sanitize to '-'
    set -l name (basename $PWD | string replace -ra '[.:]' '-')
    tmux new-session -d -s $name "claude --remote-control $name"
    echo "Claude remote session '$name' started detached. Connect from the app, or attach locally: tmux attach -t $name"
end
