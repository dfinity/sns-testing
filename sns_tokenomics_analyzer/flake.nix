{
  description = "SNS Init Analyzer";

  inputs = {
    nixpkgs.url = "nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs { inherit system; };

        pythonEnv = pkgs.python3.withPackages (ps: [
          ps.pandas
          ps.pyyaml
          ps.dash
          ps.setuptools
          ps.plotly
          ps.numpy
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pythonEnv ];
        };
      }
    );
}
