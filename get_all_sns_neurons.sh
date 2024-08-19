#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

dfx canister \
    --network "${NETWORK}" \
    call "${SNS_GOVERNANCE_CANISTER_ID}" \
    list_neurons "(record {of_principal = null; limit = 0})"
