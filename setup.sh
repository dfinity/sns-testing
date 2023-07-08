#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

await_canister_upgrade() {
    local CANISTER=$1
    local EXPECTED_SHA=$2

    for i in {0..10}; do
       INSTALLED_SHA=$(execute_nns_tools_func canister_hash "${NETWORK}" "${CANISTER}")
       if [ "${INSTALLED_SHA}" = "${EXPECTED_SHA}" ]; then
          echo "${CANISTER} upgraded to ${EXPECTED_SHA}"
          break;
       elif [ "${i}" -eq 10 ]; then
          echo "${CANISTER} didn't upgrade to the correct version. Exiting..."
          exit 1
       else
           echo "Installed SHA (${INSTALLED_SHA}) != desired SHA (${EXPECTED_SHA}). Retrying in 5s"
          sleep 5
       fi
    done
}

if [ $# -eq 0 ]
then
   echo "No arguments supplied. Script will download the sns wasm binaries at specified IC_COMMIT."
   USE_RELEASE_CANDIDATE=false
else
   USE_RELEASE_CANDIDATE=true
   CANDIDATE=$1
   echo "Using release candidate ${CANDIDATE}"
fi

set -uo pipefail

${DFX} nns import --network-mapping "${DX_NETWORK}=mainnet"
${DFX} sns import
if [ "${CANISTER_TEST}" == "_test" ]
then
  curl -L "https://raw.githubusercontent.com/dfinity/ic/${IC_COMMIT}/rs/nns/governance/canister/governance_test.did" -o ./candid/nns-governance.did
  curl -L "https://raw.githubusercontent.com/dfinity/ic/${IC_COMMIT}/rs/sns/governance/canister/governance_test.did" -o ./candid/sns_governance.did
fi
curl -L "https://github.com/dfinity/nns-dapp/blob/${IC_COMMIT}/sns_aggregator/sns_aggregator.did" -o ./candid/sns_aggregator.did
cat <<< $(jq -r 'del(.canisters."internet_identity".remote)' dfx.json) > dfx.json
cat <<< $(jq -r 'del(.canisters."nns-dapp".remote)' dfx.json) > dfx.json
cat <<< $(jq -r 'del(.canisters."sns_aggregator".remote)' dfx.json) > dfx.json

${DFX} canister create internet_identity --network "${NETWORK}" --no-wallet --specified-id qhbym-qaaaa-aaaaa-aaafq-cai
if [ ! -z "${II_RELEASE:-}" ]
then
  curl -L "https://github.com/dfinity/internet-identity/releases/download/${II_RELEASE}/internet_identity_dev.wasm.gz" -o internet-identity/internet_identity.wasm
fi

${DFX} canister create nns-dapp --network "${NETWORK}" --no-wallet --specified-id qsgjb-riaaa-aaaaa-aaaga-cai

if [ "${TESTNET}" == "local" ]
then
  ${DFX} canister create sns_aggregator --network "${NETWORK}" --no-wallet --specified-id qvhpv-4qaaa-aaaaa-aaagq-cai
else
  ${DFX} --provisional-create-canister-effective-canister-id 5v3p4-iyaaa-aaaaa-qaaaa-cai canister create sns_aggregator --network "${NETWORK}" --no-wallet
fi

if [ ! -z "${NNS_DAPP_RELEASE:-}" ]
then
  mkdir -p nns-dapp/out
  curl -L "https://github.com/dfinity/nns-dapp/releases/download/${NNS_DAPP_RELEASE}/nns-dapp.wasm" -o nns-dapp/out/nns-dapp.wasm
  curl -L "https://github.com/dfinity/nns-dapp/releases/download/${NNS_DAPP_RELEASE}/sns_aggregator.wasm" -o nns-dapp/out/sns_aggregator.wasm
fi

${DFX} canister install sns_aggregator --network "${NETWORK}" --wasm nns-dapp/out/sns_aggregator.wasm
${DFX} canister install internet_identity --network "${NETWORK}" --wasm internet-identity/internet_identity.wasm
${DFX} canister install nns-dapp --network "${NETWORK}" --wasm nns-dapp/out/nns-dapp.wasm --argument '(opt record{
  args = vec {
    record{ 0="API_HOST"; 1="'"${PROTOCOL}://${HOST_ENDPOINT}"'" };
    record{ 0="CYCLES_MINTING_CANISTER_ID"; 1="rkp4c-7iaaa-aaaaa-aaaca-cai" };
    record{ 0="DFX_NETWORK"; 1="testing" };
    record{ 0="FEATURE_FLAGS"; 1="{\"ENABLE_CKBTC\":false,\"ENABLE_CKTESTBTC\":false,\"ENABLE_SNS_2\":false,\"ENABLE_SNS_AGGREGATOR\":true,\"ENABLE_SNS_VOTING\":true}" };
    record{ 0="FETCH_ROOT_KEY"; 1="true" };
    record{ 0="GOVERNANCE_CANISTER_ID"; 1="rrkah-fqaaa-aaaaa-aaaaq-cai" };
    record{ 0="GOVERNANCE_CANISTER_URL"; 1="'"${PROTOCOL}://rrkah-fqaaa-aaaaa-aaaaq-cai.${HOST_ENDPOINT}"'" };
    record{ 0="HOST"; 1="'"${PROTOCOL}://${HOST_ENDPOINT}"'" };
    record{ 0="IDENTITY_SERVICE_URL"; 1="'"${PROTOCOL}://$(${DFX} canister --network ${NETWORK} id internet_identity).${HOST_ENDPOINT}"'" };
    record{ 0="LEDGER_CANISTER_ID"; 1="ryjl3-tyaaa-aaaaa-aaaba-cai" };
    record{ 0="LEDGER_CANISTER_URL"; 1="'"${PROTOCOL}://ryjl3-tyaaa-aaaaa-aaaba-cai.${HOST_ENDPOINT}"'" };
    record{ 0="OWN_CANISTER_ID"; 1="'"$(${DFX} canister --network ${NETWORK} id nns-dapp)"'" };
    record{ 0="OWN_CANISTER_URL"; 1="'"${PROTOCOL}://$(${DFX} canister --network ${NETWORK} id nns-dapp).${HOST_ENDPOINT}"'" };
    record{ 0="ROBOTS"; 1="<meta name=\"robots\" content=\"noindex, nofollow\" />" };
    record{ 0="SNS_AGGREGATOR_URL"; 1="'"${PROTOCOL}://$(${DFX} canister --network ${NETWORK} id sns_aggregator).${HOST_ENDPOINT}"'" };
    record{ 0="STATIC_HOST"; 1="'"${PROTOCOL}://${HOST_ENDPOINT}"'" };
    record{ 0="WASM_CANISTER_ID"; 1="qaa6y-5yaaa-aaaaa-aaafa-cai" };
  };
})'

${IC_ADMIN}  \
   --nns-url "${NETWORK_URL}" propose-to-set-authorized-subnetworks  \
   --test-neuron-proposer  \
   --proposal-title "Set authorized subnets"  \
   --proposal-url "https://forum.dfinity.org"  \
   --summary "This proposal sets the application subnet as authorized"  \
   --subnets "${APP_SUB}"

${IC_ADMIN}  \
   --nns-url "${NETWORK_URL}" propose-to-update-sns-subnet-ids-in-sns-wasm  \
   --test-neuron-proposer  \
   --summary "This proposal sets the SNS subnet"  \
   --sns-subnet-ids-to-add "${SNS_SUB}"

# if $CANDIDATE exists, we'll use the versions specified in there
# otherwise we'll just use IC_COMMIT
if [ "${USE_RELEASE_CANDIDATE}" = true ]
then
   echo "Downloading release candidates WASMs specified in ${CANDIDATE}."
   . ./download_release_candidate_wasms.sh "${CANDIDATE}"
else
   echo "Downloading WASMs at specified IC_COMMIT."
   for canister in sns-root-canister "sns-governance-canister${CANISTER_TEST}" sns-swap-canister ic-icrc1-ledger ic-icrc1-archive ic-icrc1-index
   do
     curl -L "https://download.dfinity.systems/ic/${IC_COMMIT}/canisters/${canister}.wasm.gz" -o "${canister}.wasm.gz"
   done
   if [ ! -z "${CANISTER_TEST}" ]
   then
     mv "./sns-governance-canister${CANISTER_TEST}.wasm.gz" ./sns-governance-canister.wasm.gz
   fi
   SNS_ROOT_CANISTER_FILENAME="./sns-root-canister.wasm.gz"
   SNS_GOVERNANCE_CANISTER_FILENAME="./sns-governance-canister.wasm.gz"
   SNS_SWAP_CANISTER_FILENAME="./sns-swap-canister.wasm.gz"
   ICRC1_LEDGER_FILENAME="./ic-icrc1-ledger.wasm.gz"
   ICRC1_ARCHIVE_FILENAME="./ic-icrc1-archive.wasm.gz"
   ICRC1_INDEX_FILENAME="./ic-icrc1-index.wasm.gz"
fi

submit_wasm_to_sns_wasm () {
   local CANISTER_NAME=$1
   local FILENAME=$2
   local SHA="$(sha256sum "${FILENAME}" | grep -o "^[0-9a-f]*")"
   echo "Submitting WASM for ${CANISTER_NAME}"
   ${IC_ADMIN}  \
      --nns-url "${NETWORK_URL}" propose-to-add-wasm-to-sns-wasm  \
      --test-neuron-proposer  \
      --summary "This proposal adds SNS ${CANISTER_NAME} WASM to SNS-W"  \
      --canister-type "${CANISTER_NAME}"  \
      --wasm-module-sha256 "${SHA}"  \
      --wasm-module-path "${FILENAME}" > upload_sns_"${CANISTER_NAME}".log.txt 
   
   for i in {0..10}; do
     local SNS_VERSIONS="$(${DFX} canister --network "${NETWORK}" call nns-sns-wasm get_latest_sns_version_pretty 'null')"
     # Extract version hash by looking for ${CANISTER_NAME} and then finding the hash on the next line:
     local OBSERVED_SHA=$(echo "${SNS_VERSIONS}" | grep --ignore-case --after-context 1 "${CANISTER_NAME}\"" | tail -n 1 | grep --only-matching --extended-regexp "[0-9a-f]+")
     if [ "${SHA}" == "${OBSERVED_SHA}" ]; then
        break
     elif [ "${i}" -eq 10 ]; then
        echo "${CANISTER_NAME} does not have the expected wasm hash in SNS-WASM. Exiting..."
        exit 1
     else
        echo "Waiting for ${CANISTER_NAME} to be updated in SNS-W (${i}/10)"
        sleep 5
     fi
   done
}

# Update SNS binaries in sns-wasm

submit_wasm_to_sns_wasm "root"       "${SNS_ROOT_CANISTER_FILENAME}" 
submit_wasm_to_sns_wasm "governance" "${SNS_GOVERNANCE_CANISTER_FILENAME}" 
submit_wasm_to_sns_wasm "swap"       "${SNS_SWAP_CANISTER_FILENAME}" 
submit_wasm_to_sns_wasm "ledger"     "${ICRC1_LEDGER_FILENAME}" 
submit_wasm_to_sns_wasm "index"      "${ICRC1_INDEX_FILENAME}" 
submit_wasm_to_sns_wasm "archive"    "${ICRC1_ARCHIVE_FILENAME}" 


upgrade_nns_canister () {
   local CANISTER_NAME=$1
   local FILENAME=$2
   local SHA="$(sha256sum "${FILENAME}" | grep -o "^[0-9a-f]*")"
   local CANISTER_ID="$(execute_nns_tools_func nns_canister_id "${CANISTER_NAME}")"
   echo "Upgrading ${CANISTER_NAME} (${CANISTER_ID})"
   ${IC_ADMIN} \
      --nns-url "${NETWORK_URL}" propose-to-change-nns-canister \
      --test-neuron-proposer  \
      --mode=upgrade \
      --summary "This proposal will upgrade the ${CANISTER_NAME} canister"  \
      --canister-id "${CANISTER_ID}" \
      --wasm-module-sha256 "${SHA}" \
      --wasm-module-path "${FILENAME}" > change_"${CANISTER_NAME}".log.txt 

   await_canister_upgrade "${CANISTER_NAME}" "${SHA}"
}

if [ "${USE_RELEASE_CANDIDATE}" = true ]
then
   # Update sns-wasm and nns-governance

   upgrade_nns_canister "governance" "${NNS_GOVERNANCE_CANISTER_FILENAME}" 
   upgrade_nns_canister "sns-wasm"   "${SNS_WASM_CANISTER_FILENAME}" 
fi
