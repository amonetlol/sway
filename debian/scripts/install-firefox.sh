#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
install -d -m755 /etc/apt/keyrings
curl -fsSL --retry 3 https://packages.mozilla.org/apt/repo-signing-key.gpg -o /etc/apt/keyrings/packages.mozilla.org.asc
fingerprint=$(gpg --show-keys --with-colons /etc/apt/keyrings/packages.mozilla.org.asc | awk -F: '$1=="fpr" {print $10;exit}')
[[ $fingerprint == 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3 ]] || { echo 'Chave Mozilla inesperada.' >&2; exit 1; }
chmod 644 /etc/apt/keyrings/packages.mozilla.org.asc
cat >/etc/apt/sources.list.d/mozilla.list <<'EOF'
deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main
EOF
cat >/etc/apt/preferences.d/mozilla <<'EOF'
Package: firefox firefox-l10n-*
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
apt-get update
apt-get install -y --no-install-recommends firefox firefox-l10n-pt-br
if dpkg-query -W -f='${db:Status-Status}' firefox-esr 2>/dev/null | grep -qx installed; then
 apt-get remove -y firefox-esr
fi
update-alternatives --set x-www-browser /usr/bin/firefox
