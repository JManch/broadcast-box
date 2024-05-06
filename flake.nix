{
  description = "A WebRTC broadcast server.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      gomod2nix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forEachSystem (system: {
        broadcast-box = nixpkgs.legacyPackages.${system}.callPackage ./nix {
          inherit (gomod2nix.legacyPackages.${system}) buildGoApplication;
        };
        default = self.packages.${system}.broadcast-box;
      });

      devShells = forEachSystem (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = [ gomod2nix.packages.${system}.default ];
        };
      });
    };
}
