#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

export CURRENT_DX_IDENT=$("${DFX}" identity whoami)
"${DFX}" identity use default

for NF_NEURON_IDENTITY in "${HOME}/.config/dfx/identity/"nns-nf-neuron*; do
  "${DFX}" identity remove "${NF_NEURON_IDENTITY}"
done

# Switch back to the previous identity
"${DFX}" identity use "${CURRENT_DX_IDENT}"
