#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

if [ -f "./sns_canister_ids.json" ]
then
    ./deploy_dapp.sh "test" "" "(opt record {sns_governance = opt principal\"${SNS_GOVERNANCE_CANISTER_ID}\"; greeting = null;})"
else
    ./deploy_dapp.sh "test" "" "(opt record {sns_governance = null; greeting = null;})"
fi
