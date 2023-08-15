#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

ARG="${1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call "${SNS_GOVERNANCE_CANISTER_ID}" update_neuron "(${ARG})"
