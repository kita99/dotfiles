{
  description = "NixOS dotfiles + ISO builder (impermanence + encrypted persistence)";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , nixos-generators
    , impermanence
    , disko
    , home-manager
    , ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      diskoLibForTests = pkgs.callPackage "${disko}/lib" {
        lib = nixpkgs.lib;
        makeTest = import "${nixpkgs}/nixos/tests/make-test-python.nix";
        eval-config = import "${nixpkgs}/nixos/lib/eval-config.nix";
        qemu-common = import "${nixpkgs}/nixos/lib/qemu-common.nix";
      };
    in
    {
      nixosConfigurations.wintermute = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/wintermute/configuration.nix
          ./hosts/wintermute/disko.nix

          disko.nixosModules.disko
          impermanence.nixosModules.impermanence

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.kita = import ./modules/home;
              backupFileExtension = "hm-bak";
            };
          }
        ];
      };

      nixosConfigurations.wintermute-installtest = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/wintermute/installtest.nix
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.kita = import ./modules/home;
              backupFileExtension = "hm-bak";
            };
          }
        ];
      };

      nixosConfigurations.wintermute-installtest-minimal = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/wintermute/installtest-minimal.nix
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
        ];
      };

      nixosConfigurations.iso-builder = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./iso/builder.nix ];
      };

      packages.${system} = {
        iso = self.nixosConfigurations.iso-builder.config.system.build.isoImage;
        impermanence-diff = pkgs.callPackage ./pkgs/impermanence-diff.nix { };
        default = self.packages.${system}.iso;
      };

      checks.${system} = {
        config-sanity = import ./tests/config-sanity.nix {
          inherit pkgs;
          inherit (nixpkgs) lib;
          config = self.nixosConfigurations.wintermute.config;
        };

        home-activation = import ./tests/home-activation.nix {
          inherit pkgs home-manager;
        };

        full-system = import ./tests/full-system.nix {
          inherit pkgs impermanence home-manager;
          diskoLib = diskoLibForTests;
        };

        disko-install = import ./tests/disko-install.nix {
          inherit pkgs self disko;
        };

        impermanence = import ./tests/impermanence.nix {
          inherit pkgs impermanence;
          diskoLib = diskoLibForTests;
        };
      };

      formatter.${system} = pkgs.nixpkgs-fmt;

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ nixpkgs-fmt disko.packages.${system}.disko ];
      };
    };
}
