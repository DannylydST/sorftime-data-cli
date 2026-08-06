---
name: sorftime-cli
description: >
  Call the Sorftime CLI (npm package `sorftime-cli`, unified entry point `sorftime api <Endpoint> '<json>'`) for 117 unique cross-border e-commerce data endpoints, covering Amazon 57 + Shopee 17 + Walmart 17 + 1688 9 + Temu 12 + TikTok 17 (per-platform counts include 3 shared cross-platform account endpoints: CoinQuery/CoinStream/RequestStreamMonth).
  When the user or agent needs to: write scripts that batch-query ASINs / categories / keywords / sales / reviews / monitoring; troubleshoot Sorftime API calls, parameters, fields, or error codes;
  or orchestrate multiple endpoints for product selection / competitor analysis / hijacker monitoring / cross-platform comparison, this skill **MUST** be triggered. Use it whenever the user mentions sorftime-cli, Sorftime data APIs, batch ASIN lookups, monitoring setup, or any platform endpoint (Amazon/Shopee/Walmart/1688/Temu/TikTok) — even if they don't name the CLI explicitly.
  Trigger words: sorftime api, sorftime-cli, sorftime 接口, cross-border e-commerce data, batch ASIN query, category Best Seller, hijacker monitoring, keyword reverse-lookup, ProductRequest, CategoryRequest, ASINRequestKeyword, 调用 sorftime, 批量查 ASIN, 批量类目数据, 自定义 sorftime 工作流, 写 sorftime 脚本, 采购成本分析, 监控注册, 跟卖预警, 子体销量, 关键词监控部署, Best Seller 榜单抓取, 类目趋势分析, 跨平台对比, 全量扫类目, 把这些ASIN全查一遍, 监控起来, 每天拉数据, 跨平台价差, FBM转FBA批量, 达人分析, 视频标签分析, TikTok 带货数据.
compatibility:
  tools: [Bash, Read]
  dependencies: [node>=16, npm, jq (optional), sorftime-cli@1.0.0]
version: 1.1.0
user-invocable: true
---

# Sorftime CLI Skill

> Based on the npm package `sorftime-cli@1.0.0` (unified entry point `sorftime api <Endpoint> '<json>'`), covering 117 unique Sorftime data endpoints (Amazon 57 + Shopee 17 + Walmart 17 + 1688 9 + Temu 12 + TikTok 17; CoinQuery/CoinStream/RequestStreamMonth are shared across platforms and counted once).

---

## 🔴 Language Rule (Mandatory)

**Match the user's language. Always.** If the user writes in English → respond in English. If the user writes in Chinese → respond in Chinese. Never mix. This overrides everything else in this skill. The skill documentation is English by design (international-first); your *replies* follow the user's language. This makes the skill work for both US/UK sellers and Chinese sellers.

---

## CLI Quickstart (60 seconds)

```bash
# 1. Install
npm install -g sorftime-cli

# 2. Configure profile (token from Sorftime Pro dashboard)
sorftime add myprofile

# 3. Call an endpoint
sorftime api ProductRequest '{"asinList":["B08N5WRWNW"]}' --domain 1 --profile myprofile

# 4. Common commands
sorftime list        # List all profiles
sorftime use myprofile   # Switch default profile
sorftime whoami      # View current profile
```

> **Field-naming warning**: Sorftime API field names are non-standard. Common pitfalls:
> - "price" → actual field is `SalesPrice`
> - "monthly sales" → actual field is `ListingSalesVolumeOfMonth`
> - "reviews" → actual field is `Ratings`
> - "seller" → actual field is `BuyboxSeller`
>
> When a field is missing, check `resources/_field_aliases.md` before assuming the API doesn't return it. Response shape and error codes are in [_common.md §6–§7](resources/_common.md).

---

## Sorftime CLI Recipes

Full recipes in [`resources/use-cases.md`](resources/use-cases.md) — organized as Basics / Product Selection / Operations / Research, each recipe = problem description + step-by-step commands + expected output.

