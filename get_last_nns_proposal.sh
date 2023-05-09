#!/bin/bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

dfx canister --network "${NETWORK}" call nns-governance list_proposals '(record {include_reward_status = vec {}; before_proposal = null; limit = 1; exclude_topic = vec {}; include_status = vec {};})'
