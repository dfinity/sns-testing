#!/usr/bin/env bash
#
# This takes an optional path to a configuration file; defaults to
# sns_init.yaml, in the same directory as this script. This argument gets passed
# to `sns propose`. Such a file can be constructed by following the directions
# at the top of example_sns_init.yaml.
#
# This is mostly copied from deploy_sns.sh.
#
# Besides replacing `sns deploy` with `sns propose`, the biggest differences
# here are
#
#     1. No more `ic-admin ... propose-to-update-sns-deploy-whitelist`.
#
#     2. This does not take a CONFIG argument.

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export SNS_CONFIGURATION_FILE_PATH="${1:-sns_init.yaml}"

. ./constants.sh normal

export CURRENT_DX_IDENT="$(dfx identity whoami)"

dfx identity use "${DX_IDENT}"

. ./setup_wallet.sh "${DX_IDENT}"

# Conjur some cycles.
dfx ledger \
    --network "${NETWORK}" \
    fabricate-cycles \
    --canister "${WALLET}" \
    --t 2345

# Give 200e12 cycles to sns-wasm.
dfx canister \
    --network "${NETWORK}" \
    deposit-cycles 200000000000000 \
    qaa6y-5yaaa-aaaaa-aaafa-cai # SNS-W canister

${DFX} nns import --network-mapping "${DX_NETWORK}=mainnet"
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

# This fails if the user does not follow the instructions at the top of
# ./example_sns_init.yaml.
sns propose \
    --network "${NETWORK}" \
    --test-neuron-proposer \
    "${SNS_CONFIGURATION_FILE_PATH}"

# Save SNS canister IDs to sns_canister_ids.json
dfx canister --network local \
    call nns-sns-wasm list_deployed_snses '(record {})' \
    | idl2json \
    > sns-wasm-list_deployed_snses-response.json
NUM_SNS_INSTANCES=$(jq '.instances | length' sns-wasm-list_deployed_snses-response.json)
if [[ $NUM_SNS_INSTANCES -gt 1 ]]
then
    # TODO: pick the right SNS if case there are multiple ones present
    echo "Error: sns-testing currently does not support multiple SNSes (found $NUM_SNS_INSTANCES)"
    exit 1
fi

# Need to flatten the JSON to make it compatible with quill
jq '.instances[-1] | .[] |= .[0]' \
    sns-wasm-list_deployed_snses-response.json \
        > sns_canister_ids.json

# Switch back to the previous identity
dfx identity use "$CURRENT_DX_IDENT"
