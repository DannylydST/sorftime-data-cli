#!/usr/bin/env bash
# scripts/one.sh — Single-target status query (ASIN / Keyword / Category)
#
# Purpose: Package "call an endpoint + extract key fields" so the user can see key metrics in 1 line.
#
# Usage:
#   scripts/one.sh <Endpoint> <ID> [--domain N] [--json]
#
# Common ID formats:
#   ProductRequest        → ASIN            (B0CVM8TXHP / 1275613286 / 21584486278)
#   CategoryRequest       → NodeId          (7073960011)
#   ProductSearchFromName → Keyword          ("bluetooth earbuds")
#   KeywordRequest        → Keyword          ("power bank")
#
# Options:
#   --domain <N>     Site code (default 1=Amazon US)
#   --json           Output raw JSON (skip key field extraction)
#   -h, --help       Show help

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/_lib.sh"
# Make _pyq / py_field etc. available in subshells (one.sh calls them many times via pipe in case blocks)
export -f _pyq py_field py_length py_to_csv

# ---------- 1. Parameter parsing ----------
ENDPOINT=""
ID_RAW=""
DOMAIN=1
JSON_OUT=0

usage() {
  cat >&2 <<'EOF'
Usage: scripts/one.sh <Endpoint> <ID> [--domain N] [--json]

Common ID formats:
  ProductRequest        → ASIN            (B0CVM8TXHP / 1275613286 / 21584486278)
  CategoryRequest       → NodeId          (7073960011)
  ProductSearchFromName → Keyword          ("bluetooth earbuds")
  KeywordRequest        → Keyword          ("power bank")
  CategorySearchFromName → Keyword         ("kitchen")

Options:
  --domain <N>     Site code (default 1=Amazon US)
  --json           Output raw JSON (skip key field extraction)
  -h, --help       Show help
EOF
}

if [ $# -eq 0 ]; then usage; exit 3; fi
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --domain)  DOMAIN="${2:-}"; shift 2 ;;
    --json)    JSON_OUT=1; shift ;;
    --*)       echo "[one.sh] Unknown option: $1" >&2; usage; exit 3 ;;
    *)
      if [ -z "$ENDPOINT" ]; then ENDPOINT="$1"; shift
      elif [ -z "$ID_RAW" ]; then ID_RAW="$1"; shift
      else echo "[one.sh] Unexpected parameter: $1" >&2; usage; exit 3
      fi
      ;;
  esac
done

if [ -z "$ENDPOINT" ] || [ -z "$ID_RAW" ]; then
  echo "[one.sh] Missing <Endpoint> or <ID>" >&2; usage; exit 3
fi

# ---------- 2. Build JSON parameters ----------
build_json() {
  local ep="$1" id="$2" dom="$3"
  case "$ep" in
    ProductRequest)
      if [ "$dom" -ge 1 ] && [ "$dom" -le 14 ]; then
        printf '{"asin":"%s"}' "$id"
      else
        printf '{"ProductId":"%s"}' "$id"
      fi
      ;;
    ProductVariations|ProductCustomersSay|ProductReviewsQuery|ProductReviewsCollection|ProductReviewsCollectionStatusQuery|ProductTrendRequest|ASINRequestKeyword|AsinSalesVolume|AlexaQuestionsQuery)
      printf '{"asin":"%s"}' "$id"
      ;;
    CategoryRequest|CategoryProducts|CategoryTrend)
      printf '{"nodeId":"%s"}' "$id"
      ;;
    CategorySearchFromName|ProductSearchFromName|ProductSearch)
      printf '{"name":"%s"}' "$id"
      ;;
    KeywordRequest|KeywordSearchResults|KeywordExtends|KeywordSearchResultTrend)
      local encoded
      encoded=$(printf '%s' "$id" | sed 's/ /%20/g; s/+/%2B/g; s/&/%26/g; s/?/%3F/g')
      printf '{"keyword":"%s"}' "$encoded"
      ;;
    ShopRequest|ShopSearch)
      printf '{"ShopId":"%s"}' "$id"
      ;;
    ProductRequestKeyword)
      printf '{"ProductId":"%s","PageIndex":1,"PageSize":60}' "$id"
      ;;
    ASINKeywordRanking)
      echo "[one.sh] ASINKeywordRanking requires both keyword and ASIN; please use call.sh directly" >&2
      return 1
      ;;
    *)
      printf '{"asin":"%s"}' "$id"
      ;;
  esac
}

JSON=$(build_json "$ENDPOINT" "$ID_RAW" "$DOMAIN") || exit 3

# ---------- 3. Call the API ----------
RAW_JSON=$(call_api "$ENDPOINT" "$JSON" "$DOMAIN") || exit $?

# ---------- 4. Output ----------
if [ "$JSON_OUT" -eq 1 ]; then
  printf '%s' "$RAW_JSON" | python3 -m json.tool 2>/dev/null || printf '%s' "$RAW_JSON"
  exit 0
fi

