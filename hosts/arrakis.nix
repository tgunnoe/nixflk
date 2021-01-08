{ config, pkgs, options, ... }:
{
  imports = [
    ./arrakis-hardware.nix
    ../users/tgunnoe
    ../users/root
  ];
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
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
        "/keyfile0.bin" = "/etc/secrets/initrd/keyfile0.bin";
      };
      luks.devices = {
        root = {
          name = "root";
          device = "/dev/disk/by-uuid/f33695e2-5719-44e7-bf2b-58b28eeca5ae";
          preLVM = true;
          keyFile = "/keyfile0.bin";
          allowDiscards = true;
        };
      };
    };
    supportedFilesystems = [ "ntfs" ];
  };
  console = {
      keyMap = "dvorak";
      earlySetup = true;
  };

  powerManagement.enable = true;
  services.tlp.enable = true;
  services.logind.extraConfig = "HandlePowerKey=ignore";
  services.thermald.enable = true;
  services.hdapsd.enable = true;
  networking = {
    hostId = "1e0adfe3";
    hostName = "arrakis";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 8000 ];
    useDHCP = false;
    interfaces.wlp58s0.useDHCP = true;
  };

  hardware.opengl = {
    enable = true;
    #package = unstablepkgs.mesa.drivers;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };
  hardware.pulseaudio.support32Bit = true;
  hardware.bluetooth.enable = true;

  system.stateVersion = "20.09";
}
