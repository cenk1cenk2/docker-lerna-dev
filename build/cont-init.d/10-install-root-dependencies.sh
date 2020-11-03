#!/bin/bash

source /scripts/logger.sh

[ ! -d 'node_modules' ] && log_warn "'node_modules/' folder not found in cwd. Will install dependencies."
[ ! -z "${INIT_ENV_FORCE_INSTALL}" ] && log_warn "Force installing dependencies is defined. Will install dependencies."

if [ ! -d 'node_modules' ] || [ ! -z "${INIT_ENV_FORCE_INSTALL}" ]; then
  yarn --frozen-lock-file
fi

if [ ! -z "${INIT_ENV_COMMAND}" ]; then
  ${INIT_ENV_COMMAND} || log_error "Init command failed." && exit 127
fi
