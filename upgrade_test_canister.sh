#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export GREETING="${1:-Hoi}"

. ./constants.sh normal

if [ -f "./sns_canister_ids.json" ]
then
    export SNS_GOVERNANCE="$(dfx canister --network ${NETWORK} id sns_governance)"
    ./upgrade_dapp.sh "test" "" "(opt record {sns_governance = opt principal\"${SNS_GOVERNANCE}\"; greeting = opt \"${GREETING}\";})"
else
    ./upgrade_dapp.sh "test" "" "(opt record {sns_governance = null; greeting = opt \"${GREETING}\";})"
fi
