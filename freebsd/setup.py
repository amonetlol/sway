from pathlib import Path
import json, re, subprocess
h=Path.home()
p=h/'.config/sway/config'; s=p.read_text()
s=s.replace('set $term ~/.local/bin/kitty-sway','set $term foot')
s=s.replace('output Virtual-1 mode 1920x1080 position 0,0 scale 1','output X11-1 mode 1920x1080')
s=s.replace('# Saida detectada automaticamente','output X11-1 mode 1920x1080')
if 'output X11-1 mode 1920x1080' not in s:
    s+='\noutput X11-1 mode 1920x1080\n'
s=s.replace('systemctl reboot --firmware-setup','true').replace('systemctl poweroff -i','sudo /sbin/shutdown -p now').replace('systemctl suspend','true').replace('systemctl reboot','sudo /sbin/shutdown -r now')
s='\n'.join(x for x in s.split('\n') if not any(q in x for q in ('swayosd-client','swayosd-server','vmware-user-suid-wrapper','/usr/bin/gnome-keyring-daemon','/usr/libexec/polkit-gnome','waybar-player-watch','bindsym XF86AudioRaiseVolume','bindsym XF86AudioLowerVolume','bindsym XF86AudioMute')))
s+='\nbindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5%\nbindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5%\nbindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle\n'
p.write_text(s)
p=h/'.config/wlogout/layout';s=p.read_text().replace('/usr/bin/swaylock','/usr/local/bin/swaylock').replace('/usr/bin/swaymsg','/usr/local/bin/swaymsg').replace('/usr/bin/loginctl poweroff','sudo /sbin/shutdown -p now').replace('/usr/bin/loginctl reboot','sudo /sbin/shutdown -r now');p.write_text(s)
p=h/'.config/wlogout/launch.sh';p.write_text(p.read_text().replace('/usr/bin/wlogout','/usr/local/bin/wlogout'))
p=h/'.config/waybar/config'
cfg=json.loads(p.read_text())
for key in ('modules-left','modules-center','modules-right'):
    if isinstance(cfg.get(key), list):
        cfg[key]=['custom/network' if item=='network' else item for item in cfg[key]]
cfg['custom/network']={'exec':str(h/'.local/bin/waybar-network'),'return-type':'json','interval':5,'tooltip':True,'on-click':str(h/'.local/bin/rofi-network-menu')}
p.write_text(json.dumps(cfg, indent=4, ensure_ascii=False)+'\n')
css=h/'.config/waybar/style.css'
if css.is_file():
    t=css.read_text()
    t=t.replace('#pulseaudio, #bluetooth, #network {','#pulseaudio, #bluetooth, #network, #custom-network {')
    t=t.replace('#network.disconnected { color: @red; }','#network.disconnected, #custom-network.disconnected { color: @red; }')
    css.write_text(t)
for rel in ('.local/bin/btop-float','.local/bin/show-hotkeys','.local/bin/ssh-hub.d/tmux.conf','.local/bin/term-hub.d/tmux.conf'):
 p=h/rel
 if p.is_file():
  s=p.read_text().replace('"$HOME/.local/bin/kitty-sway" --class btop --title btop /usr/bin/btop','foot -a btop -T btop btop').replace('"$HOME/.local/bin/kitty-sway"','foot').replace('nvim ', 'micro ');p.write_text(s)
for name in ('nautilus-sway', 'pavucontrol'):
 p=h/'.local/bin'/name
 if p.is_file():
  s=p.read_text().replace('#!/usr/local/bin/env','#!/usr/bin/env').replace('/usr/bin/env','\0ENV\0').replace('/usr/bin/','/usr/local/bin/').replace('\0ENV\0','/usr/bin/env')
  p.write_text(s); p.chmod(0o755)
