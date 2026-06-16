function remote-off --description "Flip OFF on-demand remote access (Tailscale + mosh)"
    #
    # 1) Disconnect from the tailnet. The daemon keeps idling (like `docker stop`),
    #    but nothing is reachable. This "stay down" preference persists across
    #    reboot, so a fresh boot comes back DISCONNECTED.
    # 2) Defensive: if macOS Remote Login (sshd) ever got switched on, switch it
    #    off. We never enable it (we use Tailscale SSH), so this normally no-ops.
    # 3) Reap lingering mosh-server processes — they outlive the SSH session by
    #    design and would otherwise sit around until reboot.
    #
    # Idempotent: safe to run when already off.

    set -l TS /opt/homebrew/bin/tailscale

    # --- 1. Disconnect from the tailnet ------------------------------------
    $TS down 2>/dev/null
    echo "Tailscale : down (node disconnected; daemon still idling)."

    # --- 2. Disable macOS Remote Login if it's on --------------------------
    # Detect WITHOUT sudo: Remote Login means sshd is listening on TCP 22.
    # Tailscale SSH does NOT open a normal port-22 listener, so a listener here
    # means the macOS setting got turned on somehow. Only then do we invoke sudo.
    if lsof -nP -iTCP:22 -sTCP:LISTEN >/dev/null 2>&1
        echo "Remote Login : appears ON — disabling (needs sudo + Full Disk Access)."
        echo "  running: sudo systemsetup -setremotelogin off"
        printf 'yes\n' | sudo systemsetup -setremotelogin off
    else
        echo "Remote Login : already off."
    end

    # --- 3. Kill lingering mosh-server processes ---------------------------
    if pkill -x mosh-server 2>/dev/null
        echo "mosh-server : killed lingering session(s)."
    else
        echo "mosh-server : none running."
    end

    # --- 4. Stop caffeinate (restore normal sleep) -------------------------
    if pkill -f 'caffeinate -dimsu' 2>/dev/null
        echo "caffeinate : stopped (normal sleep restored)."
    else
        echo "caffeinate : not running."
    end

    echo ""
    echo "Remote access is OFF."
end
