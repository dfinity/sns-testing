#!/bin/bash
# run this script locally

set -euo pipefail

export OWNER_IDENTITY="${1:-dev-ident-1}"
export HOTKEY_IDENTITY="${2:-dev-ident-2}"

. ./constants.sh normal

export CURRENT_DX_IDENT=$(dfx identity whoami)

dfx identity use "${OWNER_IDENTITY}"
OWNER_PRINCIPAL=$(dfx identity get-principal)

dfx identity use "${HOTKEY_IDENTITY}"
HOTKEY_PRINCIPAL=$(dfx identity get-principal)

export DEVELOPER_NEURON_ID="$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${OWNER_PRINCIPAL}\"; limit = 1})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs didc encode | tail -c +21)"

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
