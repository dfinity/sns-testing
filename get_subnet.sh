#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

. ./principals.sh

CANISTER_ID="$(textual_decode $1 | xxd -r -p | base64)"
while [ true ]
do
  CURL=$(curl -X POST -H 'Content-Type: application/json' http://localhost:8000/instances/0/read/get_subnet -d "{\"canister_id\": \"${CANISTER_ID}\"}" 2>/dev/null | jq -r ".subnet_id")
  if [ "${CURL}" != "null" ]
  then
    textual_encode "$(echo "${CURL}" | base64 -d | xxd -p)"
    break
  fi
done
