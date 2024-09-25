#!/bin/bash

# grab global variables
source vars

DOCKER=$(which docker)

# function to check if container is running
function check_container() {
  $DOCKER ps --filter "name=${CONTAINER_NAME}" --format "{{.ID}}"
}

# function to start new docker container
function start_container() {
  if [ "${ENABLE_PTP:-false}" = true ]; then
    echo "PTP requested..."
    if [ -e /dev/ptp0 ]; then
      echo "PTP device found: /dev/ptp0, passing through..."
      PTPARG="--device=/dev/ptp0"
    else
      echo "PTP device not found: /dev/ptp0"
    fi
  fi
  $DOCKER run --name=${CONTAINER_NAME}             \
              --detach=true                        \
              --restart=always                     \
              --publish=123:123/udp                \
              --env=NTP_SERVERS=${NTP_SERVERS}     \
              --env=ENABLE_NTS=${ENABLE_NTS}       \
              --env=ENABLE_SYSCLK=${ENABLE_SYSCLK} \
              --env=NOCLIENTLOG=${NOCLIENTLOG}     \
              --env=LOG_LEVEL=${LOG_LEVEL}         \
              --cap-add=SYS_TIME                   \
              --read-only=true                     \
              --tmpfs=/etc/chrony:rw,mode=1750     \
              --tmpfs=/run/chrony:rw,mode=1750     \
              --tmpfs=/var/lib/chrony:rw,mode=1750 \
              ${PTPARG} \
              ${DOCKER_OPTS}                       \
              ${IMAGE_NAME}:latest > /dev/null
}

# check if docker container with same name is already running.
if [ "$(check_container)" != "" ]; then
  # container found...
  # 1) rename existing container
  $DOCKER rename ${CONTAINER_NAME} "${CONTAINER_NAME}_orig" > /dev/null 2>&1
  # 2) stop exiting container
  $DOCKER stop "${CONTAINER_NAME}_orig" > /dev/null 2>&1
  # 3) start new container
  start_container
  # 4) remover existing container
  if [ "$(check_container)" != "" ]; then
    $DOCKER rm "${CONTAINER_NAME}_orig" > /dev/null 2>&1
  fi

  # finally, lets clean up old docker images
  # shellcheck disable=SC2046
  $DOCKER rmi $($DOCKER images -q ${IMAGE_NAME}) > /dev/null 2>&1

# no docker container found. start a new one.
else
  start_container
fi
