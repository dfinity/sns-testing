#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal

export CURRENT_DFX_IDENT=$(dfx identity whoami)

for CF_NEURON_IDENTITY in "$HOME"/.config/dfx/identity/nns-cf-neuron*; do
  dfx identity use "${CF_NEURON_IDENTITY}"
  NEURON_ID="$(dfx canister --network "${NETWORK}" call nns-governance get_neuron_ids "()" | sed 's/(vec { //' | sed 's/ .*//')"

  dfx canister --network "$NETWORK" call nns-governance get_full_neuron "($NEURON_ID)"
done

# Switch back to the previous identity
dfx identity use "$CURRENT_DFX_IDENT"

