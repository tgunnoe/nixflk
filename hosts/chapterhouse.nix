{ lib, pkgs, ... }:
{
  ### root password is empty by default ###
  imports = [
    ./chapterhouse-hardware.nix
    ../users/tgunnoe
    ../users/root
  ];

  # fileSystems."/" = { device = "/dev/disk/by-label/nixos"; };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-amd" "kvm-intel" ];
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        enable = true;
        device = "nodev";
        version = 2;
        efiSupport = true;
        enableCryptodisk = true;
      };
    };
    initrd = {
      secrets = {
        "keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      };
      luks.devices = {
        root = {
          name = "root";
          device = "/dev/disk/by-uuid/6e57d03c-999a-47e1-a38c-aca0e55b4013"; # UUID for /dev/nvme01np2
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
        };
      };
    };
    supportedFilesystems = [ "ntfs" ];
  };

  networking = {
    hostId = "e53dd769";
    hostName = "chapterhouse";
    firewall.allowedTCPPorts = [ 8000 ];
    enableIPv6 = false;
    useDHCP = false;

    interfaces = {
      enp37s0 = {
        ipv4 = {
          addresses = [
            {
              address = "192.168.0.5";
              prefixLength = 25;
            }
          ];
        };
      };
    };
  };

  time.timeZone = "America/New_York";

  system.stateVersion = "20.03";

}
