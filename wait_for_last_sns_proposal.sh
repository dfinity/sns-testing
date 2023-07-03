#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

while [ "$(./get_last_sns_proposal.sh | ./bin/idl2json | jq -r '.proposals[0].executed_timestamp_seconds')" == "0" ]
do
  sleep 1
done
