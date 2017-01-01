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
    findup
    fpp
    git
    gnumake
    gnupg
    htop
    i3blocks-gaps
    i3lock
    imagemagick
    keybase
    lemonbar-xft
    mysql
    nettools
    ngrok
    nix-prefetch-git
    nix-repl
    nox
    pass
    pciutils
    rofi
    rofi-pass
    silver-searcher
    spotify
    sysstat
    unzip
    vim
    wget
    which
    xclip
    xfce.terminal
    xorg.xbacklight
    xorg.xev
    zsh
  ];

  environment.variables."SSL_CERT_FILE" = "/etc/ssl/certs/ca-bundle.crt";

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
