#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

echo "$(dfx canister \
    --network "${NETWORK}" \
    call "${SNS_GOVERNANCE_CANISTER_ID}" \
    --candid candid/sns_governance.did \
    list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 1})" \
        | idl2json \
        | jq -r ".neurons[0].id[0].id" \
        | python3 -c "import sys; ints=sys.stdin.readlines(); sys.stdout.write(bytearray(eval(''.join(ints))).hex())")"
