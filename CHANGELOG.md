# Changelog

All notable changes to Sorftime CLI Skill.

---

## [2026-08-06] — v1.2.0

### Added
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
