#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

ID="${1}"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call nns-governance get_full_neuron "(${ID})"
