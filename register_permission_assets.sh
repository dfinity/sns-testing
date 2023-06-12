#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

export DEVELOPER_NEURON_ID="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 1})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs didc encode | tail -c +21)"

export CID="$(dfx canister --network "${NETWORK}" id assets)"

quill sns  \
   --canister-ids-file ./sns_canister_ids.json  \
   --pem-file "${PEM_FILE}"  \
   make-proposal --proposal "(record { title=\"Register grant permission to asset canister.\"; url=\"https://example.com/\"; summary=\"This proposals registers grant permission to asset canister.\"; action=opt variant {AddGenericNervousSystemFunction = record {id=1000:nat64; name=\"grant_permission\"; description=\"grant permission to asset canister\"; function_type=opt variant {GenericNervousSystemFunction=record{validator_canister_id=opt principal\"$CID\"; target_canister_id=opt principal\"$CID\"; validator_method_name=opt\"validate_grant_permission\"; target_method_name=opt\"grant_permission\"}}}}})" $DEVELOPER_NEURON_ID > msg.json
quill --insecure-local-dev-mode send --yes msg.json

quill sns  \
   --canister-ids-file ./sns_canister_ids.json  \
   --pem-file "${PEM_FILE}"  \
   make-proposal --proposal "(record { title=\"Register revoke permission to asset canister.\"; url=\"https://example.com/\"; summary=\"This proposals registers revoke permission to asset canister.\"; action=opt variant {AddGenericNervousSystemFunction = record {id=1001:nat64; name=\"revoke_permission\"; description=\"revoke permission to asset canister\"; function_type=opt variant {GenericNervousSystemFunction=record{validator_canister_id=opt principal\"$CID\"; target_canister_id=opt principal\"$CID\"; validator_method_name=opt\"validate_revoke_permission\"; target_method_name=opt\"revoke_permission\"}}}}})" $DEVELOPER_NEURON_ID > msg.json
quill --insecure-local-dev-mode send --yes msg.json
