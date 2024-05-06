{
  description = "A WebRTC broadcast server.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, gomod2nix, ... }:
    let
      systems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = function:
        nixpkgs.lib.genAttrs systems
          (system: function (import nixpkgs {
            inherit system;
          }));
    in
    {
      packages = forAllSystems (pkgs: rec {
        broadcast-box = pkgs.callPackage ./nix { inherit (gomod2nix.legacyPackages.${pkgs.system}) buildGoApplication; };
        default = broadcast-box;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ gomod2nix.packages.${pkgs.system}.default ];
        };
      });
    };
}
