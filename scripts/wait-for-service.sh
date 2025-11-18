#!/usr/bin/env bash
set -euo pipefail

compose_file="$1"
service="$2"
max_attempts="$3"
shift 3
cmd=("$@")

if [[ "${service,,}" == "host" ]]; then
  health_cmd=("${cmd[@]}")
  run_from_host=true
else
  health_cmd=("docker" "compose" "-f" "$compose_file" "exec" "-T" "$service" "${cmd[@]}")
  run_from_host=false
fi

if [ "$max_attempts" -eq "0" ]; then
  attempts=0
  until "${health_cmd[@]}" >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ "$run_from_host" = true ]; then
      echo "host command not ready yet, retrying (attempt $attempts)..."
    else
      echo "$service not ready yet, retrying (attempt $attempts)..."
    fi
    sleep 5
  done
else
  attempts=0
  until "${health_cmd[@]}" >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge "$max_attempts" ]; then
      if [ "$run_from_host" = true ]; then
        echo "host command did not succeed in time"
      else
        echo "$service did not become healthy in time"
      fi
      exit 1
    fi
    if [ "$run_from_host" = true ]; then
      echo "host command not ready yet, retrying..."
    else
      echo "$service not ready yet, retrying..."
    fi
    sleep 5
  done
fi
