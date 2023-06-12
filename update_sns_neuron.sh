#!/usr/bin/env bash
# run this script locally

set -euo pipefail

ARG="${1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_governance update_neuron "(${ARG})"
