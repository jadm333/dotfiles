function remote-on --description "Flip ON on-demand remote access (Tailscale + mosh)"
    #
    # Model (Docker-style): tailscaled runs continuously as a launchd service
    # (set up ONCE with `sudo brew services start tailscale`). This function only
    # *connects* the node to your tailnet and turns on Tailscale's built-in SSH
    # server, so an incoming mosh can bootstrap. tailscaled itself is the SSH
    # server — macOS Remote Login / sshd are never touched.
    #
    # No sudo: your user is the tailscale --operator (granted once at setup).
    # Idempotent: `tailscale up` is a no-op when already connected.

    set -l TS /opt/homebrew/bin/tailscale

    # --- 1. Connect + enable Tailscale SSH ---------------------------------
    if not $TS up --ssh
        echo "remote-on: 'tailscale up' failed."
        echo "The daemon may not be running. Start it once with:"
        echo "    sudo brew services start tailscale"
        return 1
    end

    # --- 1b. Keep the Mac awake --------------------------------------------
    # caffeinate prevents display/idle/disk/system sleep so an incoming mosh
    # can always reach the box. Backgrounded + disowned so it outlives this
    # shell; remote-off / remote-power reap it. Guard against double-starts.
    if pgrep -f 'caffeinate -dimsu' >/dev/null 2>&1
        echo "caffeinate : already running (Mac stays awake)."
    else
        caffeinate -dimsu &
        disown
        echo "caffeinate : started (Mac will not sleep while remote)."
    end

    # --- 2. Resolve this Mac's tailnet address -----------------------------
    # `up` returns once connected, but give the IP a few retries to be safe.
    set -l ip ""
    for i in (seq 5)
        set ip ($TS ip -4 2>/dev/null)
        test -n "$ip"; and break
        sleep 0.5
    end

    # MagicDNS FQDN (trailing dot stripped); fall back to the IP if unavailable.
    set -l fqdn ($TS status --json 2>/dev/null | jq -r '.Self.DNSName // empty' \
        | string trim --right --chars='.')
    test -n "$fqdn"; or set fqdn $ip

    set -l user (whoami)

    # --- 3. Tell me how to connect -----------------------------------------
    echo ""
    echo "Remote access is ON (Tailscale connected, SSH enabled)."
    echo ""
    echo "  Tailscale IPv4 : $ip"
    echo "  MagicDNS name  : $fqdn"
    echo ""
    echo "Connect from your phone:"
    echo ""
    echo "    mosh $user@$fqdn"
    echo ""
    echo "  (or by IP:  mosh $user@$ip )"
    echo ""
    echo "Run 'remote-off' when you're done."
end
