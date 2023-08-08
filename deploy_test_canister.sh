#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export CID=${1:-}

. ./constants.sh normal

if [ -f "./sns_canister_ids.json" ]
then
    SNS_GOVERNANCE_CANISTER_ID=$(jq -r '.governance_canister_id' sns_canister_ids.json)
    ./deploy_dapp.sh "${CID}" "test" "" "(opt record {sns_governance = opt principal\"${SNS_GOVERNANCE_CANISTER_ID}\"; greeting = null;})"
else
    ./deploy_dapp.sh "${CID}" "test" "" "(opt record {sns_governance = null; greeting = null;})"
fi
