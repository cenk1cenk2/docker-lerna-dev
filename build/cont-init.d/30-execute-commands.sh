#!/bin/bash

source /scripts/logger.sh

if [ ! -z "${INIT_ENV_COMMAND}" ]; then
  log_start "\$ ${INIT_ENV_COMMAND}"
  eval "/bin/ash -c '${INIT_ENV_COMMAND}'"
  log_finish "\$ ${INIT_ENV_COMMAND}"
fi
