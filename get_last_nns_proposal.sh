#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

dfx canister --network "${NETWORK}" call nns-governance list_proposals '(record {include_reward_status = vec {}; before_proposal = null; limit = 1; exclude_topic = vec {}; include_status = vec {};})'
