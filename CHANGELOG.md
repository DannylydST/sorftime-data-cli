# Changelog

All notable changes to Sorftime Data CLI Skill.

---

## [2026-08-07] — v1.2.2 (description optimized via trigger-eval loop)

### Changed
- **Description rewritten via skill-creator trigger-eval loop** (5 iterations, 32-query eval set, 20 train / 12 holdout): semantic "Activate for..." structure replaces the keyword-list format. Train score improved 9/20 → 11/20; holdout tied at 5/12; zero false positives on all 14 negative samples. English-first per the overseas-market positioning, with a compact Chinese trigger line as secondary (查 Best Seller 榜单 / 批量查 ASIN / 查月销 / 跨平台对比价格 / 每天拉监控数据 / 部署定时任务). Negative rule added: "Don't use for general e-commerce strategy, translation, or analytics unrelated to Sorftime."

### Fixed (skill-creator tooling, reusable)
- `run_eval.py` stream-event parsing: now accepts both the legacy `stream_event` wrapper and the current top-level event format; no longer bails on non-Skill tool calls or early assistant messages without a matching tool_use; matches skill by both injected command name and real skill name.

---

## [2026-08-07] — v1.2.1 (full-chain audit pass)

### Fixed
- **decode.sh crash on macOS default bash**: it used associative arrays (`declare -A`), which the macOS-shipped bash 3.2 does not support — every call died with `bad array subscript`. Rewritten with plain index arrays; works on bash 3.2+ everywhere.
- **decode.sh dictionary stale & wrong**: only 9 common codes, and `694` was mislabeled "Rate limited" (it actually means **Insufficient request remaining — top up credits**, which misleads users into waiting instead of topping up). Now carries the full 31-code dictionary from `_common.md` §7 with per-platform availability (A/S/W/1/T/K) and `--platform` filtering that actually works.
- **batch.sh option parsing rewritten**: the old loop matched `$2`/`$3` instead of `$1`/`$2` — fragile, and malformed options were silently swallowed. Now a standard `shift`-driven parser with "needs a value" errors and a real `--help`.
- **SKILL.md Quickstart example returned Code=10**: `{"asinList":["B0X"]}` is invalid — the correct form is `{"asin":"B0X"}` (comma-separated for batches). Fixed, and verified live (Code=0).
- **SKILL.md jq field-name bug**: examples used `jq '.code'`, but the success response is PascalCase `Code` (errors are camelCase `code`) — `jq '.code'` returned null on every success. Now documented as `jq -r '.Code // .code'` with a verified note in Quickstart.
- **Wrong section references**: error-code pointers said `_common.md §6`; the table lives in §7. Fixed both SKILL.md occurrences.
- **Stale CLI output docs**: removed all `grep -v "^info:"` pipes from SKILL.md/README — CLI 1.0.0 writes clean JSON to stdout and progress lines to stderr, so the filters were redundant and misleading.

### Changed
- `_endpoints-index.md` now shows the real endpoint list per file (extracted from `**Endpoints in this file**` lines) instead of a `# ... (N endpoints)` placeholder.
- Added missing `**Endpoints in this file**` lines to amazon-monitoring-api.md and tiktok-api.md — all 12 resource files now carry one, and gen-index.sh prefers it.

### Verified (live API calls, 2026-08-07)
- 16-case cross-platform matrix, all 6 platforms: batch ASIN (comma form), AsinSalesVolume `queryDate`, ASINRequestKeyword (both casings accepted), CategoryRequestKeyword `Nodeid` (lowercase d), CoinStream casing per platform (Amazon `QueryDate` vs Shopee/Walmart/1688 `Querydate`), Walmart/Shopee/Temu/1688 `ProductId`, Temu `Name` (capital N), TikTok domain=301. All returned Code=0.
- Confirmed camelCase error responses (`code`/`message`) on 1688/Temu errors, matching `_common.md` §6.2.

---

## [2026-08-06] — v1.2.0

