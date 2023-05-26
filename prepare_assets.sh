#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal

SNS_GOVERNANCE_ID="$(dfx canister --network ${NETWORK} id sns_governance)"

dfx canister --network ${NETWORK} call assets grant_permission "(record {to_principal = principal\"${SNS_GOVERNANCE_ID}\"; permission = variant { ManagePermissions }})"
