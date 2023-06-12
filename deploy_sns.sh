#!/usr/bin/env bash
# run this script locally

set -euo pipefail

export CONFIG="${1:-sns-test.yml}"

. ./constants.sh normal

export CURRENT_DX_IDENT="$(dfx identity whoami)"

dfx identity use "${DX_IDENT}"

. ./setup_wallet.sh

dfx ledger --network "${NETWORK}" fabricate-cycles --canister "${WALLET}" --t 2345

ic-admin  \
   --nns-url "${NETWORK_URL}" propose-to-update-sns-deploy-whitelist  \
   --test-neuron-proposer  \
   --added-principals "${WALLET}"  \
   --proposal-title "Let me SNS!"  \
   --summary "This proposal whitelists developer's principal to deploy SNS"

${DFX} nns import --network-mapping "${DFX_NETWORK}=mainnet"
${DFX} sns import
if [ "${CANISTER_TEST}" == "_test" ]
then
  curl -L "https://raw.githubusercontent.com/dfinity/ic/${IC_COMMIT}/rs/nns/governance/canister/governance_test.did" -o ./candid/nns-governance.did
  curl -L "https://raw.githubusercontent.com/dfinity/ic/${IC_COMMIT}/rs/sns/governance/canister/governance_test.did" -o ./candid/sns_governance.did
fi
curl -L "https://github.com/dfinity/nns-dapp/blob/${IC_COMMIT}/sns_aggregator/sns_aggregator.did" -o ./candid/sns_aggregator.did
cat <<< $(jq -r 'del(.canisters."internet_identity".remote)' dfx.json) > dfx.json
cat <<< $(jq -r 'del(.canisters."nns-dapp".remote)' dfx.json) > dfx.json
cat <<< $(jq -r 'del(.canisters."sns_aggregator".remote)' dfx.json) > dfx.json

sed "s/aaaaa-aa/${DX_PRINCIPAL}/" "$CONFIG" > "${CONFIG}.tmp"
mv "${CONFIG}.tmp" "${CONFIG}"
sns deploy --network "${NETWORK}" --init-config-file "${CONFIG}" --save-to ".dfx/${DX_NETWORK}/canister_ids.json"

# Switch back to the previous identity
dfx identity use "$CURRENT_DX_IDENT"
