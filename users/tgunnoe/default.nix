{ lib, pkgs, ... }:
let
  inherit (builtins) tofile readfile;
  inherit (lib) fileContents mkForce;

  name = "Taylor Gunnoe";
in
{

  imports = [ ../../profiles/develop /*./vpn.nix ./mail.nix ./graphical*/ ];

  users.users.root.hashedPassword = fileContents ../../secrets/root;

  users.users.tgunnoe.packages = with pkgs; [ pandoc ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [ cachix ];

  home-manager.users.tgunnoe = {
    imports = with pkgs; [
      ../profiles/git
      ../profiles/alacritty
      ../profiles/direnv
      #../profiles/emacs
      #nur.repos.rycee.hmModules.emacs-init
    ];

    home = {
      packages = mkForce [ ];

      file = {
#        ".ec2-keys".source = ../../secrets/ec2;
#        ".cargo/credentials".source = ../../secrets/cargo;
        ".zshrc".text = "#";
        ".gnupg/gpg-agent.conf".text = ''
            pinentry-program ${pkgs.pinentry_curses}/bin/pinentry-curses
        '';
#        ".config/cachix/cachix.dhall".source = ../../secrets/cachix.dhall;
      };
    };

    programs.mpv = {
      enable = true;
      config = {
        ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
        hwdec = "auto";
        vo = "gpu";
      };
    };

    programs.git = {
      userName = name;
      userEmail = "t@gvno.net";
      # signing = {
      #   key = "8985725DB5B0C122";
      #   signByDefault = true;
      # };
    };

    programs.ssh = {
      enable = true;
      hashKnownHosts = true;

    };
  };

  users.groups.media.members = [ "tgunnoe" ];

  users.users.tgunnoe = {
    uid = 1000;
    description = name;
    isNormalUser = true;
    hashedPassword = fileContents ../../secrets/tgunnoe;
    extraGroups = [ "wheel" "input" "networkmanager" "libvirtd" ];
  };
}
