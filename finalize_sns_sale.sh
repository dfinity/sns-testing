#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_swap finalize_swap '(record {})'
