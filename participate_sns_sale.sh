#!/bin/bash
# run this script locally

export NUM_PARTICIPANTS="${1:-3}"
export ICP_PER_PARTICIPANT="${2:-200}"
ICP_PER_PARTICIPANT_E8S=$(echo "100000000 * $ICP_PER_PARTICIPANT" | bc)

. ./constants.sh normal

# Reset to the constant's $DFX_IDENTITY before starting the sale
dfx identity use "$DFX_IDENTITY"
export CURRENT_DFX_IDENT=$(dfx identity whoami)

for (( c=0; c<${NUM_PARTICIPANTS}; c++ ))
do
  export ID="$(printf "%03d" ${c})"
  export NEW_DFX_IDENTITY="participant-${ID}"
  dfx identity new --storage-mode=plaintext "${NEW_DFX_IDENTITY}" || true
  dfx identity use "${NEW_DFX_IDENTITY}"
  export ACCOUNT_ID="$(dfx ledger --network ${NETWORK} account-id)"
  dfx identity use "${CURRENT_DFX_IDENT}"
  dfx ledger transfer --network "${NETWORK}" --memo 0 --icp "$((2 * ${ICP_PER_PARTICIPANT}))" "${ACCOUNT_ID}" || exit 1;
  dfx identity use "${NEW_DFX_IDENTITY}"
  while [ "$(dfx ledger --network "${NETWORK}" balance)" == "0.00000000 ICP" ]
  do
    sleep 1
  done
  export PEM_FILE="$(readlink -f ~/.config/dfx/identity/${NEW_DFX_IDENTITY}/identity.pem)"

  # Get the ticket
  quill sns new-sale-ticket --amount-icp-e8s "${ICP_PER_PARTICIPANT_E8S}" --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" > msg.json
  RESPONSE="$(quill --insecure-local-dev-mode send --yes msg.json)"

  TICKET_CREATION_TIME="$(echo "${RESPONSE}" | grep "creation_time" | sed "s/.*creation_time = \([0-9_]*\) : nat64;/\1/" | sed "s/_//g")"
  TICKET_ID="$(echo "${RESPONSE}" | grep "ticket_id" | sed "s/.*ticket_id = \([0-9_]*\) : nat64;/\1/" | sed "s/_//g")"
  if [ -z "${TICKET_CREATION_TIME}" ]
  then
    echo "ticket could not be created: ${RESPONSE}"
    exit 1
  else
    echo "Ticket ($TICKET_ID) created with creation time  $TICKET_CREATION_TIME"
  fi

  # Use the ticket
  quill sns pay --amount-icp-e8s "${ICP_PER_PARTICIPANT_E8S}" --ticket-creation-time "${TICKET_CREATION_TIME}" --ticket-id "${TICKET_ID}" --canister-ids-file ./sns_canister_ids.json --pem-file "${PEM_FILE}" > msg.json
  quill --insecure-local-dev-mode send --yes msg.json

done

dfx identity use "${DFX_IDENTITY}"
