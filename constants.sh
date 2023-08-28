#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# Works even when scripts invoked from outside of repository
repo_root() {
    local SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
    # Execute in subshell to not change directory of caller
    ( cd "$SCRIPT_DIR" && readlink -f . )
}

REPO_ROOT=$(repo_root)

# We always want to use our downloaded versions when available
export PATH="$REPO_ROOT/bin:${PATH}"
export REPO_ROOT

export MODE="${1}"
if [[ -z "${MODE}" ]]; then
    echo "Usage: constants.sh <mode>"
    return 1
fi

SETTINGS_FILE="${REPO_ROOT}/settings.sh"
if [[ -f "$SETTINGS_FILE" ]]; then
    . "$SETTINGS_FILE"
fi

if [[ ! -z "${2:-}" ]]; then
    DX_IDENT="${2}"
fi

if [[ -z "$TESTNET" ]]; then
    echo "TESTNET not specified. Please export the TESTNET env. variable directly"
    echo "or in settings.sh"
    exit 1
fi

if [[ -z "$IC_COMMIT" ]]; then
    echo "IC_COMMIT not specified. Please export the IC_COMMIT env. variable"
    echo "directly or in settings.sh"
    exit 1
fi

case "$(uname -sr)" in
   Darwin*)
     export OS="darwin"
     ;;

   Linux*Microsoft*)
     export OS="linux"
     ;;

   Linux*)
     export OS="linux"
     ;;

   *)
     echo "Unknown OS!"
     exit 1
     ;;
esac

# If DFX is already installed we want to ensure our constants are set correctly
if which dfx >/dev/null; then
  # We need these identities
  dfx identity import --storage-mode=plaintext dev-ident-1 "$REPO_ROOT/test-identities/dev-ident-1.pem" 2> /dev/null || true
  dfx identity import --storage-mode=plaintext dev-ident-2 "$REPO_ROOT/test-identities/dev-ident-2.pem" 2> /dev/null || true
  dfx identity import --storage-mode=plaintext dev-ident-3 "$REPO_ROOT/test-identities/dev-ident-3.pem" 2> /dev/null || true

  # Always change to the configured $DX_IDENT if it's pinned in settings.sh.  Otherwise, fall back to dev-ident-1
  export DX_IDENT=${DX_IDENT:-dev-ident-1}
  dfx identity use "$DX_IDENT"

  export DX_PRINCIPAL="$(dfx identity get-principal)"
  export DX_VERSION="$(dfx --version | sed "s/^dfx //")"
  export PEM_FILE="$(readlink -f ~/.config/dfx/identity/${DX_IDENT}/identity.pem)"
fi

export CANISTER_TEST="${CANISTER_TEST:-_test}"

if [[ -z "${DFX_IC_COMMIT:-}" ]]; then
  export DFX_IC_COMMIT="${IC_COMMIT}"
fi

export NETWORK=$([[ "$TESTNET" == "local" ]] && echo "local" || echo "https://${TESTNET}")
export DX_NETWORK=$([[ "$TESTNET" == "local" ]] && echo "local" || echo "https___${TESTNET//./_}")
export PROTOCOL=$([[ "$TESTNET" == "local" ]] && echo "http" || echo "https")

if [[ "${MODE}" == "install" ]]; then
    return 0
fi

DFX="$(which dfx)"
export DFX
IC_ADMIN="$(which ic-admin)"
export IC_ADMIN

if [[ ! -f "${DFX}" ]]; then
    echo "Couldn't find dfx at ${DFX}. You may need to run install.sh"
    exit 1
fi
if [[ ! -f "${IC_ADMIN}" ]]; then
    echo "Couldn't find ic-admin at ${IC_ADMIN}. You may need to run install.sh"
    exit 1
fi

if [[ "${TESTNET}" == "local" ]]; then
  # set IC endpoint
  export NETWORK_URL="${PROTOCOL}://localhost:$(${DFX} info replica-port)"
  export HOST_ENDPOINT="localhost:$(${DFX} info webserver-port)"
  # obtain local subnet from local registry
  export REGISTRY_PATH=""
  REGISTRY=".dfx/network/local/state/replicated_state/ic_registry_local_store"
  if [[ -d "${REGISTRY}" ]]
  then
    export REGISTRY_PATH="$(readlink -f "${REGISTRY}")"
  fi
  REGISTRY="${HOME}/Library/Application Support/org.dfinity.dfx/network/local/state/replicated_state/ic_registry_local_store"
  if [[ -d "${REGISTRY}" ]]
  then
    export REGISTRY_PATH="$(readlink -f "${REGISTRY}")"
  fi
  REGISTRY="${HOME}/.local/share/dfx/network/local/state/replicated_state/ic_registry_local_store"
  if [[ -d "${REGISTRY}" ]]
  then
    export REGISTRY_PATH="$(readlink -f "${REGISTRY}")"
  fi
  if [[ -z "${REGISTRY_PATH}" ]]
  then
    echo "Local registry not found!"
    exit 1
  fi
  export NNS_SUB="$(ic-regedit snapshot "${REGISTRY_PATH}" | jq -r .nns_subnet_id.principal_id.raw | sed "s/(principal-id)//")"
  export SNS_SUB="${NNS_SUB}"
  export APP_SUB="${NNS_SUB}"
else
    # set IC endpoint
    export NETWORK_URL="${NETWORK}"
    export HOST_ENDPOINT="${TESTNET}"

    RETRIED=0
    while ! ${IC_ADMIN} --nns-url "${NETWORK_URL}" get-subnet-list >/dev/null; do
        RETRIED=$(($RETRIED + 1))
        sleep 30
        if [[ $RETRIED -gt 10 ]]; then
            echo "Boundary Nodes not yet reachable after 300 seconds..."
            exit 1
        fi
    done

    export NNS_SUB="$(${IC_ADMIN} --nns-url "${NETWORK_URL}" get-subnet-list | jq -r '. | join("\n")' | awk 'NR == 1 {print}')"
    export SNS_SUB="$(${IC_ADMIN} --nns-url "${NETWORK_URL}" get-subnet-list | jq -r '. | join("\n")' | awk 'NR == 2 {print}')"
    export APP_SUB="$(${IC_ADMIN} --nns-url "${NETWORK_URL}" get-subnet-list | jq -r '. | join("\n")' | awk 'NR == 3 {print}')"
fi

export IC_URL="${NETWORK_URL}"

export IC_ROOT="$(pwd)/ic/"

execute_nns_tools_func() {
    (
        FUNC="./testnet/tools/nns-tools/cmd.sh"
        export PATH="${REPO_ROOT}/bin:${PATH}"
        cd $IC_ROOT && $FUNC "$@"
    )
}

export -f execute_nns_tools_func

if [[ -f sns_canister_ids.json ]]; then
  export SNS_GOVERNANCE_CANISTER_ID=$(jq -r '.governance_canister_id' sns_canister_ids.json)
  export SNS_INDEX_CANISTER_ID=$(jq -r '.index_canister_id' sns_canister_ids.json)
  export SNS_LEDGER_CANISTER_ID=$(jq -r '.ledger_canister_id' sns_canister_ids.json)
  export SNS_ROOT_CANISTER_ID=$(jq -r '.root_canister_id' sns_canister_ids.json)
  export SNS_SWAP_CANISTER_ID=$(jq -r '.swap_canister_id' sns_canister_ids.json)
fi