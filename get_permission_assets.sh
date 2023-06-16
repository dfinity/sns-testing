#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

echo "Prepare"
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {Prepare}})'
echo "Commit"
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {Commit}})'
echo "ManagePermissions"
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {ManagePermissions}})'
