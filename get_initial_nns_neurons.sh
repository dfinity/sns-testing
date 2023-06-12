#!/usr/bin/env bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

export NEURON_IDS=$(tail -n +2 initial_neurons.csv | grep -o "^[0-9]*" | sed "s/\(.*\)/\1: nat64;/")

dfx canister --network "${NETWORK}" call nns-governance list_neurons "(record {neuron_ids = vec {${NEURON_IDS}}; include_neurons_readable_by_caller=true;})"
