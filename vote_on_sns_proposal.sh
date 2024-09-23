#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export NUM_PARTICIPANTS="${1:-100}"
export PROPOSAL="${2:-2}"
export VOTE="${3:-y}"

. ./constants.sh normal

for (( c=0; c<${NUM_PARTICIPANTS}; c++ ))
do
  export ID="$(printf "%03d" ${c})"
  export NEW_DX_IDENT="participant-${ID}"
  export PEM_FILE="$(readlink -f ~/.config/dfx/identity/${NEW_DX_IDENT}/identity.pem)"
  dfx identity use "${NEW_DX_IDENT}"
  export DX_PRINCIPAL="$(dfx identity get-principal)"
  export JSON="$(dfx canister \
    --network "${NETWORK}" \
    call "${SNS_GOVERNANCE_CANISTER_ID}" \
    list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 0})" \
      | idl2json \
      | jq -r ".neurons")"
  for((i=0; i<"$(echo $JSON | jq length)"; i++))
  do
    export NEURON_ID="$(echo $JSON | jq -r ".[${i}].id[0].id" | python3 -c "import sys; ints=sys.stdin.readlines(); sys.stdout.write(bytearray(eval(''.join(ints))).hex())")"
    quill sns --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" register-vote --proposal-id ${PROPOSAL} --vote ${VOTE} ${NEURON_ID} > msg.json
    quill send --insecure-local-dev-mode --yes msg.json
  done
done

dfx identity use "${DX_IDENT}"
