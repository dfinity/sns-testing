#!/bin/bash
# run this script locally

set -euo pipefail

export PROPOSAL="${1:-1}" && shift # consume the argument
export VOTE="${2:-y}" && shift # consume the argument
export VOTING_IDENTITY="${3:-dev-ident-1}" && shift # consume the argument

. ./constants.sh normal

export CURRENT_DFX_IDENT=$(dfx identity whoami)

dfx identity use "${VOTING_IDENTITY}"
PEM_FILE="$(readlink -f "$HOME/.config/dfx/identity/${VOTING_IDENTITY}/identity.pem")"
export DFX_PRINCIPAL="$(dfx identity get-principal)"
export NEURON_IDS="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DFX_PRINCIPAL}\"; limit = 0})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs -L1 didc encode | sed 's/^.\{20\}//')"

for NEURON_ID in ${NEURON_IDS}
do
  quill sns --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" register-vote --proposal-id "${PROPOSAL}" --vote "${VOTE}" "${NEURON_ID}" > "msg_$NEURON_ID.json"
  quill --insecure-local-dev-mode send --yes "msg_$NEURON_ID.json"
done

# Switch back to the previous identity
dfx identity use "$CURRENT_DFX_IDENT"
