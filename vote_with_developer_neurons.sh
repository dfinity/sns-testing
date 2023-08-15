#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

export CURRENT_DX_IDENT=$(dfx identity whoami)

export PROPOSAL="${1:-1}"
export VOTE="${2:-y}"

for DEV_IDENT in "$HOME"/.config/dfx/identity/dev-ident-*; do
  PEM_FILE="$(readlink -f "${DEV_IDENT}/identity.pem")"
  dfx identity use "${DEV_IDENT}"
  export DX_PRINCIPAL="$(dfx identity get-principal)"
  export JSON="$(dfx canister --network "${NETWORK}" call "${SNS_GOVERNANCE_CANISTER_ID}" list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 0})" | idl2json | jq -r ".neurons")"
  for((i=0; i<"$(echo $JSON | jq length)"; i++))
  do
    export NEURON_ID="$(echo $JSON | jq -r ".[${i}].id[0].id" | python3 -c "import sys; ints=sys.stdin.readlines(); sys.stdout.write(bytearray(eval(''.join(ints))).hex())")"
    quill sns --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" register-vote --proposal-id ${PROPOSAL} --vote ${VOTE} ${NEURON_ID} > "msg_$NEURON_ID.json"
    quill --insecure-local-dev-mode send --yes "msg_$NEURON_ID.json" &
  done
done

wait

# Switch back to the previous identity
dfx identity use "$CURRENT_DX_IDENT"
