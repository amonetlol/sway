#!/usr/bin/env python3
import calendar,json,subprocess,sys
from pathlib import Path
from datetime import datetime
root=Path.home()/'.config/sway'
def sway(*args):
 p=subprocess.run(['swaymsg',*args],capture_output=True,text=True,check=True)
 return json.loads(p.stdout)
command=sys.argv[1]
if command=='monitor':
 outputs=sway('-t','get_outputs')
 output=next((o for o in outputs if o.get('focused')),next(o for o in outputs if o.get('active')))
 mode='1600x900' if output.get('current_mode',{}).get('width')==1920 else '1920x1080'
 result=sway('output',output['name'],'mode',mode)
 if any(not item.get('success',False) for item in result):raise SystemExit('Modo indisponivel')
elif command=='calendar':
 now=datetime.now()
 subprocess.run(['rofi','-no-config','-dmenu','-p','Calendario','-mesg',calendar.month(now.year,now.month),'-theme',str(root/'current/rofi/main.rasi')],input='',text=True)
elif command=='keybinds':
 text='''Super+Return: Kitty
Super+W: Firefox
Super+E: Nautilus
Super+D / Space: Rofi
Super+X: Energia
Super+M: 1920x1080 / 1600x900
Super+Shift+T: Temas Sway
Super+H / .: Editar configuracao
Super+V: Clipboard
Super+Ctrl+P: Captura
Super+Ctrl+Shift+L: Bloquear manualmente
Super+T: Flutuante
Super+F / Shift+F: Tela inteira
Super+J: Alternar divisao
Super+;: Layouts nativos do Sway
Super+Backspace: Redimensionar para 50%
Super+S: Scratchpad
Super+Setas: Foco
Super+Shift+Setas ou H/J/K/L: Mover janela
Super+Alt+H/J/K/L: Redimensionar
Super+1..0: Workspace
Super+Shift+1..0: Enviar janela
Alt+Tab: Proxima janela / aba no layout atual
Super+Tab: Workspace anterior'''
 subprocess.run(['rofi','-no-config','-dmenu','-i','-p','Atalhos','-theme',str(root/'current/rofi/main.rasi')],input=text,text=True)
