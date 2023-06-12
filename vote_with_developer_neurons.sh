#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal

export CURRENT_DX_IDENT=$(dfx identity whoami)

export PROPOSAL="${1:-1}"
export VOTE="${2:-y}"

for DEV_IDENT in "$HOME"/.config/dfx/identity/dev-ident-*; do
  PEM_FILE="$(readlink -f "${DEV_IDENT}/identity.pem")"
  dfx identity use "${DEV_IDENT}"
  export DX_PRINCIPAL="$(dfx identity get-principal)"
  export NEURON_IDS="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 0})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs -L1 didc encode | sed 's/^.\{20\}//')"
  for NEURON_ID in ${NEURON_IDS}
  do
    quill sns --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" register-vote --proposal-id ${PROPOSAL} --vote ${VOTE} ${NEURON_ID} > "msg_$NEURON_ID.json"
    quill --insecure-local-dev-mode send --yes "msg_$NEURON_ID.json" &
  done
done

wait

# Switch back to the previous identity
dfx identity use "$CURRENT_DX_IDENT"
