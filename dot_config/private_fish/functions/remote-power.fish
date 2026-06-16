function remote-power --description "Schedule a shutdown of this Mac for a clean remote/mosh disconnect"
    #
    # Run this over ssh/mosh when you want to power the laptop OFF remotely.
    # It does NOT shut down immediately — it schedules the shutdown N minutes
    # out so you can drop the mosh session cleanly first, then the Mac powers
    # off on its own. We deliberately leave Tailscale up until shutdown so your
    # session stays alive; the power-off itself tears everything down.
    #
    # Usage:
    #   remote-power          # shut down in 1 minute (default)
    #   remote-power 5        # shut down in 5 minutes
    #   remote-power cancel   # abort a pending shutdown
    #
    # Needs sudo (shutdown is privileged).

    set -l arg $argv[1]

    # --- Cancel a pending shutdown -----------------------------------------
    if test "$arg" = cancel
        if sudo killall shutdown 2>/dev/null
            echo "Pending shutdown cancelled."
        else
            echo "No shutdown was scheduled."
        end
        return 0
    end

    # --- Resolve delay (whole minutes) -------------------------------------
    set -l mins 1
    if test -n "$arg"
        if string match -qr '^[0-9]+$' -- $arg
            set mins $arg
        else
            echo "remote-power: delay must be a whole number of minutes (or 'cancel')."
            return 1
        end
    end

    # --- Schedule the shutdown ---------------------------------------------
    echo "Scheduling shutdown in $mins minute(s)."
    echo "Disconnect your mosh session now — the Mac will power off shortly."
    echo "Run 'remote-power cancel' to abort."
    echo ""
    sudo shutdown -h +$mins
end
