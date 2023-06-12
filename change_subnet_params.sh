#!/usr/bin/env bash
# run this script locally

set -euo pipefail

. ./constants.sh normal

${IC_ADMIN}  \
  --nns-url "${NETWORK_URL}" propose-to-update-subnet  \
  --test-neuron-proposer  \
  --max-ingress-messages-per-block 400  \
  --subnet "${NNS_SUB}"  \
  --summary "Set max-ingress-messages-per-block to 400 for NNS subnet."

${IC_ADMIN}  \
  --nns-url "${NETWORK_URL}" propose-to-update-subnet  \
  --test-neuron-proposer  \
  --max-ingress-messages-per-block 1000  \
  --subnet "${SNS_SUB}"  \
  --summary "Set max-ingress-messages-per-block to 1000 for SNS subnet."

${IC_ADMIN}  \
  --nns-url "${NETWORK_URL}" propose-to-update-subnet  \
  --test-neuron-proposer  \
  --max-ingress-messages-per-block 1000  \
  --subnet "${APP_SUB}"  \
  --summary "Set max-ingress-messages-per-block to 1000 for APP subnet."
