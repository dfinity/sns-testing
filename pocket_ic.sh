#!/bin/bash

set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

case "$(uname -sr)" in
   Darwin*)
     export DATE="gdate"
     ;;

   Linux*)
     export DATE="date"
     ;;

   *)
     echo "Unknown OS!"
     exit 1
     ;;
esac

APP_SUBNETS="${1:-1}"
APP_SUBNETS_LIST="$(for((i=0; i<${APP_SUBNETS}; i++)); do if [ ${i} != "0" ]; then echo -n ", "; fi; echo -n "{\"state_config\": \"New\", \"instruction_config\": \"Production\", \"dts_flag\": \"Enabled\"}"; done)"

# clean up dfx replica config
rm -rf ~/.local/share/dfx/network/local/

curl -X POST -H "Content-Type: application/json" http://localhost:8000/instances -d "{\"nns\": {\"state_config\": \"New\", \"instruction_config\": \"Production\", \"dts_flag\": \"Enabled\"}, \"sns\": {\"state_config\": \"New\", \"instruction_config\": \"Production\", \"dts_flag\": \"Enabled\"}, \"ii\": null, \"fiduciary\": null, \"bitcoin\": null, \"system\": [], \"application\": [${APP_SUBNETS_LIST}]}"
echo ""

curl -X POST -H "Content-Type: application/json" http://localhost:8000/instances/0/update/set_time -d "{\"nanos_since_epoch\": $(${DATE} +%s%N)}"
echo ""

curl -X POST http://localhost:8000/instances/0/auto_progress
echo ""

curl -X POST -H 'Content-Type: application/json' http://localhost:8000/http_gateway -d '{"forward_to": {"PocketIcInstance": 0}, "listen_at": 8080}'
echo ""
