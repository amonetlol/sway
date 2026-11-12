#!/bin/bash
# Seletor de wallpapers para Sway com tema Rofi-02 e miniaturas.
# Thumbnails are generated once with imagemagick and cached in
# ~/.cache/wallpaper-thumbs (regenerated when a wallpaper file changes).
# Escape in rofi = cancel, nothing changes.
# A imagem escolhida e aplicada pelo awww com transicao suave.
WALLPAPER_DIR="$HOME/Imagens/wallpapers"
THUMB_DIR="$HOME/.cache/wallpaper-thumbs"
THUMB_SIZE="96x54"   # resolution of the cached preview images
ICON_DISPLAY="48"    # preview size in the menu, in pixels

mkdir -p "$THUMB_DIR"

[ -d "$WALLPAPER_DIR" ] || { notify-send "Wallpaper" "Folder not found: $WALLPAPER_DIR" 2>/dev/null; exit 1; }

mapfile -t WALLS < <(find "$WALLPAPER_DIR" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort)

[ ${#WALLS[@]} -gt 0 ] || { notify-send "Wallpaper" "No images in $WALLPAPER_DIR" 2>/dev/null; exit 1; }

SELECTED=$(
    for wall in "${WALLS[@]}"; do
        name=$(basename "$wall")
        thumb="$THUMB_DIR/$name.png"
        if [ ! -f "$thumb" ] || [ "$wall" -nt "$thumb" ]; then
            magick "$wall" -resize "$THUMB_SIZE" "$thumb" 2>/dev/null || { printf '%s\n' "$name"; continue; }
        fi
        printf '%s\0icon\x1f%s\n' "$name" "$thumb"
    done | rofi -dmenu -show-icons -i -p "Wallpapers" -theme "$HOME/.config/rofi/wallpaper.rasi" \
          -theme-str "element-icon { size: ${ICON_DISPLAY}px; }"
)

[ -n "$SELECTED" ] || exit 0

TARGET="$WALLPAPER_DIR/$SELECTED"
[ -f "$TARGET" ] || exit 0

bash "$HOME/.local/bin/random-wallpaper.sh" "$TARGET"
