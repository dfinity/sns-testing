#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal

echo "Prepare"
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {Prepare}})'
echo "Commit"
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {Commit}})'
echo "ManagePermissions"
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {ManagePermissions}})'
