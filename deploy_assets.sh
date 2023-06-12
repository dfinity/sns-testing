#!/usr/bin/env bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

curl -L "https://github.com/dfinity/sdk/raw/${DX_COMMIT}/src/distributed/assetstorage.wasm.gz" -o assets.wasm.gz
curl -L "https://raw.githubusercontent.com/dfinity/sdk/${DX_COMMIT}/src/distributed/assetstorage.did" -o candid/assets.did

dfx --provisional-create-canister-effective-canister-id jrlun-jiaaa-aaaab-aaaaa-cai deploy assets --network "${NETWORK}" --no-wallet
