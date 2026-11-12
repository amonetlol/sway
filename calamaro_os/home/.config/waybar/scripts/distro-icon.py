#!/usr/bin/env python3
# Icone da distro (Nerd Font) a partir de /etc/os-release. Usa o ID; fallback: tux.
import os, re
ICONS = {
    "arch": "\uf303", "artix": "\uf303", "endeavouros": "\uf303", "cachyos": "\uf303",
    "debian": "\uf306", "antix": "\uf306", "kali": "\uf306", "mx": "\uf306",
    "ubuntu": "\uf31b", "pop": "\uf31b", "linuxmint": "\uf30e",
    "fedora": "\uf30a", "nixos": "\uf313", "opensuse-tumbleweed": "\uf314",
    "opensuse-leap": "\uf314", "opensuse": "\uf314", "gentoo": "\uf30d",
    "calculate": "\uf30d", "redcore": "\uf30d",
}
def read_id():
    data = {}
    for path in ("/etc/os-release", "/usr/lib/os-release"):
        try:
            for line in open(path, encoding="utf-8"):
                m = re.match(r'^([A-Z_]+)=(.*)$', line.strip())
                if m: data[m.group(1)] = m.group(2).strip('"\'')
            break
        except OSError:
            continue
    return data.get("ID", "").lower(), data.get("ID_LIKE", "").lower()
distro, like = read_id()
icon = ICONS.get(distro)
if icon is None:
    if os.path.exists("/etc/calamaroos"): icon = ICONS["gentoo"]
    else: icon = next((ICONS[w] for w in like.split() if w in ICONS), "\uf17c")
print(icon)
