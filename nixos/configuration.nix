# NixOS rolling (canal nixos-unstable). stateVersion permanece o da instalação.
{ config, pkgs, lib, ... }:

let
  swayBin = "/run/current-system/sw/bin";

  catppuccinSddm = pkgs.catppuccin-sddm.override {
    flavor = "frappe";
    accent = "blue";
  };

  # Cursor do rice, visível para o SDDM (o tema em ~/.local não chega no greeter).
  vimixCursors = pkgs.stdenvNoCC.mkDerivation {
    pname = "vimix-cursors";
    version = "2024-06-20";
    src = pkgs.fetchFromGitHub {
      owner = "vinceliuice";
      repo = "Vimix-cursors";
      rev = "9bc292f40904e0a33780eda5c5d92eb9a1154e9c";
      hash = "sha256-zW7nJjmB3e+tjEwgiCrdEe5yzJuGBNdefDdyWvgYIUU=";
    };
    installPhase = ''
      mkdir -p $out/share/icons
      cp -a dist $out/share/icons/Vimix-cursors
    '';
  };

  polkitAgent = pkgs.writeShellScriptBin "polkit-gnome-authentication-agent-1" ''
    exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 "$@"
  '';

  swaySessionScript = pkgs.writeShellScript "sway-session" ''
    if [ -x "$HOME/.local/bin/start-sway-full" ]; then
      exec "$HOME/.local/bin/start-sway-full" "$@"
    fi
    exec sway "$@"
  '';

  swaySession = pkgs.writeTextDir "share/wayland-sessions/sway.desktop" ''
    [Desktop Entry]
    Name=sway
    Comment=Sway
    Exec=${swaySessionScript}
    Type=Application
    DesktopNames=sway;wlroots;
  '' // {
    providedSessions = [ "sway" ];
  };

  grubBtrfsGen = pkgs.writeShellScriptBin "grub-btrfs-gen" ''
    export PATH="${swayBin}:$PATH"
    exec 9>/run/grub-btrfs-gen.lock
    flock 9
    GRUB_DIR="/boot/grub"
    [ -d "$GRUB_DIR" ] || exit 0
    SYS=""; K=""; I=""
    if [ -e /run/booted-system/kernel ]; then
      SYS=$(readlink -f /run/booted-system)
      K=$(readlink -f /run/booted-system/kernel)
      I=$(readlink -f /run/booted-system/initrd)
    elif [ -e /run/current-system/kernel ]; then
      SYS=$(readlink -f /run/current-system)
      K=$(readlink -f /run/current-system/kernel)
      I=$(readlink -f /run/current-system/initrd)
    fi
    [ -n "$K" ] && [ -f "$K" ] && [ -n "$I" ] && [ -f "$I" ] || exit 0
    UUID=$(findmnt -n -o UUID --target / || true)
    [ -n "$UUID" ] || exit 0
    OUT="$GRUB_DIR/grub-btrfs.cfg"
    TMP=$(mktemp)
    {
      echo "# Gerado por grub-btrfs-gen. Não editar."
      echo "submenu 'NixOS Snapshots' {"
      SNAPS=$(btrfs subvolume list -s / 2>/dev/null \
        | awk '{ i = index($0, " path "); if (i > 0) print $2, substr($0, i + 6) }' \
        | grep -E '^[0-9]+ \.snapshots/[0-9]+/snapshot$' \
        | sort -k1,1 -n -r | head -n 6 || true)
      printf '%s\n' "$SNAPS" | while read -r _SID SPATH; do
        [ -z "$SPATH" ] && continue
        N=$(echo "$SPATH" | cut -d/ -f2)
        INFO="/.snapshots/$N/info.xml"
        DESC=$(sed -n 's:.*<description>\(.*\)</description>.*:\1:p' "$INFO" 2>/dev/null | head -n 1)
        [ -z "$DESC" ] && DESC="snapshot $N"
        DATE=$(sed -n 's:.*<date>\(.*\)</date>.*:\1:p' "$INFO" 2>/dev/null | head -n 1)
        [ -z "$DATE" ] && DATE=$(stat -c %y "/.snapshots/$N/snapshot" 2>/dev/null | cut -d. -f1)
        INIT=""
        if [ -n "$SYS" ] && [ -f "$SYS/init" ]; then INIT=" init=$SYS/init"; fi
        printf "  menuentry '%s | %s (%s)' --class snapshot {\n" "$N" "$DESC" "$DATE"
        printf "    search --no-floppy --fs-uuid --set=root %s\n" "$UUID"
        printf "    linux %s root=UUID=%s rootflags=subvol=%s rw%s\n" "$K" "$UUID" "$SPATH" "$INIT"
        printf "    initrd %s\n" "$I"
        printf "  }\n"
      done
      echo "}"
    } > "$TMP"
    mv "$TMP" "$OUT"
  '';
