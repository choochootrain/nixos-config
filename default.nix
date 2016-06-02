{ config, pkgs, ... }:

{
  imports = [
    ./machines/xps.nix
  ];

  environment.systemPackages = with pkgs; [
    acpi
    awscli
    chromium
    direnv
    firefox
    git
    gnupg
    i3blocks
    keybase
    ngrok
    nix-repl
    nox
    pass
    rofi
    rofi-pass
    silver-searcher
    spotify
    termite
    vim
    wget
    which
    xclip
    xorg.xbacklight
    zsh
  ];

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
    ];
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

    firefox = {
      enableGoogleTalkPlugin = true;
      enableAdobeFlash = true;
    };
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "16.03";

  time.timeZone = "America/Los_Angeles";

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";
}
