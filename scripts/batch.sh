#!/usr/bin/env bash
# scripts/batch.sh — Generic batch runner for the Sorftime CLI
#
# The workhorse for the "CLI as automation base" story: loop an endpoint
# over an input list with rate limiting, retries, resume, and disk output —
# no need to write a while-read loop by hand every time.
#
# Usage:
#   bash scripts/batch.sh <Endpoint> <input-file> [options]
#
# Input file: one JSON params object per line, e.g.
#   {"asin":"B0CVM8TXHP"}
#   {"asin":"B0X1"}
# With --param <name>, each line may be a bare value (wrapped automatically):
#   B0CVM8TXHP
#
# Options:
#   --domain <N>     Platform domain (default: 1)
#   --profile <X>    Profile name (default: active profile)
#   --sleep <S>      Seconds between requests (default: 1, rate-limit guard)
#   --retries <R>    Retries per line on transient failure (default: 2)
#   --out <FILE>     Write one response JSON per line to FILE
#   --resume         Skip lines already completed (uses <out>.progress if set,
#                    else <input>.progress)
#   --dry-run        Print the commands without executing
#
# Exit codes: 0=all succeeded / 2=some failed / 3=bad input

set -uo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=scripts/_lib.sh
source scripts/_lib.sh

ENDPOINT="${1:-}"
INPUT="${2:-}"
[ -z "$ENDPOINT" ] && { log_error "usage: batch.sh <Endpoint> <input-file> [--domain N] [--profile X] [--sleep S] [--retries R] [--out FILE] [--resume] [--dry-run]"; exit 3; }
[ -f "$INPUT" ] || { log_error "input file not found: $INPUT"; exit 3; }

DOMAIN=1; PROFILE=""; SLEEP=1; RETRIES=2; OUT=""; RESUME=0; DRY=0; PARAM=""
while [ $# -gt 2 ]; do
  case "$2" in
    --domain) DOMAIN="$3"; shift 2 ;;
    --profile) PROFILE="$3"; shift 2 ;;
    --sleep) SLEEP="$3"; shift 2 ;;
    --retries) RETRIES="$3"; shift 2 ;;
    --out) OUT="$3"; shift 2 ;;
    --param) PARAM="$3"; shift 2 ;;
    --resume) RESUME=1; shift ;;
    --dry-run) DRY=1; shift ;;
    *) shift ;;
  esac
done

[ -n "$OUT" ] && : > "$OUT"
PROGRESS="${OUT:-$INPUT}.progress"
START=1
if [ "$RESUME" -eq 1 ] && [ -f "$PROGRESS" ]; then
  START=$(($(wc -l < "$PROGRESS") + 1))
  log_info "resuming from line $START (progress: $PROGRESS)"
fi

ok=0; bad=0; total=0
while IFS= read -r line || [ -n "$line" ]; do
  total=$((total + 1))
  [ "$total" -lt "$START" ] && continue
  line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  [ -z "$line" ] && continue
  if [ -n "$PARAM" ]; then
    json="{\"$PARAM\":\"$line\"}"
  else
    json="$line"
  fi

  if [ "$DRY" -eq 1 ]; then
    log_info "[$total] sorftime api $ENDPOINT '$json' --domain $DOMAIN ${PROFILE:+--profile $PROFILE}"
    ok=$((ok + 1))
    continue
  fi

  attempt=0; rc=1
  while [ "$attempt" -le "$RETRIES" ]; do
    set +e
    resp=$(call_api "$ENDPOINT" "$json" "$DOMAIN" "$PROFILE" 2>/dev/null)
    rc=$?
    set -e
    [ $rc -eq 0 ] && break
    attempt=$((attempt + 1))
    [ $attempt -le "$RETRIES" ] && { log_warn "[$total] retry $attempt/$RETRIES (rc=$rc)"; sleep "$SLEEP"; }
  done

  if [ $rc -eq 0 ]; then
    ok=$((ok + 1))
    [ -n "$OUT" ] && echo "$resp" >> "$OUT"
    [ -n "$PROGRESS" ] && echo "$line" >> "$PROGRESS"
  else
    bad=$((bad + 1))
    log_error "[$total] FAILED line: $line (rc=$rc)"
  fi
  sleep "$SLEEP"
done < "$INPUT"

log_info "batch done: $ok ok / $bad failed / $total lines"
[ "$bad" -gt 0 ] && exit 2
exit 0
