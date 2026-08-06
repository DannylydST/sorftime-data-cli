# Amazon Multi-endpoint Orchestration Recipes

**Purpose**: Demonstrate core scenarios of `sorftime-cli` — arbitrary endpoint combinations, batch scripts, custom workflows.

**Prerequisites**: You are already familiar with each endpoint's individual usage (see [amazon-category-api.md](./amazon-category-api.md) / [amazon-product-api.md](./amazon-product-api.md) / [amazon-keyword-api.md](./amazon-keyword-api.md) / [amazon-monitoring-api.md](./amazon-monitoring-api.md)).

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency.
For detailed parameters of each endpoint, see the corresponding resources file. This document only provides CLI command-chain recipes for multi-endpoint orchestration.

---

## Recipe 1: Product Selection (CategoryRequest → ProductSearch → KeywordExtends → ProductReviewsQuery)

**Scenario**: Starting from a target category, filter potential products, verify keyword traffic, check review sentiment.

```bash
# Step 1: Get the category's Best Seller Top 100 (current data)
# Get the nodeId from CategoryTree, e.g. 7073960011 = Portable Power Banks
sorftime api CategoryRequest '{"nodeId": "7073960011"}' --domain 1

# Step 2: Use ProductSearch with multi-condition filters
# Conditions: category=7073960011, monthly sales 100-1000, star rating 4+, FBA shipping
sorftime api ProductSearch '{"nodeid": "7073960011", "MonthSaleVolumeRangeMin":100,"MonthSaleVolumeRangeMax":1000,"StarRangeMin":4,"ShippingType":"FBA", "page": 1}' --domain 1

# Step 3: Extend keywords for the candidate products' core keyword
# Assume the products filtered in Step 2 have "power bank" in the title
sorftime api KeywordExtends '{"keyword": "power bank", "pageIndex": 1, "pageSize": 50}' --domain 1

# Step 4: Directly pull recent review sentiment for the candidate ASIN (star=10 = negative 1-3 stars)
sorftime api ProductReviewsQuery '{"asin": "B0CVM8TXHP", "star": "10", "querystartdt": "2026-03-01"}' --domain 1
# Then check positive reviews (star=11 = 4-5 stars)
sorftime api ProductReviewsQuery '{"asin": "B0CVM8TXHP", "star": "11", "querystartdt": "2026-03-01"}' --domain 1

# Step 5: Read collected review content (fetch more pages on demand)
sorftime api ProductReviewsQuery '{"asin": "B0CVM8TXHP", "star": "10", "querystartdt": "2026-03-01", "pageIndex": 2}' --domain 1
sorftime api ProductReviewsQuery '{"asin": "B0CVM8TXHP", "star": "11", "querystartdt": "2026-03-01", "pageIndex": 2}' --domain 1
```

## Recipe 2: Competitor Deep-Dive (ProductRequest batch → AsinSalesVolume → ASINRequestKeyword → ProductReviewsQuery)

**Scenario**: One-shot panoramic scan for 5-10 competitor ASINs — base info, variant sales history, reverse keywords, review sentiment.

```bash
# Define the competitor ASIN list
COMPETITORS="B0CVM8TXHP,B0XXXXXXX,B0YYYYYYY,B0ZZZZZZZZ,B0AAAAAAAA"

# Step 1: Batch query base info (up to 10 ASINs, 1 request)
sorftime api ProductRequest '{"asin": "'"$COMPETITORS"'", "trend": 1}' --domain 1

# Step 2: Query variant sales history for each (loop, 1 request per ASIN)
for asin in $(echo $COMPETITORS | tr ',' ' '); do
  sorftime api AsinSalesVolume '{"asin": "'"$asin"'", "queryDate": "2026-01-01", "queryEndDate": "2026-03-31"}' --domain 1
done

# Step 3: Reverse-lookup keywords for each (loop, 1 request per ASIN)
for asin in $(echo $COMPETITORS | tr ',' ' '); do
  sorftime api ASINRequestKeyword '{"asin": "'"$asin"'", "pageSize": 100}' --domain 1
done

# Step 4: Directly pull competitor review sentiment (star=10 = negative 1-3 stars)
for asin in $(echo $COMPETITORS | tr ',' ' '); do
  sorftime api ProductReviewsQuery '{"asin": "'"$asin"'", "star": "10", "querystartdt": "2026-04-01"}' --domain 1
done

# Step 5: Fetch more pages on demand
for asin in $(echo $COMPETITORS | tr ',' ' '); do
  sorftime api ProductReviewsQuery '{"asin": "'"$asin"'", "star": "10", "querystartdt": "2026-04-01", "pageIndex": 2}' --domain 1
done
```

