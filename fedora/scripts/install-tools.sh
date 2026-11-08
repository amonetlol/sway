#!/usr/bin/env bash
set -euo pipefail
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
work=/opt/sway-fedora/tools
mkdir -p "$work"
cd "$work"
# Fedora packaging recommended by the Ghostty project.
if ! command -v ghostty >/dev/null; then
 . /etc/os-release
 curl -fL --retry 3 "https://copr.fedorainfracloud.org/coprs/scottames/ghostty/repo/fedora-${VERSION_ID}/scottames-ghostty-fedora-${VERSION_ID}.repo" -o /etc/yum.repos.d/ghostty-copr.repo
 dnf install -y --setopt=install_weak_deps=False ghostty
fi
bash "$script_dir/install-quickshell.sh"
release_binary() {
 local command=$1 repo=$2 pattern=$3 archive=$4 member=$5 url
 command -v "$command" >/dev/null && return 0
 url=$(curl -fsSL --retry 3 "https://api.github.com/repos/$repo/releases/latest" | python3 -c 'import json,re,sys; p=sys.argv[1]; print(next(a["browser_download_url"] for a in json.load(sys.stdin)["assets"] if re.search(p,a["name"])))' "$pattern")
 curl -fL --retry 3 "$url" -o "$archive"
 case "$archive" in
  *.tar.gz) tar -xzf "$archive" "$member" ;;
  *.zip) unzip -o "$archive" "$member" ;;
  *) cp "$archive" "$member" ;;
 esac
 install -m755 "$member" "/usr/local/bin/$command"
}
release_binary lazygit jesseduffield/lazygit '(?i)linux_x86_64\.tar\.gz$' lazygit.tar.gz lazygit
release_binary starship starship/starship '^starship-x86_64-unknown-linux-musl\.tar\.gz$' starship.tar.gz starship
release_binary procs dalance/procs 'x86_64-linux\.zip$' procs.zip procs
release_binary tldr tealdeer-rs/tealdeer '^tealdeer-linux-x86_64-musl$' tealdeer-download tldr
if ! command -v tree-sitter >/dev/null; then npm install -g tree-sitter-cli; fi
if ! command -v prettier >/dev/null; then npm install -g prettier; fi
if ! command -v pipenv >/dev/null; then
 python3 -m venv "$work/pipenv"
 "$work/pipenv/bin/pip" install pipenv
 ln -sfn "$work/pipenv/bin/pipenv" /usr/local/bin/pipenv
fi
