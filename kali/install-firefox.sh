#!/usr/bin/env bash
# Firefox atual em deb, do repositório da Mozilla. O Kali só publica o ESR.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum, com sudo." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
sudo -n true
sudo install -d -m 0755 /etc/apt/keyrings
key="$(mktemp)"
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg -o "$key"
sudo install -m 0644 "$key" /etc/apt/keyrings/packages.mozilla.org.asc
rm -f "$key"
sudo tee /etc/apt/sources.list.d/mozilla.sources >/dev/null <<'EOF'
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
sudo tee /etc/apt/preferences.d/mozilla >/dev/null <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
sudo apt-get update
if [[ -L /usr/local/bin/firefox ]]; then
  sudo rm -f /usr/local/bin/firefox
fi
esr=()
for package in firefox-esr firefox-esr-l10n-pt-br; do
  status=$(dpkg-query -W -f='${db:Status-Status}' "$package" 2>/dev/null || true)
  case "$status" in installed|config-files) esr+=("$package");; esac
done
if ((${#esr[@]})); then
  sudo apt-get -y --solver=internal --no-install-recommends purge "${esr[@]}"
  log "Removido: ${esr[*]}"
fi
sudo apt-get install -y --solver=internal --no-install-recommends firefox firefox-l10n-pt-br
log "Firefox deb: $(firefox --version)"
