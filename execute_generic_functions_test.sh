#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export TEXT="${1:-Hoi}"

. ./constants.sh normal

export DEVELOPER_NEURON_ID="$(dfx canister \
   --network "${NETWORK}" \
   call "${SNS_GOVERNANCE_CANISTER_ID}" \
   list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 1})" \
      | idl2json \
      | jq -r ".neurons[0].id[0].id" \
      | python3 -c "import sys; ints=sys.stdin.readlines(); sys.stdout.write(bytearray(eval(''.join(ints))).hex())")"

export BLOB="$(didc encode --format blob "(\"${TEXT}\")")"

quill sns  \
   --canister-ids-file ./sns_canister_ids.json  \
   --pem-file "${PEM_FILE}"  \
   make-proposal --proposal "(record { title=\"Execute generic functions for test canister.\"; url=\"https://example.com/\"; summary=\"This proposal executes generic functions for test canister.\"; action=opt variant {ExecuteGenericNervousSystemFunction = record {function_id=2000:nat64; payload=${BLOB}}}})" $DEVELOPER_NEURON_ID > msg.json
quill --insecure-local-dev-mode send --yes msg.json
