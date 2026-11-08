#!/usr/bin/env bash
# Copia o sway-full para o HOME e adapta caminhos do NixOS.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rice="$here/../sway-full"
[[ -f "$rice/.config/sway/config" ]] || { echo "Não encontrei sway-full ao lado de nixos." >&2; exit 1; }
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }

log "Copiando .config e .local"
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.config/systemd/user"
shopt -s dotglob
for src in "$rice/.config/"*; do
  name="$(basename "$src")"
  [[ "$name" == systemd ]] && continue
  rm -rf "$HOME/.config/$name"
  cp -a "$src" "$HOME/.config/$name"
done
for src in "$rice/.local/bin/"*; do
  name="$(basename "$src")"
  rm -rf "$HOME/.local/bin/$name"
  cp -a "$src" "$HOME/.local/bin/$name"
done
cp -a "$rice/.config/systemd/user/." "$HOME/.config/systemd/user/"
shopt -u dotglob

python3 - "$HOME/.config/sway/config" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
s = p.read_text()
s = s.replace("swaybg_command -\n", "")
old = """input type:keyboard {
    xkb_layout br
    xkb_model abnt2
}"""
new = """input type:keyboard {
    xkb_layout br
    xkb_variant abnt2
    xkb_model pc105
}"""
s = s.replace(old, new)
s = s.replace("/usr/bin/gnome-keyring-daemon", "gnome-keyring-daemon")
s = s.replace("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1", "polkit-gnome-authentication-agent-1")
s = s.replace("/usr/bin/vmware-user-suid-wrapper", "/run/wrappers/bin/vmware-user-suid-wrapper")
p.write_text(s)
PY

sed -i \
  -e 's#/usr/bin/kitty#kitty#' \
  -e 's#/usr/bin/nautilus#nautilus#' \
  -e 's#/usr/bin/pavucontrol#pavucontrol#' \
  -e 's#/usr/bin/btop#btop#' \
  -e 's#/usr/bin/wlogout#wlogout#' \
  -e 's#/usr/bin/sway#sway#' \
  "$HOME/.local/bin/kitty-sway" \
  "$HOME/.local/bin/nautilus-sway" \
  "$HOME/.local/bin/pavucontrol" \
  "$HOME/.local/bin/btop-float" \
  "$HOME/.config/wlogout/launch.sh" \
  "$HOME/.local/bin/start-sway-full"

# O awww quebra no SVGA da VMware e deixa a tela preta se reiniciar em loop.
sed -i 's/^Restart=on-failure/Restart=no/' "$HOME/.config/systemd/user/awww.service" || true
sed -i \
  -e 's#/usr/bin/test#/run/current-system/sw/bin/test#' \
  -e 's#/usr/bin/awww-daemon#/run/current-system/sw/bin/awww-daemon#' \
  -e 's#/usr/bin/systemd-inhibit#/run/current-system/sw/bin/systemd-inhibit#' \
  -e 's#/usr/bin/sleep#/run/current-system/sw/bin/sleep#' \
  "$HOME/.config/systemd/user/awww.service" \
  "$HOME/.config/systemd/user/caffeine.service"

wall="$(find "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) | sort | head -n 1 || true)"
if [[ -n $wall ]] && ! grep -q '^output \* bg ' "$HOME/.config/sway/config"; then
  printf 'output * bg %s fill\n%s' "$wall" "$(cat "$HOME/.config/sway/config")" > "$HOME/.config/sway/config"
fi

# Saída limpa: o SDDM só volta ao greeter se o processo da sessão terminar com status 0.
cat > "$HOME/.local/bin/start-sway-full" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
export PATH="$HOME/.local/bin:$PATH"
export XDG_CURRENT_DESKTOP=sway XDG_SESSION_DESKTOP=sway XDG_SESSION_TYPE=wayland
export XCURSOR_THEME=Vimix-cursors XCURSOR_SIZE=24
export LANG=pt_BR.UTF-8
if [[ $(systemd-detect-virt 2>/dev/null || true) == vmware ]]; then
  export WLR_NO_HARDWARE_CURSORS=1
fi
cleanup() { systemctl --user stop sway-session.target 2>/dev/null || true; }
trap cleanup EXIT
sway "$@"
exit 0
EOF

cat > "$HOME/.config/wlogout/session-action.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
case "${1:-}" in
  lock) exec swaylock -f -c 303446 ;;
  logout) swaymsg exit; exit 0 ;;
  *) echo 'Uso: session-action.sh lock|logout' >&2; exit 2 ;;
esac
EOF

while IFS= read -r -d '' file; do
  [[ $(head -n 1 "$file") == '#!'* ]] && chmod +x "$file"
done < <(find "$HOME/.local/bin" "$HOME/.config/wlogout" "$HOME/.config/kitty" "$HOME/.config/rofi-wallpaper" -type f -print0)
log "Sway instalado em ~/.config/sway e scripts em ~/.local/bin."
