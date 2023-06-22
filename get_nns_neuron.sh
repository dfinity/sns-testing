#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

ID="${1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call nns-governance get_full_neuron "(${ID})"
