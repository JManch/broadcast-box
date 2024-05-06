{
  description = "A WebRTC broadcast server.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    gomod2nix.url = "github:nix-community/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      gomod2nix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
      forAllSystems =
        function:
        nixpkgs.lib.genAttrs systems (
          system:
          function (
            import nixpkgs {
              inherit system;
            }
          )
        );
    in
    {
      packages = forAllSystems (pkgs: rec {
        broadcast-box = pkgs.callPackage ./nix {
          inherit (gomod2nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}) buildGoApplication;
        };
        default = broadcast-box;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [ gomod2nix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
        };
      });
    };
}
