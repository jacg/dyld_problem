{ nixpkgs-commit-id ? "95d26c9a9f2a102e25cf318a648de44537f42e09" # nixos-20.09 on 2020-10-24
}:
let
  nixpkgs-url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-commit-id}.tar.gz";
  pkgs = import (fetchTarball nixpkgs-url) {
      overlays = map (uri: import (fetchTarball uri)) [
        https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz
      ];
    };

  # ----- Rust --------------------------------------------------------------------
  rust-stable  = pkgs.latest.rustChannels.stable .rust;
  rust = (rust-stable.override { extensions = []; });

  # ----- A C library -------------------------------------------------------------
  the-c-library-being-wrapped = pkgs.stdenv.mkDerivation {
    name = "the-c-library";
    version = "65";
    src = ./the-c-source;

    buildPhase = ''
      export WORKDIR=`pwd`
      echo "-----WORKDIR-----> $WORKDIR"
      echo "ls $WORKDIR":
      ls $WORKDIR
    	${pkgs.clang_9}/bin/clang++ -fpic -c -O2 -pg $WORKDIR/the_C_source_file.cc  -o $WORKDIR/the_object_file.o
      mkdir -p $out/lib
	    ${pkgs.clang_9}/bin/clang++ -shared -o     $out/lib/libTheCLibrary.so          $WORKDIR/the_object_file.o
    '';

    installPhase = ''
      echo "-----WORKDIR-----> $WORKDIR"
      echo "ls $WORKDIR":
      ls $WORKDIR
      mkdir -p $out/lib
      #mv libTheCLibrary.so $out/lib/
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
