#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh install

DFX=./bin/dfx

if [ $# -eq 0 ]
then
    echo "No arguments supplied. Please pass a neuron csv with the following format:"
    echo ""
    echo "neuron_id;owner_id;created_ts_ns;duration_to_dissolution_ns;staked_icpt;earnings;follows;not_for_profit;memo;maturity_e8s_equivalent;kyc_verified"
    echo "1;xz7xb-e726u-vsihc-fukxg-pfzzd-3cjix-gluc6-p4shw-sz4aw-ufgi3-yqe;0;15780000000000000;0;C;;false;0;0;false"
    echo "etc."
    exit 1
else
    NEURON_CSV=$1
    echo "Using neuron csv ${NEURON_CSV}"
fi

ORIGINAL_DX_IDENT="$(${DFX} identity whoami)"

readarray -t LINES < "${NEURON_CSV}"

IDENTITY_PREFIX="nns-nf-neuron-"
generate_identity_for_index () {
    local IDENTITY_INDEX=$1
    local IDENTITY_NAME="${IDENTITY_PREFIX}${IDENTITY_INDEX}"
    ${DFX} identity new --storage-mode=plaintext "${IDENTITY_NAME}" 2>/dev/null || true
    ${DFX} identity use "${IDENTITY_NAME}"
    local PRINCIPAL="$(${DFX} identity get-principal)"
    echo "${PRINCIPAL}"
}

# Use a loop to iterate over LINES, skipping the first line, and print each line 
# to stdout.
for (( i=1; i < ${#LINES[@]}; i++ ))
do
    LINE="${LINES[${i}]}"
    # Line structure: neuron_id(1);owner_id(2);created_ts_ns(3);duration_to_dissolution_ns(4);staked_icpt(5);earnings(6);follows(7);not_for_profit(8);memo(9);maturity_e8s_equivalent(10);kyc_verified(11)
    neuron_id=$(echo "${LINE}" | cut -d';' -f1)
    maturity_e8s_equivalent=$(echo "${LINE}" | cut -d';' -f10)
    # Assume Neurons' Fund neurons have their IDs in the 3000s range.
    if (( neuron_id >= 3000 && neuron_id <= 3999 ))
    then
        PRINCIPAL="$(generate_identity_for_index "${neuron_id}")"
        echo "Ensured the existence of Neurons' Fund neuron ID ${neuron_id} with identity principal = ${PRINCIPAL}"
    fi;
done

# Restore the original identity
${DFX} identity use "${ORIGINAL_DX_IDENT}" 2> /dev/null
