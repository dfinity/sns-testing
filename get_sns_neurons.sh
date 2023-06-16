#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_governance list_neurons "(record {of_principal = opt principal\"$(dfx identity get-principal)\"; limit = 0})"
