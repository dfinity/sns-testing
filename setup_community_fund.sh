#!/usr/bin/env bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

export CURRENT_DX_IDENT=$(dfx identity whoami)

for CF_NEURON_IDENTITY in "$HOME"/.config/dfx/identity/nns-cf-neuron*; do
  PEM_FILE="$(readlink -f "${CF_NEURON_IDENTITY}/identity.pem")"
  dfx identity use "${CF_NEURON_IDENTITY}"
  NEURON_ID="$(dfx canister --network "${NETWORK}" call nns-governance get_neuron_ids "()" | sed 's/(vec { //' | sed 's/ .*//')"

  quill --insecure-local-dev-mode --pem-file "$PEM_FILE" neuron-manage --join-community-fund "$NEURON_ID" > msg.json && quill --insecure-local-dev-mode send msg.json --yes

  JCF=$(dfx canister --network "${NETWORK}" call nns-governance get_full_neuron "($NEURON_ID)" | grep joined_community_fund_timestamp_seconds)
  [[ "$JCF" == *"nat64"* ]] || { echo "One of the initial Neurons did not join the CF"; exit 1; }

done

# Switch back to the previous identity
dfx identity use "$CURRENT_DX_IDENT"
