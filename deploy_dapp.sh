#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export NAME="${1:-test}"
export WASM="${2:-}"
export ARG="${3:-()}"

. ./constants.sh normal

dfx --provisional-create-canister-effective-canister-id tqzl2-p7777-77776-aaaaa-cai canister create "${NAME}" --network "${NETWORK}" --no-wallet

if [[ -z "${WASM}" ]]
then
  export WASM=".dfx/${DX_NETWORK}/canisters/${NAME}/${NAME}.wasm"
  dfx build --network "${NETWORK}" "${NAME}"
fi

dfx canister install "${NAME}" --network "${NETWORK}" --argument "${ARG}" --argument-type idl --wasm "${WASM}"
