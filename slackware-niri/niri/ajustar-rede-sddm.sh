#!/usr/bin/env bash
# Executar como root no Slackware da TWO; reaplicar a rede interrompe o SSH.
set -euo pipefail
cp -n /etc/sddm.conf /etc/sddm.conf.before-ff-virtual-keyboard
sed -i 's/^InputMethod=qtvirtualkeyboard$/InputMethod=/' /etc/sddm.conf
nmcli connection modify 'TWO Ethernet' ipv4.method manual ipv4.addresses 192.168.86.128/24 ipv4.gateway 192.168.86.2 ipv4.dns 192.168.86.2
nmcli device reapply eth0
