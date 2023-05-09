#!/bin/bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

if [ -f "./sns_canister_ids.json" ]
then
    export SNS_GOVERNANCE="$(dfx canister --network ${NETWORK} id sns_governance)"
    ./deploy_dapp.sh "test" "" "(opt record {sns_governance = opt principal\"${SNS_GOVERNANCE}\"; greeting = null;})"
else
    ./deploy_dapp.sh "test" "" "(opt record {sns_governance = null; greeting = null;})"
fi
