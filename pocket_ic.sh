#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

# clean up dfx replica config
rm -rf ~/.local/share/dfx/network/local/

curl -X POST -H 'Content-Type: application/json' http://localhost:8000/instances -d '{"nns": {"state_config": "New", "instruction_config": "Production"}, "sns": {"state_config": "New", "instruction_config": "Production"}, "ii": null, "fiduciary": null, "bitcoin": null, "system": [], "application": [{"state_config": "New", "instruction_config": "Production"}]}'
echo ""

curl -X POST -H 'Content-Type: application/json' http://localhost:8000/instances/0/update/set_time -d "{\"nanos_since_epoch\": $(date +%s%N)}"
echo ""

curl -X POST http://localhost:8000/instances/0/auto_progress
echo ""

curl -X POST -H 'Content-Type: application/json' http://localhost:8000/http_gateway -d '{"forward_to": {"PocketIcInstance": 0}, "listen_at": 8080}'
echo ""
