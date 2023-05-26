#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

ARG="${1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_governance update_neuron "(${ARG})"
