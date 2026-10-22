# Changelog

## [2026-10-22] — v1.7.0（实时关键词采集三件套上线，+3）

- **新增 3 个 Amazon 端点**（2026-10-22 全链路实测验证）：`KeywordSearchRealtimeRequest`（提交实时关键词搜索结果采集——任意关键词不限 ABA，支持批量；keyword 为**数组**且 mode/area/page 四参必填，area 与 mode 严格配对）/ `KeywordSearchRealtimeRequestStatusQuery`（任务状态列表，99=采集中、0=完成；queryDate/update 参数实测不过滤；轮询免费）/ `KeywordSearchRealtimeRequestCollection`（按 taskId 取结果，免费；完成后返回 13 元素紧凑元组：ASIN/图/标题/广告位标记/徽章/中文位次/位置标签/星级/评论数/最小单位价格/Prime）
- 站点矩阵实测：8 站可用（US/GB/DE/FR/CA/JP/ES/IT，同关键词监控矩阵）；domain 5 返回 401；积分异步扣减（提交/轮询/取数均 0 request，余额随任务执行递减，官方费率未公开——文档如实标注）
- `amazon-keyword-api.md`（12→15）新增 §5 三件套全参文档 + Notes 7 + Best Practices 6 工作流；SKILL.md 陷阱表补「keyword 数组+四参必填」行、Realtime 家族语义节纳入三件套；`_endpoints-index.md` 经 gen-index.sh 重生成
- 唯一端点数 133→136（Amazon 61→64）；trigger-eval 补 2 条实时采集用例（34 条）

## [2026-10-12] — v1.6.5（双站口径全仓清扫）

- doctor.sh 缺 profile 提示、SUPPORT.md（注册+取 Key）、decode.sh 694 充值指引、CONTRIBUTING.md 注释、_common.md 694 行×5——运行时提示与支持文档面的 open-intl 硬编码全部改为双站口径；README 断言同步软化为设计口径

## [2026-10-12] — v1.6.4（注册路径一致性修复）

- Step 3 取 Key、401 排障、两处代码注释的 open-intl 硬编码改为「以你注册的站点为准（open-intl 或 open）」——与 Step 2 双入口口径一致，消除大陆用户路径断裂
- 「两站通用」表述软化为设计口径（同一平台的同一 CLI 网关；Account-SK 取自任一站后台）

## [2026-10-12] — v1.6.3（大陆用户引导补全）

- 注册指引补大陆入口：open.sorftime.com（手机号/微信注册、人民币付费），与 open-intl（Google/PayPal）二选一，同一 CLI 网关通用——SKILL.md Onboarding 与 README Installation 同步
- npm 安装补国内镜像提示（--registry=https://registry.npmmirror.com）

## [2026-10-12] — v1.6.2（注记精确化）

- Reddit 搜索 Page 注记对齐实际验证范围（P1 实测；P2 未测）

## [2026-10-12] — v1.6.1（社媒文档勘误）

- social-api.md 响应格式表述修正（成功 PascalCase / 错误 camelCase，同 §6.2——原表述与实测字段矛盾）；SKILL.md 社媒行改两列结构修复渲染；§6.2 标题补 Social；搜索端点 Page 参数翻页实测补注（Reddit 可调；Quora 越界页空结果不扣费）；变更记录措辞对齐

## [2026-10-12] — v1.6.0（社媒端点上线：Reddit@801 + Quora@802，+6）

- **新增 6 个社媒端点**（2026-10-12 实测上线）：Reddit 三件套 `RedditPostSearch`/`RedditPostRequest`/`RedditCommentRequest`（domain=801）与 Quora 三件套 `QuoraQuestionSearch`/`QuoraQuestionRequest`/`QuoraAnswerRequest`（domain=802）——全部真数据验证（搜索 5 credits/详情 1 credit；RedditId 带 t3_ 前缀、QuoraId 纯数字；评论含 t1_/ParentCommentId 可重建讨论树）
- 新增 `resources/social-api.md`（参数表/计费/舆情选品工作流/相关性注记）；`_common.md` 域表补 5d 节（801/802；803-810 实测 404）
- v1.5.0 的「社媒走 MCP 通道」路标更新为双通道口径（CLI 已支持 + MCP 并行）
- 唯一端点数 127→133

## [2026-10-10] — v1.5.0（社媒数据路标）

- 新增「社媒舆情走 MCP 通道」指引：Reddit/Quora 数据在 MCP 端点（mcp.sorftime.com/social），CLI 网关暂无对应端点（全命名空间探测确认），避免用户在 CLI 侧找不到社媒能力

## [2026-10-10] — v1.4.5（发布说明修订）

- 发布说明表述修订；技能内容不变

## [2026-10-10] — v1.4.4（发布包精简）

- 发布包不再包含仓库维护文档（面向仓库维护者，与技能使用无关）

## [2026-10-10] — v1.4.2（计数残留清理）

- tiktok-api.md 域说明行计数修正（17→21）；§6 Account 前补节分隔线；SKILL.md gen-index 描述行计数更新（117→127）；表格排版统一

