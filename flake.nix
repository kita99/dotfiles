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
  };

  outputs = { self, nixpkgs, nixos-generators, impermanence, disko, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.wintermute = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/wintermute/configuration.nix
          ./hosts/wintermute/disko.nix
          impermanence.nixosModules.impermanence
          disko.nixosModules.disko
        ];
      };

      nixosConfigurations.iso-builder = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./iso/builder.nix ];
      };

      packages.${system}.iso =
        self.nixosConfigurations.iso-builder.config.system.build.isoImage;
    };
}
