#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
sudo -v
mkdir -p "$cache/src" "$cache/tools"
build_meson() {
  local url="$1" name="$2"
  shift 2
  local src="$cache/src/$name"
  rm -rf "$src"
  mkdir -p "$cache/src"
  download "$url" "$cache/src/$name.tar.gz"
  mkdir -p "$src"
  tar -xf "$cache/src/$name.tar.gz" -C "$src" --strip-components=1
  meson setup "$src/build" "$src" --prefix=/usr "$@"
  meson compile -C "$src/build" -j 2
  sudo meson install -C "$src/build"
  log "Instalado: $name"
}
build_meson https://github.com/swaywm/swaylock/archive/refs/tags/1.6.tar.gz swaylock -Dpam=enabled -Dman-pages=disabled
build_meson https://github.com/swaywm/swayidle/archive/refs/tags/1.7.1.tar.gz swayidle -Dman-pages=disabled
build_meson https://github.com/emersion/slurp/archive/refs/tags/v1.4.0.tar.gz slurp -Dman-pages=disabled
build_meson https://github.com/emersion/mako/archive/refs/tags/v1.7.1.tar.gz mako -Dman-pages=disabled -Dicons=enabled
build_meson https://github.com/ArtsyMacaw/wlogout/archive/refs/tags/1.2.2.tar.gz wlogout
sudo ldconfig
download https://github.com/sentriz/cliphist/releases/download/v0.7.0/v0.7.0-linux-amd64 "$cache/tools/cliphist"
sudo install -m755 "$cache/tools/cliphist" /usr/local/bin/cliphist
download https://github.com/fastfetch-cli/fastfetch/releases/download/2.71.0/fastfetch-linux-amd64.tar.gz "$cache/src/fastfetch.tar.gz"
rm -rf "$cache/src/fastfetch"
mkdir -p "$cache/src/fastfetch"
tar -xf "$cache/src/fastfetch.tar.gz" -C "$cache/src/fastfetch"
sudo install -m755 "$cache/src/fastfetch/fastfetch-linux-amd64/usr/bin/fastfetch" /usr/local/bin/fastfetch
download https://github.com/junegunn/fzf/releases/download/v0.75.0/fzf-0.75.0-linux_amd64.tar.gz "$cache/src/fzf.tar.gz"
tar -xf "$cache/src/fzf.tar.gz" -C "$cache/tools"
sudo install -m755 "$cache/tools/fzf" /usr/local/bin/fzf
download https://raw.githubusercontent.com/junegunn/fzf/v0.75.0/bin/fzf-tmux "$cache/tools/fzf-tmux"
sudo install -m755 "$cache/tools/fzf-tmux" /usr/local/bin/fzf-tmux
download https://github.com/sharkdp/fd/releases/download/v10.5.2/fd-v10.5.2-x86_64-unknown-linux-musl.tar.gz "$cache/src/fd.tar.gz"
rm -rf "$cache/src/fd"
mkdir -p "$cache/src/fd"
tar -xf "$cache/src/fd.tar.gz" -C "$cache/src/fd"
sudo install -m755 "$cache/src/fd/fd-v10.5.2-x86_64-unknown-linux-musl/fd" /usr/local/bin/fd
download https://github.com/muesli/duf/releases/download/v0.9.1/duf_0.9.1_linux_x86_64.tar.gz "$cache/src/duf.tar.gz"
rm -rf "$cache/src/duf"
mkdir -p "$cache/src/duf"
tar -xf "$cache/src/duf.tar.gz" -C "$cache/src/duf"
sudo install -m755 "$cache/src/duf/duf" /usr/local/bin/duf
if [[ ! -x /usr/bin/subl ]]; then
  sublime_build=$(curl -fsSL https://www.sublimetext.com/updates/4/stable_update_check | python3 -c 'import json,sys; print(json.load(sys.stdin)["latest_version"])')
  download "https://download.sublimetext.com/sublime_text_build_${sublime_build}_x64.tar.xz" "$cache/src/sublime.tar.xz"
  sudo mkdir -p /opt
  sudo tar -xf "$cache/src/sublime.tar.xz" -C /opt
  sudo ln -sfn /opt/sublime_text/sublime_text /usr/bin/subl
fi
for cmd in swaylock swayidle slurp mako wlogout cliphist fastfetch fzf fd duf subl; do
  command -v "$cmd" >/dev/null || fail "Ferramenta ausente apos a etapa gaps: $cmd"
done
log 'Ferramentas ausentes no repositorio instaladas. Sem Neovim e sem Kitty.'
