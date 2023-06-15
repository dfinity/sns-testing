#!/usr/bin/env bash

set -euo pipefail

export ID="${1:-1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_governance get_proposal "(record {proposal_id = opt record {id = (${ID}:nat64)}})"
