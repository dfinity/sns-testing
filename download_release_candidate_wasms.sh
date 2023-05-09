#!/bin/bash

set -euo pipefail

. ./constants.sh normal

CANDIDATE=$1
. $CANDIDATE

PWD=$(pwd)

# TODO master functions.sh has unbound variable
export SNS_WASM_CANISTER_FILENAME="$PWD/sns-wasm-canister.wasm.gz"
TMP=$(execute_nns_tools_func _download_canister_gz sns-wasm-canister "$RC_SNS_WASM_GIT_HASH")
mv "$TMP" "$SNS_WASM_CANISTER_FILENAME"

# TODO master functions.sh has unbound variable
export NNS_GOVERNANCE_CANISTER_FILENAME="$PWD/governance-canister.wasm.gz" # No sns- prefix indicates nns
TMP=$(execute_nns_tools_func _download_canister_gz governance-canister "$RC_NNS_GOVERNANCE_GIT_HASH")
mv "$TMP" "$NNS_GOVERNANCE_CANISTER_FILENAME"

export SNS_GOVERNANCE_CANISTER_FILENAME="$PWD/sns-governance-canister.wasm.gz"
TMP=$(execute_nns_tools_func get_sns_canister_wasm_gz_for_type governance "$RC_SNS_GOVERNANCE_GIT_HASH")
mv "$TMP" "$SNS_GOVERNANCE_CANISTER_FILENAME"

export SNS_ROOT_CANISTER_FILENAME="$PWD/sns-root-canister.wasm.gz"
TMP=$(execute_nns_tools_func get_sns_canister_wasm_gz_for_type root "$RC_SNS_ROOT_GIT_HASH")
mv "$TMP" "$SNS_ROOT_CANISTER_FILENAME"

export SNS_SWAP_CANISTER_FILENAME="$PWD/sns-swap-canister.wasm.gz"
TMP=$(execute_nns_tools_func get_sns_canister_wasm_gz_for_type swap "$RC_SNS_SALE_GIT_HASH")
mv "$TMP" "$SNS_SWAP_CANISTER_FILENAME"

ICRC1_LEDGER_FILENAME="$PWD/ic-icrc1-ledger.wasm.gz"
TMP=$(execute_nns_tools_func get_sns_canister_wasm_gz_for_type ledger "$RC_ICRC1_LEDGER_GIT_HASH")
mv "$TMP" "$ICRC1_LEDGER_FILENAME"

ICRC1_ARCHIVE_FILENAME="$PWD/ic-icrc1-archive.wasm.gz"
TMP=$(execute_nns_tools_func get_sns_canister_wasm_gz_for_type archive "$RC_ICRC1_ARCHIVE_GIT_HASH")
mv "$TMP" "$ICRC1_ARCHIVE_FILENAME"

ICRC1_INDEX_FILENAME="$PWD/ic-icrc1-index.wasm.gz"
TMP=$(execute_nns_tools_func get_sns_canister_wasm_gz_for_type index "$RC_ICRC1_INDEX_GIT_HASH")
mv "$TMP" "$ICRC1_INDEX_FILENAME"
