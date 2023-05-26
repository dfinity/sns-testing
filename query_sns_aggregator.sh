#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal

cd nns-dapp || exit

RESPONSE="$(dfx canister --network ${NETWORK} call sns_aggregator http_request '(record {url = "/v1/sns/list/latest/slow.json"; method = "GET"; body = vec {}; headers = vec {};})' --candid rs/sns_aggregator/sns_aggregator.did)"
echo "${RESPONSE}" | grep -o "status_code = [0-9]* : nat16"
echo "Looking for SNS governance canister ID in aggregator's response:"
echo "${RESPONSE}" | grep -o "$(jq -r ".governance_canister_id" ../sns_canister_ids.json)" | sed "s/^/found: /"

cd .. || exit
