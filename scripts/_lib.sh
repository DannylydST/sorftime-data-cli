#!/usr/bin/env bash
# scripts/_lib.sh — Shared library for sorftime scripts
#
# Provides:
#   call_api <Endpoint> '<json>' <Domain> [Profile]
#     Single-shot call. stdout writes the JSON string; stderr writes diagnostics.
#     Exit code: 0=success / 2=business error / 3=bad input / 4=CLI/network error
#
#   log_info / log_warn / log_error
#     Timestamped log output to stderr
#
#   require_cmd <cmd>
#     Validate that a command exists
#
#   _pyq '<python-expr>'  (reads JSON from stdin)
#     Lightweight JSON field extractor (python3 eval, no jq dependency)
#
#   py_field '<json>' '<dotted.path>'
#     Return the value at a dotted path
#
#   py_length '<json>' '<dotted.path>'
#     Return the length of an array/object
#
#   py_to_csv '<json>' '<dotted.path>' '<field1>,<field2>,...'
#     Output as CSV (to stdout)
#
# Platform: POSIX bash 4+

set -euo pipefail

# ---------- Color (only enabled on tty) ----------
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  C_RED='\033[31m'; C_GREEN='\033[32m'; C_YELLOW='\033[33m'
  C_BLUE='\033[34m'; C_DIM='\033[2m'; C_RESET='\033[0m'
else
  C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''; C_DIM=''; C_RESET=''
fi

# ---------- Logging ----------
_ts() { date '+%Y-%m-%dT%H:%M:%S%z' 2>/dev/null || date '+%Y-%m-%d %H:%M:%S'; }
log_info()  { printf "${C_BLUE}[%s][info]${C_RESET} %s\n"  "$(_ts)" "$*" >&2; }
log_warn()  { printf "${C_YELLOW}[%s][warn]${C_RESET} %s\n" "$(_ts)" "$*" >&2; }
log_error() { printf "${C_RED}[%s][error]${C_RESET} %s\n" "$(_ts)" "$*" >&2; }

# ---------- Command validation ----------
require_cmd() {
  for c in "$@"; do
    if ! command -v "$c" >/dev/null 2>&1; then
      log_error "Missing command: $c"
      return 3
    fi
  done
}

