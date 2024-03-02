#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

curl -X POST -H 'Content-Type: application/json' http://localhost:8000/instances/0/update/set_time -d "{\"nanos_since_epoch\": $(($(date +%s%N) + $1 * 1000000000))}"
echo ""
