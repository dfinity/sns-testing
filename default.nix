{
  system ? builtins.currentSystem,
}:

let nixpkgs = import ./nix { inherit system; }; in
let stdenv = nixpkgs.stdenv; in
let subpath = nixpkgs.subpath; in
let naersk = nixpkgs.callPackage nixpkgs.sources.naersk {
    inherit (nixpkgs.rustPackages) cargo rustc;
}; in
let subnet = (naersk.buildPackage rec {
    name = "subnet-id";
    root = subpath ./subnet-id;
    doCheck = false;
    release = true;
    nativeBuildInputs = with nixpkgs; [ pkg-config ];
    buildInputs = with nixpkgs; [ openssl ];
}); in

let dfx-env = import (builtins.fetchTarball "https://github.com/ninegua/ic-nix/releases/latest/download/dfx-env.tar.gz") { version = "20230605"; }; in

dfx-env.overrideAttrs (old: {
  nativeBuildInputs = with nixpkgs; old.nativeBuildInputs ++
    [ rustup pkg-config openssl protobuf cmake cachix killall jq coreutils bc subnet quill ];
  shellHook = ''
    rustup toolchain install stable
    rustup target add wasm32-unknown-unknown
  '';
})