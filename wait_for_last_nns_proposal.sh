#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

while [ "$(./get_last_nns_proposal.sh | ./bin/idl2json | jq -r '.proposal_info[0].executed_timestamp_seconds')" == "0" ]
do
  sleep 1
done
