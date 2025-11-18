#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="$1"
SERVICE="$2"
MAX_ATTEMPTS="$3"
shift 3
CMD=("$@")
HEALTH_CMD=("docker" "compose" "-f" "${COMPOSE_FILE}" "exec" "-T" "${SERVICE}" "${CMD[@]}")

if [ "${MAX_ATTEMPTS}" -eq "0" ]; then
  attempts=0
  until "${HEALTH_CMD[@]}" >/dev/null 2>&1; do
    attempts=$((attempts+1))
    echo "${SERVICE} not ready yet, retrying (attempt ${attempts})..."
    sleep 5
  done
else
  attempts=0
  until "${HEALTH_CMD[@]}" >/dev/null 2>&1; do
    attempts=$((attempts+1))
    if [ "${attempts}" -ge "${MAX_ATTEMPTS}" ]; then
      echo "${SERVICE} did not become healthy in time"
      exit 1
    fi
    echo "${SERVICE} not ready yet, retrying..."
    sleep 5
  done
fi

