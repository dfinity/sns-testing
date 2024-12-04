#!/usr/bin/env bash

set -xeuo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export NUM_PARTICIPANTS="${1:-100}"
export ICP_PER_PARTICIPANT="${2:-10000}"
ICP_PER_PARTICIPANT_E8S=$(echo "100000000 * $ICP_PER_PARTICIPANT" | bc)

. ./constants.sh normal

# Reset to the constant's $DX_IDENT before starting the swap
dfx identity use "$DX_IDENT"
export CURRENT_DX_IDENT=$(dfx identity whoami)

for (( c=0; c<${NUM_PARTICIPANTS}; c++ ))
do
  export ID="$(printf "%03d" ${c})"
  export NEW_DX_IDENT="participant-${ID}"
  dfx identity new --storage-mode=plaintext "${NEW_DX_IDENT}" 2>/dev/null || true
  dfx identity use "${NEW_DX_IDENT}"
  export ACCOUNT_ID="$(dfx ledger --network ${NETWORK} account-id)"
  dfx identity import --force --storage-mode=plaintext icp-ident-RqOPnjj5ERjAEnwlvfKw "$REPO_ROOT/test-identities/icp-ident.pem" 2> /dev/null
  dfx identity use icp-ident-RqOPnjj5ERjAEnwlvfKw
  dfx ledger transfer --network "${NETWORK}" --memo 0 --icp "$((2 * ${ICP_PER_PARTICIPANT}))" "${ACCOUNT_ID}" || exit 1;
  dfx identity use "${NEW_DX_IDENT}"
  while [ "$(dfx ledger --network "${NETWORK}" balance)" == "0.00000000 ICP" ]
  do
    sleep 1
  done
  export PEM_FILE="$(readlink -f ~/.config/dfx/identity/${NEW_DX_IDENT}/identity.pem)"

  # Get the ticket
  ./bin/quill sns new-sale-ticket --amount-icp-e8s "${ICP_PER_PARTICIPANT_E8S}" --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" > msg.json
  RESPONSE="$(./bin/quill --insecure-local-dev-mode send --yes msg.json)"
  if [[ "${RESPONSE}" == *"invalid_user_amount"* ]]
  then
    echo "ERROR: invalid_user_amount error; see full output from quill below this line"
    echo "${RESPONSE}"
    exit 1
  fi

  TICKET_CREATION_TIME="$(echo "${RESPONSE}" | grep "creation_time" | sed "s/.*creation_time = \([0-9_]*\) : nat64;/\1/" | sed "s/_//g")"
  TICKET_ID="$(echo "${RESPONSE}" | grep "ticket_id" | sed "s/.*ticket_id = \([0-9_]*\) : nat64;/\1/" | sed "s/_//g")"
  if [ -z "${TICKET_CREATION_TIME}" ]
  then
    echo "ERROR: ticket could not be created: see full output from quill below this line"
    echo "${RESPONSE}"
    exit 1
  else
    echo "Ticket (${TICKET_ID}) created with creation time  ${TICKET_CREATION_TIME}"
  fi

  # Use the ticket
  ./bin/quill sns pay --amount-icp-e8s "${ICP_PER_PARTICIPANT_E8S}" --ticket-creation-time "${TICKET_CREATION_TIME}" --ticket-id "${TICKET_ID}" --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" > msg.json
  ./bin/quill --insecure-local-dev-mode send --yes msg.json

done

dfx identity use "${DX_IDENT}"
