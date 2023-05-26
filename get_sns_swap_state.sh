#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal

dfx canister call --network "${NETWORK}" sns_swap get_state '(record {})'
