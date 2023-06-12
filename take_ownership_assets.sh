#!/usr/bin/env bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

dfx canister --network ${NETWORK} call assets take_ownership '()'
