#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

export NAME="${1:-test}"
export WASM="${2:-}"
export ARG="${3:-()}"

. ./constants.sh normal

dfx --provisional-create-canister-effective-canister-id jrlun-jiaaa-aaaab-aaaaa-cai canister create "${NAME}" --network "${NETWORK}" --no-wallet

if [[ -z "${WASM}" ]]
then
  dfx build --network "${NETWORK}" "${NAME}"
  export WASM=".dfx/${DFX_NETWORK}/canisters/${NAME}/${NAME}.wasm"
fi

dfx canister install "${NAME}" --network "${NETWORK}" --argument "${ARG}" --argument-type idl --wasm "${WASM}"
