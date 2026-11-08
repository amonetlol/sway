#!/usr/bin/env python3
import json,subprocess
LABELS={'splith':'Horizontal','splitv':'Vertical','tabbed':'Abas','stacked':'Empilhado','stacking':'Empilhado','floating':'Flutuante'}
def focused_path(node,path=None):
 path=(path or [])+[node]
 if node.get('focused'):return path
 for child in node.get('nodes',[])+node.get('floating_nodes',[]):
  found=focused_path(child,path)
  if found:return found
 return None
try:
 tree=json.loads(subprocess.check_output(['swaymsg','-t','get_tree'],text=True,timeout=2,stderr=subprocess.DEVNULL))
 path=focused_path(tree) or []
 layout=None
 for node in reversed(path):
  if node.get('type')=='floating_con':layout='floating';break
  if node.get('layout') in LABELS:layout=node['layout'];break
 if not layout:layout='splith'
 print(json.dumps({'text':LABELS[layout],'tooltip':'Layout Sway: '+layout,'class':layout},ensure_ascii=False))
except (OSError,ValueError,subprocess.SubprocessError):
 print(json.dumps({'text':'—','tooltip':'Layout indisponível'},ensure_ascii=False))