### Added
- **🧭 Positioning section — "Why Data CLI (vs the MCP Seller Agent)"**: README comparison table and SKILL.md routing guidance. The CLI is positioned as the raw data foundation (all 117 endpoints, raw JSON, scriptable, deterministic) vs the MCP agent's curated intelligence layer.
- **🚀 Onboarding Protocol**: Five-step closed loop (detect → register → get Account-SK → configure profile → verify & return to task), triggered by missing CLI / missing profile / auth errors. Registration points to [open-intl.sorftime.com](https://open-intl.sorftime.com) (Google sign-up, free trial credits).
- **🛠️ `batch.sh` — generic batch runner**: Loop any endpoint over an input file with rate limiting (`--sleep`), retries (`--retries`), resume (`--resume`), disk output (`--out`), and dry-run preview. The automation workhorse for the CLI-as-data-base story: no more hand-writing `while read` loops.
- **🩺 `doctor.sh` — environment self-check**: One command verifies node / npm / CLI version / profile / live connectivity (`--connect`), with install-and-configure hints on every failure. Drives onboarding: error message → next action.
- **📊 `gen-index.sh` + `_endpoints-index.md`**: Auto-generated endpoint count matrix from resource headers. Run after any resources update so the endpoint count never goes stale (no more manual "117 endpoints" claims drifting from the docs).
- **🗺️ Three-column Shortcut Map**: Every shortcut now states user intent → command → expected output, including batch.sh / doctor.sh / gen-index.sh entries.

### Changed
- **🌐 English-first international release**: Full documentation in English for global sellers. New 🔴 Language Rule — the skill replies in the user's language (English ↔ Chinese), never mixed.
- **🗣️ Bilingual trigger support**: Trigger words in English and Chinese (批量查 ASIN / 跟卖预警 / 跨平台对比 / 监控部署 / 达人分析...), plus an expanded trigger-eval set (32 queries: 18 should-trigger / 14 should-not-trigger).
- **📋 Parameter Naming Trap table**: 13 highest-frequency pitfalls — Walmart `NodePath` vs `nodeId`, Temu `Name` (capital N), `ASINRequestKeyword` all-caps params, `ScheduelId` (sic) spelling, CoinStream `Querydate`/`QueryDate` casing per platform, TikTok creator/video requires domain=301.
- **📝 Service Principles**: problem-first, plan-before-execute guidance for assistant replies.
- **🏷️ Frontmatter metadata**: `version` + `user-invocable` fields for version management.

### Fixed
- **Account/setup wording unified for international users**: All registration, Account-SK, and top-up references now point to the international platform (open-intl.sorftime.com) — no other platform entries appear anywhere in the docs.
- **Endpoint count**: 132 → 117 unique. CoinQuery/CoinStream/RequestStreamMonth are shared across Shopee/Walmart/1688/Temu/TikTok and now counted once.
- **Cross-reference links**: All internal resource links repaired (amazon-ai-api / amazon-alexa-api / amazon-product-api / amazon-category-api file naming).
- **Field alias gaps**: Added Walmart-specific fields, monitoring-series fields, common response fields, and casing-traps sections to `_field_aliases.md`.
- **Description length**: Brought under the 1,024-char platform limit (was 1,360).
- **Table of Contents**: Added TOC to all 12 reference files over 100 lines that lacked one (partial-read safety).

### Changed
- **Baseline**: Built on the official `sorftime-cli@1.0.0` npm release (Amazon 57 + Shopee 17 + Walmart 17 + 1688 9 + Temu 12 + TikTok 17).
- **SKILL.md**: Restructured with bilingual description, Language Rule, parameter trap table, service principles, and 3-column shortcut map.

---

## [2026-08-05] — v1.0.0

### Added
- Initial official release: English documentation, 4 helper scripts (`call.sh` / `one.sh` / `decode.sh` / `_lib.sh`), compatibility metadata, 21-query trigger eval set.
