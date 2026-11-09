#!/usr/bin/env bash
set -u
base=https://raw.githubusercontent.com/amonetlol/sh/main/modules
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failed=()
for module in btop fastfetch fonts starship setup-nvim recovery-shortcuts hide-shortcuts wallpapers; do
  printf '\n[*] Modulo: %s\n' "$module"
  if curl -fsSL --retry 2 "$base/$module.sh" -o "$work/$module.sh" && bash "$work/$module.sh"; then
    printf '[OK] %s\n' "$module"
  else
    printf '[ERRO] %s\n' "$module" >&2
    failed+=("$module")
  fi
done
if ((${#failed[@]})); then printf '[ERRO] Modulos pendentes: %s\n' "${failed[*]}" >&2; exit 1; fi
