#!/usr/bin/env bash
set -euo pipefail
fail=0
ok() { printf 'OK %s\n' "$*"; }
bad() { printf 'FALTA %s\n' "$*" >&2; fail=1; }
export PATH="$HOME/.local/bin:$HOME/.bin:/usr/local/bin:$PATH"
commands=(
  sway swaymsg swaybg swaylock swayidle waybar rofi wlogout kitty
  cliphist wl-copy wl-paste mako playerctl grim slurp nautilus firefox
  pavucontrol btop fastfetch starship nvim jq loginctl vmtoolsd
  fd fzf duf pactl awww awww-daemon subl
)
for cmd in "${commands[@]}"; do
  if path=$(command -v "$cmd"); then ok "$cmd: $path"; else bad "$cmd"; fi
done
modules=(
  ".bashrc|bash"
  ".bin|bin"
  ".config/btop/themes|btop"
  ".config/fastfetch|fastfetch"
  ".fonts|fonts"
  ".config/starship-nord.toml|starship"
  ".config/nvim|nvim"
  ".config/kitty/kitty.conf|kitty"
  ".local/bin/hide-shortcuts|hide-shortcuts"
  ".local/bin/recovery-shortcuts|recovery-shortcuts"
  "Imagens/wallpapers|wallpapers"
  ".aliases-antix|aliases"
  ".var/app/com.sublimehq.SublimeText/config/sublime-text/Packages/User/Preferences.sublime-settings|sublime-text"
)
for item in "${modules[@]}"; do
  rel=${item%%|*}; name=${item#*|}
  if [[ -e $HOME/$rel ]]; then ok "modulo $name: $rel"; else bad "modulo $name ($rel)"; fi
done
wall_count=$(find "$HOME/Imagens/wallpapers" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf . 2>/dev/null | wc -c)
if [[ ${wall_count:-0} -gt 0 ]]; then
  ok "wallpapers com imagens ($wall_count)"
else
  bad "pasta de wallpapers vazia"
fi
layout=$HOME/.config/wlogout/layout
python3 - "$layout" <<'PY'
import json, shlex, sys
from pathlib import Path
layout = Path(sys.argv[1])
rows = json.loads("[" + layout.read_text(encoding="utf-8") + "]")
missing = []
for row in rows:
    args = shlex.split(row["action"])
    if not Path(args[0]).is_file():
        missing.append(row["label"] + " sem executavel " + args[0])
    elif Path(args[0]).name in {"loginctl", "systemctl", "66"}:
        import subprocess
        help_text = subprocess.check_output([args[0], "--help"], text=True, stderr=subprocess.STDOUT)
        if args[1] not in help_text:
            missing.append(row["label"] + " comando invalido " + args[1])
    print("OK wlogout " + row["label"] + ": " + row["action"])
if missing:
    raise SystemExit("\n".join(missing))
PY
for script in "$HOME/.config/wlogout/launch.sh" "$HOME/.config/wlogout/session-action.sh" "$HOME/.local/bin/start-sway-full" "$HOME/.local/bin/sway-session-init"; do
  if [[ -f $script ]]; then bash -n "$script" && ok "sintaxe $script"; else bad "script $script"; fi
done
session_dir=/usr/local/share/sddm/sway-sessions
names=()
while IFS= read -r desktop; do
  name=$(awk -F= '/^Name=/ {print $2; exit}' "$desktop")
  names+=("$name")
done < <(find "$session_dir" -maxdepth 1 -name '*.desktop' | sort)
if [[ ${#names[@]} -eq 1 && ${names[0]} == Sway ]]; then
  ok "SDDM: uma sessao Sway"
else
  bad "SDDM sessoes: ${names[*]:-nenhuma}"
fi
if grep -q '^SessionDir=/usr/local/share/sddm/sway-sessions$' /etc/sddm.conf.d/96-sway-session.conf; then
  ok "SDDM SessionDir isolado"
else
  bad "SDDM SessionDir"
fi
if sudo 66 status sddm | grep -Eq 'Status[[:space:]]*:[[:space:]]*enabled'; then ok "sddm habilitado"; else bad "sddm habilitado"; fi
if sudo 66 status sshd | grep -Eq 'Status[[:space:]]*:[[:space:]]*enabled'; then ok "ssh habilitado"; else bad "ssh habilitado"; fi
if sudo test -d /boot/efi/EFI/antix || sudo test -d /boot/efi/EFI/BOOT; then ok "GRUB EFI antiX preservado"; else bad "GRUB EFI antiX"; fi
aliases=$(bash -ic 'alias up2; alias yin' 2>/dev/null || true)
if grep -q 'apt update' <<<"$aliases"; then ok "alias up2"; else bad "alias up2"; fi
if grep -q 'apt install -y' <<<"$aliases"; then ok "alias yin"; else bad "alias yin"; fi
if [[ $fail -ne 0 ]]; then
  echo "Verificacao falhou." >&2
  exit 1
fi
echo "Verificacao de pacotes, modulos, SDDM e comandos wlogout: OK"
