#!/usr/bin/env bash
# Ferramentas sem pacote independente no repositorio Mocaccino.
set -euo pipefail
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$HOME/.local/bin"
curl -fsSL https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -o "$work/eza.tar.gz"
tar -xzf "$work/eza.tar.gz" -C "$work" eza
install -m755 "$work/eza" "$HOME/.local/bin/eza"
curl -fsSL https://github.com/ajeetdsouza/zoxide/releases/download/v0.10.0/zoxide-0.10.0-x86_64-unknown-linux-musl.tar.gz -o "$work/zoxide.tar.gz"
tar -xzf "$work/zoxide.tar.gz" -C "$work" zoxide
install -m755 "$work/zoxide" "$HOME/.local/bin/zoxide"
curl -fsSL https://github.com/sharkdp/fd/releases/download/v10.5.2/fd-v10.5.2-x86_64-unknown-linux-musl.tar.gz -o "$work/fd.tar.gz"
tar -xzf "$work/fd.tar.gz" -C "$work"
install -m755 "$work/fd-v10.5.2-x86_64-unknown-linux-musl/fd" "$HOME/.local/bin/fd"
curl -fsSL https://github.com/dalance/procs/releases/download/v0.14.12/procs-v0.14.12-x86_64-linux.zip -o "$work/procs.zip"
unzip -oq "$work/procs.zip" -d "$work/procsdir"
install -m755 "$work/procsdir/procs" "$HOME/.local/bin/procs"
curl -fsSL https://github.com/jesseduffield/lazygit/releases/download/v0.66.3/lazygit_0.66.3_linux_x86_64.tar.gz -o "$work/lazygit.tar.gz"
tar -xzf "$work/lazygit.tar.gz" -C "$work" lazygit
install -m755 "$work/lazygit" "$HOME/.local/bin/lazygit"
curl -fsSL https://github.com/tealdeer-rs/tealdeer/releases/download/v1.9.1/tealdeer-linux-x86_64-musl -o "$work/tldr"
install -m755 "$work/tldr" "$HOME/.local/bin/tldr"
curl -fsSL https://github.com/sentriz/cliphist/releases/download/v0.7.0/v0.7.0-linux-amd64 -o "$work/cliphist"
install -m755 "$work/cliphist" "$HOME/.local/bin/cliphist"
for path in s/slurp/slurp_1.5.0-1_amd64.deb p/playerctl/playerctl_2.4.1-3_amd64.deb p/playerctl/libplayerctl2_2.4.1-3_amd64.deb; do
 file="$work/${path##*/}"; curl -fsSL "https://deb.debian.org/debian/pool/main/$path" -o "$file"
 bsdtar -xOf "$file" data.tar.xz | tar -xJf - -C "$work"
done
if ldd "$work/usr/bin/slurp" | grep -q 'not found'; then echo 'slurp: bibliotecas ausentes' >&2; exit 1; fi
install -m755 "$work/usr/bin/slurp" "$HOME/.local/bin/slurp"
lib="$work/usr/lib/x86_64-linux-gnu"
if LD_LIBRARY_PATH="$lib" ldd "$work/usr/bin/playerctl" | grep -q 'not found'; then echo 'playerctl: bibliotecas ausentes' >&2; exit 1; fi
install -Dm755 "$work/usr/bin/playerctl" "$HOME/.local/libexec/mocaccino-playerctl/playerctl"
mkdir -p "$HOME/.local/libexec/mocaccino-playerctl/lib"
cp -a "$lib/"*playerctl* "$HOME/.local/libexec/mocaccino-playerctl/lib/"
cat > "$HOME/.local/bin/playerctl" <<'WRAPPER'
#!/bin/sh
export LD_LIBRARY_PATH="$HOME/.local/libexec/mocaccino-playerctl/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
exec "$HOME/.local/libexec/mocaccino-playerctl/playerctl" "$@"
WRAPPER
chmod 755 "$HOME/.local/bin/playerctl"