**Output archival suggestion**:

```bash
OUTDIR="./competitor-$(date +%Y%m%d)"
mkdir -p "$OUTDIR"
# Redirect each step's result to a file under $OUTDIR/
# Finally use jq to extract price / sales / ratings / brand for the comparison table
```

**Batch extract comparison fields**:

```bash
# Extract key metrics from ProductRequest result
jq '{asin: .data.asin, title: .data.title, price: .data.price, monthlySales: .data.monthlySales, ratings: .data.ratings, brand: .data.brand}' base.json

# Extract the latest monthly sales from AsinSalesVolume
jq '.data | last | {date: .[0], sales: .[1]}' sales.json

# Extract the top 10 keywords from ASINRequestKeyword
jq '.data[:10] | map({keyword: .keyword, share: .ShowShare})' keywords.json
```

**CLI advantages**: `for` loops + variable substitution are native shell capabilities; ASIN list, time range, and page count can all be parameterized.

---

## Recipe 3: Monitoring Deployment (KeywordBatchSubscription + period config + schedule detail extraction)

**Scenario**: Register rank monitoring for 3 core keywords, limit work hours, then verify the deployment result and extract a single monitoring run's detail.

```bash
# Step 1: Register 3 keywords for monitoring
# Conditions: PC browser mode, New York postal code, monitor first 3 pages
# Time slots: Monday-Friday, 9-12 and 13-16 (slots 3, 4), once per slot (frequency 1)
sorftime api KeywordBatchSubscription '{"keyword": ["power bank", "portable charger", "external battery"], "mode": 0, "area": "10041", "page": 3, "period": "1,2,3,4,5|3,4|1"}' --domain 1
# Return example: ["power bank:12345", "portable charger:12346", ...]

# Step 2: Query all valid monitoring tasks to confirm successful registration
sorftime api KeywordTasks '{"pageIndex": 1, "pageSize": 50}' --domain 1

# Step 3: Query all execution batches of a specific task (use taskId from Step 1)
TASK_ID=12345
sorftime api KeywordBatchScheduleList '{"TaskId": '"$TASK_ID"'}' --domain 1
# Return example: ["202604270930:batch001:1:202604270935", ...]

# Step 4: Extract the latest batch's detail data (use ScheduelId from Step 3)
SCHEDULE_ID=batch001
sorftime api KeywordBatchScheduleDetail '{"ScheduelId": "'"$SCHEDULE_ID"'"}' --domain 1
# Return: exposure type, rank, price, seller and other fields for all ASINs in the first 3 pages of this monitoring run

# Step 5 (optional): Modify task settings, e.g. change to hourly monitoring
sorftime api KeywordBatchTaskUpdate '{"taskId": '"$TASK_ID"', "update": 0, "mode": 0, "area": "10041", "page": 3, "period": "1,2,3,4,5|3,4|2"}' --domain 1
```

**period expression cheat sheet**:

