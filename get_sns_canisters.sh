#!/bin/bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_root list_sns_canisters '(record {})'
