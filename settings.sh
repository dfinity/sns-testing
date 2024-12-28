#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# put your dfx identity here
export DX_IDENT="default"

# if you don't export CANISTER_TEST or set its value to "_test",
# then the test flag is set for NNS and SNS governance canisters;
# if you export CANISTER_TEST to be the empty string "",
# then the test flag is not set.
# export CANISTER_TEST=""

# you can find available II releases here:
# https://github.com/dfinity/internet-identity/tags
export II_RELEASE="release-2023-10-30"

# you can find NNS proposals upgrading system canisters here:
# https://dashboard.internetcomputer.org/governance?topic=TOPIC_NETWORK_CANISTER_MANAGEMENT
# NNS proposals to upgrade NNS frontend dapp are called "Upgrade Nns Canister: qoctq-giaaa-aaaaa-aaaea-cai"
export NNS_DAPP_RELEASE="nightly-2023-10-30"

# you can find NNS proposals upgrading system canisters here:
# https://dashboard.internetcomputer.org/governance?topic=TOPIC_NETWORK_CANISTER_MANAGEMENT
# NNS proposals to upgrade NNS frontend dapp are called "Upgrade Nns Canister: 3r4gx-wqaaa-aaaaq-aaaia-cai"
export SNS_AGGREGATOR_RELEASE="proposal-129614-agg"

# only edit IC_COMMIT to a commit to master with disk image obtained via:
# $ ./gitlab-ci/src/artifacts/newest_sha_with_disk_image.sh origin/master
# from the IC monorepo: https://github.com/dfinity/ic
# if you change IC_COMMIT, then you need to rerun `source install.sh`
export IC_COMMIT="25c1bb0227d9970f5673b908817d7c4962b29911"

export TESTNET="local"

export DFX_VERSION="0.24.3"
export DFX_SNS_VERSION="0.4.1"
export DFX_NNS_VERSION="0.4.1"

export QUILL_VERSION="0.5.2"
export IC_WASM_VERSION="0.9.1"
