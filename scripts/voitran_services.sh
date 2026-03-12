#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RUNTIME_DIR="${VOITRAN_RUNTIME_ROOT:-/Volumes/SSDExterno/Voitran_runtime}"
STATE_DIR="${RUNTIME_DIR}/services"
PID_DIR="${STATE_DIR}/pids"
LOG_DIR="${RUNTIME_DIR}/logs/services"
BIN_DIR="${RUNTIME_DIR}/bin"
CONTROL_PLANE_PID_FILE="${PID_DIR}/control-plane.pid"
CONTROL_PLANE_PORT="${VOITRAN_CONTROL_PLANE_PORT:-8080}"
CONTROL_PLANE_HOST="${VOITRAN_CONTROL_PLANE_HOST:-127.0.0.1}"
CONTROL_PLANE_DIR="${VOITRAN_CONTROL_PLANE_DIR:-${ROOT_DIR}/backend/control-plane}"

mkdir -p "${PID_DIR}" "${LOG_DIR}" "${BIN_DIR}"

service_running() {
  local pid_file="$1"
  if [[ -f "${pid_file}" ]]; then
    local pid
    pid="$(cat "${pid_file}")"
    if [[ -n "${pid}" ]] && kill -0 "${pid}" 2>/dev/null; then
      return 0
    fi
  fi
  return 1
}

start_control_plane() {
  if service_running "${CONTROL_PLANE_PID_FILE}"; then
    return 0
  fi

  if [[ ! -d "${CONTROL_PLANE_DIR}" ]]; then
    echo "[voitran_services] control-plane indisponivel neste bundle: ${CONTROL_PLANE_DIR}" >&2
    return 1
  fi

  (
    cd "${CONTROL_PLANE_DIR}"
    HOST="${CONTROL_PLANE_HOST}" \
    PORT="${CONTROL_PLANE_PORT}" \
    APP_ENV="desktop-local" \
    nohup go run ./cmd/server >"${LOG_DIR}/control-plane.log" 2>&1 &
    echo $! >"${CONTROL_PLANE_PID_FILE}"
  )
  sleep 1
}

stop_control_plane() {
  if service_running "${CONTROL_PLANE_PID_FILE}"; then
    local pid
    pid="$(cat "${CONTROL_PLANE_PID_FILE}")"
    kill "${pid}" 2>/dev/null || true
    rm -f "${CONTROL_PLANE_PID_FILE}"
  fi
}

voice_runtime_health_json() {
  bash "${SCRIPT_DIR}/voice_runtime.sh" health
}

status_control_plane_json() {
  local status="stopped"
  local pid="null"
  local available="true"
  local status_detail=""
  local install_mode="development"

  if [[ ! -d "${CONTROL_PLANE_DIR}" ]]; then
    available="false"
    status="unavailable"
    status_detail="servico disponivel apenas no ambiente de desenvolvimento"
    install_mode="bundled-app"
  fi

  if service_running "${CONTROL_PLANE_PID_FILE}"; then
    status="running"
    pid="$(cat "${CONTROL_PLANE_PID_FILE}")"
  fi
  cat <<EOF
{"id":"control-plane","name":"Control Plane","kind":"process","status":"${status}","pid":${pid},"host":"${CONTROL_PLANE_HOST}","port":${CONTROL_PLANE_PORT},"log_path":"${LOG_DIR}/control-plane.log","available":${available},"status_detail":"${status_detail}","install_mode":"${install_mode}"}
EOF
}

status_services_json() {
  local runtime_json
  runtime_json="$(voice_runtime_health_json)"
  local sidecar_status="degraded"
  if echo "${runtime_json}" | grep -q '"ready": true'; then
    sidecar_status="ready"
  fi

  cat <<EOF
{"services":[
{"id":"voice-runtime","name":"Voice Runtime","kind":"bootstrap","status":"${sidecar_status}","runtime_health":${runtime_json},"managed_on_launch":true,"managed_on_exit":false},
{"id":"voice-sidecar-cli","name":"Voice Sidecar CLI","kind":"on-demand","status":"${sidecar_status}","script":"${SCRIPT_DIR}/voice_runtime.sh","managed_on_launch":true,"managed_on_exit":false},
$(status_control_plane_json | python3 -c 'import json,sys; item=json.load(sys.stdin); item["managed_on_launch"]=False; item["managed_on_exit"]=True; print(json.dumps(item, separators=(",", ":")))')
]}
EOF
}

start_all() {
  bash "${SCRIPT_DIR}/bootstrap_voice_runtime.sh" >/dev/null
  status_services_json
}

stop_all() {
  stop_control_plane
  status_services_json
}

case "${1:-}" in
  start-all)
    start_all
    ;;
  stop-all)
    stop_all
    ;;
  status-all)
    status_services_json
    ;;
  start)
    case "${2:-}" in
      control-plane)
        start_control_plane
        status_control_plane_json
        ;;
      voice-runtime|voice-sidecar-cli)
        bash "${SCRIPT_DIR}/bootstrap_voice_runtime.sh" >/dev/null
        status_services_json
        ;;
      *)
        echo "uso: bash scripts/voitran_services.sh start {control-plane|voice-runtime|voice-sidecar-cli}" >&2
        exit 1
        ;;
    esac
    ;;
  stop)
    case "${2:-}" in
      control-plane)
        stop_control_plane
        status_control_plane_json
        ;;
      voice-runtime|voice-sidecar-cli)
        status_services_json
        ;;
      *)
        echo "uso: bash scripts/voitran_services.sh stop {control-plane|voice-runtime|voice-sidecar-cli}" >&2
        exit 1
        ;;
    esac
    ;;
  *)
    echo "uso: bash scripts/voitran_services.sh {start-all|stop-all|status-all|start <service>|stop <service>}" >&2
    exit 1
    ;;
esac
