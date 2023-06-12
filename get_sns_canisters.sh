#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_root list_sns_canisters '(record {})'
