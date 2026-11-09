# Salix 15.0 + Sway

Rice de `sway-full` com os pacotes binários do Salix. Foot e Micro substituem Kitty e Neovim. Executar como `pio`, a partir da raiz do repositório:

```sh
bash salix/install.sh
```

Etapas: `pacotes`, `gaps`, `modules`, `sway`, `sddm`, `services`, `themes`, `verify`.

`gaps` compila só o que o repositório não tem: swaylock, swayidle, slurp, mako e wlogout. O SDDM fica no runlevel 4 com uma única sessão, Sway. O SSH continua no boot e o `eth0` permanece no DHCP.
