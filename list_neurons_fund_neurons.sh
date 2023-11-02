#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

export CURRENT_DX_IDENT=$(${DFX} identity whoami)

for NF_NEURON_IDENTITY in "$HOME"/.config/dfx/identity/nns-nf-neuron*; do
  ${DFX} identity use "${NF_NEURON_IDENTITY}"
  NEURON_ID="$(${DFX} canister --network "${NETWORK}" call nns-governance get_neuron_ids "()" | sed 's/(vec { //' | sed 's/ .*//')"

  ${DFX} canister --network "$NETWORK" call nns-governance get_full_neuron "($NEURON_ID)"
done

# Switch back to the previous identity
${DFX} identity use "$CURRENT_DX_IDENT"

