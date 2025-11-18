#!/usr/bin/env bash
set -euo pipefail

compose_file="$1"
service="$2"
max_attempts="$3"
shift 3
cmd=("$@")
health_cmd=("docker" "compose" "-f" "$compose_file" "exec" "-T" "$service" "${cmd[@]}")

if [ "$max_attempts" -eq "0" ]; then
  attempts=0
  until "${health_cmd[@]}" >/dev/null 2>&1; do
    attempts=$((attempts+1))
    echo "$service not ready yet, retrying (attempt $attempts)..."
    sleep 5
  done
else
  attempts=0
  until "${health_cmd[@]}" >/dev/null 2>&1; do
    attempts=$((attempts+1))
    if [ "$attempts" -ge "$max_attempts" ]; then
      echo "$service did not become healthy in time"
      exit 1
    fi
    echo "$service not ready yet, retrying..."
    sleep 5
  done
fi
