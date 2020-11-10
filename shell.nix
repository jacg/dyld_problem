{ nixpkgs-commit-id ? "95d26c9a9f2a102e25cf318a648de44537f42e09" # nixos-20.09 on 2020-10-24
}:
let
  nixpkgs-url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-commit-id}.tar.gz";
  pkgs = import (fetchTarball nixpkgs-url) {
      overlays = map (uri: import (fetchTarball uri)) [
        https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz
      ];
    };
  stdenv = pkgs.stdenv;

  # ----- Rust --------------------------------------------------------------------
  rust-stable  = pkgs.latest.rustChannels.stable .rust;
  rust = (rust-stable.override { extensions = []; });

  # ----- A C library -------------------------------------------------------------
  the-c-library-being-wrapped = pkgs.stdenv.mkDerivation {
    name = "the-c-library";
    version = "64";
    src = ./the-c-source;

    nativeBuildInputs = stdenv.lib.optional stdenv.isDarwin [ pkgs.fixDarwinDylibNames ];

    buildPhase = ''
      export WORKDIR=`pwd`
      CXX=${pkgs.clang_9}/bin/clang++ make
    '';

    installPhase = ''
      mkdir -p $out/lib
      mv libTheCLibrary.so $out/lib/
    '';
  };

  # --------------------------------------------------------------------------------
  buildInputs = [
    the-c-library-being-wrapped
    rust
    pkgs.clang_9
  ];

in

pkgs.stdenv.mkDerivation {
  name = "dydl-error";
  buildInputs = buildInputs;
  LD_LIBRARY_PATH = "${pkgs.stdenv.lib.makeLibraryPath buildInputs}";

  # Needed if using bindgen to wrap C libraries in Rust
  LIBCLANG_PATH = "${pkgs.llvmPackages_9.libclang}/lib";
}
