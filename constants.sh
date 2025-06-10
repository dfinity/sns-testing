#!/usr/bin/env bash

echo C1
set -euo pipefail

echo C2
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# Works even when scripts invoked from outside of repository
echo C3
repo_root() {
    local SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
    # Execute in subshell to not change directory of caller
    ( cd "$SCRIPT_DIR" && readlink -f . )
}

echo C4
REPO_ROOT=$(repo_root)

# We always want to use our downloaded versions when available
echo C5
export PATH="$REPO_ROOT/bin:${PATH}"
export REPO_ROOT

echo C6
export MODE="${1}"
if [[ -z "${MODE}" ]]; then
    echo C7
    echo "Usage: constants.sh <mode>"
    return 1
fi

echo C8
SETTINGS_FILE="${REPO_ROOT}/settings.sh"
if [[ -f "$SETTINGS_FILE" ]]; then
    echo C9
    . "$SETTINGS_FILE"
fi

echo C10
if [[ ! -z "${2:-}" ]]; then
    echo C11
    DX_IDENT="${2}"
fi

echo C12
if [[ -z "$TESTNET" ]]; then
    echo C13
    echo "TESTNET not specified. Please export the TESTNET env. variable directly"
    echo "or in settings.sh"
    exit 1
fi

echo C14
if [[ -z "$IC_COMMIT" ]]; then
    echo C15
    echo "IC_COMMIT not specified. Please export the IC_COMMIT env. variable"
    echo "directly or in settings.sh"
    exit 1
fi

echo C16
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
echo C17
if which dfx >/dev/null; then
  # We need these identities
  echo C18
  dfx identity import --storage-mode=plaintext dev-ident-1 "$REPO_ROOT/test-identities/dev-ident-1.pem" 2> /dev/null || true
  dfx identity import --storage-mode=plaintext dev-ident-2 "$REPO_ROOT/test-identities/dev-ident-2.pem" 2> /dev/null || true
  dfx identity import --storage-mode=plaintext dev-ident-3 "$REPO_ROOT/test-identities/dev-ident-3.pem" 2> /dev/null || true

  # Always change to the configured $DX_IDENT if it's pinned in settings.sh.  Otherwise, fall back to dev-ident-1
  echo C19
  export DX_IDENT=${DX_IDENT:-dev-ident-1}
  dfx identity use "$DX_IDENT"

  echo C20
  export DX_PRINCIPAL="$(dfx identity get-principal)"
  export DX_VERSION="$(dfx --version | sed "s/^dfx //")"
  export PEM_FILE="$(readlink -f ~/.config/dfx/identity/${DX_IDENT}/identity.pem)"
fi

echo C21
export CANISTER_TEST="${CANISTER_TEST:-_test}"

echo C22
if [[ -z "${DFX_IC_COMMIT:-}" ]]; then
  echo C23
  export DFX_IC_COMMIT="${IC_COMMIT}"
fi

echo C24
export NETWORK=$([[ "$TESTNET" == "local" ]] && echo "local" || echo "https://${TESTNET}")
export DX_NETWORK=$([[ "$TESTNET" == "local" ]] && echo "local" || echo "https___${TESTNET//./_}")
export PROTOCOL=$([[ "$TESTNET" == "local" ]] && echo "http" || echo "https")

echo C25
if [[ "${MODE}" == "install" ]]; then
  echo C26
  return 0
fi

echo C27
DFX="$(which dfx)"
export DFX
IC_ADMIN="$(which ic-admin)"
export IC_ADMIN

echo C28
if [[ ! -f "${DFX}" ]]; then
    echo C29
    echo "Couldn't find dfx at ${DFX}. You may need to run install.sh"
    exit 1
fi
echo C30
if [[ ! -f "${IC_ADMIN}" ]]; then
    echo C31
    echo "Couldn't find ic-admin at ${IC_ADMIN}. You may need to run install.sh"
    exit 1
fi

