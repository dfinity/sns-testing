#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

export NAME="${1:-test}"

. ./constants.sh normal

dfx canister --network $NETWORK status "${NAME}"
