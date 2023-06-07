#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal

echo "$(dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"${DFX_PRINCIPAL}\"; limit = 1})" | grep "^ *id = blob" | sed "s/^ *id = \(.*\);$/'(\1)'/" | xargs didc encode | tail -c +21)"
