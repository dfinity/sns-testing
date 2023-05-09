#!/bin/bash
# run this script locally

set -euo pipefail

export ICP="${1:-200}"
export ACCOUNT="${2}"

. ./constants.sh normal

dfx identity use "${DFX_IDENTITY}"
dfx ledger transfer --network "${NETWORK}" --memo 0 --icp "${ICP}" "${ACCOUNT}"
