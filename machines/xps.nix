{ config, lib, pkgs, ... }:

let
  ledger-udev-rules = import ../lib/ledger-udev-rules { inherit pkgs; };
in
{
  imports =
    [ <nixpkgs/nixos/modules/hardware/network/broadcom-43xx.nix>
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "wl" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/f82cd8ac-11e4-4a37-ac62-254529c20369";
      fsType = "ext4";
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/660aa277-454b-4c25-b9d5-d53f6c3356ea";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B0AF-B489";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = 4;

  networking.hostName = "octetstream";
  networking.hostId = "fd4a42a0";
  networking.wireless.enable = true;

  hardware.bluetooth.enable = true;

  services = {
    acpid.enable = true;

    xserver = {
      enable = true;
      deviceSection = ''
        Option "DRI" "False"
      '';
      resolutions = [
        {
          x = 2048;
          y = 1152;
        }
      ];

      layout = "us";
      xkbOptions = "caps:escape";

      libinput = {
        buttonMapping = "1 3 3 4 5";
        disableWhileTyping = true;
        enable = true;
      };

      displayManager.slim = {
        enable = true;
        theme = pkgs.fetchurl {
          url = "https://github.com/edwtjo/nixos-black-theme/archive/v1.0.tar.gz";
          sha256 = "13bm7k3p6k7yq47nba08bn48cfv536k4ipnwwp1q1l2ydlp85r9d";
        };
      };

      windowManager = {
        default = "i3";
        i3 = {
          enable = true;
          package = pkgs.i3-gaps;
        };
      };

      desktopManager = {
        xterm.enable = false;
        default = "none";
      };
    };

    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };

    redshift = {
      enable = true;
      latitude = "37.7749";
      longitude = "122.4194";
    };

    xbanish = {
      enable = true;
    };

    udev.packages = [ pkgs.android-udev-rules ledger-udev-rules ];
  };

  users.extraUsers.hp = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "audio" "docker" ];
  };

  virtualisation.docker.enable = true;
}
