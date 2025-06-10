#!/bin/bash

echo B1
set -euo pipefail

echo B2
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

echo B3
. ./constants.sh normal

echo B4
for canister in cycles-minting-canister genesis-token-canister governance-canister governance-canister_test ic-ckbtc-minter identity-canister ledger-canister_notify-method lifeline_canister nns-ui-canister registry-canister root-canister sns-wasm-canister sns-root-canister "sns-governance-canister${CANISTER_TEST}" sns-swap-canister ic-icrc1-ledger ic-icrc1-archive ic-icrc1-index-ng
do
    echo B5
  curl -L "https://download.dfinity.systems/ic/${IC_COMMIT}/canisters/${canister}.wasm.gz" -o "${canister}.wasm"
done

echo B6
mv "./ic-icrc1-index-ng.wasm" "ic-icrc1-index.wasm"

echo B7
if [ ! -z "${CANISTER_TEST}" ]
then
    echo B8
  mv "./sns-governance-canister${CANISTER_TEST}.wasm" ./sns-governance-canister.wasm
fi

# TODO: look into installing these extensions locally so we can ensure we get a particular version
echo B9
${DFX} extension install nns --version ${DFX_NNS_VERSION} || true 
echo B10
${DFX} extension install sns --version ${DFX_SNS_VERSION} || true 

echo B11
${DFX} nns import
if [ "${CANISTER_TEST}" == "_test" ]
then
  echo B12
  curl -L "https://raw.githubusercontent.com/dfinity/ic/${IC_COMMIT}/rs/nns/governance/canister/governance_test.did" -o ./candid/nns-governance.did
  echo B13
  curl -L "https://raw.githubusercontent.com/dfinity/ic/${IC_COMMIT}/rs/sns/governance/canister/governance_test.did" -o ./candid/sns_governance.did
fi

# Generate DFX identities for Neurons' Fund neurons
echo B14
./generate_identities_for_neurons_fund_neurons.sh initial_neurons.csv

echo B15
ic-nns-init \
  --initialize-ledger-with-test-accounts-for-principals "${DX_PRINCIPAL}" \
  --initialize-ledger-with-test-accounts 5b315d2f6702cb3a27d826161797d7b2c2e131cd312aece51d4d5574d1247087 \
  --initialize-ledger-with-test-accounts 2b8fbde99de881f695f279d2a892b1137bfe81a42d7694e064b1be58701e1138 \
  --url "${NETWORK_URL}" \
  --initial-neurons initial_neurons.csv \
  --pass-specified-id

# Ensure the Neurons' Fund neurons have joined the fund.
echo B16
./setup_neurons_fund.sh

echo B17
./setup.sh
