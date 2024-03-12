#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

export XDR_PERMYRIAD_PER_ICP="${1:-106292}"

echo "Setting ICP/XDR conversion rate to ${XDR_PERMYRIAD_PER_ICP} ..."

ic-admin \
    --nns-url "${NETWORK_URL}" \
    propose-xdr-icp-conversion-rate \
    --xdr-permyriad-per-icp "${XDR_PERMYRIAD_PER_ICP}" \
    --test-neuron-proposer \
    --summary "Set ICP/XDR conversion rate to ${XDR_PERMYRIAD_PER_ICP}"
