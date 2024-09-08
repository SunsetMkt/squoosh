{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    flake-utils.url = "github:numtide/flake-utils";
    fenix.url = "github:nix-community/fenix/7bad6c7ff73b784a9c7de9147626c8d5d5072809";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      fenix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) callPackage lib;

        buildSquooshRustCodec = callPackage (import ../../nix/squoosh-rust-builder) {
          fenix = fenix.packages.${system};
        };
        squooshHelpers = callPackage (import ../../nix/squoosh-helpers) { };
        inherit (squooshHelpers) mkRepoBinaryUpdater forAllVariants;

        variants = {
          base = { };
        };

        src = lib.sources.sourceByRegex ./. [
          "Cargo\.*"
          ".*\.rs"
        ];

        builder = variantName: opts: {
          rotate-squoosh = buildSquooshRustCodec {
            name = "rotate-squoosh";
            inherit src;
            cargoLock = {
              lockFile = "${src}/Cargo.lock";
            };
            wasmBindgen = null;
          };
        };

        packageVariants = forAllVariants { inherit builder variants; };
      in
      mkRepoBinaryUpdater {
        packages = packageVariants // {
          default = packageVariants."rotate-squoosh-base";
        };
      }
    );
}
