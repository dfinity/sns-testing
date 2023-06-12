#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export NAME=${1:-default}
export PERMISSION=${2:-Commit}

. ./constants.sh normal

export DEVELOPER_NEURON_ID="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 1})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs didc encode | tail -c +21)"

export CID="$(dfx canister --network "${NETWORK}" id assets)"

export IDENTITY="$(dfx identity --identity "${NAME}" get-principal)"
export BLOB="$(didc encode --format blob "(record {of_principal = principal\"${IDENTITY}\"; permission = variant {${PERMISSION}}})")"
quill sns  \
   --canister-ids-file ./sns_canister_ids.json  \
   --pem-file "${PEM_FILE}"  \
   make-proposal --proposal "(record { title=\"Execute revoke permission to asset canister.\"; url=\"https://example.com/\"; summary=\"This proposal executes revoke permission to asset canister.\"; action=opt variant {ExecuteGenericNervousSystemFunction = record {function_id=1001:nat64; payload=${BLOB}}}})" $DEVELOPER_NEURON_ID > msg.json
quill --insecure-local-dev-mode send --yes msg.json
