#!/bin/env bash
# run this script locally

export NUM_PARTICIPANTS="${1:-3}"
export ICP_PER_PARTICIPANT="${2:-200}"

. ./constants.sh normal

for (( c=0; c<${NUM_PARTICIPANTS}; c++ ))
do
  export ID="$(printf "%03d" ${c})"
  export NEW_DX_IDENT="participant-${ID}"
  dfx identity new --storage-mode=plaintext "${NEW_DX_IDENT}" || true
  dfx identity use "${NEW_DX_IDENT}"
  export ACCOUNT_ID="$(dfx ledger --network ${NETWORK} account-id)"
  dfx identity use "${DX_IDENT}"
  dfx ledger transfer --network "${NETWORK}" --memo 0 --icp "$((2 * ${ICP_PER_PARTICIPANT}))" "${ACCOUNT_ID}" || exit 1;
  dfx identity use "${NEW_DX_IDENT}"
  while [ "$(dfx ledger --network "${NETWORK}" balance)" == "0.00000000 ICP" ]
  do
    sleep 1
  done
  export PEM_FILE="$(readlink -f ~/.config/dfx/identity/${NEW_DX_IDENT}/identity.pem)"

  sns-quill --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" swap --memo 0 --amount ${ICP_PER_PARTICIPANT} > msg.json
  sns-quill send --yes msg.json
done

dfx identity use "${DX_IDENT}"
