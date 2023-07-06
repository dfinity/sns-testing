#!/usr/bin/env bash
#
# This takes an optional path to a configuration file; defaults to
# sns_init.yaml, in the same directory as this script. This file would be passed
# to propose_sns.sh or `sns propose`. Such a file can be constructed by
# following the directions at the top of example_sns_init.yaml.
#
# The only thing in the configuration file that gets used is the dapp_canisters
# field.
#
# The principals listed there get passed to `sns prepare-canisters add-nns-root`.
#
# TODO(NNS1-2293): This will stop working once that gets implemented and people
# start using it, because this just uses yq to read the configuration file, and
# yq does not do unaliasing, of course.

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export SNS_CONFIGURATION_FILE_PATH="${1:-sns_init.yaml}"

. ./constants.sh normal

export CURRENT_DX_IDENT="$(dfx identity whoami)"

dfx identity use "${DX_IDENT}"

eval "$(
  yq --output-format json $SNS_CONFIGURATION_FILE_PATH | \
    jq -r '
      .dapp_canisters |
      ["sns", "prepare-canisters", "add-nns-root"] + . |
      @sh'
)"

# Switch back to the previous identity
dfx identity use "$CURRENT_DX_IDENT"
