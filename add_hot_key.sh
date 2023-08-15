#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export OWNER_IDENTITY="${1:-dev-ident-1}"
export HOTKEY_IDENTITY="${2:-dev-ident-2}"

. ./constants.sh normal

export CURRENT_DX_IDENT=$(dfx identity whoami)

dfx identity use "${OWNER_IDENTITY}"
OWNER_PRINCIPAL=$(dfx identity get-principal)

dfx identity use "${HOTKEY_IDENTITY}"
HOTKEY_PRINCIPAL=$(dfx identity get-principal)

export DEVELOPER_NEURON_ID="$(dfx canister \
  --network "${NETWORK}" \
  call "${SNS_GOVERNANCE_CANISTER_ID}" \
  --candid candid/sns_governance.did \
  list_neurons "(record {of_principal = opt principal\"${OWNER_PRINCIPAL}\"; limit = 1})"
    | idl2json
    | jq -r ".neurons[0].id[0].id"
    | python3 -c "import sys; ints=sys.stdin.readlines(); sys.stdout.write(bytearray(eval(''.join(ints))).hex())")"

PEM_FILE="$(readlink -f "$HOME/.config/dfx/identity/${OWNER_IDENTITY}/identity.pem")"
quill sns \
  --canister-ids-file ./sns_canister_ids.json \
  --pem-file "${PEM_FILE}" \
  neuron-permission \
  --principal "${HOTKEY_PRINCIPAL}" \
  --permissions vote,submit-proposal,manage-voting-permission \
  add \
  "${DEVELOPER_NEURON_ID}" \
  > msg.json
quill --insecure-local-dev-mode send --yes msg.json


dfx identity use "${CURRENT_DX_IDENT}"
