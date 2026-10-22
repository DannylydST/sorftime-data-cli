---
name: sorftime-data-cli
description: >
  Activate for tasks involving the actual Sorftime product-data platform or CLI: installing/configuring `sorftime-cli` and the API token/profile, calling `sorftime api` endpoints, writing bash/PowerShell loops over ASINs, keywords, or nodeIds, pulling Best Seller lists / monthly sales, comparing prices across Amazon, Shopee, Walmart, 1688, Temu, or TikTok, and setting up hijacker/keyword monitoring, realtime keyword search-result collection (live SERP snapshots for any keyword), or scheduled recurring pulls, Reddit/Quora social listening (posts, comments, Q&A mining). Also activate for Sorftime API support: choosing the right endpoint/parameter/field/type, and debugging invalid-parameter errors, non-zero error codes, or response issues.

  Trigger even when "Sorftime" isn't named if the user wants to look up, compare, monitor, or batch-query marketplace product data by ASIN/nodeId/keyword, or asks in Chinese (查 Best Seller 榜单, 批量查 ASIN, 查月销, 跨平台对比价格, 每天拉监控数据, 部署定时任务). Don't use for general e-commerce strategy, translation, or analytics unrelated to Sorftime.
compatibility:
  tools: [Bash, Read]
  dependencies: [node>=16, npm, jq (optional), sorftime-cli@1.0.0]
version: 1.7.0
user-invocable: true
---

# Sorftime Data CLI Skill

> Based on the npm package `sorftime-cli@1.0.0` (unified entry point `sorftime api <Endpoint> '<json>'`), covering 136 unique Sorftime data endpoints (Amazon 64 + Shopee 17 + Walmart 19 + 1688 9 + Temu 12 + TikTok 21 + Social 6; CoinQuery/CoinStream/RequestStreamMonth are shared across platforms and counted once; live-synced 2026-10-22).

---

## 🔴 Language Rule (Mandatory)

**Match the user's language. Always.** If the user writes in English → respond in English. If the user writes in Chinese → respond in Chinese. Never mix. This overrides everything else in this skill. The skill documentation is English by design (international-first); your *replies* follow the user's language.

---

## 🧭 Positioning: Data CLI vs MCP Agent

