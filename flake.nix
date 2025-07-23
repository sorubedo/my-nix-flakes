# my-flakes/flake.nix
{
  description = "My collection of Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      overlays.default = final: prev: {
        myFlakes = self.packages.${prev.system};
      };
    }

    //

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;

        packagesPath = ./pkgs;
        packageNames = builtins.attrNames (
          lib.filterAttrs (name: type: type == "directory") (builtins.readDir packagesPath)
        );

        buildPackage = name: pkgs.callPackage "${packagesPath}/${name}/package.nix" {};
        allPackages = lib.genAttrs packageNames buildPackage;
      in
      {
        packages = allPackages;
      }
    );
}
