#!/usr/bin/env bash
# Aplica temas do waybar ou do rofi.
# Uso: theme-apply.sh init | waybar <tema> | rofi <tema>
set -euo pipefail

CFG="$HOME/.config"
STATE="$HOME/.local/state/hakuspace"

write_palette() {
    # Paleta Catppuccin Frappe Blue (mesma do sway-full)
    mkdir -p "$STATE/theme/opaque"
    cat > "$STATE/theme/colors.css" <<'EOF'
@define-color accent_color #8caaee;
@define-color background #303446;
@define-color foreground #c6d0f5;
EOF
    cat > "$STATE/theme/fonts.css" <<'EOF'
* {
    font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
}
EOF
    : > "$STATE/theme/opaque/waybar.css"
    cat > "$STATE/theme/rofi-style.rasi" <<'EOF'
* {
    accent:     #8caaee;
    accent-dim: #626880;
    background: #303446;
    foreground: #c6d0f5;
}
EOF
    printf '/* sem overrides */\n' > "$STATE/theme/opaque/rofi.rasi"
}

apply_waybar() {
    local t="$1" dir="$CFG/waybar/$1"
    if [[ ! -f "$dir/config" || ! -f "$dir/style.css" ]]; then
        echo "tema waybar invalido: $t" >&2
        exit 1
    fi
    cp "$dir/config" "$CFG/waybar/config"
    cp "$dir/style.css" "$CFG/waybar/style.css"
    echo "$t" > "$STATE/waybar-theme"
    pkill -x waybar 2>/dev/null || true
    (waybar >/dev/null 2>&1 &)
}

apply_rofi() {
    local t="$1"
    if [[ ! -f "$CFG/rofi/themes/$t.rasi" ]]; then
        echo "tema rofi invalido: $t" >&2
        exit 1
    fi
    printf '@import "%s/.config/rofi/themes/%s.rasi"\n' "$HOME" "$t" > "$STATE/rofi-theme.rasi"
    echo "$t" > "$STATE/rofi-theme-name"
}

case "${1:-}" in
    init)
        write_palette
        [[ -f "$STATE/rofi-theme.rasi" ]] || apply_rofi legacy
        [[ -f "$CFG/waybar/config" ]] || { cp "$CFG/waybar/top/config" "$CFG/waybar/config"; cp "$CFG/waybar/top/style.css" "$CFG/waybar/style.css"; echo top > "$STATE/waybar-theme"; }
        ;;
    waybar) apply_waybar "${2:?informe o tema}" ;;
    rofi) apply_rofi "${2:?informe o tema}" ;;
    *) echo "uso: $0 init | waybar <tema> | rofi <tema>" >&2; exit 2 ;;
esac