This skill is the **raw data foundation**: complete, scriptable, deterministic access to all Sorftime data endpoints. It is the sibling of the [Sorftime Seller Agent](https://github.com/DannylydST/sorftime-seller-agent) (MCP), which packages the same data as agent-friendly intelligence.

Route by what the user needs:

- **Data, scripts, automation, raw fields, custom workflows, monitoring pipelines** → THIS skill (`sorftime-data-cli`). Write the `sorftime api ...` calls / `batch.sh` / `doctor.sh` yourself.
- **One-shot marketplace intelligence** (product analysis, selection advice, competitor summaries, keyword strategy) delivered as a structured answer → the MCP-based **Sorftime Seller Agent** skill (if installed; otherwise note it exists).

Do not add analysis layers here — deliver the data, let the caller (or the Seller Agent skill) interpret it.

---

## 🧭 社媒舆情（Reddit / Quora）

CLI 已支持（2026-10-12 实测上线）：**Reddit 三件套 domain=801、Quora 三件套 domain=802**，完整参数/计费/串联键见 [`resources/social-api.md`](resources/social-api.md)。MCP 通道（`https://mcp.sorftime.com/social`）同能力并行可用，适合 agent 直连。

## CLI Quickstart (60 seconds)

```bash
# 1. Install
npm install -g sorftime-cli

# 2. Configure profile (Account-SK from your Sorftime dashboard — open-intl.sorftime.com or open.sorftime.com)
sorftime add myprofile <your-account-sk>
sorftime use myprofile

# 3. Call an endpoint
sorftime api ProductRequest '{"asin":"B08N5WRWNW"}' --domain 1 --profile myprofile

# 4. Common commands
sorftime list        # List all profiles
sorftime use myprofile   # Switch default profile
sorftime whoami      # View current profile
```

> **CLI output format**: `sorftime api` writes **clean JSON to stdout** — the progress banner (`- 正在调用API...`, `✔`) goes to stderr, so pipe stdout straight into `jq`. The status field is `Code` (PascalCase) on success and `code` (camelCase) on error: use `jq -r '.Code // .code'` to read it either way. Note: `{"asin":"B0X"}` returns Code=0, while `{"asinList":["B0X"]}` returns Code=10 (invalid parameter) — the field is `asin`, not `asinList`.

> **Field-naming warning**: Sorftime API field names are non-standard. Common pitfalls:
> - "price" → actual field is `SalesPrice`
> - "monthly sales" → actual field is `ListingSalesVolumeOfMonth`
> - "reviews" → actual field is `Ratings`
> - "seller" → actual field is `BuyboxSeller`
>
> When a field is missing, check `resources/_field_aliases.md` before assuming the API doesn't return it. Response shape and error codes are in [_common.md §6–§7](resources/_common.md).

---

## 🚀 Onboarding Protocol (Mandatory when setup is missing)

**Never leave the user stuck on "it doesn't work".** Any of these triggers the full onboarding flow below:

- `sorftime: command not found`
- `sorftime list` shows no active profile
- `sorftime api` returns auth errors (401 / "invalid token" / "no permission")
- The user says they don't have a Sorftime account or API key yet

### Step 1 — Detect
Run `bash scripts/doctor.sh` and identify exactly what's missing (CLI / profile / connectivity).

### Step 2 — Register (only if the user has no account)
→ **[open-intl.sorftime.com](https://open-intl.sorftime.com)** — sign up with Google, free trial credits included, PayPal for additional credits.

**Mainland-China users**: [open.sorftime.com](https://open.sorftime.com) is the more convenient entrance — phone-number (+86) or WeChat sign-up, CNY payment. Both sites are one platform built around the same CLI gateway; the Account-SK from either site's dashboard is what it accepts.

**npm slow in mainland China?** Use the npmmirror registry mirror:
```bash
npm install -g sorftime-cli --registry=https://registry.npmmirror.com
```

### Step 3 — Get the Account-SK
After registration, copy the Account-SK from the dashboard of **the site you registered on** ([open-intl.sorftime.com](https://open-intl.sorftime.com) or [open.sorftime.com](https://open.sorftime.com)) (account settings). Keep it private.

### Step 4 — Configure the profile

```bash
npm install -g sorftime-cli
sorftime add myprofile <your-account-sk>
sorftime use myprofile
```

### Step 5 — Verify, then return to the original task
Run `bash scripts/doctor.sh --connect` → all checks pass → **re-run the user's original request immediately**, without making them repeat it.

### Failure handling
- Registration blocked (region / network / payment)? → state what failed, ask how the user wants to proceed
- `doctor.sh` still failing after configure? → show the exact failing check and its fix hint (the script prints these)
- **401 with a key already configured** → the key is likely an **MCP key** (issued for Sorftime's MCP service), **not an Account-SK**. The two are different credentials: the CLI gateway (`cli.sorftime.com`) accepts only the Account-SK shown on the open-platform dashboard (whichever site you registered on — open-intl or open → API/CLI service page). Re-run `sorftime add <profile> <Account-SK>` with the right key.

---

## Sorftime Data CLI Recipes

Full recipes in [`resources/use-cases.md`](resources/use-cases.md) — organized as Basics / Product Selection / Operations / Research, each recipe = problem description + step-by-step commands + expected output.

---

## Progressive Discovery Path

### Level 0: Total beginner (5 minutes)
→ Read [README.md](README.md) for quickstart
→ `sorftime api CategoryTree --domain 1`
→ Verify: `sorftime whoami` shows profile and balance

### Level 1: I want to query a single data point
→ Use the daily-query shortcuts in [Shortcut Map](#shortcut-map-semantic-wrappers) below
→ `sorftime api ProductRequest '{"asin":"B0CVM8TXHP"}' --domain 1 | jq .`
→ Next: try KeywordRequest, CategoryRequest, AsinSalesVolume

### Level 2: I want to run a batch
→ Use a pure CLI loop with `sleep` to control rate
→ See "Batch Operations" section below
→ For large responses (e.g. CategoryTree), set a long timeout in your CLI client

### Level 3: I want to orchestrate multiple endpoints
→ Use the command chains from the "Operations / Research" sections of the recipe book
→ Troubleshooting in [_common.md §7 (error codes) + §8 (rate limits)](resources/_common.md)

---

## Environment Prerequisites

| Dependency | Required? | Description |
|------|--------|------|
| **Node.js + npm** | **Required** | The `sorftime-cli` itself is an npm package; all operations depend on it |
| **jq** | Optional | Process `sorftime api` JSON output for easier field extraction in CLI |

**Environment self-check (first use)**:

```bash
# Check Node / npm (required, all platforms)
node --version && npm --version

# Check jq (optional; for pure-CLI workflows)
jq --version || echo "⚠️ jq not installed; pure-CLI JSON processing is limited"
# Install:
#   macOS: brew install jq
#   Windows: https://jqlang.github.io/jq/download/
#   Linux: sudo apt install jq
```

**Windows users**:
- `sorftime api` works natively in Windows PowerShell / CMD with no restrictions.
- Cross-platform batching / workflows in PowerShell: use `while read` + `sleep` + `sorftime api`.

---

## Resources Directory Index (loaded on demand)

### Common References

| File | Contents |
|------|------|
| [`_common.md`](resources/_common.md) | Amazon/Shopee/Walmart/Temu/TikTok/1688 Domain table, complete error codes (per platform), common response structure, CLI call template, rate limit and concurrency constraints |
| [`_field_aliases.md`](resources/_field_aliases.md) | Field alias mapping table |
| [`account.md`](resources/account.md) | Cross-platform account management (3 endpoints): CoinQuery, CoinStream, RequestStreamMonth |
| [`social-api.md`](resources/social-api.md) | Social media sentiment (6 endpoints): RedditPostSearch, RedditPostRequest, RedditCommentRequest (domain=801); QuoraQuestionSearch, QuoraQuestionRequest, QuoraAnswerRequest (domain=802) |
| [`use-cases.md`](resources/use-cases.md) | Sorftime Data CLI recipes / use cases |

### Amazon (64 endpoints: 50 base + 14 monitoring)

| File | Count | Endpoints |
|------|--------|---------|
| [`amazon-category-api.md`](resources/amazon-category-api.md) | 7 | CategoryTree, CategoryRequest, CategoryProducts, CategoryTrend, CategorySearchFromName, CategoryAssistant, SimilarProductFeature |
| [`amazon-product-api.md`](resources/amazon-product-api.md) | 22 | All 22 endpoints: ProductRequest, ProductSearch, AsinSalesVolume, ProductVariations, ProductReviewsCollection, ProductReviewsCollectionStatusQuery, ProductReviewsQuery, ProductSearchFromName, ProductCustomersSay, ASINSubscription, ASINSubscriptionQuery, ASINSubscriptionCollection, ProductAssistant, ProductRealtimeRequest, ProductRealtimeRequestStatusQuery, SimilarProductRealtimeRequest, SimilarProductRealtimeRequestStatusQuery, SimilarProductRealtimeRequestCollection, SellerSearch, SellerSearchFromName, SellerRequest, BrandRequest |
| [`amazon-keyword-api.md`](resources/amazon-keyword-api.md) | 15 | KeywordQuery, KeywordSearchResults, KeywordRequest, KeywordSearchResultTrend, KeywordExtends, CategoryRequestKeyword, ASINRequestKeyword, KeywordProductRanking, ASINKeywordRanking, FavoriteKeyword, ChangeFavoriteKeyword, GetFavoriteKeyword, KeywordSearchRealtimeRequest, KeywordSearchRealtimeRequestStatusQuery, KeywordSearchRealtimeRequestCollection |
| [`amazon-alexa-api.md`](resources/amazon-alexa-api.md) | 4 | AlexaQuestionsCollection, AlexaQuestionsCollectionStatusQuery, AlexaQuestionsCollectionResultQuery, AlexaQuestionsQuery |
| [`amazon-ai-api.md`](resources/amazon-ai-api.md) | 2 | AIResultQuery, AIResult |
| [`amazon-monitoring-api.md`](resources/amazon-monitoring-api.md) | 14 | Common rules + all 14 endpoints: KeywordBatchSubscription, KeywordTasks, KeywordBatchTaskUpdate, KeywordBatchScheduleList, KeywordBatchScheduleDetail, BestSellerListSubscription, BestSellerListTask, BestSellerListDelete, BestSellerListDataCollect, ProductSellerSubscription, ProductSellerTasks, ProductSellerTaskUpdate, ProductSellerTaskScheduleList, ProductSellerTaskScheduleDetail |
| [`amazon-recipes.md`](resources/amazon-recipes.md) | — | **Multi-endpoint orchestration recipes**: product selection flow, competitor deep-dive, monitoring setup, trend tracking, cross-platform comparison. Core orchestration scenarios. |
| [`amazon-data-types.md`](resources/amazon-data-types.md) | — | Amazon data type definitions |

### Shopee (17 endpoints)

| File | Count | Endpoints |
|------|--------|---------|
| [`shopee-api.md`](resources/shopee-api.md) | 17 | CategoryTree, CategorySearchFromName, CategoryRequest, CategoryTrend, ProductRequest, ProductSearchFromName, ProductTrend, ProductSearch, ShopRequest, KeywordSearch, KeywordRelationResults, FavoriteKeyword, ChangeFavoriteKeyword, GetFavoriteKeyword, CoinQuery, CoinStream, RequestStreamMonth |
| [`shopee-data-types.md`](resources/shopee-data-types.md) | — | Shopee data type definitions |

### Walmart (19 endpoints)

| File | Count | Endpoints |
|------|--------|---------|
| [`walmart-api.md`](resources/walmart-api.md) | 19 | All 19 endpoints: CategoryTree, CategoryRequest, CategorySearchFromName, ProductRequest, ProductTrendRequest, ProductSearchFromName, ProductSalesVolume, CoinQuery, CoinStream, RequestStreamMonth, KeywordQuery, KeywordSearchFromName, KeywordSearchResults, KeywordRequest, ProductRequestKeyword, KeywordExtends, FavoriteKeyword, ChangeFavoriteKeyword, GetFavoriteKeyword |
| [`walmart-data-types.md`](resources/walmart-data-types.md) | — | Walmart data type definitions |

### 1688 (9 endpoints)

| File | Count | Endpoints |
|------|--------|---------|
| [`1688-api.md`](resources/1688-api.md) | 9 | ProductSearchFromName, CoinQuery, CoinStream, RequestStreamMonth, CategoryTree, ProductSearchFromImage, ProductRequest, ProductVariations, ProductSearch |

### Temu (12 endpoints)

| File | Count | Endpoints |
|------|--------|---------|
| [`temu-api.md`](resources/temu-api.md) | 12 | CategoryTree, CategoryRequest, CategorySearchFromName, CategorySearch, ProductRequest, ProductSearchFromName, ProductTrendRequest, ProductSearch, ShopRequest, CoinQuery, CoinStream, RequestStreamMonth |
| [`temu-data-types.md`](resources/temu-data-types.md) | — | Temu data type definitions |

### TikTok (21 endpoints)

| File | Count | Endpoints |
|------|--------|---------|
| [`tiktok-api.md`](resources/tiktok-api.md) | 21 | CategoryTree, CategoryRequest, CategorySearchFromName, CategorySearch, CategoryTrend, ProductRequest, ProductSearchFromName, ProductTrendRequest, ProductSearch, ShopSearch, ShopRequest, AuthorRequest, VideoRequest, VideoTagSearch, CoinQuery, CoinStream, RequestStreamMonth, ShopSearchFromName, AuthorSearchFromName, VideoSearchFromName, BrandSearchFromName |
| [`tiktok-data-types.md`](resources/tiktok-data-types.md) | — | TikTok data type definitions |

> **US only**: AuthorRequest, VideoRequest, VideoTagSearch are limited to the US site (domain=301).

---

## Shortcut Map (semantic wrappers)

Map user intent → command → expected output. If the intent matches, use the command as-is; adapt the values (ASIN / nodeId / keyword / date) to the task.

### Daily Query Shortcuts

| User intent | Command | Output |
|------|------|------|
| Query a single product | `sorftime api ProductRequest '{"asin":"B0X"}' --domain 1 \| jq .` | Full product JSON (price `SalesPrice`, monthly sales `ListingSalesVolumeOfMonth`, rating `Ratings`, buybox `BuyboxSeller`) |
| Query category Best Seller | `sorftime api CategoryRequest '{"nodeId":"3743561"}' --domain 1 \| jq '.data.list[0].asinList[:10]'` | Top-10 ASIN list for the node |
| Query ASIN variant sales | `sorftime api AsinSalesVolume '{"asin":"B0X","queryDate":"2026-01-01"}' --domain 1 \| jq .` | Daily sales per variant, one entry per date |
| Query keyword traffic | `sorftime api KeywordRequest '{"keyword":"water bottle"}' --domain 1 \| jq .` | Keyword volume/share/competition snapshot |
| Reverse-lookup keywords for ASIN | `sorftime api ASINRequestKeyword '{"asin":"B0X","pageSize":50}' --domain 1 \| jq .` | Ranked keyword list the ASIN ranks for |

### Batch Operations Shortcuts

> **First choice: `scripts/batch.sh`** — generic batch runner with rate limiting, retries, resume, and disk output. Only fall back to manual `while read` loops when you need per-line custom logic.

| User intent | Command | Output |
|------|------|------|
| Batch product base info | `bash scripts/batch.sh ProductRequest asins.txt --param asin --domain 1 --out products.jsonl` | One response JSON per line in `products.jsonl`; summary `N ok / M failed` |
| Batch variant sales | `bash scripts/batch.sh AsinSalesVolume asins.txt --param asin --domain 1 --out sales.jsonl` | Same, with `{"queryDate":"YYYY-MM-DD"}` JSON lines input for fixed-date queries |
| Batch reverse-lookup keywords | `bash scripts/batch.sh ASINRequestKeyword asins.txt --param asin --domain 1 --out kws.jsonl` | One keyword list per ASIN, line-aligned with input |
| Resume an interrupted batch | `bash scripts/batch.sh ProductRequest asins.txt --param asin --out products.jsonl --resume` | Skips lines already done (progress in `products.jsonl.progress`) |
| Dry-run preview before paying calls | `bash scripts/batch.sh ProductRequest asins.txt --param asin --dry-run` | Prints every command without executing |
| Paginate full category tree | `sorftime api CategoryTree '{"nodeId":"0"}' --domain 1 \| jq . > tree.json` then `jq` on demand | Local cache; see Large-data Persistence below |

### Debugging & Pre-flight Shortcuts

| User intent | Command | Output |
|------|------|------|
| Full environment self-check | `bash scripts/doctor.sh --connect` | ✅/❌ per check: node, npm, CLI version, profile, live API call |
| Preview a request (see raw return) | `sorftime api ProductRequest '{"asin":"B0X"}' --domain 1` | Raw JSON on stdout (progress lines go to stderr) |
| Check endpoint availability | `sorftime api ProductRequest '{"asin":"B0X"}' --domain 1 \| jq -r '.Code // .code'` | `0` = success; non-zero = error code (see `_common.md` §7) |
| Environment connectivity test | `sorftime api CategoryTree '{"nodeId":"0"}' --domain 1` | A return value means connected |
| Search field name | Look up `resources/_field_aliases.md` | Field → actual API name mapping |
| View actual fields returned by an endpoint | Call the endpoint and inspect the JSON; aliases in `resources/_field_aliases.md` | Live field list |

### Large-data Persistence

> **Core principle**: large payloads (category tree > 10KB) should be cached locally and queried on demand, not loaded in full.

**Manual caching tip**:
```bash
# First pull: save category tree to a local file
sorftime api CategoryTree --domain 1 | jq . > category-tree-us.json

# On-demand jq query of a specific node
cat category-tree-us.json | jq '.data[] | select(.NodeId=="3743561")'

# Refresh cache
sorftime api CategoryTree --domain 1 | jq . > category-tree-us.json
```

**When to use a cache vs calling the API directly**:
- Large response (> 10KB) and infrequently changing → use local cache
- Only need a specific node/entry → use jq query, don't read in full
- High real-time demand (price, sales) → call API directly, no cache
- Category tree is the best cache candidate: large, slow-changing, usually only a few nodes are needed

---

## Directory Structure

```
Skills/sorftime-cli/
├── SKILL.md                              # Main index + discovery path + endpoint catalog
├── README.md                             # Human quick reference
├── CHANGELOG.md                          # Version history
├── trigger-eval.json                     # Trigger evaluation queries (34, bilingual)
├── resources/
│   ├── _common.md                        # Common: Domain/error codes/CLI template/rate limits/troubleshooting
│   ├── _field_aliases.md                 # Field alias mapping
│   ├── _endpoints-index.md               # Auto-generated endpoint count matrix (run gen-index.sh to refresh)
│   ├── account.md                        # Cross-platform account management (3 endpoints)
│   ├── amazon-category-api.md                # Amazon category 7 endpoints
│   ├── amazon-data-types.md              # Amazon data type definitions
│   ├── amazon-product-api.md                 # Amazon product: 22 endpoints (core 13 + real-time 5 + seller/brand 4)
│   ├── amazon-keyword-api.md                 # Amazon keyword 15 endpoints (incl. realtime SERP collection trio)
│   ├── amazon-alexa-api.md                   # Amazon Alexa question collection/query 4 endpoints
│   ├── amazon-ai-api.md                      # Amazon AI interpretation 2 endpoints
│   ├── amazon-monitoring-api.md          # Amazon monitoring: common rules + 14 endpoints (keyword×5, bestseller×4, hijacker×5)
│   ├── amazon-recipes.md                 # Multi-endpoint orchestration recipes
│   ├── shopee-api.md                     # Shopee category+product+shop+keyword 17 endpoints
│   ├── shopee-data-types.md              # Shopee data type definitions
│   ├── walmart-api.md                    # Walmart 19 endpoints (category+product+account 10 + keyword+library 9)
│   ├── walmart-data-types.md             # Walmart data type definitions
│   ├── 1688-api.md                       # 1688 sourcing search+product detail 9 endpoints
│   ├── temu-api.md                       # Temu category+product+shop 12 endpoints
│   ├── temu-data-types.md                # Temu data type definitions
│   ├── tiktok-api.md                     # TikTok category+product+seller+creator+video+brand 21 endpoints
│   ├── tiktok-data-types.md              # TikTok data type definitions
│   └── use-cases.md                      # Use case documentation
└── scripts/                              # 7 helper scripts (see Bundled Scripts)
```

---

## Important Rules

1. **Don't guess domain values** — always use the site reference table in `_common.md`
2. **Wrap JSON parameters in single quotes** — `sorftime api XXX '{"key": "value"}'`
3. **Set a long timeout for large responses** — CategoryTree returns ~10MB+, configure your CLI client accordingly
4. **Error code judgement** — the status field is `Code` (PascalCase) on success and `code` (camelCase) on error, so jq must handle both: `jq -r '.Code // .code'`. Non-zero = error code (see [_common.md §7](resources/_common.md))

---

## Parameter Naming Traps (highest-frequency pitfalls)

> ⚠️ Parameter names differ in casing and naming across platforms — this is the single most common source of errors. Get the parameter names right and most issues disappear.

| Trap | Correct | Wrong |
|------|---------|-------|
| Amazon ProductRequest single ASIN | `{"asin":"B0X"}` | `{"asinList":["B0X"]}` |
| ProductRequest batch (≤10) | `{"asin":"B0X,B0Y"}` comma-separated | array |
| Shopee product ID | `{"ProductId":"xxx"}` | `{"asin":"xxx"}` |
| Walmart product ID | `{"ProductId":"xxx"}` | `{"asin":"xxx"}` |
| Walmart category | `{"NodePath":"4044_90548"}` | `{"nodeId":"xxx"}` |
| Temu search | `{"Name":"keyword"}` (capital N) | `{"name":"keyword"}` |
| Walmart search by name | `{"Name":"led tv"}` for `CategorySearchFromName` / `ProductSearchFromName` | searching via `nodeId`/`asin` |
| 1688 image search | `{"ImageUrl":"https://..."}` | `{"image":"..."}` |
| CategoryRequestKeyword | `{"Nodeid":"xxx"}` (lowercase d) | `{"NodeId":"xxx"}` |
| ASINRequestKeyword | `{"ASIN":"B0X"}` (all caps) | `{"asin":"B0X"}` |
| KeywordBatchScheduleDetail | `{"ScheduelId":"xxx"}` (sic — API's own spelling) | `{"ScheduleId":"xxx"}` |
| KeywordSearchRealtimeRequest | `{"keyword":["kw"],"mode":0,"area":"10041","page":1}` — keyword is an **array**; all four params required; area is mode-specific | `{"keyword":"kw"}` string / any param omitted → Code 10 |
| CoinStream date (Shopee/Walmart/1688) | `{"Querydate":[...]}` (lowercase d) | `{"QueryDate":...}` |
| CoinStream date (Amazon) | `{"QueryDate":[...]}` (capital D) | `{"Querydate":...}` |
| TikTok creator/video | domain=301 (US only) | other domains return 401 |

---

## Realtime Task Semantics (RealtimeRequest 家族，2026-10-05 空转事故实证)

> 适用 `SimilarProductRealtimeRequest` / `ProductRealtimeRequest` / `*ReviewsCollection` 等「提交任务→异步收取」端点。`KeywordSearchRealtimeRequest` 三件套（见 `resources/amazon-keyword-api.md` §5）同属此模式，但差异实测在案：StatusQuery 不收过滤参数、Collection 按 taskId 取数；**第 1 条幂等语义对三件套未实测**（同 keyword 不同 page 会得到不同任务 ID；同入参重提是否返回旧 ID 未知）——勿按「重提=拿回旧任务」假设设计重试/去重。

1. **按入参幂等**：同一张图片/同一个 ASIN 重复提交，返回**同一个任务 ID**（图搜实证：两天后重提同图仍返回 128710）。任务终态（含失败）永久冻结在该 ID 上——**重提同入参不是重试，是拿回同一个死任务**。
2. **先查状态再判定**：`SimilarProductRealtimeRequestStatusQuery` 不收 taskId——只收 `{"Update": 小时数}`（1-240），返回该窗口全量任务列表 [{TaskId, Status}]。状态码：0=完成、4=积分不足、11=无采集任务、97=无匹配商品（图搜无同款）、98=采集失败、99=采集中。**零积分消耗**。
3. **Collection 的 Data=None 有两种含义**：任务在途（99）或终态无结果（97/98）——只看 Collection 永远分不清，必须配 StatusQuery 分流。97/98 终态后 Collection 永远返回 None，超期重提策略会永久空转（实证：135 提交/3 收数）。
4. **业务解读**：图搜 97=「无同款」是有效业务信号（差异化机会），不是失败；4=提交时积分不足，任务根本没执行。

---

## Service Principles

When helping the user solve a problem:

1. **Understand the underlying need** — grasp the business context behind the request, solve the real problem instead of mechanically fulfilling the literal ask
2. **Plan before executing** — think through the approach and the user's goal first, then execute; avoid blind trial-and-error
3. **Keep it simple** — use the most direct solution; don't pile up information or introduce unnecessary complexity
4. **Goal-driven** — keep the user's final objective in view, not just surface-level request items

---

## Bundled Scripts (`scripts/`)

The skill ships 7 helper scripts (3 wrappers + 3 utilities + 1 shared library) that wrap the raw `sorftime api` command with output cleaning, error handling, retries, and convenience features:

| Script | Purpose |
|------|------|
| [`scripts/call.sh`](scripts/call.sh) | Single API call with auto-cleaned output (drops `info:`, `✔`, ANSI), JSON pretty-print, business-error exit code 2, optional retry |
| [`scripts/one.sh`](scripts/one.sh) | One-line status query: `one ProductRequest B0CVM8TXHP` → 11 key fields (title/price/sales/rating/...) for a single ASIN/keyword/category |
| [`scripts/decode.sh`](scripts/decode.sh) | Error-code dictionary: `decode 10` → meaning + troubleshooting (no API call needed) |
| [`scripts/batch.sh`](scripts/batch.sh) | **Generic batch runner**: loop an endpoint over an input file with rate limiting, retries, resume, disk output (`--out`), and dry-run. The automation workhorse — see Shortcut Map → Batch Operations |
| [`scripts/doctor.sh`](scripts/doctor.sh) | Environment self-check: node/npm/CLI version/profile/live connectivity, with install-and-configure hints on failure. `doctor.sh --connect` for the full check |
| [`scripts/gen-index.sh`](scripts/gen-index.sh) | Auto-generates `resources/_endpoints-index.md` (endpoint count matrix) from resource headers — run after any resources update so the endpoint counts never go stale |
| [`scripts/_lib.sh`](scripts/_lib.sh) | Shared library sourced by all scripts — defines `call_api` / `_pyq` / `py_field` / `py_to_csv` helpers |

**Typical usage** (replace `sorftime api ... | jq .` with 1 line):

```bash
# Raw (stdout is already clean JSON; stderr carries progress lines)
sorftime api ProductRequest '{"asin":"B0CVM8TXHP"}' --domain 1 | jq .

# After (1 line + checkable exit code)
scripts/one.sh ProductRequest B0CVM8TXHP
```

**Exit code table** (applies to all scripts):
- `0` — API code=0 (success)
- `2` — API code≠0 (business error, message written to stderr)
- `3` — Bad input (missing parameter / invalid endpoint name format)
- `4` — Network / CLI error (automatic retry with `--retries N`)

**Full documentation**: `scripts/call.sh --help` / `scripts/one.sh --help` / etc.