```
Format: <which days of the week>|<which time slots each day>|<monitoring frequency>

Which days of the week: 1-7 (comma-separated, 1=Monday, 7=Sunday)
Which time slots each day: 1-6 (each slot is 4 hours, Beijing time)
  1: 1-4,  2: 5-8,  3: 9-12
  4: 13-16, 5: 17-20, 6: 21-0
Monitoring frequency:
  1:  once at any time within the slot
  2:  once per hour within the slot
  3:  once every 2 hours within the slot
  11-14: 1st-4th time slot within the slot
  31: odd hours within the slot, total 2 runs
  32: even hours within the slot, total 2 runs
```

**CLI advantages**: `TASK_ID` and `SCHEDULE_ID` can be written into environment variables or a `.env` file; the whole flow can be wrapped into a single `deploy-monitor.sh` script for one-click deploy + verify.

---

## Recipe 4: Trend Tracking (CategoryTrend trendIndex 0-39 → time series stitching)

**Scenario**: For the same nodeId, query 40 trend indices in sequence, and stitch the last 2 years of sales, monopoly, new product share and other time series into a complete market trend table.

```bash
NODE_ID="7073960011"

# Step 1: Define the core metric indices to track
# 0=sales, 3=average price, 6=1-month new product share, 28=top 3 listing monopoly, 34=top 10 brand monopoly
INDICES="0 3 6 28 34"

# Step 2: Loop through, 2 requests per metric
for idx in $INDICES; do
  echo "=== trendIndex: $idx ==="
  sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": '"$idx"'}' --domain 1 > "trend_${idx}.json"
  sleep 0.3  # control QPS to avoid 429
done

# Step 3: Local stitching (use jq to merge the data fields of multiple JSON files)
# Assume each trend_${idx}.json's data field is [202010,1000,202011,1010,...]
jq -s 'map(.data) | {nodeId: "'"$NODE_ID"'", trends: .}' trend_*.json > "${NODE_ID}_trends.json"

# Step 4: For all 40 metrics, loop 0-39 directly
for idx in $(seq 0 39); do
  sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": '"$idx"'}' --domain 1 > "trend_${idx}.json"
  sleep 0.3
done
```

**Key metric index cheat sheet**:

| Index | Meaning | Analytical use |
|------|------|---------|
| 0 | Sales trend | Judge overall category rise/fall |
| 3 | Average price trend | Whether the price band is moving down |
| 6 | 1-month new product share | Difficulty of new product entry |
| 28 | Top 3 listing monopoly | Top concentration |
| 34 | Top 10 brand monopoly | Brand competition pattern |
| 9 | Amazon self-operated share | Self-operated squeeze degree |
| 12 | Average per-product profit | Profit space change |

**CLI advantages**: This is a "script mode", not a single API call. You can choose 5 core metrics for a quick scan, or pull all 40 metrics for deep analysis; intermediate results are persisted to `.json` files, and you can use `jq` for secondary processing at any time.

---

## Recipe 5: Cross-Platform Comparison (Amazon ProductRequest + Shopee CategoryRequest + Walmart ProductRequest)

**Scenario**: Compare the same product concept (e.g. "water bottle") across Amazon, Shopee, and Walmart.

```bash
# ========================================
# Amazon US site (domain=1)
# ========================================
# First query the category's Best Seller, get the ASIN list
sorftime api CategoryRequest '{"nodeId": "7073960011"}' --domain 1

# Query specific product details (ASIN from the previous step's output)
sorftime api ProductRequest '{"asin": "B0CVM8TXHP", "trend": 1}' --domain 1

# Reverse-lookup keywords
sorftime api ASINRequestKeyword '{"asin": "B0CVM8TXHP", "pageSize": 50}' --domain 1

# ========================================
# Shopee Vietnam site (domain=201)
# ========================================
# Shopee uses productId, not ASIN; CategoryRequest returns productId
sorftime api CategoryRequest '{"nodeId": "11035813"}' --domain 201

# Query product details
sorftime api ProductRequest '{"productId": "21584486278"}' --domain 201

# Query shop info (Shopee-specific endpoint)
sorftime api ShopRequest '{"shopId": "123456"}' --domain 201

# ========================================
# Walmart US site (domain=21)
# ========================================
# Walmart uses nodePath, not nodeId
sorftime api CategoryRequest '{"nodePath": "4044_623679_1032619_5842891_9823303"}' --domain 21

# Query product details (Walmart uses productId)
sorftime api ProductRequest '{"productId": "3319869184"}' --domain 21

# Query variant sales history
sorftime api ProductSalesVolume '{"productId": "3319869184", "queryDate": "2026-01-01", "queryEndDate": "2026-03-31"}' --domain 21

# ========================================
# Three-platform domain quick reference
# ========================================
# Amazon US  -> --domain 1
# Shopee VN  -> --domain 201
# Walmart US -> --domain 21
```

