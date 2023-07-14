#!/usr/bin/env bash
#
# This takes an optional path to a configuration file; defaults to
# sns_init.yaml, in the same directory as this script. This file would be passed
# to propose_sns.sh or `sns propose`. Such a file can be constructed by
# following the directions at the top of example_sns_init.yaml. If no argument
# is passed, and sns_init.yaml doesn't already exist, this assumes that the
# example dapp is being used, and constructs sns_init.yaml automatically (from
# example_sns_init.yaml).
#
# The only thing in the configuration file that this script uses is the
# dapp_canisters field. The principals listed there get passed to `sns
# prepare-canisters add-nns-root`.
#
# TODO(NNS1-2293): This will stop working once that gets implemented and people
# start using it, because this just uses yq to read the configuration file, and
# yq does not do unaliasing, of course. The solution is to implement
# `sns let-nns-control-dapp` or something like that. Then, we no longer need yq
# in Dockerfile.

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export SNS_CONFIGURATION_FILE_PATH="${1:-}"

. ./constants.sh normal

export CURRENT_DX_IDENT="$(dfx identity whoami)"

dfx identity use "${DX_IDENT}"

if [[ -z $SNS_CONFIGURATION_FILE_PATH ]]
then
    SNS_CONFIGURATION_FILE_PATH=sns_init.yaml

    # Write sns_init.yaml, but only if it doesn't exist already (do not clobber).
    if [[ ! -e "$SNS_CONFIGURATION_FILE_PATH" ]]
    then
        PRINCIPAL_ID="$(dfx identity get-principal)"
        CANISTER_ID="$(dfx canister id test)"
        cat example_sns_init.yaml \
            | sed "s/YOUR_PRINCIPAL_ID/${PRINCIPAL_ID}/" \
            | sed "s/YOUR_CANISTER_ID/${CANISTER_ID}/" \
            | sed 's/  # propose_sns[.]sh .*//' \
            > "$SNS_CONFIGURATION_FILE_PATH"
    fi
fi

eval "$(
  yq --output-format json $SNS_CONFIGURATION_FILE_PATH | \
    jq -r '
      .dapp_canisters |
      ["sns", "prepare-canisters", "add-nns-root"] + . |
      @sh'
)"

# Switch back to the previous identity
dfx identity use "$CURRENT_DX_IDENT"
