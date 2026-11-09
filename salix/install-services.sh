#!/usr/bin/env bash
source "$(dirname "$0")/common.sh"
sudo chmod +x /etc/rc.d/rc.messagebus /etc/rc.d/rc.elogind /etc/rc.d/rc.sshd /etc/rc.d/rc.4
[[ ! -f /etc/rc.d/rc.vmtoolsd ]] || sudo chmod +x /etc/rc.d/rc.vmtoolsd
sudo mkdir -p /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/90-sway-salix.conf >/dev/null <<'EOF'
[keyfile]
unmanaged-devices=interface-name:eth0
EOF
if [[ -f /etc/rc.d/rc.networkmanager ]]; then
  sudo chmod +x /etc/rc.d/rc.networkmanager
  sudo /etc/rc.d/rc.networkmanager start || true
fi
sudo /etc/rc.d/rc.messagebus status >/dev/null 2>&1 || sudo /etc/rc.d/rc.messagebus start || true
if [[ -x /etc/rc.d/rc.elogind ]]; then
  sudo /etc/rc.d/rc.elogind start || true
fi
if [[ -x /etc/rc.d/rc.vmtoolsd ]]; then
  if ! grep -q 'sway-salix vmtools' /etc/rc.d/rc.local; then
    sudo cp -an /etc/rc.d/rc.local /etc/rc.d/rc.local.before-sway-salix
    printf '\n# sway-salix vmtools\n[ ! -x /etc/rc.d/rc.vmtoolsd ] || /etc/rc.d/rc.vmtoolsd start\n' | sudo tee -a /etc/rc.d/rc.local >/dev/null
  fi
  sudo chmod +x /etc/rc.d/rc.local
  sudo /etc/rc.d/rc.vmtoolsd start || true
fi
sudo cp -an /etc/inittab /etc/inittab.before-sway-salix
sudo sed -i 's/^id:[0-9]:initdefault:/id:4:initdefault:/' /etc/inittab
log 'SDDM no runlevel 4. SSH permanece no boot e eth0 continua no DHCP.'
