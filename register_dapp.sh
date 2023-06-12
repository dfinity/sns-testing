#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export CID=${1:-jrlun-jiaaa-aaaab-aaaaa-cai}

. ./constants.sh normal

export SNS_ROOT_ID="$(dfx canister id sns_root --network ${NETWORK})"
dfx canister --network "${NETWORK}" update-settings --add-controller "${SNS_ROOT_ID}" "${CID}"

export DEVELOPER_NEURON_ID="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DX_PRINCIPAL}\"; limit = 1})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs didc encode | tail -c +21)"

quill sns   \
   --canister-ids-file ./sns_canister_ids.json  \
   --pem-file "${PEM_FILE}"  \
   make-proposal --proposal "(record { title=\"Register test dapp\"; url=\"https://example.com/\"; summary=\"This proposal registers test dapp with SNS\"; action=opt variant {RegisterDappCanisters = record {canister_ids=vec {principal\"$CID\"}}}})"   \
   "${DEVELOPER_NEURON_ID}" > msg.json
quill --insecure-local-dev-mode send --yes msg.json
