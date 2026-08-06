---
name: sorftime-data-cli
description: >
  Call the Sorftime CLI (npm package `sorftime-cli`, entry point `sorftime api <Endpoint> '<json>'`) for 117 unique data endpoints across Amazon/Shopee/Walmart/1688/Temu/TikTok. Use for: batch-querying ASINs/categories/keywords/sales/reviews/monitoring; troubleshooting API calls, parameters, fields, or error codes; orchestrating endpoints for product selection / competitor analysis / hijacker monitoring / cross-platform comparison. **MUST** trigger whenever the user mentions sorftime-cli, Sorftime data APIs, batch ASIN lookups, monitoring setup, or any platform endpoint — even if the CLI isn't named explicitly.
  Trigger words: sorftime api, sorftime-cli, sorftime-data-cli, batch ASIN query, category Best Seller, hijacker monitoring, keyword reverse-lookup, 批量查 ASIN, 批量类目数据, 调用 sorftime, 写 sorftime 脚本, 采购成本分析, 跟卖预警, 子体销量, 关键词监控, Best Seller 榜单, 类目趋势, 跨平台对比, 全量扫类目, 把这些ASIN全查一遍, 监控起来, 每天拉数据, 跨平台价差, FBM转FBA批量, 达人分析, 视频标签分析, TikTok 带货数据.
compatibility:
  tools: [Bash, Read]
  dependencies: [node>=16, npm, jq (optional), sorftime-cli@1.0.0]
version: 1.2.0
user-invocable: true
---

# Sorftime Data CLI Skill

> Based on the npm package `sorftime-cli@1.0.0` (unified entry point `sorftime api <Endpoint> '<json>'`), covering 117 unique Sorftime data endpoints (Amazon 57 + Shopee 17 + Walmart 17 + 1688 9 + Temu 12 + TikTok 17; CoinQuery/CoinStream/RequestStreamMonth are shared across platforms and counted once).

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

## CLI Quickstart (60 seconds)

```bash
# 1. Install
npm install -g sorftime-cli

# 2. Configure profile (Account-SK from Sorftime dashboard (open-intl.sorftime.com))
sorftime add myprofile <your-account-sk>
sorftime use myprofile

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

### Step 3 — Get the Account-SK
After registration, copy the Account-SK from the Sorftime dashboard (open-intl.sorftime.com) (account settings). Keep it private.

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
| [`use-cases.md`](resources/use-cases.md) | Sorftime Data CLI recipes / use cases |

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

Map user intent → command → expected output. If the intent matches, use the command as-is; adapt the values (ASIN / nodeId / keyword / date) to the task.

### Daily Query Shortcuts

| User intent | Command | Output |
|------|------|------|
| Query a single product | `sorftime api ProductRequest '{"asin":"B0X"}' --domain 1 \| grep -v "^info:" \| jq .` | Full product JSON (price `SalesPrice`, monthly sales `ListingSalesVolumeOfMonth`, rating `Ratings`, buybox `BuyboxSeller`) |
| Query category Best Seller | `sorftime api CategoryRequest '{"nodeId":"3743561"}' --domain 1 \| grep -v "^info:" \| jq '.data.list[0].asinList[:10]'` | Top-10 ASIN list for the node |
| Query ASIN variant sales | `sorftime api AsinSalesVolume '{"asin":"B0X","queryDate":"2026-01-01"}' --domain 1 \| grep -v "^info:" \| jq .` | Daily sales per variant, one entry per date |
| Query keyword traffic | `sorftime api KeywordRequest '{"keyword":"water bottle"}' --domain 1 \| grep -v "^info:" \| jq .` | Keyword volume/share/competition snapshot |
| Reverse-lookup keywords for ASIN | `sorftime api ASINRequestKeyword '{"asin":"B0X","pageSize":50}' --domain 1 \| grep -v "^info:" \| jq .` | Ranked keyword list the ASIN ranks for |

### Batch Operations Shortcuts

> **First choice: `scripts/batch.sh`** — generic batch runner with rate limiting, retries, resume, and disk output. Only fall back to manual `while read` loops when you need per-line custom logic.

| User intent | Command | Output |
|------|------|------|
| Batch product base info | `bash scripts/batch.sh ProductRequest asins.txt --param asin --domain 1 --out products.jsonl` | One response JSON per line in `products.jsonl`; summary `N ok / M failed` |
| Batch variant sales | `bash scripts/batch.sh AsinSalesVolume asins.txt --param asin --domain 1 --out sales.jsonl` | Same, with `{"queryDate":"YYYY-MM-DD"}` JSON lines input for fixed-date queries |
| Batch reverse-lookup keywords | `bash scripts/batch.sh ASINRequestKeyword asins.txt --param asin --domain 1 --out kws.jsonl` | One keyword list per ASIN, line-aligned with input |
| Resume an interrupted batch | `bash scripts/batch.sh ProductRequest asins.txt --param asin --out products.jsonl --resume` | Skips lines already done (progress in `products.jsonl.progress`) |
| Dry-run preview before paying calls | `bash scripts/batch.sh ProductRequest asins.txt --param asin --dry-run` | Prints every command without executing |
| Paginate full category tree | `sorftime api CategoryTree '{"nodeId":"0"}' --domain 1 \| grep -v "^info:" \| jq . > tree.json` then `jq` on demand | Local cache; see Large-data Persistence below |

### Debugging & Pre-flight Shortcuts

| User intent | Command | Output |
|------|------|------|
| Full environment self-check | `bash scripts/doctor.sh --connect` | ✅/❌ per check: node, npm, CLI version, profile, live API call |
| Preview a request (see raw return) | `sorftime api ProductRequest '{"asin":"B0X"}' --domain 1` | Raw JSON including `info:` lines |
| Check endpoint availability | `sorftime api ProductRequest '{"asin":"B0X"}' --domain 1 \| grep -v "^info:" \| jq '.code'` | `0` = success; non-zero = error code (see `_common.md` §6) |
| Environment connectivity test | `sorftime api CategoryTree '{"nodeId":"0"}' --domain 1` | A return value means connected |
| Search field name | Look up `resources/_field_aliases.md` | Field → actual API name mapping |
| View actual fields returned by an endpoint | Call the endpoint and inspect the JSON; aliases in `resources/_field_aliases.md` | Live field list |

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
├── CHANGELOG.md                          # Version history
├── trigger-eval.json                     # Trigger evaluation queries (32, bilingual)
├── resources/
│   ├── _common.md                        # Common: Domain/error codes/CLI template/rate limits/troubleshooting
│   ├── _field_aliases.md                 # Field alias mapping
│   ├── _endpoints-index.md               # Auto-generated endpoint count matrix (run gen-index.sh to refresh)
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
└── scripts/                              # 7 helper scripts (see Bundled Scripts)
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
| [`scripts/batch.sh`](scripts/batch.sh) | **Generic batch runner**: loop an endpoint over an input file with rate limiting, retries, resume, disk output (`--out`), and dry-run. The automation workhorse — see Shortcut Map → Batch Operations |
| [`scripts/doctor.sh`](scripts/doctor.sh) | Environment self-check: node/npm/CLI version/profile/live connectivity, with install-and-configure hints on failure. `doctor.sh --connect` for the full check |
| [`scripts/gen-index.sh`](scripts/gen-index.sh) | Auto-generates `resources/_endpoints-index.md` (endpoint count matrix) from resource headers — run after any resources update so the 117-endpoint number never goes stale |
| [`scripts/_lib.sh`](scripts/_lib.sh) | Shared library sourced by all scripts — defines `call_api` / `_pyq` / `py_field` / `py_to_csv` helpers |

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
