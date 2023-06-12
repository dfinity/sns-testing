#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

ARG="${1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call nns-governance update_neuron "(${ARG})"
