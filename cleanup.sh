#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh install

cp dfx.json.orig dfx.json
cp sns-test.yml.orig sns-test.yml

rm -rf .dfx \
    *.wasm *.wasm.gz \
    nns-dapp/out \
    nns-dapp/.dfx/* \
    nns-dapp/canister_ids.json \
    nns-dapp/*.wasm \
    nns-dapp/*.wasm.gz \
    internet-identity/.dfx \
    internet-identity/internet_identity.wasm \
    msg.json \
    sns_canister_ids.json \
    upload_*.txt

# Remove Wallets
rm -rf ~/.local/share/dfx/network/${NETWORK}/wallets.json
rm -rf ~/Library/Application\ Support/org.dfinity.dfx/network/${NETWORK}/wallets.json

# Remove any generated quill messages
rm -rf msg_*.json

