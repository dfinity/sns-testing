#!/usr/bin/env bash
# run this script locally

set -euo pipefail

ID="${1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call nns-governance get_full_neuron "(${ID})"
