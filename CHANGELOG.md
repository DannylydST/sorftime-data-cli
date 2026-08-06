# Changelog

All notable changes to the sorftime-cli skill are documented here.

## [2026-08-06] — v1.1.0 整合版

**Added**
- 🔴 Language Rule（强制）：跟随用户语言回复，英文→英文、中文→中文，永不混用
- 中英双语触发词：description 覆盖中英文场景，trigger-eval.json 扩展至 32 条（18 触发 / 14 负例，含中文条目）
- Parameter Naming Traps 表（13 条高频踩坑，来自 v2 经验）与 Service Principles
- `version: 1.1.0` + `user-invocable: true` frontmatter（对标 sorftime-seller-agent）

**Fixed**
- 7 处死链：amazon-product-api.md（2 处）、amazon-ai-api.md（2 处）、amazon-recipes.md（1 处）、amazon-data-types.md 的 `../20260720/` 死链、_field_aliases.md 的 `sf-field-find.py` 失效引用
- `_field_aliases.md` 回填 Walmart / Monitoring / Common response / Casing traps 4 小节
- 接口计数口径：132 → 117 unique（CoinQuery/CoinStream/RequestStreamMonth 重复计 6 次修正为 1 次）

**Changed**
- 基于产品部官方包 `sorftime-cli@1.0.0`（npm latest），废弃旧 0.1.x 文档声明
- 退役本机 4 个旧版本（98-endpoint 中文版 / intl / standalone / v2），历史备份于 `/Volumes/HIKSEMI/01-claude-code-backups/sorftime-cli-skill-20260806/`

---

## [1.0.0] — 产品部原包（2026-08-05）

产品部交付：英文版，117 unique endpoints（Amazon 57 + Shopee 17 + Walmart 17 + 1688 9 + Temu 12 + TikTok 17），4 个 bash 脚本（call/one/decode/_lib），compatibility frontmatter，trigger-eval 21 条。
