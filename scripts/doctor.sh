#!/usr/bin/env bash
# scripts/doctor.sh — Environment self-check for the Sorftime CLI
#
# One command answers: is everything installed and configured?
# Errors drive onboarding: if a check fails, the message tells the user
# exactly what to do next (install / add profile / verify balance).
#
# Usage: bash scripts/doctor.sh [--connect]
#   --connect  additionally runs a live API call (CategoryTree, domain 1)
# Exit codes: 0=all checks passed / 1=at least one check failed

set -uo pipefail
cd "$(dirname "$0")/.."

# shellcheck source=scripts/_lib.sh
source scripts/_lib.sh

CONNECT=0
[ "${1:-}" = "--connect" ] && CONNECT=1

fail=0

check() {  # check <name> <status> <hint>
  if [ "$2" -eq 0 ]; then
    log_info "✅ $1"
  else
    log_error "❌ $1"
    [ -n "${3:-}" ] && log_warn "   → $3"
    fail=1
  fi
}

log_info "=== Sorftime CLI doctor ==="

# 1. Node / npm
node --version >/dev/null 2>&1
check "node installed ($(node --version 2>/dev/null || echo missing))" $? \
  "Install: https://nodejs.org (v16+)"
npm --version >/dev/null 2>&1
check "npm installed ($(npm --version 2>/dev/null || echo missing))" $? "Ships with Node.js"

# 2. sorftime CLI
if command -v sorftime >/dev/null 2>&1; then
  ver=$(sorftime --version 2>/dev/null || echo "?")
  check "sorftime CLI installed (v${ver})" 0
else
  check "sorftime CLI installed" 1 \
    "Run: npm install -g sorftime-cli  (then: sorftime add <profile> <api-key>)  — no account? register at open-intl.sorftime.com"
fi

# 3. jq (optional)
if command -v jq >/dev/null 2>&1; then
  log_info "✅ jq installed ($(jq --version))"
else
  log_warn "⚠️ jq not installed (optional — pure-CLI JSON processing is limited; scripts fall back to python3)"
fi

# 4. Profiles
if command -v sorftime >/dev/null 2>&1; then
  profiles=$(sorftime list 2>&1)
  if echo "$profiles" | grep -q "当前活跃\|active\|→"; then
    log_info "✅ Profile configured: $(echo "$profiles" | grep -o '→.*\|当前活跃 profile' | head -1)"
  else
    check "at least one profile configured" 1 \
      "Run: sorftime add <profile-name> <api-key>  (api-key from Sorftime dashboard (open-intl.sorftime.com))"
  fi
fi

# 5. Optional live connectivity test
if [ "$CONNECT" -eq 1 ] && command -v sorftime >/dev/null 2>&1; then
  log_info "--- Live connectivity test (CategoryTree, domain=1) ---"
  set +e
  raw=$(sorftime api CategoryTree '{"nodeId":"0"}' --domain 1 2>&1)
  rc=$?
  set -e
  # NOTE: use <<< here-string, not a pipe — pipefail + grep -q on large output
  # (CategoryTree ~10MB) makes grep close the pipe early and echo die with
  # SIGPIPE, so the pipeline exits non-zero and the match is lost.
  if [ $rc -eq 0 ] && grep -qE '"(Code|code)": ?0' <<< "$raw"; then
    log_info "✅ Live API call succeeded"
  else
    check "live API call" 1 \
      "Check network / proxy (Sorftime is direct-connect; disable VPN exit for CN traffic) and profile balance"
  fi
fi

echo ""
if [ "$fail" -eq 0 ]; then
  log_info "All checks passed."
else
  log_error "Some checks failed — fix the items above, then re-run doctor.sh"
fi
exit "$fail"