p=h/'.local/bin/waybar-network';p.write_text(r'''#!/usr/bin/env python3
import json, re, subprocess
text = subprocess.check_output(["ifconfig"], text=True, errors="replace")
chosen = None
for block in re.split(r"\n(?=\S)", text.strip() + "\n"):
    if ":" not in block:
        continue
    name = block.split(":", 1)[0]
    if name == "lo0":
        continue
    flags = set()
    match = re.search(r"flags=\d+<([^>]*)>", block)
    if match:
        flags = set(match.group(1).split(","))
    if "UP" not in flags:
        continue
    inet = re.search(r"\binet (\d+\.\d+\.\d+\.\d+)", block)
    ip = inet.group(1) if inet else ""
    chosen = (name, ip)
    if ip:
        break
if not chosen or not chosen[1]:
    tip = "Sem rede" if not chosen else chosen[0]
    print(json.dumps({"text": "\uf071", "tooltip": tip, "class": "disconnected"}, ensure_ascii=False))
else:
    name, ip = chosen
    print(json.dumps({"text": "\uf796", "tooltip": name + "\n" + ip, "class": "connected"}, ensure_ascii=False))
''');p.chmod(0o755)
p=h/'.local/bin/rofi-network-menu';p.write_text('''#!/usr/bin/env python3
import re, subprocess
text = subprocess.check_output(["ifconfig"], text=True, errors="replace")
rows = []
for block in re.split(r"\\n(?=\\S)", text.strip() + "\\n"):
    if ":" not in block:
        continue
    name = block.split(":", 1)[0]
    if name == "lo0":
        continue
    flags = set()
    match = re.search(r"flags=\\d+<([^>]*)>", block)
    if match:
        flags = set(match.group(1).split(","))
    inet = re.search(r"\\binet (\\d+\\.\\d+\\.\\d+\\.\\d+)", block)
    ip = inet.group(1) if inet else "sem endereco"
    state = "up" if "RUNNING" in flags else "down"
    rows.append(f"{name}  {state}  {ip}")
if not rows:
    rows = ["Sem interface"]
subprocess.run(["rofi", "-dmenu", "-i", "-p", "Rede", "-no-custom"], input="\\n".join(rows) + "\\n", text=True)
''');p.chmod(0o755)
p=h/'.config/rofi-wallpaper/launch.sh'
if p.is_file(): p.chmod(0o755)
p=h/'.local/bin/random-wallpaper.sh'
if p.is_file():
 s=p.read_text().replace('| shuf -n 1','| gshuf -n 1')
 p.write_text(s); p.chmod(0o755)
p=h/'.local/bin/mon'
if p.is_file() and 'select(.focused)' not in p.read_text():
 t=p.read_text()
 new='''apply_sway() {
  local outputs current target name reply
  outputs="$(swaymsg -r -t get_outputs)"
  name="$(jq -r '.[] | select(.focused) | .name' <<< "$outputs")"
  [[ -n "$name" && "$name" != "null" ]] || name="$(jq -r '.[] | select(.active) | .name' <<< "$outputs" | head -n 1)"
  current="$(jq -r --arg name "$name" '.[] | select(.name == $name) | "\\(.current_mode.width)x\\(.current_mode.height)"' <<< "$outputs")"
  [[ -n "$current" && "$current" != "x" ]] || { echo "Nenhuma saida sway ativa" >&2; return 1; }
  target="$(next_res "$current")"
  reply="$(swaymsg -r "output ${name} mode --custom ${target}")"
  jq -e 'all(.[]; .success == true)' <<< "$reply" >/dev/null
  notify "${current} → ${target}"
}

'''
 t2,n=re.subn(r'apply_sway\(\) \{.*?\n\}\n\n', new, t, count=1, flags=re.S)
 if n: p.write_text(t2)
p=h/'.config/starship.toml'
if p.is_file():
 t=p.read_text()
 if 'FreeBSD =' not in t and '[os.symbols]' in t:
  p.write_text(t.replace('[os.symbols]\n','[os.symbols]\nFreeBSD = "\uf30c "\n',1))
apps=h/'.local/share/applications'
apps.mkdir(parents=True, exist_ok=True)
for name in ('btop.desktop','foot.desktop','footclient.desktop','foot-server.desktop','micro.desktop','gtk3-demo.desktop','org.gtk.Demo4.desktop','org.gtk.gtk4.NodeEditor.desktop','org.gtk.PrintEditor4.desktop','rofi.desktop','rofi-theme-selector.desktop','gtk3-widget-factory.desktop','org.gtk.WidgetFactory4.desktop'):
 src=Path('/usr/local/share/applications')/name
 if not src.is_file(): continue
 text=re.sub(r'^NoDisplay=.*\n','',src.read_text(errors='replace'),flags=re.M)
 (apps/name).write_text(text.replace('[Desktop Entry]','[Desktop Entry]\nNoDisplay=true',1))
