#!/usr/bin/env bash

set -euo pipefail

APP_NAME="${1:-test-secnum}"
DEPLOY_BRANCH="${DEPLOY_BRANCH:-main}"
MIN_WAIT_SECONDS="${MIN_WAIT_SECONDS:-30}"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-180}"
DEPLOY_COUNT="${DEPLOY_COUNT:-0}"
FOLLOW_DEPLOY="${FOLLOW_DEPLOY:-false}"
ITERATION=0

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log() {
  printf '[deploy-loop] %s\n' "$*"
}

random_wait() {
  local min_wait="$1"
  local max_wait="$2"

  if [ "${max_wait}" -lt "${min_wait}" ]; then
    log "invalid wait range: MIN_WAIT_SECONDS=${min_wait} MAX_WAIT_SECONDS=${max_wait}"
    exit 1
  fi

  echo $((min_wait + RANDOM % (max_wait - min_wait + 1)))
}

run_deploy() {
  if [ "${FOLLOW_DEPLOY}" = "true" ]; then
    log "trigger_at=$(timestamp) app=${APP_NAME} branch=${DEPLOY_BRANCH} iteration=${ITERATION} command=scalingo -a ${APP_NAME} integration-link-manual-deploy --follow ${DEPLOY_BRANCH}"
    scalingo -a "${APP_NAME}" integration-link-manual-deploy --follow "${DEPLOY_BRANCH}"
  else
    log "trigger_at=$(timestamp) app=${APP_NAME} branch=${DEPLOY_BRANCH} iteration=${ITERATION} command=scalingo -a ${APP_NAME} integration-link-manual-deploy ${DEPLOY_BRANCH}"
    scalingo -a "${APP_NAME}" integration-link-manual-deploy "${DEPLOY_BRANCH}"
  fi
  log "completed_at=$(timestamp) app=${APP_NAME} branch=${DEPLOY_BRANCH} iteration=${ITERATION}"
}

if ! command -v scalingo >/dev/null 2>&1; then
  log "scalingo CLI is not installed or not available in PATH"
  exit 1
fi

log "starting deployment loop app=${APP_NAME} branch=${DEPLOY_BRANCH} min_wait=${MIN_WAIT_SECONDS}s max_wait=${MAX_WAIT_SECONDS}s deploy_count=${DEPLOY_COUNT} follow=${FOLLOW_DEPLOY}"

while true; do
  ITERATION=$((ITERATION + 1))
  wait_seconds="$(random_wait "${MIN_WAIT_SECONDS}" "${MAX_WAIT_SECONDS}")"
  log "iteration=${ITERATION} sleeping_for=${wait_seconds}s"
  sleep "${wait_seconds}"
  run_deploy

  if [ "${DEPLOY_COUNT}" -gt 0 ] && [ "${ITERATION}" -ge "${DEPLOY_COUNT}" ]; then
    break
  fi
done

log "deployment loop finished iterations=${ITERATION}"
