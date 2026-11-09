# Void + Sway Full

As configs ficam em `sway-full`. Esta pasta instala com xbps, GRUB, SDDM via runit e os módulos do GitHub (`sublime-text.sh` incluído).

O Void não usa systemd. Waybar e awww sobem pelo `sway-session-init` quando o `systemctl --user` não existe.

```bash
bash void/install.sh
```