**Three-platform parameter differences**:

| Dimension | Amazon | Shopee | Walmart |
|------|--------|--------|---------|
| Domain | 1 | 201 | 21 |
| Category identifier | `nodeId` | `nodeId` | `nodePath` |
| Product identifier | `asin` | `productId` | `productId` |
| Shop identifier | None (uses sellerName/sellerId) | `shopId` | None (uses seller field) |
| Sales field | `monthlySales` | `salesCount` | `listingSalesVolumeOfMonth` |
| Variant sales endpoint | `AsinSalesVolume` | None | `ProductSalesVolume` |
| Reverse-lookup keywords | `ASINRequestKeyword` | None | `ProductRequestKeyword` |
| Shop query | None | `ShopRequest` | None |

**Batch cross-platform collection script**:

```bash
#!/bin/bash
# cross-platform.sh — batch collection of similar products across three platforms
AMZ_NODE="7073960011"
SHOPEE_NODE="11035813"
WALMART_PATH="4044_623679_1032619_5842891_9823303"
OUTDIR="./cross-platform-$(date +%Y%m%d)"
mkdir -p "$OUTDIR"

sorftime api CategoryRequest '{"nodeId": "'"$AMZ_NODE"'"}' --domain 1 > "$OUTDIR/amz.json"
sorftime api CategoryRequest '{"nodeId": "'"$SHOPEE_NODE"'"}' --domain 201 > "$OUTDIR/shopee.json"
sorftime api CategoryRequest '{"nodePath": "'"$WALMART_PATH"'"}' --domain 21 > "$OUTDIR/walmart.json"

# Unified extraction: title, price, sales, ratings, brand
jq '{platform:"amazon", title:.data[0].title, price:.data[0].price, sales:.data[0].monthlySales, ratings:.data[0].ratings, brand:.data[0].brand}' "$OUTDIR/amz.json" > "$OUTDIR/amz_summary.json"
jq '{platform:"shopee", title:.data.products[0].title, price:.data.products[0].price, sales:.data.products[0].salesCount, ratings:.data.products[0].ratings, brand:.data.products[0].brand}' "$OUTDIR/shopee.json" > "$OUTDIR/shopee_summary.json"
jq '{platform:"walmart", title:.data[0].title, price:.data[0].price, sales:.data[0].listingSalesVolumeOfMonth, ratings:.data[0].ratings, brand:.data[0].brand}' "$OUTDIR/walmart.json" > "$OUTDIR/walmart_summary.json"

jq -s '.' "$OUTDIR"/*_summary.json > "$OUTDIR/comparison.json"
echo "Comparison result: $OUTDIR/comparison.json"
```

**CLI advantages**:
- **Parameter differences are transparent**: Amazon uses `nodeId` + `asin`, Shopee uses `nodeId` + `productId` + `shopId`, Walmart uses `nodePath` + `productId` — the CLI lets you directly face these differences, precisely controlling each platform's inputs.
- **Arbitrary combinations**: You can compare Amazon + Walmart only, or sweep all 8 Shopee sites.
- **Unified output format**: All three platforms' results are JSON, so the same `jq` script can extract fields and generate comparison reports.