---

## Progressive Discovery Path

### Level 0: Total beginner (5 minutes)
→ Read [README.md](README.md) for quickstart
→ `sorftime api CategoryTree --domain 1`
→ Verify: `sorftime whoami` shows profile and balance

### Level 1: I want to query a single data point
→ Use the daily-query shortcuts in [Shortcut Map](#shortcut-map-semantic-wrappers) below
→ `sorftime api ProductRequest '{"asin":"B0CVM8TXHP"}' --domain 1 | grep -v "^info:" | jq .`
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
| [`use-cases.md`](resources/use-cases.md) | Sorftime CLI recipes / use cases |

### Amazon (57 endpoints: 43 base + 14 monitoring)

| File | Count | Endpoints |
|------|--------|---------|
| [`amazon-category-api.md`](resources/amazon-category-api.md) | 7 | CategoryTree, CategoryRequest, CategoryProducts, CategoryTrend, CategorySearchFromName, CategoryAssistant, SimilarProductFeature |
| [`amazon-product-api.md`](resources/amazon-product-api.md) | 18 | All 18 endpoints: ProductRequest, ProductSearch, AsinSalesVolume, ProductVariations, ProductReviewsCollection, ProductReviewsCollectionStatusQuery, ProductReviewsQuery, ProductSearchFromName, ProductCustomersSay, ASINSubscription, ASINSubscriptionQuery, ASINSubscriptionCollection, ProductAssistant, ProductRealtimeRequest, ProductRealtimeRequestStatusQuery, SimilarProductRealtimeRequest, SimilarProductRealtimeRequestStatusQuery, SimilarProductRealtimeRequestCollection |
| [`amazon-keyword-api.md`](resources/amazon-keyword-api.md) | 12 | KeywordQuery, KeywordSearchResults, KeywordRequest, KeywordSearchResultTrend, KeywordExtends, CategoryRequestKeyword, ASINRequestKeyword, KeywordProductRanking, ASINKeywordRanking, FavoriteKeyword, ChangeFavoriteKeyword, GetFavoriteKeyword |
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

### Walmart (17 endpoints)

| File | Count | Endpoints |
|------|--------|---------|
| [`walmart-api.md`](resources/walmart-api.md) | 17 | All 17 endpoints: CategoryTree, CategoryRequest, ProductRequest, ProductTrendRequest, ProductSalesVolume, CoinQuery, CoinStream, RequestStreamMonth, KeywordQuery, KeywordSearchFromName, KeywordSearchResults, KeywordRequest, ProductRequestKeyword, KeywordExtends, FavoriteKeyword, ChangeFavoriteKeyword, GetFavoriteKeyword |
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

### TikTok (17 endpoints)

| File | Count | Endpoints |
|------|--------|---------|
| [`tiktok-api.md`](resources/tiktok-api.md) | 17 | CategoryTree, CategoryRequest, CategorySearchFromName, CategorySearch, CategoryTrend, ProductRequest, ProductSearchFromName, ProductTrendRequest, ProductSearch, ShopSearch, ShopRequest, AuthorRequest, VideoRequest, VideoTagSearch, CoinQuery, CoinStream, RequestStreamMonth |
| [`tiktok-data-types.md`](resources/tiktok-data-types.md) | — | TikTok data type definitions |

> **US only**: AuthorRequest, VideoRequest, VideoTagSearch are limited to the US site (domain=301).

---

## Shortcut Map (semantic wrappers)

Map common intents to one-line commands.

### Daily Query Shortcuts

| Intent | Command |
|------|------|
| Query a single product | `sorftime api ProductRequest '{"asin":"B0X"}' --domain 1 \| grep -v "^info:" \| jq .` |
| Query category Best Seller | `sorftime api CategoryRequest '{"nodeId":"3743561"}' --domain 1 \| grep -v "^info:" \| jq '.data.list[0].asinList[:10]'` |
| Query ASIN variant sales | `sorftime api AsinSalesVolume '{"asin":"B0X","queryDate":"2026-01-01"}' --domain 1 \| grep -v "^info:" \| jq .` |
| Query keyword traffic | `sorftime api KeywordRequest '{"keyword":"water bottle"}' --domain 1 \| grep -v "^info:" \| jq .` |
| Reverse-lookup keywords for ASIN | `sorftime api ASINRequestKeyword '{"asin":"B0X","pageSize":50}' --domain 1 \| grep -v "^info:" \| jq .` |

### Batch Operations Shortcuts

> All batch commands default to `sleep 1` between requests to avoid rate limits (code 500/501/694).

| Intent | Command |
|------|------|
| Batch product base info | `while read asin; do sorftime api ProductRequest "{\"asin\":\"$asin\"}" --domain 1; sleep 1; done < asins.txt` |
| Batch variant sales | `while read asin; do sorftime api AsinSalesVolume "{\"asin\":\"$asin\",\"queryDate\":\"2026-01-01\"}" --domain 1; sleep 1; done < asins.txt` |
| Batch reverse-lookup keywords | `while read asin; do sorftime api ASINRequestKeyword "{\"asin\":\"$asin\",\"pageSize\":100}" --domain 1; sleep 1; done < asins.txt` |
| Paginate full category tree | Write a manual loop that increments `pageToken` etc. |

### Debugging & Pre-flight Shortcuts

| Intent | Command |
|------|------|
| Preview a request (see raw return) | `sorftime api ProductRequest '{"asin":"B0X"}' --domain 1` |
| Check endpoint availability | `sorftime api ProductRequest '{"asin":"B0X"}' --domain 1 \| grep -v "^info:" \| jq '.code'` |
| Environment connectivity test | `sorftime api CategoryTree '{"nodeId":"0"}' --domain 1` (a return value means connected) |
| Search field name | Look up `resources/_field_aliases.md` |
| View actual fields returned by an endpoint | Call the endpoint and inspect the JSON; aliases in `resources/_field_aliases.md` |

### Large-data Persistence

> **Core principle**: large payloads (category tree > 10KB) should be cached locally and queried on demand, not loaded in full.

**Manual caching tip**:
```bash
# First pull: save category tree to a local file
sorftime api CategoryTree --domain 1 | grep -v "^info:" | jq . > category-tree-us.json

# On-demand jq query of a specific node
cat category-tree-us.json | jq '.data[] | select(.NodeId=="3743561")'

# Refresh cache
sorftime api CategoryTree --domain 1 | grep -v "^info:" | jq . > category-tree-us.json
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
├── trigger-eval.json                     # Trigger evaluation queries
├── resources/
│   ├── _common.md                        # Common: Domain/error codes/CLI template/rate limits/troubleshooting
│   ├── _field_aliases.md                 # Field alias mapping
│   ├── account.md                        # Cross-platform account management (3 endpoints)
│   ├── amazon-category-api.md                # Amazon category 7 endpoints
│   ├── amazon-data-types.md              # Amazon data type definitions
│   ├── amazon-product-api.md                 # Amazon product: 18 endpoints (core 13 + real-time 5)
│   ├── amazon-keyword-api.md                 # Amazon keyword 12 endpoints
│   ├── amazon-alexa-api.md                   # Amazon Alexa question collection/query 4 endpoints
│   ├── amazon-ai-api.md                      # Amazon AI interpretation 2 endpoints
│   ├── amazon-monitoring-api.md          # Amazon monitoring: common rules + 14 endpoints (keyword×5, bestseller×4, hijacker×5)
│   ├── amazon-recipes.md                 # Multi-endpoint orchestration recipes
│   ├── shopee-api.md                     # Shopee category+product+shop+keyword 17 endpoints
│   ├── shopee-data-types.md              # Shopee data type definitions
│   ├── walmart-api.md                    # Walmart 17 endpoints (category+product+account 8 + keyword+library 9)
│   ├── walmart-data-types.md             # Walmart data type definitions
│   ├── 1688-api.md                       # 1688 sourcing search+product detail 9 endpoints
│   ├── temu-api.md                       # Temu category+product+shop 12 endpoints
│   ├── temu-data-types.md                # Temu data type definitions
│   ├── tiktok-api.md                     # TikTok category+product+seller+creator+video 17 endpoints
│   ├── tiktok-data-types.md              # TikTok data type definitions
│   └── use-cases.md                      # Use case documentation
```

---

## Important Rules

1. **Don't guess domain values** — always use the site reference table in `_common.md`
2. **Wrap JSON parameters in single quotes** — `sorftime api XXX '{"key": "value"}'`
3. **Set a long timeout for large responses** — CategoryTree returns ~10MB+, configure your CLI client accordingly
4. **Error code judgement** — based on the `Code` / `code` field (case-insensitive, see [_common.md §6](resources/_common.md))

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
| 1688 image search | `{"ImageUrl":"https://..."}` | `{"image":"..."}` |
| CategoryRequestKeyword | `{"Nodeid":"xxx"}` (lowercase d) | `{"NodeId":"xxx"}` |
| ASINRequestKeyword | `{"ASIN":"B0X"}` (all caps) | `{"asin":"B0X"}` |
| KeywordBatchScheduleDetail | `{"ScheduelId":"xxx"}` (sic — API's own spelling) | `{"ScheduleId":"xxx"}` |
| CoinStream date (Shopee/Walmart/1688) | `{"Querydate":[...]}` (lowercase d) | `{"QueryDate":...}` |
| CoinStream date (Amazon) | `{"QueryDate":[...]}` (capital D) | `{"Querydate":...}` |
| TikTok creator/video | domain=301 (US only) | other domains return 401 |

---

## Service Principles

When helping the user solve a problem:

1. **Understand the underlying need** — grasp the business context behind the request, solve the real problem instead of mechanically fulfilling the literal ask
2. **Plan before executing** — think through the approach and the user's goal first, then execute; avoid blind trial-and-error
3. **Keep it simple** — use the most direct solution; don't pile up information or introduce unnecessary complexity
4. **Goal-driven** — keep the user's final objective in view, not just surface-level request items

---

## Bundled Scripts (`scripts/`)

The skill ships 4 ready-to-use helper scripts that wrap the raw `sorftime api` command with output cleaning, error handling, retries, and convenience features:

| Script | Purpose |
|------|------|
| [`scripts/call.sh`](scripts/call.sh) | Single API call with auto-cleaned output (drops `info:`, `✔`, ANSI), JSON pretty-print, business-error exit code 2, optional retry |
| [`scripts/one.sh`](scripts/one.sh) | One-line status query: `one ProductRequest B0CVM8TXHP` → 11 key fields (title/price/sales/rating/...) for a single ASIN/keyword/category |
| [`scripts/decode.sh`](scripts/decode.sh) | Error-code dictionary: `decode 10` → meaning + troubleshooting (no API call needed) |
| [`scripts/_lib.sh`](scripts/_lib.sh) | Shared library sourced by `call.sh` / `one.sh` / `decode.sh` — defines `call_api` / `_pyq` / `py_field` / `py_to_csv` helpers |

**Typical usage** (replace the 5-line `... 2>&1 | grep -v "^info:" | jq .` with 1 line):

```bash
# Before (5 segments)
sorftime api ProductRequest '{"asin":"B0CVM8TXHP"}' --domain 1 2>&1 \
  | grep -v "^info:" | jq .

# After (1 line + checkable exit code)
scripts/one.sh ProductRequest B0CVM8TXHP
```

**Exit code table** (applies to all scripts):
- `0` — API code=0 (success)
- `2` — API code≠0 (business error, message written to stderr)
- `3` — Bad input (missing parameter / invalid endpoint name format)
- `4` — Network / CLI error (automatic retry with `--retries N`)

**Full documentation**: `scripts/call.sh --help` / `scripts/one.sh --help` / etc.
