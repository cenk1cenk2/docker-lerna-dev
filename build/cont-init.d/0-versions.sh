#!/bin/bash

set -o nounset

source /scripts/logger.sh

log_this "node: [$(node -v)]" "${CYAN}VERSION${RESET}"
log_this "npm:  [$(npm -v)]" "${CYAN}VERSION${RESET}"
log_this "yarn: [$(yarn -v)]" "${CYAN}VERSION${RESET}"
