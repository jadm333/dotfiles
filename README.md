# dotfiles
Personal dotfiles using chezmoi

## Init
```bash
chezmoi init jadm333 --ssh
```

## Add new dotfile
```bash
chezmoi add path/to/dotfile
chezmoi add --template path/to/dotfile
```

## Secrets Management (Proton Pass)

Files:
```gotemplate
{{- secret "item" "view" "pass://dotfiles/file.<name>/note" -}}
```

Vars:
```gotemplate
{{ secret "item" "view" "pass://dotfiles/var.<name>/note" }}
```

## External monitor disconnect

`moni` removes an external display from the macOS desktop layout. It uses the
private `CGSConfigureDisplayEnabled` CoreGraphics function with session scope,
so Apple can break it in a future macOS release and the change should reset at
logout. It does not guarantee that the physical panel will enter standby.

Commands:

```fish
moni        # toggle the fixed display
moni status # report the fixed display state
moni list   # list displays and UUIDs
moni check  # verify the private API still exists
moni recover # recover once when an older build left it disabled
```

The helper refuses built-in displays and refuses to disable the last active
display. Before disabling, it caches the display's session-specific numeric ID
in macOS's per-user temporary directory; macOS removes disabled displays from
its online list, so the persistent UUID alone is not enough to enable one
again. The cache includes the current audit-session ID, is ignored after
logout, and is deleted after a verified re-enable.

If an older `monictl` build already disabled the monitor without saving that
ID, rebuild and perform one explicit recovery:

```fish
chezmoi apply
moni recover
```

Recovery tries contextual ID `2`, the last ID recorded for this monitor on the
current Mac, requires the fixed UUID to reappear, and rolls the probe back if it
does not match. On another Mac, use recovery only if that ID is known to match;
logging out is the no-probe alternative because the configuration uses session
scope. Normal toggling is portable: each Mac caches its own ID immediately
before disabling the monitor.
