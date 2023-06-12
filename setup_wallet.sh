#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

DX_IDENT="${1:-dev-ident-1}"

dfx identity use $DX_IDENT || { echo "Couldn't load dev identity to create the dev wallet. Exiting..."; exit 1; }
export WALLET="$(dfx --provisional-create-canister-effective-canister-id jrlun-jiaaa-aaaab-aaaaa-cai identity --network "${NETWORK}" get-wallet)"
