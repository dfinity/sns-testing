#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export NAME="${1:-test}"
export WASM="${2:-}"
export ARG="${3:-()}"

. ./constants.sh normal

./bin/dfx \
  --provisional-create-canister-effective-canister-id jrlun-jiaaa-aaaab-aaaaa-cai \
  canister create "${NAME}" \
  --network "${NETWORK}" \
  --no-wallet

if [[ -z "${WASM}" ]]
then
  rm -f "${WASM}-s.wasm.gz"
  ./bin/dfx build --network "${NETWORK}" "${NAME}"
  WASM=".dfx/${DX_NETWORK}/canisters/${NAME}/${NAME}"
  ic-wasm "${WASM}.wasm" -o "${WASM}-s.wasm" shrink
  gzip "${WASM}-s.wasm"
  export WASM="${WASM}-s.wasm.gz"
fi

./bin/dfx canister install "${NAME}" --network "${NETWORK}" --argument "${ARG}" --argument-type idl --wasm "${WASM}"
