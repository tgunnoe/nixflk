inputs@{ home, nixpkgs, unstablePkgs, qt515Pkgs, self, pkgs, system, ... }:
let
  inherit (nixpkgs) lib;

  utils = import ../lib/utils.nix { inherit lib; };

  inherit (utils) recImport;

  inherit (builtins) attrValues removeAttrs;

  config = hostName:
    lib.nixosSystem {
      inherit system;

      modules = let
        inherit (home.nixosModules) home-manager;

        core = self.nixosModules.profiles.core;

        global = {
          networking.hostName = hostName;
          nix.nixPath = [
            "nixpkgs=${nixpkgs}"
            "nixos-config=/etc/nixos/configuration.nix"
            "nixpkgs-overlays=/etc/nixos/overlays"
          ];

          nixpkgs = { inherit pkgs; };

          nix.registry = {
            nixpkgs.flake = nixpkgs;
            nixflk.flake = self;
            master.flake = inputs.unstable;
          };
        };

        unstables = {
          systemd.package = unstablePkgs.systemd;
          nixpkgs.overlays = [
            (final: prev:
              with unstablePkgs; {
                inherit starship element-desktop discord signal-desktop mpv
                  protonvpn-cli-ng;
              })
            (final: prev: with qt515Pkgs; { inherit qute qutebrowser; })
          ];
        };

        local = import "${toString ./.}/${hostName}.nix";

        # Everything in `./modules/list.nix`.
        flakeModules =
          attrValues (removeAttrs self.nixosModules [ "profiles" ]);

      in flakeModules ++ [ core global local home-manager unstables ];

    };

  hosts = recImport {
    dir = ./.;
    _import = config;
  };
in hosts
