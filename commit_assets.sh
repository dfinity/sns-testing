#!/bin/bash

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

set -euo pipefail

. ./constants.sh normal "${3:-}"

KEY="${1:-/asset.txt}"
TEXT="${2:-hoi}"
GZIP="$(python3 -c "x=bytes.fromhex(\"$(echo -n "${TEXT}" | gzip | xxd -p - | tr -d '\n')\"); print(x)" | sed "s/\\\\x/\\\\/g" | sed "s/^..//" | sed "s/.$//")"
BATCH="$(dfx canister --network ${NETWORK} call assets create_batch '(record {})' | grep -o "[0-9]*")"
CHUNK="$(dfx canister --network ${NETWORK} call assets create_chunk "(record {batch_id = ${BATCH}; content = blob \"${GZIP}\";})" | grep -o "[0-9]*")"
dfx canister --network ${NETWORK} call assets commit_batch "(record {batch_id = ${BATCH}; operations = vec {variant {CreateAsset = record {key = \"${KEY}\"; content_type = \"text/plain\";}}; variant {SetAssetContent = record {key = \"${KEY}\"; content_encoding = \"gzip\"; chunk_ids = vec {${CHUNK}}; sha256 = null;}};}})"
