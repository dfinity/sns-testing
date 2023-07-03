#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# Deploy test canister

./deploy_test_canister.sh
# assert the default greeting text
[ "$(./bin/dfx canister call test greet "M")" == '("Hoi, M!")' ] && echo "OK" || exit 1

# Deploy SNS

./deploy_sns.sh sns-test.yml
# assert the SNS swap lifecycle
[ "$(./get_sns_swap_state.sh | sed "s/0 : float32/0 : nat64/" | ./bin/idl2json | jq -r '.swap[0].lifecycle')" == "1" ] && echo "OK" || exit 1
# assert that all SNS canister IDs have been returned by SNS-W
jq -r '.governance_canister_id' -e sns_canister_ids.json
jq -r '.index_canister_id' -e sns_canister_ids.json
jq -r '.ledger_canister_id' -e sns_canister_ids.json
jq -r '.root_canister_id' -e sns_canister_ids.json
jq -r '.swap_canister_id' -e sns_canister_ids.json

# Register test canister

./register_dapp.sh "$(./bin/dfx canister id test)"
./wait_for_last_sns_proposal.sh
# assert that the test canister is indeed registered
[ "$(./get_sns_canisters.sh  | ./bin/idl2json | jq -r '.dapps[0]')" == "$(./bin/dfx canister id test)" ] && echo "OK" || exit 1

# Upgrade test canister

./upgrade_test_canister.sh Hello
./wait_for_last_sns_proposal.sh
./wait_for_canister_running.sh "$(./bin/dfx canister id test)"
# assert the new greeting text
[ "$(./bin/dfx canister call test greet "M")" == '("Hello, M!")' ] && echo "OK" || exit 1

# Open SNS swap

./open_sns_swap.sh
./wait_for_last_nns_proposal.sh
# assert the SNS swap lifecycle after opening SNS swap
[ "$(./get_sns_swap_state.sh | sed "s/: float32/: nat64/" | ./bin/idl2json | jq -r '.swap[0].lifecycle')" == "2" ] && echo "OK" || exit 1

# Participate in SNS swap

./participate_sns_swap.sh 3 10
# wait for the SNS swap to become completed (until heartbeat on SNS swap canister is executed)
while [ "$(./get_sns_swap_state.sh | sed "s/: float32/: nat64/" | ./bin/idl2json | jq -r '.swap[0].lifecycle')" != "3" ]; do sleep 1; done

# Finalize SNS swap

SWAP="$(./finalize_sns_swap.sh | ./bin/idl2json)"
# assert that the swap has been successful for the 3 participants from the previous step
[ "$(echo "${SWAP}" | jq -r '.sweep_icp_result[0].success')" == "3" ] && echo "OK" || exit 1
[ "$(echo "${SWAP}" | jq -r '.claim_neuron_result[0].success')" == "9" ] && echo "OK" || exit 1
[ "$(echo "${SWAP}" | jq -r '.sweep_sns_result[0].success')" == "9" ] && echo "OK" || exit 1

# Upgrade test canister

./upgrade_test_canister.sh Welcome
# collect votes by the SNS developer neuron submitting the upgrade proposal and total number of votes
YES="$(./get_last_sns_proposal.sh | ./bin/idl2json | jq -r '.proposals[0].latest_tally[0].yes')"
TOTAL="$(./get_last_sns_proposal.sh | ./bin/idl2json | jq -r '.proposals[0].latest_tally[0].total')"
# assert that the SNS developer neuron does not have a voting majority after finishing the SNS swap anymore
[ "$((2 * ${YES}))" -lt "${TOTAL}" ] && echo "OK" || exit 1

# Vote on upgrade canister SNS proposal

./vote_on_sns_proposal.sh 3 3 y
./wait_for_last_sns_proposal.sh
./wait_for_canister_running.sh "$(./bin/dfx canister id test)"
# assert the new greeting text
[ "$(./bin/dfx canister call test greet "M")" == '("Welcome, M!")' ] && echo "OK" || exit 1

echo "Basic scenario has successfully finished."
