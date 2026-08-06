# Sorftime CLI Quick Reference

## 🆕 What's New

<details>
<summary><b>2026-08-06 — v1.1.0 整合版（市场部整合）</b></summary>

- **统一英文版化**：SKILL.md / README / resources 全英文，面向国际卖家；新增 🔴 Language Rule（跟随用户语言回复，中英均支持）
- **中英双语触发**：description 与 trigger-eval.json（32 条评估集）同时覆盖中英文场景
- **回填参数命名陷阱表**（13 条高频踩坑）与服务原则
- **修复 7 处死链**（amazon-ai-api / amazon-alexa-api 等文件名引用）与 `_field_aliases.md` 的失效脚本引用
- **修正接口计数口径**：117 unique endpoints（原 132 重复计入 3 个跨平台账户接口）
- 基于产品部官方包 `sorftime-cli@1.0.0`（npm latest），废弃旧 0.1.x 文档
</details>

> Based on the npm package `sorftime-cli@1.0.0` (unified entry point `sorftime api <Endpoint> '<json>'`), covering **117 unique** Sorftime cross-border e-commerce data endpoints: Amazon 57 + Shopee 17 + Walmart 17 + 1688 9 + Temu 12 + TikTok 17 (per-platform counts include the 3 shared cross-platform account endpoints CoinQuery/CoinStream/RequestStreamMonth, counted once).

For the full index (discovery path, recipes, all endpoint references), see [SKILL.md](SKILL.md).

---

## Installation

```bash
npm install -g sorftime-cli

# Configure a profile (token is available in the Sorftime Pro dashboard)
sorftime add myprofile <your-account-sk>
sorftime use myprofile
```

---

## 5-minute Quickstart

```bash
# 1. Query the category Best Seller Top 100
sorftime api CategoryRequest '{"nodeId": "3743561"}' --domain 1

# 2. Query a single product's details
sorftime api ProductRequest '{"asin": "B0CVM8TXHP"}' --domain 1

# 3. Query the details of the keyword "power bank"
sorftime api KeywordRequest '{"keyword": "power bank"}' --domain 1

# 4. Multi-condition combined filter (keyword: power bank + price range: 20-50 + monthly sales > 500)
sorftime api ProductSearch '{"keyword":"power bank","PriceRangeMin":20,"PriceRangeMax":50,"MonthSaleVolumeRangeMin":500}' --domain 1
```

For raw CLI output (a noisy mix of `info:` lines and JSON), pipe through `scripts/call.sh` instead — it drops the noise and pretty-prints the JSON, plus returns a meaningful exit code.

---

## Bundled Helper Scripts (`scripts/`)

All scripts are POSIX bash 4+ (macOS / Linux / Windows Git Bash / WSL). They wrap the raw `sorftime api` command with output cleaning, error handling, and convenience features.

| Script | One-liner |
|---|---|
| `scripts/call.sh` | Single API call with auto-cleaned output (drops `info:`, `✔`, ANSI), JSON pretty-print, business-error exit code 2, optional retry |
| `scripts/one.sh` | One-line status query: `one ProductRequest B0CVM8TXHP` → 11 key fields (title/price/sales/rating/...) for a single ASIN / keyword / category |
| `scripts/decode.sh` | Error-code dictionary: `decode 10` → meaning + troubleshooting (no API call needed) |
| `scripts/_lib.sh` | Shared library sourced by the three scripts above — defines `call_api` / `_pyq` / `py_field` / `py_to_csv` helpers |

**Exit codes (applies to `call.sh` / `one.sh`)**:

- `0` — API `code=0` (success)
- `2` — API `code≠0` (business error, message written to stderr)
- `3` — Bad input (missing parameter / invalid endpoint name format)
- `4` — Network / CLI error (automatic retry with `--retries N`)

**Typical usage**:

```bash
# Before (5 segments, hard to grep / chain)
sorftime api ProductRequest '{"asin":"B0CVM8TXHP"}' --domain 1 2>&1 \
  | grep -v "^info:" | jq .

# After (1 line + checkable exit code)
scripts/one.sh ProductRequest B0CVM8TXHP
```

Full docs: `scripts/call.sh --help` / `scripts/one.sh --help` / `scripts/decode.sh --help`.

---

## Common Field-Naming Pitfalls

Sorftime API field names are non-standard. Common pitfalls — check this before searching for a field:

| What you're looking for | Actual field name |
|---|---|
| price, Price | `SalesPrice` |
| monthly sales, Monthly sales | `ListingSalesVolumeOfMonth` |
| reviews, Review count | `Ratings` |
| review count | `RatingsCount` |
| seller, Buybox seller | `BuyboxSeller` |
| brand | `Brand` |
| FBA | `IsFBA` |

For the full alias table, see [`resources/_field_aliases.md`](resources/_field_aliases.md).

**Can't find a field?**:

1. Look it up in `resources/_field_aliases.md`.
2. Call the endpoint and inspect the JSON yourself — the alias table covers the common cases but is not exhaustive.

