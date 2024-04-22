#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# Set the ICP/XDR conversion rate (needed for the NNS Governance and the Neurons' Fund).
./set-icp-xdr-rate.sh 10000

# Deploy test canister
./deploy_test_canister.sh

# assert that we can interact with the test canister by querying the default greeting text
[ "$(./bin/dfx canister call test greet "M")" == '("Hoi, M!")' ] && echo "OK" || exit 1

# Add NNS Root as a co-controller of the dapp canisters to be decentralized.
./let_nns_control_dapp.sh

# Create Service Nervous System.
./propose_sns.sh

# Assert that all SNS canister IDs have been returned by SNS-W
jq -r '.governance_canister_id' -e sns_canister_ids.json
jq -r '.index_canister_id' -e sns_canister_ids.json
jq -r '.ledger_canister_id' -e sns_canister_ids.json
jq -r '.root_canister_id' -e sns_canister_ids.json
jq -r '.swap_canister_id' -e sns_canister_ids.json

# Assert the SNS swap lifecycle is in the OPEN state.
[ "$(./get_sns_swap_state.sh | ./bin/idl2json | jq -r '.swap[0].lifecycle')" == "2" ] && echo "OK" || exit 1

# Assert that the test canister is indeed registered.
[ "$(./get_sns_canisters.sh | ./bin/idl2json | jq -r '.dapps[0]')" == "$(./bin/dfx canister id test)" ] && echo "OK" || exit 1

# Upgrade test canister (I)
# TODO: Make sure the following commands work. Currently, we get "The replica returned a replica error: Replica Error: reject code CanisterError, reject message Canister be2us-64aaa-aaaaa-qaabq-cai violated contract: Error getting performance counter type 1, error code None"
./upgrade_test_canister.sh Hello
./wait_for_last_sns_proposal.sh
./wait_for_canister_running.sh "$(./bin/dfx canister id test)"

# assert the new greeting text
[ "$(./bin/dfx canister call test greet "M")" == '("Hello, M!")' ] && echo "OK" || exit 1

# Participate in SNS swap
./participate_sns_swap.sh

# Wait for the SNS swap lifecycle is in the COMPLETED state.
# This happens when the heartbeat of the SNS Swap canister is executed.
while [ "$(./get_sns_swap_state.sh | ./bin/idl2json | jq -r '.swap[0].lifecycle')" != "3" ]; do sleep 1; done

# Upgrade test canister (II)
./upgrade_test_canister.sh Welcome
# We expect that the canister has not been changed yet as we have now decentralized
# so we don't hold the majority of the voting power.
[ "$(./bin/dfx canister call test greet "M")" == '("Hello, M!")' ] && echo "OK" || exit 1

# Collect votes by the SNS developer neuron submitting the upgrade proposal and total number of votes.
YES="$(./get_last_sns_proposal.sh | ./bin/idl2json | jq -r '.proposals[0].latest_tally[0].yes')"
TOTAL="$(./get_last_sns_proposal.sh | ./bin/idl2json | jq -r '.proposals[0].latest_tally[0].total')"

# Assert that the SNS developer neuron no longer holds voting majority after the SNS swap is completed.
[ "$((2 * ${YES}))" -lt "${TOTAL}" ] && echo "OK" || exit 1

# Vote on upgrade canister SNS proposal
./vote_on_sns_proposal.sh \
    61 `# Simulate this number of SNS users' votes. TODO: determine the smallest possible value that will work here` \
    2  `# Proposal ID` \
    y  `# Vote to adopt this proposal`
./wait_for_last_sns_proposal.sh
./wait_for_canister_running.sh "$(./bin/dfx canister id test)"

# Assert the new greeting text
[ "$(./bin/dfx canister call test greet "M")" == '("Welcome, M!")' ] && echo "OK" || exit 1

echo "Basic scenario has successfully finished."
