#!/usr/bin/env bash
# run this script locally

set -euo pipefail

export NAME="${1:-test}"
export WASM="${2:-}"
export ARG="${3:-()}"

. ./constants.sh normal

export DEVELOPER_NEURON_ID="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 1})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs didc encode | tail -c +21)"

if [[ -z "${WASM}" ]]
then
  dfx build --network "${NETWORK}" "${NAME}"
  export WASM=".dfx/${DX_NETWORK}/canisters/${NAME}/${NAME}.wasm"
fi

export CID="$(dfx canister --network "${NETWORK}" id "${NAME}")"
quill sns  \
   --canister-ids-file ./sns_canister_ids.json  \
   --pem-file "${PEM_FILE}"  \
   make-upgrade-canister-proposal  \
   --summary "This proposal upgrades test canister"  \
   --title "Upgrade test canister"  \
   --url "https://example.com/"  \
   --target-canister-id "${CID}"  \
   --wasm-path "${WASM}"  \
   --canister-upgrade-arg "${ARG}"  \
   "${DEVELOPER_NEURON_ID}" > msg.json
quill --insecure-local-dev-mode send --yes msg.json | grep -v "new_canister_wasm"
