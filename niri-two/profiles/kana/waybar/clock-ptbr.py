#!/usr/bin/python3
import calendar
import datetime as dt
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
from zoneinfo import ZoneInfo

now = dt.datetime.now(ZoneInfo('America/Sao_Paulo'))
state = Path.home()/'.local/state/hypr-kana/waybar-calendar-month'
state.parent.mkdir(parents=True, exist_ok=True)
try:
    offset = int(state.read_text())
except (OSError, ValueError):
    offset = 0
if len(sys.argv) > 1:
    offset = 0 if sys.argv[1] == 'reset' else offset + int(sys.argv[1])
    state.write_text(str(offset))
    subprocess.run(['pkill', f'-{signal.SIGRTMIN + 9}', '-u', str(os.getuid()), '-x', 'waybar'], check=False)
    raise SystemExit

year, month0 = divmod(now.year * 12 + now.month - 1 + offset, 12)
month = month0 + 1
months = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
          'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro']
weekdays = ['segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira',
            'sexta-feira', 'sábado', 'domingo']
rows = ['Dom Seg Ter Qua Qui Sex Sáb']
for week in calendar.Calendar(firstweekday=6).monthdayscalendar(year, month):
    cells = []
    for day in week:
        cell = f'{day:>3}' if day else '   '
        if (year, month, day) == (now.year, now.month, now.day):
            cell = f'<span foreground="#c4b28a"><b>{cell}</b></span>'
        cells.append(cell)
    rows.append(' '.join(cells))
heading = f'<b>{months[month - 1]} de {year}</b>'
today = f'{weekdays[now.weekday()]}, {now.day} de {months[now.month - 1].lower()}'
tooltip = heading + '\n<tt>' + '\n'.join(rows) + '</tt>\n\n' + today
print(json.dumps({'text': now.strftime('%H:%M'), 'tooltip': tooltip}, ensure_ascii=False))
