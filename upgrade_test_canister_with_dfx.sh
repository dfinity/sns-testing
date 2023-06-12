#!/usr/bin/env bash
# run this script locally

set -euo pipefail

export GREETING="${1:-Hoi}"

. ./constants.sh normal

dfx canister install test --network "${NETWORK}" --mode upgrade --argument "(opt record {sns_governance = null; greeting = opt \"$GREETING\";})" --argument-type idl --wasm test.wasm