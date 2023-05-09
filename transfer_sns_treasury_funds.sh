#!/bin/bash
# run this script locally

set -euo pipefail

export AMOUNT_E8s="${1:-1000000000}" # 1 Token
export TO_PRINCIPAL="${2:-$DFX_PRINCIPAL}"

. ./constants.sh normal

export DEVELOPER_NEURON_ID="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DFX_PRINCIPAL}\"; limit = 1})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs didc encode | tail -c +21)"

quill sns  \
   --canister-ids-file ./sns_canister_ids.json  \
   --pem-file "${PEM_FILE}"  \
   make-proposal --proposal "(record { title=\"Execute TransferSnsTreasuryFunds proposal.\"; url=\"https://example.com/\"; summary=\"This proposal transfers funds from the sns treasury.\"; action=opt variant {TransferSnsTreasuryFunds = record {from_treasury=1:int32; amount_e8s=${AMOUNT_E8s}:nat64; to_principal=opt principal \"${TO_PRINCIPAL}\";memo=null; to_subaccount=null;}}})" "${DEVELOPER_NEURON_ID}" > msg.json
quill --insecure-local-dev-mode send --yes msg.json