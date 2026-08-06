#!/usr/bin/env bash
# scripts/decode.sh — Error code dictionary query (no API call)
#
# Purpose: When the user calls an API and sees code=X, they can run `decode X` to see the meaning and troubleshooting steps,
#          without having to look through _common.md §7 error code table.
#
# Usage:
#   scripts/decode.sh <code>          # Query a single code
#   scripts/decode.sh --list          # List all known codes
#   scripts/decode.sh --platform X    # Filter by platform (amazon/shopee/walmart/temu/tiktok/1688/all)
#   scripts/decode.sh -h | --help
#
# Examples:
#   scripts/decode.sh 10
#   scripts/decode.sh 11
#   scripts/decode.sh 106
#   scripts/decode.sh -1
#   scripts/decode.sh --list
#   scripts/decode.sh --platform amazon
#
# Platform: POSIX bash 4+ (macOS / Linux / Windows Git Bash / WSL).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_lib.sh"

# ---------- Error code dictionary (source: sorftime-cli-check verification + _common.md §7) ----------
# Format: code|platform|meaning|suggestion
#   platform: Common / Amazon / Shopee / Walmart / 1688 / Temu / TikTok
declare -A ERR_MEANING=(
  ["0"]="Success"
  ["-1"]="Business preconditions not met / execution failed"
  ["10"]="Invalid request parameter (wrong input type/format)"
  ["11"]="No data available (business empty data)"
  ["99"]="Task processing (in progress)"
  ["106"]="Data already exists (business deduplication)"
  ["500"]="Rate limited"
  ["501"]="Rate limited"
  ["694"]="Rate limited"
)
declare -A ERR_PLATFORM=(
  ["0"]="Common"
  ["-1"]="Common"
  ["10"]="Common"
  ["11"]="Common"
  ["99"]="Common"
  ["106"]="Common"
  ["500"]="Common"
  ["501"]="Common"
  ["694"]="Common"
)
declare -A ERR_SUGGEST=(
  ["0"]="No action needed"
  ["-1"]="Check whether ASIN monthly sales is sufficient / whether taskId exists / whether input is valid"
  ["10"]="Check parameter type (int/string/JSON format); taskId should usually be an integer"
  ["11"]="Business empty data: try a real ID / time range; or task not completed (AIResult needs to wait for a real ProductAssistant taskId)"
  ["99"]="Task is running (5-15 minutes); poll with the status query endpoint"
  ["106"]="Subscription already exists: query the current taskId from the task list"
  ["500"]="Rate limit triggered: add sleep 1+ or lower concurrency; or change time slot"
  ["501"]="Rate limit triggered: same as 500"
  ["694"]="Rate limit triggered: same as 500"
)

# ---------- Utility functions ----------
usage() {
  cat >&2 <<'EOF'
Usage: scripts/decode.sh <code> [options]

Options:
  --list              List all known error codes
  --platform <name>   Filter by platform (amazon/shopee/walmart/temu/tiktok/1688/all)
  -h, --help          Show help
EOF
}

print_code() {
  local code="$1"
  local meaning="${ERR_MEANING[$code]:-Unknown (not in the _lib.sh dictionary; please check _common.md §7)}"
  local platform="${ERR_PLATFORM[$code]:-Common}"
  local suggest="${ERR_SUGGEST[$code]:-Check _common.md §7 error code table}"
  echo "📕 code=$code"
  echo "   Meaning:    $meaning"
  echo "   Platform:    $platform"
  echo "   Suggestion:    $suggest"
}

print_list() {
  local filter="${1:-all}"
  echo "📕 All known error codes (${#ERR_MEANING[@]} in total):"
  for code in "${!ERR_MEANING[@]}"; do
    if [ "$filter" = "all" ] || [ "${ERR_PLATFORM[$code]:-Common}" = "$filter" ]; then
      printf "  %-5s  %s  [%s]\n" "$code" "${ERR_MEANING[$code]}" "${ERR_PLATFORM[$code]:-Common}"
    fi
  done | sort -n
}

# ---------- Main logic ----------
if [ $# -eq 0 ]; then usage; exit 3; fi

PLATFORM_FILTER="all"
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --list) shift; print_list; exit 0 ;;
    --platform) PLATFORM_FILTER="${2:-all}"; shift 2 ;;
    --*) echo "[decode.sh] Unknown option: $1" >&2; usage; exit 3 ;;
    *) CODE="$1"; shift ;;
  esac
done

if [ -z "${CODE:-}" ]; then usage; exit 3; fi

if [ -n "${ERR_MEANING[$CODE]:-}" ]; then
  print_code "$CODE"
  exit 0
else
  echo "[decode.sh] code=$CODE not in the local dictionary"
  echo "💡 Suggestion: grep '_common.md' §7 error code table or the sorftime-cli-check report"
  exit 0
fi
