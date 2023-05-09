#!/bin/bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

curl -L "https://github.com/dfinity/sdk/raw/${DFX_COMMIT}/src/distributed/assetstorage.wasm.gz" -o assets.wasm.gz
curl -L "https://raw.githubusercontent.com/dfinity/sdk/${DFX_COMMIT}/src/distributed/assetstorage.did" -o candid/assets.did

dfx --provisional-create-canister-effective-canister-id jrlun-jiaaa-aaaab-aaaaa-cai deploy assets --network "${NETWORK}" --no-wallet
