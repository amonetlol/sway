from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Screen
from libqtile.lazy import lazy
import os
import subprocess

os.environ['GTK_THEME'] = 'KanagawaVoid-Dark'
os.environ['XDG_CURRENT_DESKTOP'] = 'qtile'

mod = 'mod4'
keys = [
    Key([mod], 'Return', lazy.spawn('kitty')),
    Key([mod], 'q', lazy.window.kill()),
    Key([mod, 'shift'], 'q', lazy.window.kill()),
    Key([mod], 'd', lazy.spawn('rofi -show drun')),
    Key([mod, 'shift'], 'd', lazy.spawn('rofi -show run')),
    Key([mod], 'x', lazy.spawn(os.path.expanduser('~/.local/bin/rofi-power'))),
    Key([mod], 'semicolon', lazy.spawn(os.path.expanduser('~/.local/bin/rofi-layout'))),
    Key([mod], 'F10', lazy.spawn(os.path.expanduser('~/.local/bin/rofi-wallpaper'))),
    Key([mod], 'e', lazy.spawn('nautilus')),
    Key([mod], 'w', lazy.spawn('firefox')),
    Key([mod], 'F1', lazy.spawn(os.path.expanduser('~/.local/bin/show-hotkeys'))),
    Key([mod], 'm', lazy.spawn(os.path.expanduser('~/.local/bin/mon') + ' --qtile')),
    Key([mod], 'v', lazy.spawn('env CM_LAUNCHER=rofi clipmenu')),
    Key([mod], 'f', lazy.window.toggle_fullscreen()),
    Key([mod], 't', lazy.window.toggle_floating()),
    Key([mod, 'shift'], 'p', lazy.spawn('xset dpms force off')),
    Key([mod, 'mod1'], 't', lazy.spawn('kitty -e btop')),
    Key([], 'XF86AudioRaiseVolume', lazy.spawn('pactl set-sink-volume @DEFAULT_SINK@ +5%')),
    Key([], 'XF86AudioLowerVolume', lazy.spawn('pactl set-sink-volume @DEFAULT_SINK@ -5%')),
    Key([], 'XF86AudioMute', lazy.spawn('pactl set-sink-mute @DEFAULT_SINK@ toggle')),
    Key([mod, 'shift'], 'r', lazy.reload_config()),
    Key([mod], 'h', lazy.layout.left()), Key([mod], 'j', lazy.layout.down()),
    Key([mod], 'k', lazy.layout.up()), Key([mod], 'l', lazy.layout.right()),
    Key([mod, 'shift'], 'h', lazy.layout.shuffle_left()),
    Key([mod, 'shift'], 'j', lazy.layout.shuffle_down()),
    Key([mod, 'shift'], 'k', lazy.layout.shuffle_up()),
    Key([mod, 'shift'], 'l', lazy.layout.shuffle_right()),
    Key([mod], 'space', lazy.next_layout()),
]
groups = [Group(str(i)) for i in range(1, 10)] + [Group('0')]
for group in groups:
    keys.extend([Key([mod], group.name, lazy.group[group.name].toscreen()),
                 Key([mod, 'shift'], group.name, lazy.window.togroup(group.name))])
border = dict(border_focus='#7e9cd8', border_normal='#54546d', border_width=2, margin=8)
layouts = [layout.MonadTall(**border), layout.Floating(**border), layout.Max(),
           layout.MonadWide(**border), layout.Plasma(**border), layout.Columns(**border),
           layout.Tile(**border), layout.Zoomy(**border)]
widget_defaults = dict(font='CodeNewRoman Nerd Font', fontsize=12, padding=8)
extension_defaults = widget_defaults.copy()
screens = [Screen()]
mouse = [Drag([mod], 'Button1', lazy.window.set_position_floating(), start=lazy.window.get_position()),
         Drag([mod], 'Button3', lazy.window.set_size_floating(), start=lazy.window.get_size()),
         Click([mod], 'Button2', lazy.window.bring_to_front())]
floating_layout = layout.Floating(float_rules=layout.Floating.default_float_rules)
@hook.subscribe.startup_once
def autostart():
    subprocess.Popen([os.path.expanduser('~/.config/qtile/autostart.sh')])
wmname = 'Qtile'
