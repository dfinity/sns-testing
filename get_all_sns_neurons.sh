#!/bin/bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = null; limit = 0})"
