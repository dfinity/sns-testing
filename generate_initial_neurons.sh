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

ORIGINAL_DX_IDENT="$(dfx identity whoami)"

OUTPUT_FILE="${REPO_ROOT}/initial_neurons.csv"
# clear the file
echo "neuron_id;owner_id;created_ts_ns;duration_to_dissolution_ns;staked_icpt;earnings;follows;not_for_profit;memo;maturity_e8s_equivalent;kyc_verified" > "${OUTPUT_FILE}"


# defaults
CREATED_TS_NS=0
DURATION_TO_DISSOLUTION_NS=$((15780000*1000000000))
EARNINGS="C"
FOLLOWS=""
NOT_FOR_PROFIT=false
MEMO=0
KYC_VERIFIED=false

IDENTITY_PREFIX="nns-cf-neuron-"

readarray -t LINES < "${NEURON_CSV}"

generate_identity_for_index () {
    local IDENTITY_INDEX=$1
    local IDENTITY_NAME="${IDENTITY_PREFIX}${IDENTITY_INDEX}"
    dfx identity new --storage-mode=plaintext "${IDENTITY_NAME}" 2>/dev/null || true
    dfx identity use "${IDENTITY_NAME}" 2> /dev/null
    local PRINCIPAL="$(dfx identity get-principal)"
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

# Append the super proposer neuron
echo "449479075714955186;b2ucp-4x6ou-zvxwi-niymn-pvllt-rdxqr-wi4zj-jat5l-ijt2s-vv4f5-4ae;0;31536000000000000;100;D;;false;0;10000000000;false" >> "${OUTPUT_FILE}"

# Restore the original identity
dfx identity use "${ORIGINAL_DX_IDENT}" 2> /dev/null

echo "Generated initial neurons file at ${OUTPUT_FILE}."
echo "DFX identities have been created for each neuron. View them with dfx identity list. (Neuron 1 is ${IDENTITY_PREFIX}1, etc.)."
