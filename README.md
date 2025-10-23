# dotfiles
Personal dotfiles using chezmoi
Init:
```bash
chezmoi init jadm333 --ssh
```

Add new dotfile:
```bash
chezmoi add path/to/dotfile
chezmoi add --template path/to/dotfile
```

Ssh
```bash
ssh-keygen -t ed25519
ssh-copy-id -i ~/.ssh/id_ed25519_pi.pub pi@raspberrypi.local
```