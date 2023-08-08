#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

SNS_ROOT_CANISTER_ID=$(jq -r '.root_canister_id' sns_canister_ids.json)

dfx canister \
    --network "${NETWORK}" \
    call "${SNS_ROOT_CANISTER_ID}" \
    --candid candid/sns_root.did \
    list_sns_canisters '(record {})'
