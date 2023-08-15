#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

ID="${1}"

. ./constants.sh normal

dfx canister \
    --network "${NETWORK}" \
    call "${SNS_GOVERNANCE_CANISTER_ID}" \
    --candid candid/sns_governance.did \
    get_neuron "(record {neuron_id = opt record {id = blob \"${ID}\"};})"
