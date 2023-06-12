{ system ? builtins.currentSystem }:
let
  sourcesnix = builtins.fetchurl {
    url = https://raw.githubusercontent.com/nmattia/niv/v0.2.21/nix/sources.nix;
    sha256 = "129xhkih5sjdifcdfgfy36vj0a9qlli3cgxlrpqq8qfz42avn93v";
  };
  nixpkgs = (import sourcesnix { sourcesFile = ./sources.json; inherit pkgs; }).nixpkgs;

  pkgs =
    import nixpkgs {
      inherit system;
      overlays = [
        (self: super: {
          sources = import sourcesnix { sourcesFile = ./sources.json; pkgs = super; };
          rustPackages = self.rustPackages_1_66;
          subpath = import ./gitSource.nix;
          quill = super.stdenv.mkDerivation {
            name = "quill";
            src = builtins.fetchurl {
              url = "https://github.com/dfinity/quill/releases/download/v0.4.1/quill-linux-x86_64-musl";
              sha256 = "sha256:0v8dvhm5nzcfh24a4pmfbk14ws7mkjkpp06d7nv64yw32hzfx344";
            };
            phases = [ "installPhase" ]; # Removes all phases except installPhase
            installPhase = ''
              mkdir -p $out/bin
              cp $src $out/bin/quill
              chmod +x $out/bin/quill
            '';
          };
        })
      ];
    };
in
pkgs
