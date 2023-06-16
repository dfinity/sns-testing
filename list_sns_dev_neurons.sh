#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

export CURRENT_DX_IDENT=$(dfx identity whoami)

for DEV_IDENT in "$HOME"/.config/dfx/identity/dev-ident-*; do
  PEM_FILE="$(readlink -f "${DEV_IDENT}/identity.pem")"
  dfx identity use "${DEV_IDENT}"
  export DX_PRINCIPAL="$(dfx identity get-principal)"
  export NEURON_IDS="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 0})")"
  echo "Listing Developer Neurons for Identity $DEV_IDENT, Principal $DX_PRINCIPAL"
  echo "$NEURON_IDS"

done

# List the canister controlled SNS Dev Neurons for the OC SNS deployment config
CANISTER_DEV_NEURON=n2xex-iyaaa-aaaar-qaaeq-cai
echo "Listing for $CANISTER_DEV_NEURON"
dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"$CANISTER_DEV_NEURON\"; limit = 0})"

# Switch back to the previous identity
dfx identity use "$CURRENT_DX_IDENT"
