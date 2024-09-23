#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

dfx canister call \
    --network "${NETWORK}" \
    "${SNS_SWAP_CANISTER_ID}" \
    get_state '(record {})'
