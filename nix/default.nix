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
        })
      ];
    };
in
pkgs
