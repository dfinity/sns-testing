#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

export DEVELOPER_NEURON_ID="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 1})" | idl2json | jq -r ".neurons[0].id[0].id" | python3 -c "import sys; ints=sys.stdin.readlines(); sys.stdout.write(bytearray(eval(''.join(ints))).hex())")"

quill sns  \
   --canister-ids-file ./sns_canister_ids.json  \
   --pem-file "${PEM_FILE}"  \
   configure-dissolve-delay --start-dissolving "${DEVELOPER_NEURON_ID}" > msg.json
quill --insecure-local-dev-mode send --yes msg.json
