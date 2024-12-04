#!/usr/bin/env bash

set -euo pipefail

CURRENTDIR="$(pwd)"

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

REPODIR="$(pwd)"

export NAME="${1:-test}"
export WASM="${2:-}"
export ARG="${3:-()}"

. ./constants.sh normal

export DEVELOPER_NEURON_ID="$(./bin/dfx canister \
  --network "${NETWORK}" \
  call "${SNS_GOVERNANCE_CANISTER_ID}" \
  list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 1})" \
    | idl2json \
    | jq -r ".neurons[0].id[0].id" \
    | python3 -c "import sys; ints=sys.stdin.readlines(); sys.stdout.write(bytearray(eval(''.join(ints))).hex())")"

cd "${CURRENTDIR}"

if [ -f "${ARG}" ]
then
  ARGFLAG="--canister-upgrade-arg-path"
else
  ARGFLAG="--canister-upgrade-arg"
fi

if [[ -z "${WASM}" ]]
then
  ./bin/dfx build --network "${NETWORK}" "${NAME}"
  WASM=".dfx/${DX_NETWORK}/canisters/${NAME}/${NAME}"
  ic-wasm "${WASM}.wasm" -o "${WASM}-s.wasm" shrink
  gzip "${WASM}-s.wasm"
  export WASM="${WASM}-s.wasm.gz"
fi

export CID="$(./bin/dfx canister --network "${NETWORK}" id "${NAME}")"
./bin/quill sns \
   --canister-ids-file "${REPODIR}/sns_canister_ids.json" \
   --pem-file "${PEM_FILE}" \
   make-upgrade-canister-proposal \
   --target-canister-id "${CID}" \
   --mode upgrade \
   --wasm-path "${WASM}" \
   "${ARGFLAG}" "${ARG}" \
   "${DEVELOPER_NEURON_ID}" > msg.json

./bin/quill send \
  --insecure-local-dev-mode \
  --yes msg.json | grep -v "new_canister_wasm"
