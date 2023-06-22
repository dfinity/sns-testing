#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export ICP="${1:-200}"
export ACCOUNT="${2}"

. ./constants.sh normal

dfx identity use "${DX_IDENT}"
dfx ledger transfer --network "${NETWORK}" --memo 0 --icp "${ICP}" "${ACCOUNT}"
