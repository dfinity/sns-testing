#!/usr/bin/env bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

export SNS_SWAP_ID="$(dfx canister --network "${NETWORK}" id sns_swap)"

export DEADLINE=$(($(date +%s) + 86400 + 86400))
ic-admin   \
   --nns-url "${NETWORK_URL}" propose-to-open-sns-token-swap  \
   --test-neuron-proposer  \
   --min-participants 4  \
   --min-icp-e8s 1200000000  \
   --max-icp-e8s 3000000000  \
   --min-participant-icp-e8s 400000000  \
   --max-participant-icp-e8s 1000000000  \
   --swap-due-timestamp-seconds "${DEADLINE}"  \
   --sns-token-e8s 3000000000  \
   --target-swap-canister-id "${SNS_SWAP_ID}"  \
   --community-fund-investment-e8s 200000000  \
   --neuron-basket-count 3  \
   --neuron-basket-dissolve-delay-interval-seconds 31536000  \
   --proposal-title "Decentralize this SNS"  \
   --summary "Decentralize this SNS"