in
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    copyKernels = true;
    configurationLimit = 8;
    extraConfig = ''
      if [ -f /boot/grub/grub-btrfs.cfg ]; then
        source /boot/grub/grub-btrfs.cfg
      fi
    '';
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Cursor de software no X do SDDM. O SVGA da VMware não desenha o cursor de hardware.
  # O driver vmware atual quebra o X com segfault. O modesetting dirige o SVGA.
  services.xserver.videoDrivers = lib.mkForce [ "modesetting" ];
  services.xserver.deviceSection = ''
    Option "SWcursor" "true"
  '';
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr || true
  '';

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };
  i18n.supportedLocales = [
    "pt_BR.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "C.UTF-8/UTF-8"
  ];
  console.keyMap = "br-abnt2";

  services.xserver = {
    enable = true;
    xkb.layout = "br";
    xkb.variant = "abnt2";
    xkb.model = "pc105";
    desktopManager.xterm.enable = lib.mkForce false;
    excludePackages = [ pkgs.xterm ];
  };
  services.libinput.enable = true;

  services.displayManager.defaultSession = "sway";
  services.displayManager.sessionPackages = lib.mkForce [ swaySession ];
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    theme = "catppuccin-frappe-blue";
    extraPackages = with pkgs; [
      qt6.qtsvg
      qt6.qtdeclarative
      qt6.qt5compat
    ];
    settings = {
      General = {
        DisplayServer = "x11";
        InputMethod = "";
      };
      Theme = {
        CursorTheme = "Vimix-cursors";
        CursorSize = "24";
      };
      Users.RememberLastSession = true;
    };
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
    extraPackages = lib.mkForce (
      with pkgs;
      [
        brightnessctl
        grim
        swayidle
        swaylock
      ]
    );
    extraSessionCommands = ''
      export WLR_NO_HARDWARE_CURSORS=1
      export XCURSOR_THEME=Vimix-cursors
      export XCURSOR_SIZE=24
      export MOZ_ENABLE_WAYLAND=1
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export SDL_VIDEODRIVER=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };

  programs.firefox = {
    enable = true;
    languagePacks = [ "pt-BR" ];
  };
  programs.dconf.enable = true;
  services.gvfs.enable = true;

  security.polkit.enable = true;
  security.pam.services.swaylock = { };
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  virtualisation.vmware.guest = {
    enable = true;
    # Evita o mount vmblock-fuse, que falha e aborta o switch, e o driver vmmouse.
    headless = true;
    package = pkgs.open-vm-tools;
  };
  security.wrappers.vmware-user-suid-wrapper = {
    setuid = true;
    owner = "root";
    group = "root";
    source = "${pkgs.open-vm-tools}/bin/vmware-user-suid-wrapper";
  };

  environment.variables = {
    XCURSOR_THEME = "Vimix-cursors";
    XCURSOR_SIZE = "24";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
  environment.pathsToLink = [
    "/share/icons"
    "/share/sddm"
    "/share/gsettings-schemas"
    "/share/glib-2.0"
  ];

  services.openssh.enable = true;

  services.snapper = {
    snapshotRootOnBoot = true;
    configs.root = {
      SUBVOLUME = "/";
      ALLOW_USERS = [ "pio" ];
      TIMELINE_CREATE = false;
      TIMELINE_CLEANUP = false;
      NUMBER_CLEANUP = true;
      NUMBER_MIN_AGE = 0;
      NUMBER_LIMIT = "6";
      NUMBER_LIMIT_IMPORTANT = "6";
    };
  };
  system.activationScripts.snapperSnapshotsSubvol.text = ''
    if ! ${pkgs.btrfs-progs}/bin/btrfs subvolume show /.snapshots >/dev/null 2>&1; then
      if [ -d /.snapshots ] && [ -z "$(ls -A /.snapshots 2>/dev/null)" ]; then
        rmdir /.snapshots
      fi
      ${pkgs.btrfs-progs}/bin/btrfs subvolume create /.snapshots
    fi
    touch /boot/grub/grub-btrfs.cfg || true
  '';
  systemd.services.grub-btrfs-gen = {
    description = "Regenera o submenu de snapshots no GRUB";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${grubBtrfsGen}/bin/grub-btrfs-gen";
    };
  };
  systemd.paths.grub-btrfs-watch = {
    description = "Observa /.snapshots para atualizar o menu GRUB";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathModified = "/.snapshots";
      Unit = "grub-btrfs-gen.service";
    };
  };

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.geist-mono
    nerd-fonts._0xproto
    nerd-fonts.terminess-ttf
    geist-font
    noto-fonts
    noto-fonts-color-emoji
    cantarell-fonts
    font-awesome
    dejavu_fonts
  ];

  environment.systemPackages = with pkgs; [
    grubBtrfsGen
    catppuccinSddm
    vimixCursors
    polkitAgent
    adwaita-icon-theme

    git wget curl unzip zip p7zip gnutar rsync
    nano vim neovim bash-completion procs less
    wl-clipboard cliphist xclip inetutils

    starship zoxide eza fd ripgrep fzf duf fastfetch btop htop
    tree tealdeer lazygit bat

    gcc gnumake cmake pkg-config jq bc findutils coreutils
    gnu-efi binutils

    nodejs lua5_1 luarocks
    (python3.withPackages (ps: with ps; [ pip pynvim virtualenv pipenv ]))
    tree-sitter
    prettier

    swaybg waybar rofi awww kitty nautilus sublime4 nwg-look
    glib gsettings-desktop-schemas
    pavucontrol mako swayidle swaylock swayosd playerctl wlogout
    grim slurp libnotify imagemagick
    xdg-utils xdg-user-dirs
    polkit_gnome gnome-keyring herdr
    papirus-icon-theme
    sassc gnome-themes-extra inkscape optipng
    xorg.xsetroot xorg.xauth
    tmux
    mesa
    efibootmgr snapper btrfs-progs
    loupe papers gnome-text-editor
    qt6.qtsvg qt6.qtdeclarative qt6.qt5compat
  ];

  documentation.nixos.enable = false;
  documentation.doc.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  users.users.pio = {
    isNormalUser = true;
    description = "pio";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.bash;
  };

  system.stateVersion = "26.05";
}
