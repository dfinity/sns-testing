#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

SNS_GOVERNANCE_CANISTER_ID=$(jq -r '.governance_canister_id' sns_canister_ids.json)

dfx canister \
    --network "${NETWORK}" \
    call "${SNS_GOVERNANCE_CANISTER_ID}" \
    --candid candid/sns_governance.did \
    list_proposals '(record {include_reward_status = vec {}; limit = 1:nat32; exclude_type = vec {}; include_status = vec {};})'
