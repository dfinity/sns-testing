#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh install

if [ $# -eq 0 ]
then
    echo "No arguments supplied. Please pass a neuron csv with the following format:"
    echo ""
    echo "staked_icpt,maturity_e8s_equivalent"
    echo "100,100"
    echo "40,130"
    echo "etc."
    exit 1
else
    NEURON_CSV=$1
    echo "Using neuron csv ${NEURON_CSV}"
fi

ORIGINAL_DX_IDENT="$(${DFX} identity whoami)"

OUTPUT_FILE="${REPO_ROOT}/initial_neurons.csv"

# defaults
CREATED_TS_NS=0
DURATION_TO_DISSOLUTION_NS=$((15780000*1000000000))
EARNINGS="C"
FOLLOWS=""
NOT_FOR_PROFIT=false
MEMO=0
KYC_VERIFIED=false


readarray -t LINES < "${NEURON_CSV}"

IDENTITY_PREFIX="nns-nf-neuron-"
generate_identity_for_index () {
    local IDENTITY_INDEX=$1
    local IDENTITY_NAME="${IDENTITY_PREFIX}${IDENTITY_INDEX}"
    ${DFX} identity new --storage-mode=plaintext "${IDENTITY_NAME}" 2>/dev/null || true
    ${DFX} identity use "${IDENTITY_NAME}" 2> /dev/null
    local PRINCIPAL="$(${DFX} identity get-principal)"
    echo "${PRINCIPAL}"
}

# Use a loop to iterate over LINES, skipping the first line, and print each line 
# to stdout.
for (( i=1; i < ${#LINES[@]}; i++ )); do
    LINE="${LINES[${i}]}"
    # Line structure: $STAKED_ICPE8S,$MATURITY_E8S_EQUIVALENT
    STAKED_ICPE8S=$(echo "${LINE}" | cut -d',' -f1)
    MATURITY_E8S_EQUIVALENT=$(echo "${LINE}" | cut -d',' -f2)
    PRINCIPAL="$(generate_identity_for_index "${i}")"

    echo "${i};${PRINCIPAL};${CREATED_TS_NS};${DURATION_TO_DISSOLUTION_NS};${STAKED_ICPE8S};${EARNINGS};${FOLLOWS};${NOT_FOR_PROFIT};${MEMO};${MATURITY_E8S_EQUIVALENT};${KYC_VERIFIED}" >> "${OUTPUT_FILE}"
done

# Restore the original identity
${DFX} identity use "${ORIGINAL_DX_IDENT}" 2> /dev/null
