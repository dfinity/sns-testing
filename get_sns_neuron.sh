#!/bin/bash
# run this script locally

set -euo pipefail

ID="${1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_governance get_neuron "(record {neuron_id = opt record {id = blob \"${ID}\"};})"