subprocess.run(['update-desktop-database', str(apps)], check=False)
p=h/'.local/bin/set-x-mode.c';p.write_text(r'''#include <stdio.h>
#include <stdlib.h>
#include <X11/Xlib.h>
#include <X11/extensions/Xrandr.h>
#include <X11/extensions/xf86vmode.h>
static int use_vidmode(Display *dpy, int screen, int want_w, int want_h) {
    int event_base, error_base, count, i, best, best_area, w, h;
    XF86VidModeModeInfo **modes;
    if (!XF86VidModeQueryExtension(dpy, &event_base, &error_base)) return 0;
    if (!XF86VidModeGetAllModeLines(dpy, screen, &count, &modes)) return 0;
    best = -1; best_area = 0;
    for (i = 0; i < count; i++) {
        w = modes[i]->hdisplay; h = modes[i]->vdisplay;
        fprintf(stderr, "vidmode %dx%d\n", w, h);
        if (w == want_w && h == want_h) { best = i; break; }
        if (w >= 1280 && w <= want_w && h <= want_h && w * h > best_area) { best = i; best_area = w * h; }
    }
    if (best < 0 || !XF86VidModeSwitchToMode(dpy, screen, modes[best])) { XFree(modes); return 0; }
    XF86VidModeSetViewPort(dpy, screen, 0, 0);
    XFlush(dpy);
    fprintf(stderr, "ok vidmode %dx%d\n", modes[best]->hdisplay, modes[best]->vdisplay);
    XFree(modes);
    return 1;
}
static int use_randr(Display *dpy, int screen, int want_w, int want_h) {
    int event_base, error_base, count, i, best, best_area, w, h;
    XRRScreenSize *sizes;
    XRRScreenConfiguration *config;
    Window root;
    Rotation current;
    if (!XRRQueryExtension(dpy, &event_base, &error_base)) return 0;
    sizes = XRRSizes(dpy, screen, &count);
    if (!sizes || count < 1) return 0;
    best = -1; best_area = 0;
    for (i = 0; i < count; i++) {
        w = sizes[i].width; h = sizes[i].height;
        fprintf(stderr, "randr %dx%d\n", w, h);
        if (w == want_w && h == want_h) { best = i; break; }
        if (w >= 1280 && w <= want_w && h <= want_h && w * h > best_area) { best = i; best_area = w * h; }
    }
    if (best < 0) return 0;
    root = RootWindow(dpy, screen);
    config = XRRGetScreenInfo(dpy, root);
    if (!config) return 0;
    current = RR_Rotate_0;
    XRRConfigRotations(config, &current);
    if (XRRSetScreenConfig(dpy, config, root, best, current, CurrentTime) != Success) {
        XRRFreeScreenConfigInfo(config); return 0;
    }
    XFlush(dpy);
    fprintf(stderr, "ok randr %dx%d\n", sizes[best].width, sizes[best].height);
    XRRFreeScreenConfigInfo(config);
    return 1;
}
int main(int argc, char **argv) {
    int want_w = argc > 1 ? atoi(argv[1]) : 1920;
    int want_h = argc > 2 ? atoi(argv[2]) : 1080;
    Display *dpy = XOpenDisplay(NULL);
    int screen;
    if (!dpy) { fprintf(stderr, "sem display\n"); return 1; }
    screen = DefaultScreen(dpy);
    if (use_vidmode(dpy, screen, want_w, want_h) || use_randr(dpy, screen, want_w, want_h)) {
        XCloseDisplay(dpy); return 0;
    }
    fprintf(stderr, "modo alvo ausente\n");
    XCloseDisplay(dpy);
    return 1;
}
''')
subprocess.check_call(['/usr/bin/cc','-O2','-o',str(h/'.local/bin/set-x-mode'),str(p),'-I/usr/local/include','-L/usr/local/lib','-lX11','-lXrandr','-lXxf86vm'])
(h/'.local/bin/set-x-mode').chmod(0o755)
p=h/'.local/bin/wallpaper-freebsd';p.write_text('''#!/usr/bin/env python3
from pathlib import Path
import random, subprocess, time
directory = Path.home() / 'Imagens/wallpapers'
while True:
    files = [p for p in directory.rglob('*') if p.suffix.lower() in ('.jpg', '.jpeg', '.png', '.webp')]
    if files:
        subprocess.run(['awww', 'img', '--transition-type', 'fade', str(random.choice(files))], check=False)
    time.sleep(90)
''');p.chmod(0o755)
p=h/'.local/bin/sway-session-init';p.write_text('''#!/bin/sh
dbus-update-activation-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
for pid in $(ps -ax -o pid= -o comm= | awk '$2=="pipewire" || $2=="pipewire-pulse" || $2=="wireplumber" {print $1}'); do
  kill "$pid" 2>/dev/null || true
done
if ! pactl list short sinks 2>/dev/null | grep -q .; then
  pulseaudio --start --exit-idle-time=-1 --log-target=syslog || true
fi
awww-daemon &
(sleep 3; "$HOME/.local/bin/wallpaper-freebsd") &
waybar &
''');p.chmod(0o755)
p=h/'.local/bin/start-sway-freebsd';p.write_text('''#!/bin/sh
export XDG_CURRENT_DESKTOP=sway XDG_SESSION_DESKTOP=sway XDG_SESSION_TYPE=wayland
export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/sway-runtime-$(id -u)}
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"
export WLR_BACKENDS=x11 WLR_X11_OUTPUTS=1920x1080 WLR_RENDERER=pixman WLR_NO_HARDWARE_CURSORS=1
export EDITOR=micro VISUAL=micro
if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]; then exec dbus-run-session -- "$0" "$@"; fi
if [ -n "${DISPLAY:-}" ] && [ -x "$HOME/.local/bin/set-x-mode" ]; then
  "$HOME/.local/bin/set-x-mode" 1920 1080 || true
fi
exec sway "$@"
''');p.chmod(0o755)
