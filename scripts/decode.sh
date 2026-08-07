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

# ---------- Error code dictionary (source: _common.md §7, per-platform tables) ----------
# One entry per code: "code|platforms|meaning|suggestion"
#   platforms: A=Amazon S=Shopee W=Walmart 1=1688 T=Temu K=TikTok
# NOTE: a single index array (not `declare -A`) — macOS ships bash 3.2, which
# has no associative arrays. Index arrays work on bash 3.2+ everywhere.
DICT=(
  "0|A S W 1 T K|Execution succeeded|No action needed"
  "4|A S W 1 T K|Insufficient credit balance|Top up credits or wait for next month's reset"
  "9|K|Resource access restricted|Check account permissions and IP whitelist"
  "10|A S W 1 T K|Request parameters error|Check endpoint parameter format, type, and required fields"
  "11|A S W 1 T|No data available|No data under this condition; try a real ID / wider time range"
  "12|A S W|Data already exists (duplicate submit)|No need to repeat the request"
  "13|A S W|First-page review data does not exist|Collect reviews first (reviews collection endpoint), then query"
  "14|A S W|ID count exceeded|A single request supports up to 100 IDs"
  "15|A S W|ID query count exceeded|A single request supports up to 10 IDs"
  "16|A S|Endpoint not supported|This endpoint is not supported on this site"
  "17|A S|Detail collection count exceeded|A single request supports up to 30 IDs for detail collection"
  "18|A S|Task detail query exceeded|A single request supports up to 20 task detail queries"
  "19|A S|Only sub-categories supported|Non-sub-category queries are not supported"
  "20|A S W|Real-time data is being calculated|Please retry later"
  "21|A S|Some IDs are being calculated|Some IDs still calculating; retry later"
  "22|A S|Only single-ID monitoring supported|Stock monitoring only supports a single ID"
  "23|A S|Data beyond two years not supported|Data older than two years is not supported"
  "24|A S|Monthly query not supported|Monthly historical queries are not supported"
  "-1|A S W 1 T|Execution failed|General error; see the message field for details"
  "97|A S W T|ID does not exist|Check whether the product ID (ASIN / ProductId) is correct"
  "98|A S W T|Collection failed|Retry later, or contact Sorftime support"
  "99|A S W T|Collecting (task in progress)|Real-time fetching takes ~5-15 min; poll with the status query endpoint"
  "106|A S|Subscription already exists|Query the current taskId from the task list"
  "400|A S W 1 T K|Unverified IP|Current IP is not in the whitelist"
  "401|A S W 1 T K|Endpoint not open|Check the endpoint name, and whether the plan includes it"
  "402|A S W T|No permission to view this data|Check account permissions"
  "500|A S W T K|Monthly request count limit reached|Wait for next month's reset or upgrade the plan"
  "501|A S W T K|Per-minute request limit reached|Lower frequency / add sleep 1+; retry in 1 minute"
  "502|A S W T|Daily request limit reached|Wait for next day's reset or upgrade the plan"
  "503|A S|Task registration failed|Task volume exceeded; try another time slot"
  "694|A S W T|Insufficient request remaining (credits exhausted)|Log in to open-intl.sorftime.com to check or top up request credits"
)

# ---------- Utility functions ----------
# Split "code|platforms|meaning|suggestion" into globals D_CODE/D_PLATFORM/D_MEANING/D_SUGGEST.
parse_entry() {
  local entry="$1" IFS='|'
  read -r D_CODE D_PLATFORM D_MEANING D_SUGGEST <<< "$entry"
}

# Find the dictionary entry for a code (string compare; -1 is a legal code here).
find_entry() {
  local code="$1" entry
  for entry in "${DICT[@]}"; do
    parse_entry "$entry"
    [ "$D_CODE" = "$code" ] && { echo "$entry"; return 0; }
  done
  return 1
}
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
  if entry=$(find_entry "$code"); then
    parse_entry "$entry"
    echo "📕 code=$code"
    echo "   Meaning:    $D_MEANING"
    echo "   Platform:    $D_PLATFORM  (A=Amazon S=Shopee W=Walmart 1=1688 T=Temu K=TikTok)"
    echo "   Suggestion:    $D_SUGGEST"
  else
    echo "📕 code=$code"
    echo "   Meaning:    Unknown (not in the local dictionary; please check _common.md §7)"
    echo "   Suggestion:    Check _common.md §7 error code table"
  fi
}

# Map a platform name (full or abbreviation) to its single-letter code.
normalize_platform() {
  case "$1" in
    amazon|a) echo "A" ;;
    shopee|s) echo "S" ;;
    walmart|w) echo "W" ;;
    1688|one) echo "1" ;;
    temu|t) echo "T" ;;
    tiktok|k) echo "K" ;;
    *) echo "" ;;
  esac
}

print_list() {
  local filter="${1:-all}" entry norm
  norm=$(normalize_platform "$filter")
  echo "📕 All known error codes (${#DICT[@]} in total):"
  for entry in "${DICT[@]}"; do
    parse_entry "$entry"
    if [ "$filter" = "all" ] || [[ " $D_PLATFORM " == *" $norm "* ]]; then
      printf "  %-5s  %s  [%s]\n" "$D_CODE" "$D_MEANING" "$D_PLATFORM"
    fi
  done
}

# ---------- Main logic ----------
if [ $# -eq 0 ]; then usage; exit 3; fi

PLATFORM_FILTER="all"
LIST=0
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --list) LIST=1; shift ;;
    --platform) PLATFORM_FILTER="${2:-all}"; shift 2 ;;
    --*) echo "[decode.sh] Unknown option: $1" >&2; usage; exit 3 ;;
    *) CODE="$1"; shift ;;
  esac
done

if [ "$LIST" -eq 1 ] || [ "$PLATFORM_FILTER" != "all" ]; then
  print_list "$PLATFORM_FILTER"
  exit 0
fi

if [ -z "${CODE:-}" ]; then usage; exit 3; fi

if find_entry "$CODE" > /dev/null; then
  print_code "$CODE"
  exit 0
else
  echo "[decode.sh] code=$CODE not in the local dictionary"
  echo "💡 Suggestion: grep '_common.md' §7 error code table or the sorftime-cli-check report"
  exit 0
fi
