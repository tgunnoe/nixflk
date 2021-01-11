{ lib, pkgs, config, ... }:
let
  inherit (builtins) tofile readfile;
  inherit (lib) fileContents mkForce;

  name = "Taylor Gunnoe";
in
{

  imports = [
    ../../profiles/develop /*./vpn.nix ./mail.nix*/
    ../../profiles/graphical
  ];

  users.users.root.hashedPassword = fileContents ../../secrets/root;

  users.users.tgunnoe.packages = with pkgs; [ /*pandoc*/ ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.systemPackages = with pkgs; [ cachix ];

  home-manager.users.tgunnoe = {
    imports = with pkgs; [
      ../profiles/git
      #../profiles/alacritty
      ../profiles/kitty
      ../profiles/zsh
      ../profiles/direnv
      ../profiles/emacs
      pkgs.nur.repos.rycee.hmModules.emacs-init
    ];

    home = {
      # packages = with pkgs; [

      # ];

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

    programs = {
      firefox = {
        enable = true;
        extensions =
          with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            browserpass
            umatrix
            https-everywhere
          ];
        package = pkgs.firefox-wayland;
        profiles =
          let defaultSettings = {
                "app.update.auto" = false;
                "browser.startup.homepage" = "https://duckduckgo.com";
                "browser.search.region" = "US";
                "browser.search.countryCode" = "US";
                "browser.search.isUS" = true;
                "browser.ctrlTab.recentlyUsedOrder" = false;
                "browser.newtabpage.enabled" = false;
                "browser.bookmarks.showMobileBookmarks" = true;
                "distribution.searchplugins.defaultLocale" = "en-US";
                "general.useragent.locale" = "en-US";
                "identity.fxaccounts.account.device.name" = config.networking.hostName;
                "privacy.trackingprotection.enabled" = true;
                "privacy.trackingprotection.socialtracking.enabled" = true;
                "privacy.trackingprotection.socialtracking.annotate.enabled" = true;
                "services.sync.declinedEngines" = "addons,passwords,prefs";
                "services.sync.engine.addons" = false;
                "services.sync.engineStatusChanged.addons" = true;
                "services.sync.engine.passwords" = false;
                "services.sync.engine.prefs" = false;
                "services.sync.engineStatusChanged.prefs" = true;
                "signon.rememberSignons" = false;
              };
          in {
            home = {
              id = 0;
              settings = defaultSettings // {
                "browser.urlbar.placeholderName" = "DuckDuckGo";
              };
            };

            work = {
              id = 1;
              settings = defaultSettings // {
                "browser.startup.homepage" = "about:blank";
              };
            };
          };
      }; # /firefox

      mpv = {
        enable = true;
        config = {
          ytdl-format = "bestvideo[height<=?1080]+bestaudio/best";
          hwdec = "auto";
          vo = "gpu";
        };
      };

      git = {
        userName = name;
        userEmail = "t@gvno.net";
        # signing = {
        #   key = "8985725DB5B0C122";
        #   signByDefault = true;
        # };
      };

      ssh = {
        enable = true;
        hashKnownHosts = true;
      };
    };
  };

  users.groups.media.members = [ "tgunnoe" ];

  users.users.tgunnoe = {
    uid = 1000;
    description = name;
    isNormalUser = true;
    shell = pkgs.zsh;
    hashedPassword = fileContents ../../secrets/tgunnoe;
    extraGroups = [ "wheel" "input" "networkmanager" "libvirtd" "video" ];
  };
}
