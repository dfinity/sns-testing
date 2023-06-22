#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export NAME="${1:-test}"

. ./constants.sh normal

dfx canister --network $NETWORK status "${NAME}"
