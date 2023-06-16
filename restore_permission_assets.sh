#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

SNS_GOVERNANCE_ID="$(dfx canister --network "${NETWORK}" id sns_governance)"
dfx canister --network "${NETWORK}" call assets revoke_permission "(record {of_principal = principal\"${SNS_GOVERNANCE_ID}\"; permission = variant { ManagePermissions }})"

dfx canister --network "${NETWORK}" call assets grant_permission "(record {to_principal = principal\"${DX_PRINCIPAL}\"; permission = variant { ManagePermissions }})"
