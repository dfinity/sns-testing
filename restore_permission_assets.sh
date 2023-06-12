#!/usr/bin/env bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

SNS_GOVERNANCE_ID="$(dfx canister --network "${NETWORK}" id sns_governance)"
dfx canister --network "${NETWORK}" call assets revoke_permission "(record {of_principal = principal\"${SNS_GOVERNANCE_ID}\"; permission = variant { ManagePermissions }})"

dfx canister --network "${NETWORK}" call assets grant_permission "(record {to_principal = principal\"${DFX_PRINCIPAL}\"; permission = variant { ManagePermissions }})"
