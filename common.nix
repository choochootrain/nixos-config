{ config, pkgs, ... }:

let
  findup = pkgs.writeScriptBin "findup" ''
    #! ${pkgs.bash}/bin/bash

    arg="$1"
    if test -z "$arg"; then exit 1; fi

    while ! test -e "$arg"; do
     cd ..
     if test "$PWD" = "/"; then
        exit 1
     fi
    done

    echo $PWD/$arg
  '';

  nd = pkgs.writeScriptBin "nd" ''
    #! ${pkgs.bash}/bin/bash

    if [ $? -eq 0 ]; then
        notify-send $@
    else
        notify-send "($?) "$@
    fi
  '';

  neovim = pkgs.neovim.override {
    vimAlias = true;
  };
in
rec {
  environment.systemPackages = with pkgs; [
    acpi
    awscli
    bind
    cacert
    chromium
    direnv
    dragon-drop
    dstat
    dunst
    file
    findup
    fpp
    git
    gnumake
    gnupg
    htop
    i3blocks-gaps
    i3lock
    inotify-tools
    imagemagick
    jq
    keybase
    libnotify
    lemonbar-xft
    lsof
    mysql
    nd
    neovim
    nettools
    ngrok
    nix-prefetch-git
    nix-repl
    nox
    pass
    patchelf
    pciutils
    rofi
    rofi-pass
    silver-searcher
    sysstat
    tree
    unzip
    usbutils
    wget
    which
    xclip
    xfce.terminal
    xorg.xbacklight
    xorg.xev
    zsh
  ];

  environment.variables."SSL_CERT_FILE" = "/etc/ssl/certs/ca-bundle.crt";

  environment.etc = {
    editrc.text = ''
      bind -v
      bind "^R" em-inc-search-prev
      bind \\t rl_complete
    '';

    inputrc.text = ''
      # inputrc borrowed from CentOS (RHEL).

      set bell-style none

      set meta-flag on
      set input-meta on
      set convert-meta off
      set output-meta on
      set colored-stats on

      #set mark-symlinked-directories on

      $if mode=emacs

      # for linux console and RH/Debian xterm
      "\e[1~": beginning-of-line
      "\e[4~": end-of-line
      "\e[5~": beginning-of-history
      "\e[6~": end-of-history
      "\e[3~": delete-char
      "\e[2~": quoted-insert
      "\e[5C": forward-word
      "\e[5D": backward-word
      "\e[1;5C": forward-word
      "\e[1;5D": backward-word

      # for rxvt
      "\e[8~": end-of-line

      # for non RH/Debian xterm, can't hurt for RH/DEbian xterm
      "\eOH": beginning-of-line
      "\eOF": end-of-line

      # for freebsd console
      "\e[H": beginning-of-line
      "\e[F": end-of-line
      $endif

      set editing-mode vi

      $if mode=vi

      set keymap vi-command
      Control-l: clear-screen

      set keymap vi-insert
      Control-l: clear-screen
      $endif
    '';

    pyrc.text = ''
      import rlcompleter
      import readline
      readline.parse_and_bind("tab: complete")
    '';

    "user-dirs.defaults".text = ''
      XDG_DESKTOP_DIR="$HOME"
      XDG_DOCUMENTS_DIR="$HOME"
      XDG_DOWNLOAD_DIR="$HOME/dl"
      XDG_MUSIC_DIR="$HOME"
      XDG_PICTURES_DIR="$HOME"
      XDG_PUBLICSHARE_DIR="$HOME/public"
      XDG_TEMPLATES_DIR="$HOME"
      XDG_VIDEOS_DIR="$HOME"
    '';
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleUseXkbConfig = true;
    defaultLocale = "en_US.UTF-8";
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      inconsolata
      powerline-fonts
      source-code-pro
    ];

    fontconfig = {
        enable = true;
    };
  };

  nix = {
    buildCores = 0;
    extraOptions = ''
      auto-optimise-store = true
    '';
    nixPath = [ "/etc/nixos" "nixos-config=/etc/nixos/config" ];
    useSandbox = true;
  };

  nixpkgs.config = {
    allowUnfree = true;

    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  security.sudo.extraConfig = ''
    Defaults !lecture,tty_tickets,!fqdn,insults
  '';

  system.copySystemConfiguration = true;
  system.stateVersion = "16.03";

  time.timeZone = "America/Los_Angeles";

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";
}
