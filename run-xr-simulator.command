#!/bin/bash
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
"$PROJECT_ROOT/scripts/run-xr-simulator.sh" "$@"
RESULT=$?
if [[ $RESULT -ne 0 ]]; then
  printf '\nAvvio non riuscito. Premi Invio per chiudere.\n'
  read -r
fi
exit "$RESULT"
