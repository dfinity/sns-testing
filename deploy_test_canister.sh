#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

export NAME="test"
export WASM_FILE_NAME="${NAME}.wasm"
export WASM_LOCATION=".dfx/${DX_NETWORK}/canisters/${NAME}"
export WASM="${WASM_LOCATION}/test.wasm"
mkdir -p "${WASM_LOCATION}"
curl --fail -L "https://github.com/dfinity/sns-testing/releases/download/test-wasm-rc-1/${WASM_FILE_NAME}" -o "${WASM}"

# TODO: Set WASM="" in case the caller of this script opts for re-compiling the test canister.

if [ -f "./sns_canister_ids.json" ]
then
    ./deploy_dapp.sh "test" "${WASM}" "(opt record {sns_governance = opt principal\"${SNS_GOVERNANCE_CANISTER_ID}\"; greeting = null;})"
else
    ./deploy_dapp.sh "test" "${WASM}" "(opt record {sns_governance = null; greeting = null;})"
fi
