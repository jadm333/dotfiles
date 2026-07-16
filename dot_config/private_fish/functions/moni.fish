function moni --description "Toggle the fixed external monitor"
    set -l backend "$HOME/.local/bin/monictl"
    set -l target "4B838198-B101-4B5B-A739-5EAB1A78584D"
    set -l legacy_recovery_id 2

    set -l action $argv[1]
    switch "$action"
        case ""
            set action toggle
        case help --help -h
            printf '%s\n' \
                'usage: moni' \
                '       moni toggle|status|recover' \
                '       moni list|check' \
                '' \
                'Bare "moni" toggles display 4B838198-B101-4B5B-A739-5EAB1A78584D.' \
                '"moni recover" tries the saved legacy ID if an older build disabled it.'
            return 0
        case list check
            if test (count $argv) -ne 1
                echo "moni: '$action' does not accept arguments." >&2
                return 2
            end
        case toggle status recover
            if test (count $argv) -ne 1
                echo "moni: '$action' does not accept arguments." >&2
                return 2
            end
        case '*'
            echo "moni: unknown command '$action'. Run 'moni help'." >&2
            return 2
    end

    if not test -x "$backend"
        echo "moni: $backend is missing. Run 'chezmoi apply' to build it." >&2
        return 127
    end

    if contains -- "$action" list check
        "$backend" "$action"
        return $status
    end

    if test "$action" = recover
        "$backend" recover "$target" "$legacy_recovery_id"
        return $status
    end

    "$backend" "$action" "$target"
end
