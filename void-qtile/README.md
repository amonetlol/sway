# Void + Sway Full

As configs ficam em `sway-full`. Esta pasta instala com xbps, GRUB, SDDM via runit e os módulos do GitHub (`sublime-text.sh` incluído).

O Void não usa systemd. Waybar e awww sobem pelo `sway-session-init` quando o `systemctl --user` não existe.

```bash
bash void-qtile/install.sh
```

## Fixes v3

- `fixes-v3.sh`: term-hub atualizado e launcher oculto/renomeado (0-default-remove_and_hide).
- `install-grub.sh`: GRUB com tema bsol (`grub-mkconfig`). Usa `--no-nvram` para não alterar a ordem UEFI.
- Registro da máquina em `PROGRESSO.md`.
