#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./constants.sh normal

./deploy_test_canister.sh
./deploy_sns.sh sns-test.yml
./register_dapp.sh "$(dfx canister --network "${NETWORK}" id test)"
./upgrade_test_canister.sh Hello
./open_sns_sale.sh
./participate_sns_sale.sh 3 200
./finalize_sns_sale.sh
./upgrade_test_canister.sh Hoi
./vote_on_sns_proposal.sh 3 3 y

echo "Basic scenario has successfully finished."
