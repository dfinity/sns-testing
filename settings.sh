#!/bin/bash

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
export NNS_DAPP_RELEASE="proposal-122282"

# only edit IC_COMMIT to a commit to master with disk image obtained via:
# $ ./gitlab-ci/src/artifacts/newest_sha_with_disk_image.sh origin/master
# from the IC monorepo: https://github.com/dfinity/ic
# if you change IC_COMMIT, then you need to rerun `source install.sh`
export IC_COMMIT="f0256969bfea4d721060776790ebc87337a82d29"

# the asset canister version is specified by a DFX commit
# you can take an arbitrary DFX commit to master:
# https://github.com/dfinity/sdk/commits/master
export DX_COMMIT="266c913f71344f6fa3320287965120e56288c86c"

export TESTNET="local"
