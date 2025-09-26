#!/bin/bash
set -euo pipefail

SOCKET_GLOB="/run/user/1000/sway-ipc.*.sock"
echo "$SOCKET_GLOB"

ls -l ${SOCKET_GLOB} 2>/dev/null || true

SWAYSOCK_PATH="$(ls -1t ${SOCKET_GLOB} 2>/dev/null | head -n1 || true)"
echo "$SWAYSOCK_PATH"

if [[ -z "${SWAYSOCK_PATH}" ]]; then
  echo "Ошибка: не найден sway socket по маске ${SOCKET_GLOB}" >&2
  exit 1
fi

export SWAYSOCK="${SWAYSOCK_PATH}"

if ! command -v jq >/dev/null || ! command -v swaymsg >/dev/null; then
  echo "Ошибка: нужны jq и swaymsg в PATH" >&2
  exit 1
fi

EXTERNAL_MONITOR="$(
  swaymsg -t get_outputs \
  | jq -r '.[] | select(.active == true and .name != "eDP-1") | .name' \
  | head -n1
)"

if [[ -n "${EXTERNAL_MONITOR}" ]]; then
  swaymsg "workspace 1, move workspace to output ${EXTERNAL_MONITOR}"
  swaymsg "workspace 2, move workspace to output ${EXTERNAL_MONITOR}"
  swaymsg "workspace 3, move workspace to output ${EXTERNAL_MONITOR}"
  swaymsg "workspace 4, move workspace to output eDP-1"
else
  for ws in 1 2 3 4; do
    swaymsg "workspace ${ws}, move workspace to output eDP-1"
  done
fi
