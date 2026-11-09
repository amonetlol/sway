#!/usr/bin/env bash
# Baixa os módulos atuais de amonetlol/sh. Não guarda cópia congelada.
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Execute como usuário comum." >&2; exit 1; }
log() { printf '[*] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }
base="https://raw.githubusercontent.com/amonetlol/sh/main/modules"
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/install-session.sh"
names=(bash bin btop fastfetch fonts starship nvim vmware random-wallpapers hide-shortcuts recovery-shortcuts kitty wallpapers sublime-text)
paths=(bash.sh bin.sh btop.sh fastfetch.sh fonts.sh starship.sh setup-nvim.sh VMware/vmware.sh random-wallpapers.sh hide-shortcuts.sh recovery-shortcuts.sh kitty.sh wallpapers.sh sublime-text.sh)
selected=(); for _ in "${names[@]}"; do selected+=(1); done
if [[ ${1:-} != --all ]]; then
  [[ -r /dev/tty ]] || fail "A seleção requer um terminal. Use --all para confirmar todos sem o menu."
  while true; do
    printf '\nMódulos — todos selecionados inicialmente:\n'
    for i in "${!names[@]}"; do
      mark=' '; [[ ${selected[i]} == 0 ]] || mark=X
      printf ' [%s] %2d. %s\n' "$mark" "$((i+1))" "${names[i]}"
    done
    printf '\nNúmeros para marcar/desmarcar (ex.: 2,8); t=todos; n=nenhum; Enter=instalar; q=cancelar: '
    read -r answer </dev/tty
    case "$answer" in
      '') break ;;
      q|Q) exit 0 ;;
      t|T) for i in "${!names[@]}"; do selected[i]=1; done ;;
      n|N) for i in "${!names[@]}"; do selected[i]=0; done ;;
      *) for number in ${answer//,/ }; do
           if [[ "$number" =~ ^[0-9]+$ ]] && ((number>=1 && number<=${#names[@]})); then
             selected[number-1]=$((1-selected[number-1]))
           else log "Opção ignorada: $number"; fi
         done ;;
    esac
  done
fi
work="$(mktemp -d)"
cleanup() {
  rm -rf -- "$work"
  debian_finish_session
}
trap cleanup EXIT
debian_prepare_session
for i in "${!names[@]}"; do
  [[ ${selected[i]} == 1 ]] || continue
  name="${names[i]}"
  script="$work/$name.sh"
  log "Baixando módulo atualizado: $name"
  curl -fL --retry 3 -o "$script" "$base/${paths[i]}"
  sed -i 's/\r$//' "$script"
  if [[ $name == sublime-text ]]; then
    bash "$here/install-sublime.sh" "$script"
  else
    bash "$script"
  fi
done
log "Módulos concluídos a partir do GitHub."
