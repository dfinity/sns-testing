#!/bin/bash
# run this script locally

set -euo pipefail

export NAME="${1:-test}"

. ./constants.sh normal

dfx canister --network $NETWORK status "${NAME}"
