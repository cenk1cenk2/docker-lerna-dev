#!/bin/bash

if [ ! -d 'node_modules' ] || [ ! -z "${INIT_ENV_FORCE_INSTALL}" ]; then
  yarn --frozen-lock-file
fi

if [ ! -z "${INIT_ENV_COMMAND}" ]; then
  yarn ${INIT_ENV_COMMAND} || echo "Init command failed."
fi
