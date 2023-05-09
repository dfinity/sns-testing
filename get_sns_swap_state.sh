#!/bin/bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

dfx canister call --network "${NETWORK}" sns_swap get_state '(record {})'
