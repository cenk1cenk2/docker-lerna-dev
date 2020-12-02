#!/bin/bash

set -o nounset

source /scripts/logger.sh

# service format SERVICE='packages/service1,off,override="start":packages/service2,override='dev''
# first parameter is mandatory and has to be in first parameter position for the rest does not matter
>/.env
echo "PACKAGE_START_COMMAND=${PACKAGE_START_COMMAND:-'dev:start'}" >>/.env
echo "DEBUG_PORT=${DEBUG_PORT_START:-9229}" >>/.env

log_finish "Container variables generated."

log_this "node: [$(node -v)]" "${CYAN}VERSION${RESET}"
log_this "npm: [$(npm -v)]" "${CYAN}VERSION${RESET}"
log_this "yarn: [$(yarn -v)]" "${CYAN}VERSION${RESET}"
