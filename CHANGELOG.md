# Changelog

All notable changes to Sorftime CLI Skill.

---

## [2026-08-06]

### Added
- **🌐 English-first international release**: Full documentation in English for global sellers. New 🔴 Language Rule — the skill replies in the user's language (English ↔ Chinese), never mixed.
- **🗣️ Bilingual trigger support**: Trigger words in English and Chinese (批量查 ASIN / 跟卖预警 / 跨平台对比 / 监控部署 / 达人分析...), plus an expanded trigger-eval set (32 queries: 18 should-trigger / 14 should-not-trigger) covering both languages.
- **📋 Parameter Naming Trap table**: 13 highest-frequency pitfalls — Walmart `NodePath` vs `nodeId`, Temu `Name` (capital N), `ASINRequestKeyword` all-caps params, `ScheduelId` (sic) spelling, CoinStream `Querydate`/`QueryDate` casing per platform, TikTok creator/video requires domain=301.
- **📝 Service Principles**: problem-first, plan-before-execute guidance for assistant replies.
- **🏷️ Frontmatter metadata**: `version` + `user-invocable` fields for version management.

### Fixed
- **Endpoint count**: 132 → 117 unique. CoinQuery/CoinStream/RequestStreamMonth are shared across Shopee/Walmart/1688/Temu/TikTok and now counted once.
- **Cross-reference links**: All internal resource links repaired (amazon-ai-api / amazon-alexa-api / amazon-product-api / amazon-category-api file naming).
- **Field alias gaps**: Added Walmart-specific fields, monitoring-series fields, common response fields, and casing-traps sections to `_field_aliases.md`.

### Changed
- **Baseline**: Built on the official `sorftime-cli@1.0.0` npm release (Amazon 57 + Shopee 17 + Walmart 17 + 1688 9 + Temu 12 + TikTok 17).
- **SKILL.md**: Restructured with bilingual description, Language Rule, parameter trap table, and service principles.

---

## [2026-08-05]

### Added
- Initial official release: English documentation, 4 helper scripts (`call.sh` / `one.sh` / `decode.sh` / `_lib.sh`), compatibility metadata, 21-query trigger eval set.
