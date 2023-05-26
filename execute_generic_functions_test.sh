#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

export TEXT="${1:-Hoi}"

. ./constants.sh normal

export DEVELOPER_NEURON_ID="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DFX_PRINCIPAL}\"; limit = 1})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs didc encode | tail -c +21)"

export BLOB="$(didc encode --format blob "(\"${TEXT}\")")"

quill sns  \
   --canister-ids-file ./sns_canister_ids.json  \
   --pem-file "${PEM_FILE}"  \
   make-proposal --proposal "(record { title=\"Execute generic functions for test canister.\"; url=\"https://example.com/\"; summary=\"This proposal executes generic functions for test canister.\"; action=opt variant {ExecuteGenericNervousSystemFunction = record {function_id=2000:nat64; payload=${BLOB}}}})" $DEVELOPER_NEURON_ID > msg.json
quill --insecure-local-dev-mode send --yes msg.json
