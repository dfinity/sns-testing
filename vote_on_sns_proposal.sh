#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export NUM_PARTICIPANTS="${1:-3}"
export PROPOSAL="${2:-3}"
export VOTE="${3:-y}"

. ./constants.sh normal

for (( c=0; c<${NUM_PARTICIPANTS}; c++ ))
do
  export ID="$(printf "%03d" ${c})"
  export NEW_DX_IDENT="participant-${ID}"
  export PEM_FILE="$(readlink -f ~/.config/dfx/identity/${NEW_DX_IDENT}/identity.pem)"
  dfx identity use "${NEW_DX_IDENT}"
  export DX_PRINCIPAL="$(dfx identity get-principal)"
  export NEURON_IDS="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 0})" | grep "^          id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs -L1 didc encode | sed 's/^.\{20\}//')"
  for NEURON_ID in ${NEURON_IDS}
  do
    quill sns --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" register-vote --proposal-id ${PROPOSAL} --vote ${VOTE} ${NEURON_ID} > msg.json
    quill --insecure-local-dev-mode send --yes msg.json
  done
done

dfx identity use "${DX_IDENT}"
