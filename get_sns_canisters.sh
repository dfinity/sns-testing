#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal

dfx canister --network "${NETWORK}" call sns_root list_sns_canisters '(record {})'