---

## Large-Data Handling (Category Tree, etc.)

The Amazon category tree (`CategoryTree`) can be up to ~10MB / several hundred thousand lines. **Don't load it all at once — query just the node you need**.

```bash
# First pull, save to local cache
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

## Batch Operations (with Rate-Limit Safety)

`CategoryTree` and similar large endpoints are best handled one-shot. For high-volume batch queries (e.g. 200 ASINs):

```bash
# Batch product base info
while read asin; do
  sorftime api ProductRequest "{\"asin\":\"$asin\"}" --domain 1
  sleep 1
done < asins.txt
```

**Always add `sleep 1` between requests** to stay clear of the per-profile rate limit (default rate-limit errors: code 500 / 501 / 694 — see [`resources/_common.md`](resources/_common.md) §7 for the full list, §8 for QPM/concurrency).

For retry / failure-log automation, wrap calls with `scripts/call.sh --retries N`. For very large batches, see the recipe book at [`resources/use-cases.md`](resources/use-cases.md).

---

## Domain Quick Reference

Full table in [`resources/_common.md`](resources/_common.md). Most-used values:

| Platform | domain | Description |
|---|---|---|
| Amazon US | 1 | US site |
| Amazon UK | 2 | UK site |
| Amazon DE | 3 | Germany site |
| Amazon FR | 4 | France site |
| Amazon JP | 7 | Japan site |
| Shopee VN | 201 | Vietnam site |
| Shopee TH | 204 | Thailand site |
| Shopee SG | 202 | Singapore site |
| Shopee MY | 203 | Malaysia site |
| Walmart US | 21 | US site (the only Walmart site currently open) |
| 1688 | 601 | 1688 sourcing platform (China) |
| Temu US | 701 | US site |
| Temu EU | 705 | EU site |
| TikTok US | 301 | US site (only site supporting AuthorRequest / VideoRequest / VideoTagSearch) |

---

## File Index

```
sorftime-cli/
├── SKILL.md                                 # Main index (discovery path, recipes, endpoint catalog)
├── README.md                                # This file: human quick reference
├── trigger-eval.json                        # Trigger evaluation queries
├── resources/
│   ├── _common.md                           # Domain table, error codes, response structure, CLI template
│   ├── _field_aliases.md                    # Field alias mapping
│   ├── account.md                           # Cross-platform account management (3 endpoints)
│   ├── amazon-category-api.md               # Amazon category (7 endpoints)
│   ├── amazon-product-api.md                # Amazon product (18 endpoints)
│   ├── amazon-keyword-api.md                # Amazon keyword (12 endpoints)
│   ├── amazon-alexa-api.md                  # Amazon Alexa question (4 endpoints)
│   ├── amazon-ai-api.md                     # Amazon AI interpretation (2 endpoints)
│   ├── amazon-monitoring-api.md             # Amazon monitoring (14 endpoints)
│   ├── amazon-data-types.md                 # Amazon data type definitions
│   ├── amazon-recipes.md                    # Multi-endpoint orchestration recipes
│   ├── shopee-api.md                        # Shopee (17 endpoints)
│   ├── shopee-data-types.md                 # Shopee data type definitions
│   ├── walmart-api.md                       # Walmart (17 endpoints)
│   ├── walmart-data-types.md                # Walmart data type definitions
│   ├── 1688-api.md                          # 1688 (9 endpoints)
│   ├── temu-api.md                          # Temu (12 endpoints)
│   ├── temu-data-types.md                   # Temu data type definitions
│   ├── tiktok-api.md                        # TikTok (17 endpoints)
│   ├── tiktok-data-types.md                 # TikTok data type definitions
│   └── use-cases.md                         # Use case documentation / recipes
└── scripts/
    ├── _lib.sh                              # Shared bash library (sourced by the others)
    ├── call.sh                              # Single API call wrapper
    ├── one.sh                               # One-line status query
    └── decode.sh                            # Error-code dictionary
```

---

## Common Questions

- **Returns `code=11` "no data available"** — The ASIN / category has no data in the Sorftime library. Try another ASIN that has data.
- **Returns `code=401` "endpoint not open"** — The endpoint (e.g. `ProductTrend`) is not open on your plan, or the chosen domain does not support it.
- **Returns `code=10` "parameter error"** — Check the JSON parameter format (single-quoted, PascalCase endpoint name).
- **Request rate** — Default per-profile rate limit is conservative; use `sleep 1` between batch calls. Rate-limit error codes: 500 / 501 / 694.
- **Can't find a field** — Check `resources/_field_aliases.md` first; the endpoint may return it under a different name.
- **Large responses** — Use a local cache (see "Large-Data Handling" above) and `jq` to extract just the node you need.
- **Want a one-line status query** — Use `scripts/one.sh <Endpoint> <ID>` instead of a raw `sorftime api ... | jq`.

For detailed troubleshooting, see [`resources/_common.md`](resources/_common.md) §7 (error codes) and §8 (rate limits).