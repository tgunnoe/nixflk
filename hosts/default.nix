inputs@{ home, nixpkgs, unstablePkgs, self, pkgs, system, ... }:
let
  inherit (nixpkgs) lib;

  utils = import ../lib/utils.nix { inherit lib; };

  inherit (utils) recImport;

  inherit (builtins) attrValues removeAttrs;

  config = hostName:
    lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit unstablePkgs;
        usr = { inherit utils; };
        nurModules = inputs.nur.nixosModules;
        nurOverlays = inputs.nur.overlays;
      };

      modules = let
        inherit (home.nixosModules) home-manager;

        core = ../profiles/core.nix;

        global = {
          networking.hostName = hostName;
          nix.nixPath = [
            "nixpkgs=${nixpkgs}"
            "nixos-config=/etc/nixos/configuration.nix"
            "nixpkgs-overlays=/etc/nixos/overlays"
          ];

          nixpkgs = { inherit pkgs; };
          nixpkgs.overlays = [ inputs.nur.overlay ];
        };

        local = import "${toString ./.}/${hostName}.nix";

        # Everything in `./modules/list.nix`.
        flakeModules =
          attrValues (removeAttrs self.nixosModules [ "profiles" ]);

      in flakeModules ++ [ core global local home-manager ];

    };

  hosts = recImport {
    dir = ./.;
    _import = config;
  };
in hosts
