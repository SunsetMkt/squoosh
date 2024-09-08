{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/24.05";
    flake-utils.url = "github:numtide/flake-utils";
    mozjpeg-src = {
      url = "github:mozilla/mozjpeg/v3.3.1";
      flake = false;
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      mozjpeg-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) callPackage stdenv lib;

        buildSquooshCppCodec = callPackage (import ../../nix/squoosh-cxx-builder) { };
        squooshHelpers = callPackage (import ../../nix/squoosh-helpers) { };
        inherit (squooshHelpers) forAllVariants mkRepoBinaryUpdater;

        variants = {
          base = { };
        };

        src = lib.sources.sourceByRegex ./. [
          "Makefile"
          "enc(/.+)?"
        ];

        builder = variantName: opts: {
          mozjpeg-squoosh = buildSquooshCppCodec {
            name = "mozjpeg-squoosh";
            inherit src;
            MOZJPEG = self.packages.${system}."mozjpeg-${variantName}";

            dontConfigure = true;
            decoder = null;
          };

          mozjpeg = stdenv.mkDerivation {
            name = "mozjpeg";
            src = mozjpeg-src;
            nativeBuildInputs = [
              pkgs.autoconf
              pkgs.automake
              pkgs.libtool
              pkgs.emscripten
              pkgs.pkg-config
            ];
            configurePhase = ''
                # $HOME is required for Emscripten to work.
                # See: https://nixos.org/manual/nixpkgs/stable/#emscripten
              	export HOME=$TMPDIR
              	autoreconf -ifv
                emconfigure ./configure \
                  --disable-shared \
                  --without-turbojpeg \
                  --without-simd \
                  --without-arith-enc \
                  --without-arith-dec \
                  --with-build-date=squoosh \
                  --prefix=$out
            '';
            buildPhase = ''
              export HOME=$TMPDIR
              emmake make V=1 -j$(nproc) --trace 
            '';
            installPhase = ''
              make install
              cp *.h $out/include
              cp rdswitch.o $out/lib
            '';
            dontFixup = true;
          };
        };

        packageVariants = forAllVariants { inherit builder variants; };
      in

      mkRepoBinaryUpdater {
        packages = packageVariants // {
          default = packageVariants."mozjpeg-squoosh-base";
        };
      }
    );
}