# ---------- Single-shot call ----------
# Usage: call_api <Endpoint> '<json>' <Domain> [Profile]
# Output: stdout writes clean JSON (CLI progress lines + ANSI stripped); stderr writes logs
# Exit code: 0=code=0 / 2=business error / 4=CLI/network error
call_api() {
  local endpoint="$1" json="$2" domain="$3" profile="${4:-}"
  local args=(api "$endpoint" "$json" --domain "$domain")
  [ -n "$profile" ] && args+=(--profile "$profile")

  # Capture
  local raw rc
  set +e
  raw=$(sorftime "${args[@]}" 2>&1)
  rc=$?
  set -e

  if [ $rc -ne 0 ]; then
    log_error "$endpoint CLI exit code=$rc"
    echo "$raw" >&2
    return 4
  fi

  # Robust cleaning: CLI progress lines have 4 prefix types (info: / -  / ✔ / ANSI) → extract from the first { or [ to the end
  local clean
  clean=$(printf '%s' "$raw" | tr -d '\r' | awk 'BEGIN{n=0} {
    s=$0
    gsub(/\033\[[0-9;]*[mK]/, "", s)
    if (n==0) {
      p=index(s, "{"); if (p==0) p=index(s, "[")
      if (p>0) { print substr(s, p); n=1; next }
    } else {
      print s
    }
  }')

  if [ -z "$clean" ]; then
    log_warn "$endpoint returned no JSON"
    return 4
  fi

  # Write JSON to stdout
  printf '%s' "$clean"

  # Business-error check
  local code msg
  code=$(printf '%s' "$clean" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    print(d.get('Code', d.get('code', '')))
except: print('')
" 2>/dev/null || true)
  if [ -n "$code" ] && [ "$code" != "0" ]; then
    msg=$(printf '%s' "$clean" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    print(d.get('Message', d.get('message', '')))
except: print('')
" 2>/dev/null || true)
    log_warn "$endpoint business error code=$code message=$msg"
    return 2
  fi

  return 0
}

# ---------- Retry wrapper ----------
# Usage: call_api_retry <Endpoint> '<json>' <Domain> [Profile] [MaxRetries]
# Automatically retries on rate-limit / network errors with 1s/2s/3s ... backoff
call_api_retry() {
  local endpoint="$1" json="$2" domain="$3" profile="${4:-}" max_retries="${5:-3}"
  local attempt=0 rc
  while [ $attempt -lt "$max_retries" ]; do
    attempt=$((attempt + 1))
    set +e
    raw=$(call_api "$endpoint" "$json" "$domain" "$profile")
    rc=$?
    set -e

    if [ $rc -eq 0 ] || [ $rc -eq 2 ]; then
      printf '%s' "$raw"
      return $rc
    fi
    # rc=4 network error → retry
    if [ $attempt -lt "$max_retries" ]; then
      log_warn "$endpoint attempt $attempt/$max_retries failed (rc=$rc); retrying in ${attempt}s"
      sleep $attempt
    fi
  done
  log_error "$endpoint failed after $max_retries retries"
  return 4
}

# ---------- JSON extraction (python3 fallback, no jq required) ----------
# Usage: _pyq '<python-expr>'   ←  stdin is JSON
#   Example: echo "$json" | _pyq 'd["Data"]["Title"]'
#   Example: echo "$json" | _pyq 'd.get("Data", {}).get("Code", "")'
#   Example: echo "$json" | _pyq 'p["Title"] for p in d.get("Data", {}).get("Products", [])[:5]'
#
# Output: always keeps JSON shape (scalar via repr, list/dict via json.dumps), so it composes for nested calls
# Missing fields return None (no output)
_pyq() {
  local expr="$1"
  python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    expr = '''$expr'''
    # Expose common built-ins (len / str / int / float / bool / repr / sorted / set)
    safe_builtins = {
        'len': len, 'str': str, 'int': int, 'float': float,
        'bool': bool, 'repr': repr, 'sorted': sorted, 'set': set,
        'list': list, 'tuple': tuple, 'dict': dict, 'range': range,
        'min': min, 'max': max, 'sum': sum, 'abs': abs, 'round': round,
        'enumerate': enumerate, 'zip': zip, 'map': map, 'filter': filter,
    }
    out = eval(expr, {'__builtins__': safe_builtins}, {'d': d, 'p': d, 'env': __import__('os').environ})
    if out is None:
        pass
    elif isinstance(out, bool):
        print('true' if out else 'false')
    elif isinstance(out, (int, float, str)):
        print(out)
    elif isinstance(out, (list, tuple)):
        for item in out:
            print(json.dumps(item, ensure_ascii=False))
    elif isinstance(out, dict):
        print(json.dumps(out, ensure_ascii=False))
    else:
        print(json.dumps(out, ensure_ascii=False))
except Exception as e:
    sys.stderr.write(f'[pyq] {e}\n')
    sys.exit(1)
" 2>&1
}

# Usage: py_field '<json>' '<dotted.path>'   ←  returns the field value (multi-line or empty)
#   Example: py_field "$json" "Data.Code"
#   Example: py_field "$json" "Data.Products.0.Title"
py_field() {
  local json="$1" path="$2"
  local expr=""
  IFS='.' read -ra parts <<< "$path"
  for p in "${parts[@]}"; do
    if [[ "$p" =~ ^[0-9]+$ ]]; then
      expr="$expr[$p]"
    else
      expr="$expr[\"$p\"]"
    fi
  done
  printf '%s' "$json" | _pyq "d$expr"
}

# Usage: py_length '<json>' '<dotted.path>'   ←  returns array/object length
py_length() {
  local json="$1" path="$2"
  printf '%s' "$json" | _pyq "len($path)" 2>/dev/null
}

# Usage: py_to_csv '<json>' '<dotted.path>' '<field1>,<field2>,...'   ←  CSV format output
#   Example: echo "$json" | py_to_csv 'Data.Products' 'Title,ASIN,SalesPrice,Ratings'
py_to_csv() {
  local json="$1" path="$2" fields="$3"
  printf '%s' "$json" | python3 -c "
import sys, json, csv, io
d = json.loads(sys.stdin.read())
expr = '''$path'''
arr = eval(expr, {'__builtins__': {}}, {'d': d})
if not isinstance(arr, list): arr = [arr]
fields = '''$fields'''.split(',')
w = csv.writer(sys.stdout)
w.writerow(fields)
for item in arr:
    w.writerow([item.get(f, '') for f in fields])
"
}
