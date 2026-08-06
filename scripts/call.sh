#!/usr/bin/env bash
# scripts/call.sh — Single-shot sorftime API call with output cleaning
#
# Purpose: Package "call + clean + error-flag" into a single command.
# Design goal: Replace the 5-segment bash pattern in docs/examples (`... 2>&1 | grep -v "^info:" | jq .`) with 1 line.
#
# Usage:
#   scripts/call.sh <Endpoint> '<json-params>' --domain <N> [--profile <name>] [--no-jq] [--raw] [--retries <N>]
#
# Examples:
#   scripts/call.sh ProductRequest '{"asin":"B0CVM8TXHP"}' --domain 1
#   scripts/call.sh CategoryRequest '{"nodeId":"7073960011"}' --domain 1 --no-jq
#   scripts/call.sh ProductRequest '{"asin":"B0X"}' --domain 1 --profile myprofile --raw
#   scripts/call.sh SimilarProductRealtimeRequestCollection '{"taskId":"6994"}' --domain 1 --retries 2
#
# Exit codes:
#   0  — API code=0
#   2  — API code≠0 (business error; message written to stderr)
#   3  — Bad input (parameter parse failure / missing sorftime command)
#   4  — Network / CLI exception (command did not run, profile not found, etc.)
#
# Platform: POSIX bash 4+ (macOS / Linux / Windows Git Bash / WSL).

set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage: scripts/call.sh <Endpoint> '<json-params>' --domain <N> [options]

Required:
  <Endpoint>           PascalCase endpoint name (e.g. ProductRequest, CategoryRequest)
  '<json-params>'      JSON string wrapped in single quotes; pass '' for no parameters
  --domain <N>         Site code (1=Amazon US, 21=Walmart, 201-208=Shopee, ...)

Options:
  --profile <name>     Profile name (omit to use the default selected by `sorftime use`)
  --no-jq              Do not pretty-print JSON (keep the raw compressed output)
  --raw                Do not process at all (do not filter `info:` lines, do not pretty-print)
  --retries <N>        Retry times for rate limit / network errors (default 1 = no retry)
  -h, --help           Show this help

Exit codes:
  0  API code=0 (success)
  2  API code≠0 (business error)
  3  Bad input
  4  Network / CLI exception
EOF
}

# ---------- 1. Parameter parsing ----------
ENDPOINT=""
JSON='{}'
DOMAIN=""
PROFILE=""
USE_JQ=1
RAW=0
RETRIES=1

if [ $# -eq 0 ]; then usage; exit 3; fi

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --domain)  DOMAIN="${2:-}"; shift 2 ;;
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --no-jq)   USE_JQ=0; shift ;;
    --raw)     RAW=1; USE_JQ=0; shift ;;
    --retries) RETRIES="${2:-1}"; shift 2 ;;
    --*)       echo "[call.sh] Unknown option: $1" >&2; usage; exit 3 ;;
    *)
      if [ -z "$ENDPOINT" ]; then ENDPOINT="$1"; shift
      elif [ "$JSON" = "{}" ]; then JSON="$1"; shift
      else echo "[call.sh] Unexpected positional parameter: $1" >&2; usage; exit 3
      fi
      ;;
  esac
done

# ---------- 2. Required validation ----------
if [ -z "$ENDPOINT" ]; then echo "[call.sh] Missing <Endpoint>" >&2; exit 3; fi
if [ -z "$DOMAIN" ];  then echo "[call.sh] Missing --domain <N>"   >&2; exit 3; fi

# Endpoint-name format validation: must be PascalCase (first letter uppercase, no spaces/hyphens, alphanumeric only)
if ! [[ "$ENDPOINT" =~ ^[A-Z][A-Za-z0-9]+$ ]]; then
  echo "[call.sh] Endpoint '$ENDPOINT' is not a valid PascalCase name (first letter must be uppercase; no spaces or hyphens)" >&2
  exit 3
fi

if ! command -v sorftime >/dev/null 2>&1; then
  echo "[call.sh] 'sorftime' command not found; please run: npm install -g sorftime-cli" >&2
  exit 4
fi

# ---------- 3. Assemble the command ----------
CMD=(sorftime api "$ENDPOINT" "$JSON" --domain "$DOMAIN")
if [ -n "$PROFILE" ]; then CMD+=(--profile "$PROFILE"); fi

# ---------- 4. Call + clean + retry ----------
attempt=0
last_stdout=""
last_stderr=""

while [ "$attempt" -lt "$RETRIES" ]; do
  attempt=$((attempt + 1))

  # Capture stdout / stderr; preserve the real return (no size limit)
  set +e
  RAW_OUT=$("${CMD[@]}" 2>&1)
  RAW_RC=$?
  set -e

  if [ $RAW_RC -ne 0 ]; then
    last_stdout="$RAW_OUT"
    last_stderr="[call.sh] Command exit code=$RAW_RC (not API code=0)"
    # Network / CLI exception → retry
    if [ "$attempt" -lt "$RETRIES" ]; then
      sleep $((attempt * 1))   # 1s, 2s, 3s, ...
      continue
    fi
    echo "$last_stderr" >&2
    echo "$last_stdout"  >&2
    exit 4
  fi

  # ---------- 5. Clean the output ----------
  if [ "$RAW" -eq 1 ]; then
    echo "$RAW_OUT"
    exit 0
  fi

  # Robust cleaning: the CLI progress lines have 4 prefix types
  #   info: ...
  #   - Calling API...
  #   ✔ Call successful (contains ANSI color codes)
  #   [32m...     (raw ANSI escape)
  # Take "from the first { or [ to the end" as the JSON block (regardless of any noise lines in between).
  JSON_BLOCK=$(echo "$RAW_OUT" | tr -d '\r' | awk 'BEGIN{n=0} {
    s=$0
    # Strip ANSI escape codes \033[...m
    gsub(/\033\[[0-9;]*[mK]/, "", s)
    if (n==0) {
      p=index(s, "{"); if (p==0) p=index(s, "[")
      if (p>0) { print substr(s, p); n=1; next }
    } else {
      print s
    }
  }')

  # No JSON found → output as plain text (fallback: CI / older CLI, etc.)
  if [ -z "$JSON_BLOCK" ]; then
    CLEAN=$(echo "$RAW_OUT" | grep -v '^info:' | grep -v '^[- ]' || true)
    echo "$CLEAN"
    exit 0
  fi

  CLEAN="$JSON_BLOCK"

  # Try to parse the code; not found or parse failed → output raw stdout (compat fallback)
  CODE=$(echo "$CLEAN" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    # PascalCase + camelCase compatible
    print(d.get('Code', d.get('code', '')))
except Exception:
    print('')
" 2>/dev/null || true)

  # Pretty-print
  if [ "$USE_JQ" -eq 1 ] && command -v jq >/dev/null 2>&1; then
    echo "$CLEAN" | jq . 2>/dev/null || echo "$CLEAN"
  else
    echo "$CLEAN"
  fi

  # ---------- 6. Business error handling ----------
  if [ -n "$CODE" ] && [ "$CODE" != "0" ]; then
    MSG=$(echo "$CLEAN" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    print(d.get('Message', d.get('message', '')))
except Exception:
    print('')
" 2>/dev/null || true)
    echo "[call.sh] $ENDPOINT business error code=$CODE message=$MSG" >&2
    exit 2
  fi

  exit 0
done
