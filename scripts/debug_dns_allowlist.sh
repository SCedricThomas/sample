#!/usr/bin/env bash

set -euo pipefail

APP_NAME="${APP:-${SCALINGO_APP:-test-secnum}}"
CONTAINER_NAME="${CONTAINER:-unknown-container}"
PRIVATE_HOSTNAME="${SCALINGO_PRIVATE_HOSTNAME:-unknown-private-hostname}"
PRIVATE_NETWORK_ID="${SCALINGO_PRIVATE_NETWORK_ID:-unknown-private-network}"
REGION_NAME_VALUE="${REGION_NAME:-unknown-region}"
ALLOWLIST_FILE="${DNS_DEBUG_ALLOWLIST_FILE:-./dns-allowlist.txt}"
CLI_TABLE_FILE="${DNS_DEBUG_CLI_TABLE_FILE:-./private-networks-domain-names.txt}"
TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "${TMP_FILE}"
}

trap cleanup EXIT

log() {
  printf '[dns-debug] %s\n' "$*"
}

append_domains_from_env() {
  if [ -z "${DNS_DEBUG_DOMAINS:-}" ]; then
    return
  fi

  printf '%s\n' "${DNS_DEBUG_DOMAINS}" | tr ', ' '\n\n' >> "${TMP_FILE}"
}

append_domains_from_file() {
  if [ ! -f "${ALLOWLIST_FILE}" ]; then
    return
  fi

  cat "${ALLOWLIST_FILE}" >> "${TMP_FILE}"
}

append_domains_from_cli_table() {
  if [ ! -f "${CLI_TABLE_FILE}" ]; then
    return
  fi

  awk -F '│' '
    /^│/ {
      domain=$3
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", domain)
      if (domain != "" && domain != "DOMAIN NAME") {
        print domain
      }
    }
  ' "${CLI_TABLE_FILE}" >> "${TMP_FILE}"
}

load_domains() {
  append_domains_from_env
  append_domains_from_file
  append_domains_from_cli_table
  sed -i '/^[[:space:]]*#/d;/^[[:space:]]*$/d' "${TMP_FILE}"
}

print_resolver_context() {
  log "app=${APP_NAME} container=${CONTAINER_NAME} host=${HOSTNAME:-unknown-host} private_hostname=${PRIVATE_HOSTNAME} private_network_id=${PRIVATE_NETWORK_ID} region=${REGION_NAME_VALUE} started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  log "resolver_context begin"
  while IFS= read -r line; do
    log "resolv.conf ${line}"
  done < /etc/resolv.conf
  log "env PWD=${PWD:-unknown}"
  log "env PORT=${PORT:-unknown}"
  log "env STACK=${STACK:-unknown}"
  log "env CONTAINER_SIZE=${CONTAINER_SIZE:-unknown}"
  log "env CONTAINER_MEMORY=${CONTAINER_MEMORY:-unknown}"
  log "env CONTAINER_VERSION=${CONTAINER_VERSION:-unknown}"
  log "resolver_context end"
}

run_dig() {
  local domain="$1"

  if ! command -v dig >/dev/null 2>&1; then
    log "domain=${domain} dig=unavailable"
    return
  fi

  local dig_output
  dig_output="$(dig +time=2 +tries=1 +short "${domain}" A "${domain}" AAAA 2>&1 || true)"
  if [ -z "${dig_output}" ]; then
    log "domain=${domain} dig=no-answer"
    return
  fi

  while IFS= read -r line; do
    [ -n "${line}" ] && log "domain=${domain} dig ${line}"
  done <<EOF
${dig_output}
EOF
}

run_getent() {
  local domain="$1"

  if ! command -v getent >/dev/null 2>&1; then
    log "domain=${domain} getent=unavailable"
    return
  fi

  local getent_output
  getent_output="$(getent ahosts "${domain}" 2>&1 || true)"
  if [ -z "${getent_output}" ]; then
    log "domain=${domain} getent=no-answer"
    return
  fi

  while IFS= read -r line; do
    [ -n "${line}" ] && log "domain=${domain} getent ${line}"
  done <<EOF
${getent_output}
EOF
}

run_nslookup() {
  local domain="$1"

  if ! command -v nslookup >/dev/null 2>&1; then
    log "domain=${domain} nslookup=unavailable"
    return
  fi

  local nslookup_output
  nslookup_output="$(nslookup "${domain}" 2>&1 || true)"
  if [ -z "${nslookup_output}" ]; then
    log "domain=${domain} nslookup=no-answer"
    return
  fi

  while IFS= read -r line; do
    [ -n "${line}" ] && log "domain=${domain} nslookup ${line}"
  done <<EOF
${nslookup_output}
EOF
}

main() {
  load_domains
  print_resolver_context

  if [ ! -s "${TMP_FILE}" ]; then
    log "no domains configured. populate ${ALLOWLIST_FILE}, ${CLI_TABLE_FILE}, or DNS_DEBUG_DOMAINS"
    exit 1
  fi

  while IFS= read -r domain; do
    log "domain=${domain} probe=begin"
    run_dig "${domain}"
    run_getent "${domain}"
    run_nslookup "${domain}"
    log "domain=${domain} probe=end"
  done < "${TMP_FILE}"

  log "completed finished_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}

main "$@"
