{ config, lib, pkgs, ... }:

let
  rmdocker = pkgs.writeScriptBin "rmdocker" ''
    #! ${pkgs.bash}/bin/bash
    get_psy3_docker_images() {
      docker images | while read repo tag image_id rest
      do
        if [[ "$repo" = "psy3.memcompute.com/psy3-test*" ]]
        then
          echo $image_id
        fi
      done
    }

    docker rm $(docker ps -qa);
    docker rmi $(docker images -f dangling=true -q);
    docker rmi $(get_psy3_docker_images);
  '';
in
{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/669e1e02-97e3-419c-90f3-9dd06f2c6464";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nix.maxJobs = 8;

  networking.hostName = "gbop";
  networking.hostId = "512b64e0";
  networking.wireless.enable = true;

  hardware.bluetooth.enable = true;

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

  services = {
    acpid.enable = true;

    xserver = {
      enable = true;

      layout = "us";
      xkbOptions = "caps:escape";

      displayManager.slim = {
        enable = true;
        theme = pkgs.fetchurl {
          url = "https://github.com/edwtjo/nixos-black-theme/archive/v1.0.tar.gz";
          sha256 = "13bm7k3p6k7yq47nba08bn48cfv536k4ipnwwp1q1l2ydlp85r9d";
        };
      };

      windowManager = {
        default = "i3";
        i3.enable = true;
      };
    };

    redshift = {
      enable = true;
      latitude = "37.7749";
      longitude = "122.4194";
      extraOptions = [ "-m randr" "-v" ];
    };

    xbanish.enable = true;
  };

  users.extraUsers.memsql = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "docker" ];
  };

  virtualisation.docker = {
    enable = true;
    extraOptions = "-H tcp://0.0.0.0:4243 -H unix:// --restart=false --insecure-registry psy3.memcompute.com --dns 8.8.8.8 --dns 8.8.4.4";
  };

  nixpkgs.config.packageOverrides = pkgs: rec {
    arcanist = pkgs.stdenv.lib.overrideDerivation pkgs.arcanist (oldAttrs: {
      version = "20151222";

      libphutil = pkgs.fetchFromGitHub {
        owner = "memsql";
        repo = "libphutil";
        rev = "14765d36f83acac0a109a047244aaa6fd8e081ea";
        sha256 = "1na3hhdvy43q6vdiabxj8c5x3amjzkg5vzm7wpijpzgq535g7liz";
      };

      arcanist = pkgs.fetchFromGitHub {
        owner = "memsql";
        repo = "arcanist";
        rev = "b3e68c9f179318d65b6a2512efa6830e0362de8e";
        sha256 = "0zjfsbjw21kbkji43jib48dfnxb8i7gw9s0lr6xgwd6vkj1kw5y3";
      };
    });
  };

  environment.systemPackages = with pkgs; [
    arcanist
    rmdocker
  ];
}
