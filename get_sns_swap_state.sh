#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

SNS_SWAP_CANISTER_ID=$(jq -r '.swap_canister_id' sns_canister_ids.json)

dfx canister call \
    --network "${NETWORK}" \
    "${SNS_SWAP_CANISTER_ID}" \
    --candid candid/sns_swap.did \
    get_state '(record {})'
