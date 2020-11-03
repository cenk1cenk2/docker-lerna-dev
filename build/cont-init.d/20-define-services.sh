#!/bin/bash

source /.env
source /scripts/logger.sh

# Clean up all services
rm -r /etc/services.d && mkdir -p /etc/services.d

log_divider
log_this "Creating multiple node.js instances..." "${YELLOW}docker-lerna-dev${RESET}"

if [[ ! -z ${RUN_IN_BAND} ]]; then
  log_supervisor "RUN_IN_BAND set will run in sequential mode."
  echo "RUN_IN_BAND_ITEM=0" >/.lock
fi

for SERVICE in $(echo "${SERVICES}" | sed -r "s/:/ /g"); do
  # Get service options
  SERVICE_ARRAY=($(echo "${SERVICE}" | sed "s/,/ /g"))
  SERVICE_PATH=${SERVICE_ARRAY[0]}
  SERVICE_DIR_SAFE=$(echo "${SERVICE_PATH}" | sed -r "s/[\.\*\\\/]/_/g")
  SERVICE_OPTIONS=$(echo "${SERVICE_ARRAY[@]:1}")

  # check for options
  OFF=$(echo "${SERVICE_OPTIONS[@]}" | grep -q off || grep -q OFF)
  NO_LOG=$(echo "${SERVICE_OPTIONS[@]}" | grep -q NO_LOG || grep -q no_log)
  PACKAGE_START_OVERRIDE=$(echo "${SERVICE_OPTIONS[@]}" | grep -o -E "override=('|\")?(.*)('|\")?" | sed -r "s/override=('|\")?(.*)('|\")?/\2/g")

  if [[ -z "${OFF}" ]]; then
    # Package start
    FINAL_START_COMMAND=${PACKAGE_START_OVERRIDE:-${PACKAGE_START_COMMAND}}

    # Create the service directory
    mkdir -p /etc/services.d/${SERVICE_DIR_SAFE}
    printf "#!/bin/bash

    set -eo pipefail

    source /scripts/logger.sh

    # If execution order is set
    if [[ ! -z \${RUN_IN_BAND} ]]; then
      RUN_IN_BAND=($(echo "${RUN_IN_BAND}" | sed "s/:/ /g"))
      while [[ -f /.lock && -z \${RUN_IN_BAND_DAVAI} ]]; do
        source /.lock
        if [[ \"\${RUN_IN_BAND[\${RUN_IN_BAND_ITEM}]}\" == \"${SERVICE_PATH}\" ]]; then
          if [[ \${#RUN_IN_BAND[@]} -eq \$((\${RUN_IN_BAND_ITEM} + 1)) ]]; then
            s6-sleep ${RUN_IN_BAND_WAIT:-10}
            rm /.lock
            log_supervisor 'Removing lock file. Queue is empty.' 'top'
          else
            echo \"RUN_IN_BAND_ITEM=\$((\${RUN_IN_BAND_ITEM} + 1))\" >/.lock
            RUN_IN_BAND_DAVAI=1
          fi
        else
          log_wait '${SERVICE_PATH}' 'top'
          s6-sleep ${RUN_IN_BAND_WAIT:-10}
        fi
      done
    fi

    # Change directory to package
    cd /data/app/${SERVICE_PATH}

    # Get directory env variables if exists
    if [[ -f .env ]]; then
      log_info \"source ${SERVICE_PATH}/.env for given scope.\"
      source .env
    fi

    # For more distinction
    log_start '${SERVICE_PATH}' 'top'

    # Package start command
    if [[ ! -z "${NO_LOG}" ]]; then
      fdmove -c 2 1 /bin/bash -c \"DEBUG_PORT=${DEBUG_PORT} yarn ${FINAL_START_COMMAND} > /dev/null 2&>1\"
    elif [[ ${PREFIX_LABEL:-'true'} == true ]]; then
      fdmove -c 2 1 /bin/bash -c \"DEBUG_PORT=${DEBUG_PORT} yarn ${FINAL_START_COMMAND}\" | awk '{print \"[${GREEN}${SERVICE_PATH}${RESET}] \" \$0}'
    else
      fdmove -c 2 1 /bin/bash -c \"DEBUG_PORT=${DEBUG_PORT} yarn ${FINAL_START_COMMAND}\"
    fi

    # For run in band on crash
    if [[ -f /.lock ]]; then
      echo \"RUN_IN_BAND_ITEM=\$((\${RUN_IN_BAND_ITEM} - 1))\" >/.lock
    fi

    # For more distinction
    log_error '${SERVICE_PATH}' 'both'

    s6-sleep 5
    " >/etc/services.d/${SERVICE_DIR_SAFE}/run

    # Punch debug port
    DEBUG_PORT=$((${DEBUG_PORT} + 1))
    echo "DEBUG_PORT=${DEBUG_PORT}" >>/.env

    chmod +x /etc/services.d/${SERVICE_DIR_SAFE}/run

    log_add "${SERVICE_PATH}@/etc/services.d/${SERVICE_DIR_SAFE}."
  else
    log_skip "[${RED}OFF${RESET}]: ${SERVICE_PATH}"
  fi
done
