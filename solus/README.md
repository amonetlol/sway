# Solus + Sway Full

As configs ficam em `sway-full`. Execute como usuario comum com sudo:

```bash
bash solus/install.sh
```

Instala eopkg, SDDM, temas e modulos atuais de amonetlol/sh. Preserva o
clr-boot-manager; nao instala nem reconfigura outro gerenciador de partida.

Remove GNOME desktop e aplicativos GNOME, todos os pacotes LibreOffice,
Thunderbird e GParted depois de preparar a sessao Sway Full. Antes da remocao,
confere o plano do eopkg para preservar boot, rede, audio, Nautilus e keyring.
Nao reinicia a maquina automaticamente.

Adaptacoes Solus: mako-notify e o pacote do daemon de notificacoes; cliphist
0.7.0 vem do release oficial upstream para x86_64. Wallpaper usa o backend
nativo do Sway, sem transicoes do awww. Volume e microfone usam wpctl;
brilho usa light. Nao instala swayosd nem nwg-look, indisponiveis no eopkg.
As preferencias GTK sao aplicadas diretamente pelo instalador de temas.
