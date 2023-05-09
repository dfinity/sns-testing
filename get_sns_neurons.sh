#!/bin/bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"$(dfx identity get-principal)\"; limit = 0})"
