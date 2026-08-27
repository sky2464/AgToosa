#!/usr/bin/env bash
# Mock gh for GIP bats — records invocations to GH_MOCK_LOG; no network.
set -euo pipefail

LOG="${GH_MOCK_LOG:-/dev/null}"
printf 'gh %s\n' "$*" >>"$LOG"

_apply_jq() {
  local payload="$1" filter="$2"
  if [[ -n "$filter" ]]; then
    echo "$payload" | jq -r "$filter"
  else
    printf '%s' "$payload"
  fi
}

if [[ "${1:-}" == "api" ]]; then
  jq_filter=""
  create_milestone=false
  shift
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -f) [[ "${2:-}" == title=* ]] && create_milestone=true; shift 2 ;;
      --jq) jq_filter="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  if [[ "$create_milestone" == true ]]; then
    _apply_jq '{"number": 7}' "$jq_filter"
    exit 0
  fi
  _apply_jq "${GH_MOCK_MILESTONES_JSON:-[]}" "$jq_filter"
  exit 0
fi

if [[ "${1:-}" == "issue" ]]; then
  subcmd="${2:-}"
  shift 2 || true
  label=""
  jq_filter=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --label) label="$2"; shift 2 ;;
      --jq) jq_filter="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  case "$subcmd" in
    list)
      payload='[]'
      if [[ "$label" == "agtoosa:DEV-Alpha" ]]; then
        payload='[{"number": 42}]'
      elif [[ "$label" == "agtoosa:DEV-Gamma" ]]; then
        payload='[{"number": 55}]'
      fi
      _apply_jq "$payload" "$jq_filter"
      ;;
    create)
      _apply_jq '{"number": 1001}' "$jq_filter"
      ;;
    edit|close|reopen)
      exit 0
      ;;
    *)
      exit 0
      ;;
  esac
  exit 0
fi

exit 0