echo C32
if [[ "${TESTNET}" == "local" ]]; then
  echo C33
  # set IC endpoint
  export NETWORK_URL="${PROTOCOL}://localhost:$(${DFX} info webserver-port)"
  echo C33.1
  export HOST_ENDPOINT="localhost:$(${DFX} info webserver-port)"
  # obtain local subnet from local registry
  echo C33.2
  export REGISTRY_PATH=""
  REGISTRY=".dfx/network/local/state/replicated_state/ic_registry_local_store"
  echo C34
  if [[ -d "${REGISTRY}" ]]
  then
    echo C35
    export REGISTRY_PATH="$(readlink -f "${REGISTRY}")"
  fi
  echo C36
  # Determine the operating system
  OS_TYPE="$(uname)"
  if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo C37
    BASE_PATH="$HOME/Library/Application Support/org.dfinity.dfx/network/local"
  elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo C38
    BASE_PATH="$HOME/.local/share/dfx/network/local"
  else
    echo "Unsupported OS type: $OS_TYPE"
    exit 1
  fi

  # Find the ic_registry_local_store directory within the base path
  echo C39
  REGISTRY_FOUND=$(find "$BASE_PATH" -type d -name ic_registry_local_store 2>/dev/null)

  echo C40
  if [ $(echo "$REGISTRY_FOUND" | wc -l) -gt 1 ]; then
      echo C41
      # If you get to this case, it's likely that it can be resolved by starting
      # your local replica using `dfx start --clean`
      echo "Error: Multiple ic_registry_local_store directories found: ${REGISTRY_FOUND}"
      exit 1
  fi
  
  echo C42
  # If the directory is found, set REGISTRY_PATH to its absolute path
  if [[ -d "$REGISTRY_FOUND" ]]; then
    echo C43
    export REGISTRY_PATH="$(readlink -f "$REGISTRY_FOUND")"
  fi

  echo C44
  if [[ -z "${REGISTRY_PATH}" ]]
  then
    echo C45
    echo "Error: Local registry not found!"
    exit 1
  fi
  echo C46
  export NNS_SUB="$(ic-regedit snapshot "${REGISTRY_PATH}" | jq -r .nns_subnet_id.principal_id.raw | sed "s/(principal-id)//")"
  export SNS_SUB="${NNS_SUB}"
  export APP_SUB="${NNS_SUB}"
else
    echo C47
    # set IC endpoint
    export NETWORK_URL="${NETWORK}"
    export HOST_ENDPOINT="${TESTNET}"

    echo C48
    RETRIED=0
    while ! ${IC_ADMIN} --nns-url "${NETWORK_URL}" get-subnet-list >/dev/null; do
        echo C48
        RETRIED=$(($RETRIED + 1))
        sleep 30
        echo C49
        if [[ $RETRIED -gt 10 ]]; then
            echo C50
            echo "Boundary Nodes not yet reachable after 300 seconds..."
            exit 1
        fi
    done

    echo C51
    export NNS_SUB="$(${IC_ADMIN} --nns-url "${NETWORK_URL}" get-subnet-list | jq -r '. | join("\n")' | awk 'NR == 1 {print}')"
    export SNS_SUB="$(${IC_ADMIN} --nns-url "${NETWORK_URL}" get-subnet-list | jq -r '. | join("\n")' | awk 'NR == 2 {print}')"
    export APP_SUB="$(${IC_ADMIN} --nns-url "${NETWORK_URL}" get-subnet-list | jq -r '. | join("\n")' | awk 'NR == 3 {print}')"
fi

echo C52
export IC_URL="${NETWORK_URL}"

export IC_ROOT="$(pwd)/ic/"

execute_nns_tools_func() {
    (
        FUNC="./testnet/tools/nns-tools/cmd.sh"
        export PATH="${REPO_ROOT}/bin:${PATH}"
        cd $IC_ROOT && $FUNC "$@"
    )
}

echo C53
export -f execute_nns_tools_func

echo C54
if [[ -f sns_canister_ids.json ]]; then
  echo C55
  export SNS_GOVERNANCE_CANISTER_ID=$(jq -r '.governance_canister_id' sns_canister_ids.json)
  export SNS_INDEX_CANISTER_ID=$(jq -r '.index_canister_id' sns_canister_ids.json)
  export SNS_LEDGER_CANISTER_ID=$(jq -r '.ledger_canister_id' sns_canister_ids.json)
  export SNS_ROOT_CANISTER_ID=$(jq -r '.root_canister_id' sns_canister_ids.json)
  export SNS_SWAP_CANISTER_ID=$(jq -r '.swap_canister_id' sns_canister_ids.json)
fi

echo C56
