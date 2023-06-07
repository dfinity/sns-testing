#!/bin/bash

CURRENTDIR="$(pwd)"

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

REPODIR="$(pwd)"

set -euo pipefail

export NAME="${1:-test}"
export WASM="${2:-}"
export ARG="${3:-()}"

. ./constants.sh normal

export DEVELOPER_NEURON_ID="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DFX_PRINCIPAL}\"; limit = 1})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs didc encode | tail -c +21)"

cd "${CURRENTDIR}"

if [ -f "${ARG}" ]
then
  ARGFLAG="--canister-upgrade-arg-path"
else
  ARGFLAG="--canister-upgrade-arg"
fi

if [[ -z "${WASM}" ]]
then
  dfx build --network "${NETWORK}" "${NAME}"
  export WASM=".dfx/${DFX_NETWORK}/canisters/${NAME}/${NAME}.wasm"
fi

export CID="$(dfx canister --network "${NETWORK}" id "${NAME}")"
quill sns  \
   --canister-ids-file "${REPODIR}/sns_canister_ids.json"  \
   --pem-file "${PEM_FILE}"  \
   make-upgrade-canister-proposal  \
   --summary "This proposal upgrades test canister"  \
   --title "Upgrade test canister"  \
   --url "https://example.com/"  \
   --target-canister-id "${CID}"  \
   --wasm-path "${WASM}"  \
   "${ARGFLAG}" "${ARG}"  \
   "${DEVELOPER_NEURON_ID}" > msg.json
quill --insecure-local-dev-mode send --yes msg.json | grep -v "new_canister_wasm"
