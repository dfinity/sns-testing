#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

export CURRENT_DX_IDENT=$(${DFX} identity whoami)

for NF_NEURON_IDENTITY in "${HOME}/.config/dfx/identity/"nns-nf-neuron*; do
  PEM_FILE="$(readlink -f "${NF_NEURON_IDENTITY}/identity.pem")"
  ${DFX} identity use "${NF_NEURON_IDENTITY}"
  NEURON_ID="$(${DFX} canister --network "${NETWORK}" call nns-governance get_neuron_ids "()" | sed 's/(vec { //' | sed 's/ .*//')"

  quill \
    --insecure-local-dev-mode \
    --pem-file "$PEM_FILE" \
    neuron-manage \
    --join-community-fund "$NEURON_ID" \
      > msg.json
  quill --insecure-local-dev-mode send msg.json --yes

  JNF=$(${DFX} canister --network "${NETWORK}" call nns-governance get_full_neuron "(${NEURON_ID})" | grep joined_community_fund_timestamp_seconds)
  [[ "$JNF" == *"nat64"* ]] || { echo "One of the initial Neurons did not join the NF"; exit 1; }

done

# Switch back to the previous identity
${DFX} identity use "$CURRENT_DX_IDENT"