## [2026-10-10] — v1.4.1（正文清单计数同步）

- SKILL.md 正文清单与目录树同步 v1.4.0 计数口径（amazon-product 18→22 并补 4 个新端点名；TikTok 17→21 并补 4 个新端点名；目录树 walmart 17→19 一并修正）；README 概览行 119/57/17→127/61/21
- tiktok-api.md：§5 标题扩展为 Video & Brand、5.4 补「仅 301 站点实测、其他站点未测」注记；amazon-product-api.md §7 前分隔线去重

## [2026-10-10] — v1.4.0（server sync: +8 endpoints, live sweep 127）

- **Live sweep 2026-10-10**: all 74 previously-documented endpoint names re-verified alive (zero removals) with the documented `--domain` routing; full probe across Amazon/Shopee/Walmart/1688/Temu/TikTok domains.
- **Amazon +4**: `SellerSearch` / `SellerSearchFromName` (mirror the MCP `seller_search` family — exist on the gateway, test account returns `Code 694` package-not-enabled), `SellerRequest` / `BrandRequest` (exist; `Code 10` on `{}`/Name/BrandName/SellerName guesses — required key likely ID-style, TBD from official docs; BrandRequest routes on Amazon domain only, 404 on 301/201/701/21).
- **TikTok +4**: by-name search family — `AuthorSearchFromName` / `BrandSearchFromName` / `VideoSearchFromName` (verified with real data: `{"Name","QueryType":1}`, 2 credits; returns AuthorId/AuthorName, BrandName/Photo, VideoId/VideoTitle), `ShopSearchFromName` (exists, `Code 694`).
- **Not on CLI (MCP-only, verified absent)**: low-price-mall category search, ProductContent, Quora trio, Reddit trio, CommonUsageQuery — CLI quota stays on `CoinQuery`.
- Docs: new sections in `resources/amazon-product-api.md` (§7 Seller & Brand) and `resources/tiktok-api.md` (§3.2/§4.2/§5.3/§5.4); `_endpoints-index.md` regenerated (sum 142, unique 127).

All notable changes to Sorftime Data CLI Skill.

---

## [2026-08-25] — v1.3.2 (image-search parameter fix)

### Fixed
- **Amazon `SimilarProductRealtimeRequest` parameter updated**: the API now takes an image **URL** (`imageUrl`, publicly accessible, max 1MB), not a Base64-encoded image. Examples and the parameter table corrected.
- Image-search site list corrected to 8 sites (US/GB/DE/FR/IN/JP/ES/IT); submit consumes 0 requests — result queries via `SimilarProductRealtimeRequestCollection` consume 5 credits (6 on JP).

---

## [2026-08-24] — v1.3.1 (119 endpoints: Walmart additions & docs fixes)

### Added
- **Walmart `CategorySearchFromName`** — search categories by name, returns `NodeId` (underscore NodePath format, feeds `CategoryRequest`) + `CategoryName`; 1 request/call.
- **Walmart `ProductSearchFromName`** — search products by name (`{"Name":"led tv"}`), up to ~100 matches per call with full ProductObject fields; 2 requests/call.
- Onboarding troubleshooting: a configured key returning **401** is usually an MCP key, not an Account-SK — re-add the profile with the Account-SK from the open-intl dashboard.

### Fixed
- Endpoint-name casing: gateway routing is case-insensitive (the docs previously claimed case-sensitivity). Names containing `_` return 404.
- Error `694` can also mean "API not activated on your account", not only insufficient credits (all 5 platform error tables updated).
- **Amazon `AlexaQuestionsQuery` marked deprecated** — prefer `AlexaQuestionsCollectionResultQuery`.
- Endpoint count updated 117 → **119** across SKILL.md, resource headers and the auto-generated index.

---

## [2026-08-07] — v1.2.3 (full-interface live verification pass)

### Verified (live API calls, 52 endpoints)
- Ran every directly-queryable endpoint from the resource docs (52 of 117; the rest require prior subscription/task registration): **40 Code=0, 8 Code=11 (no data — correct params), 4 business responses, 0 parameter errors**. Every endpoint in the docs accepts its documented parameters.
- Notable business responses (all correct): `ProductRealtimeRequest` → 99 (collection in progress, task created); `ProductAssistant` → -1 "product sales too low for AI interpretation"; `BestSellerListDelete` → -1 (deleting a non-existent subscription); `ASINKeywordRanking` → 23 (sample date exceeded the 2-year window).

### Fixed
- **Sample dates exceeded the 2-year data limit**: 16 example dates across 7 resource files (account, amazon-category, amazon-keyword, amazon-monitoring, amazon-product, use-cases, walmart) were pinned to 2024 — the API rejects data older than 2 years (Code 23). Rolled all examples forward to 2025 and re-verified (`ASINKeywordRanking` now Code=0). Also fixed an invalid `2025-02-29` (non-leap year) → `2025-02-28`.

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
- **SKILL.md Quickstart example returned Code=10**: `{"asinList":["B0X"]}` is invalid — the correct form is `{"asin":"B0X"}` (comma-separated for batches). Fixed.
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
