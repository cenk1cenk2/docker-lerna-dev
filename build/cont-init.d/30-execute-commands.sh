#!/bin/bash

source /scripts/logger.sh

if [ ! -z "${INIT_ENV_COMMAND}" ]; then
  eval ${INIT_ENV_COMMAND} || log_error "Init command failed." && exit 127
fi
