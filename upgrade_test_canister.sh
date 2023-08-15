#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

GREETING="${1:-Hoi}"

. ./constants.sh normal

if [ -f "./sns_canister_ids.json" ]
then
    ./upgrade_dapp.sh "test" "" "(opt record {sns_governance = opt principal\"${SNS_GOVERNANCE_CANISTER_ID}\"; greeting = opt \"${GREETING}\";})"
else
    ./upgrade_dapp.sh "test" "" "(opt record {sns_governance = null; greeting = opt \"${GREETING}\";})"
fi
