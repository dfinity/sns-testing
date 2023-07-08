#!/usr/bin/env bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

export CID="${1}"

while [ "$(./bin/dfx canister call sns_root canister_status "(record {canister_id=principal\"${CID}\"})" | ./bin/idl2json | jq -r '.status')" != "$(echo -e "{\n  \"running\": null\n}")" ]
do
  sleep 1
done
