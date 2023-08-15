#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

dfx canister \
    --network "${NETWORK}" \
    call "${SNS_ROOT_CANISTER_ID}" \
    --candid candid/sns_root.did \
    list_sns_canisters '(record {})'
