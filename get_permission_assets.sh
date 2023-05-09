#!/bin/bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

echo "Prepare"
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {Prepare}})'
echo "Commit"
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {Commit}})'
echo "ManagePermissions"
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {ManagePermissions}})'
