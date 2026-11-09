# Artix dinit + Sway Full

Usa as configuracoes de `../sway-full` e adapta servicos, audio, sessao,
wallpapers e energia para dinit/elogind. Nao precisa de systemd.

```bash
bash artix/install.sh
```

Execute como usuario comum com sudo. Os repositorios Artix tem prioridade;
`artix-archlinux-support` permite obter do Arch Extra os pacotes ausentes.
Os modulos atuais sao baixados de `amonetlol/sh`; as adaptacoes de VMware
e wallpaper ficam nesta pasta. Configuracoes existentes recebem backup.

Etapas: `pacotes`, `grub`, `sddm`, `modules`, `sway`, `services`, `verify`.
Para retomar, por exemplo: `bash artix/install.sh modules`.
O registro fica em `~/.local/state/sway-artix/`.

Selecione **Sway** no SDDM. Waybar, PipeWire, WirePlumber, awww,
wallpaper a cada 90 segundos e inibicao de inatividade iniciam com a sessao.
O wlogout usa swaylock, swaymsg e loginctl; a verificacao nao desliga nem reinicia a VM.
