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
