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
export II_RELEASE="release-2023-04-28"

# you can find NNS proposals upgrading system canisters here:
# https://dashboard.internetcomputer.org/governance?topic=TOPIC_NETWORK_CANISTER_MANAGEMENT
# NNS proposals to upgrade NNS frontend dapp are called "Upgrade Nns Canister: qoctq-giaaa-aaaaa-aaaea-cai"
export NNS_DAPP_RELEASE="proposal-123301"

# only edit IC_COMMIT to a commit to master with disk image obtained via:
# $ ./gitlab-ci/src/artifacts/newest_sha_with_disk_image.sh origin/master
# from the IC monorepo: https://github.com/dfinity/ic
# if you change IC_COMMIT, then you need to rerun `source install.sh`
export IC_COMMIT="91cef7a53a5064fe3d41a5f2a0e87b65123af4b0"

export TESTNET="local"
