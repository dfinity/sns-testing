#!/bin/bash
# run this script locally

set -euo pipefail

ARG="${1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call nns-governance update_neuron "(${ARG})"
