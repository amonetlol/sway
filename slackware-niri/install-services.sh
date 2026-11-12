#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
sudo -v
sudo chmod +x /etc/rc.d/rc.messagebus /etc/rc.d/rc.elogind /etc/rc.d/rc.sshd /etc/rc.d/rc.4
[[ ! -f /etc/rc.d/rc.vmtoolsd ]] || sudo chmod +x /etc/rc.d/rc.vmtoolsd
# Preserve o cliente DHCP ativo, evitando queda do acesso SSH.
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/90-sway-slackware.conf >/dev/null <<'EOF'
[keyfile]
unmanaged-devices=interface-name:eth0
EOF
sudo chmod +x /etc/rc.d/rc.networkmanager
sudo /etc/rc.d/rc.messagebus status >/dev/null 2>&1 || sudo /etc/rc.d/rc.messagebus start
sudo /etc/rc.d/rc.networkmanager start
if [[ -x /etc/rc.d/rc.vmtoolsd ]]; then
  if ! grep -q 'sway-slackware vmtools' /etc/rc.d/rc.local; then
    sudo cp -an /etc/rc.d/rc.local /etc/rc.d/rc.local.before-sway-slackware
    printf '\n# sway-slackware vmtools\n[ ! -x /etc/rc.d/rc.vmtoolsd ] || /etc/rc.d/rc.vmtoolsd start\n' | sudo tee -a /etc/rc.d/rc.local >/dev/null
  fi
  sudo chmod +x /etc/rc.d/rc.local
  sudo /etc/rc.d/rc.vmtoolsd start
fi
sudo cp -an /etc/inittab /etc/inittab.before-sway-slackware
sudo sed -i 's/^id:3:initdefault:/id:4:initdefault:/' /etc/inittab
log 'SDDM no runlevel 4; SSH/elogind/DBus habilitados. GRUB existente preservado.'
