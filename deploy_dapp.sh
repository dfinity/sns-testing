#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export NAME="${1:-test}"
export WASM="${2:-}"
export ARG="${3:-()}"

. ./constants.sh normal

dfx --provisional-create-canister-effective-canister-id jrlun-jiaaa-aaaab-aaaaa-cai canister create "${NAME}" --network "${NETWORK}" --no-wallet

if [[ -z "${WASM}" ]]
then
  # dfx build --network "${NETWORK}" "${NAME}" -- TODO: Make this step optional
  export WASM=".dfx/${DX_NETWORK}/canisters/${NAME}/${NAME}.wasm"
  curl --fail -L https://github.com/dfinity/sns-testing/releases/download/test-wasm-rc-1/test.wasm -o "${WASM}"
fi

dfx canister install "${NAME}" --network "${NETWORK}" --argument "${ARG}" --argument-type idl --wasm "${WASM}"