# Smart extraction by endpoint — uses _pyq (python3 eval)
case "$ENDPOINT" in
  ProductRequest)
    DATA=$(printf '%s' "$RAW_JSON" | _pyq 'd.get("Data", d.get("data", {}))')
    [ -n "$DATA" ] && {
      echo "📦 $(printf '%s' "$DATA" | _pyq 'd.get("Title", "N/A")')"
      echo "💰 Selling price:    $(printf '%s' "$DATA" | _pyq 'd.get("SalesPrice", d.get("Price", "N/A"))')"
      echo "💰 List price (strikethrough):  $(printf '%s' "$DATA" | _pyq 'd.get("ListPrice", "N/A")')"
      echo "📊 Monthly sales:  $(printf '%s' "$DATA" | _pyq 'd.get("ListingSalesVolumeOfMonth", "N/A")')"
      echo "⭐ Rating:    $(printf '%s' "$DATA" | _pyq 'd.get("Ratings", "N/A")')"
      echo "💬 Review count:  $(printf '%s' "$DATA" | _pyq 'd.get("RatingsCount", "N/A")')"
      echo "🏷️ Brand:    $(printf '%s' "$DATA" | _pyq 'd.get("Brand", "N/A")')"
      echo "🏪 Buybox:  $(printf '%s' "$DATA" | _pyq 'd.get("BuyboxSeller", "N/A")')"
      echo "📦 FBA:     $(printf '%s' "$DATA" | _pyq '"yes" if d.get("IsFBA") else "no"')"
      echo "🔗 ASIN:    $(printf '%s' "$DATA" | _pyq 'd.get("ASIN", d.get("Asin", "N/A"))')"
      echo "📅 Listing date:    $(printf '%s' "$DATA" | _pyq 'd.get("OnlineDate", "N/A")')"
    }
    ;;
  KeywordRequest)
    DATA=$(printf '%s' "$RAW_JSON" | _pyq 'd.get("Data", d.get("data", {}))')
    [ -n "$DATA" ] && {
      echo "🔍 Keyword:    $(printf '%s' "$DATA" | _pyq 'd.get("Keyword", "N/A")')"
      echo "🔍 Chinese name:    $(printf '%s' "$DATA" | _pyq 'd.get("KeywordCNName", "N/A")')"
      echo "📅 Weekly search rank: $(printf '%s' "$DATA" | _pyq 'd.get("Rank", "N/A")')"
      echo "📈 Monthly search volume:  $(printf '%s' "$DATA" | _pyq 'd.get("SearchVolume", "N/A")')"
      echo "💵 CPC:       $(printf '%s' "$DATA" | _pyq 'd.get("Cpc", "N/A")')"
      echo "🏷️ Product count:    $(printf '%s' "$DATA" | _pyq 'd.get("ProductCount", "N/A")')"
      echo "🎯 90-day purchases: $(printf '%s' "$DATA" | _pyq 'd.get("ClickOf90D", "N/A")')"
      echo "🎯 90-day sales:  $(printf '%s' "$DATA" | _pyq 'd.get("SalesVolumeOf90D", "N/A")')"
      echo "🏆 Top 3 ASIN: $(printf '%s' "$DATA" | _pyq 'd.get("Top3asin", "N/A")')"
      echo "🏆 Top 3 brands: $(printf '%s' "$DATA" | _pyq 'd.get("Top3Brand", "N/A")')"
    }
    ;;
  CategoryRequest)
    SUBCAT=$(printf '%s' "$RAW_JSON" | _pyq 'd.get("Data", d.get("data", {})).get("SubCategory", "N/A")')
    COUNT=$(printf '%s' "$RAW_JSON" | _pyq 'len(d.get("Data", d.get("data", {})).get("Products", []))')
    echo "📂 Sub-category:    $SUBCAT"
    echo "📊 Product count:  $COUNT"
    echo "🥇 Top 5:"
    printf '%s' "$RAW_JSON" | _pyq '[f"  - {(p.get(\"Title\", p.get(\"ProductName\", \"N/A\"))[:80])} | ID: {p.get(\"ASIN\", p.get(\"ProductId\", \"N/A\"))}" for p in d.get("Data", d.get("data", {})).get("Products", [])[:5]]'
    ;;
  ProductSearchFromName|CategorySearchFromName)
    COUNT=$(printf '%s' "$RAW_JSON" | _pyq 'len(d.get("Data", d.get("data", [])))')
    echo "🔍 Found $COUNT results (first 5):"
    printf '%s' "$RAW_JSON" | _pyq '[f"  - {item.get(\"Title\", item.get(\"Name\", item.get(\"CategoryName\", \"N/A\")))}" for item in d.get("Data", d.get("data", []))[:5]]'
    ;;
  KeywordSearchResults)
    DATA=$(printf '%s' "$RAW_JSON" | _pyq 'd.get("Data", d.get("data", {}))')
    echo "📊 Total pages:   $(printf '%s' "$DATA" | _pyq 'd.get("PageCount", "N/A")')"
    echo "🥇 Top 5 organic positions:"
    printf '%s' "$RAW_JSON" | _pyq '[f"  - {(p.get(\"Title\", \"N/A\")[:80])} | ASIN: {p.get(\"ASIN\", \"N/A\")}" for p in d.get("Data", d.get("data", {})).get("Products", [])[:5]]'
    ;;
  *)
    # Unknown endpoint: output as-is (pretty-print)
    printf '%s' "$RAW_JSON" | python3 -m json.tool 2>/dev/null || printf '%s' "$RAW_JSON"
    ;;
esac
