# Sorftime Data CLI Recipes

> This document is **not** an endpoint manual, but rather a set of **executable templates for solving concrete business problems**. Each template = problem description + step-by-step commands + expected output.
> For common reference (Domain table, error codes, CLI template), see [`_common.md`](./_common.md).


## Table of Contents

- [Quick access](#quick-access)
- [Natural language search (Quick access)](#natural-language-search-quick-access)
- [1. Basics](#1-basics)
- [1.1 Account and quota management](#11-account-and-quota-management)
- [1.2 Core method basic calls](#12-core-method-basic-calls)
- [1.3 Natural language search](#13-natural-language-search)
- [1.4 Batch execution](#14-batch-execution)
- [2. Product selection](#2-product-selection)
- [2.1 New high-potential products](#21-new-high-potential-products)
- [2.3 Hot potential bestsellers (market breakthrough)](#23-hot-potential-bestsellers-market-breakthrough)
- [2.4 Seasonal hot sellers](#24-seasonal-hot-sellers)
- [2.5 High-price, low-competition potential hits](#25-high-price-low-competition-potential-hits)
- [2.6 FBM hot sellers](#26-fbm-hot-sellers)
- [3. Operations](#3-operations)
- [3.1 Find competitors (via product name search)](#31-find-competitors-via-product-name-search)
- [3.2 Competitor keyword reverse lookup (find common core keywords)](#32-competitor-keyword-reverse-lookup-find-common-core-keywords)
- [3.3 Discover keywords via category](#33-discover-keywords-via-category)
- [3.4 Long-tail keyword extension + CPC analysis](#34-long-tail-keyword-extension--cpc-analysis)
- [3.5 Track your/competitor's exposure rank changes for a keyword](#35-track-yourcompetitors-exposure-rank-changes-for-a-keyword)
- [3.6 Keyword competition analysis](#36-keyword-competition-analysis)
- [3.7 Build your own keyword library](#37-build-your-own-keyword-library)
- [3.8 Full keyword research workflow (from finding competitors to building a library)](#38-full-keyword-research-workflow-from-finding-competitors-to-building-a-library)
- [3.9 Listing creation (from competitor analysis to copy / images output)](#39-listing-creation-from-competitor-analysis-to-copy--images-output)
- [Temu Special](#temu-special)
- [Temu Basic Calls](#temu-basic-calls)
- [Temu Product Query](#temu-product-query)
- [Temu Shop Query](#temu-shop-query)
- [Temu vs Amazon Cross-Platform Comparison](#temu-vs-amazon-cross-platform-comparison)
- [4. Research](#4-research)
- [4.1 Product research](#41-product-research)
- [4.2 Market research](#42-market-research)
- [4.3 Keyword ad-investment research](#43-keyword-ad-investment-research)
- [API name quick reference](#api-name-quick-reference)

---

## Quick access

| What you want to do | Jump |
|-----------|------|
| Don't know the nodeId/ASIN? Start with a **natural language search** to find your target | [Natural language search](#natural-language-search-quick-access) |
| Don't know the endpoint name? See the [API name quick reference](#api-name-quick-reference) |

---

## Natural language search (Quick access)

Don't know the nodeId or ASIN? Start with a fuzzy search by product name / category name, then extract the nodeId / ASIN from the returned result.

| Search target | Endpoint | Supported platform | Example |
|---------|------|---------|------|
| **Find product** | `ProductSearchFromName` | Amazon | `sorftime api ProductSearchFromName '{"name":"water bottle"}' --domain 1` |
| **Find category** | `CategorySearchFromName` | Amazon | `sorftime api CategorySearchFromName '{"name":"bluetooth earphones"}' --domain 1` |
| **Find sourcing** | `ProductSearchFromName` | 1688 | `sorftime api ProductSearchFromName '{"name":"phone case"}' --domain 601` |
| **Find Temu product** | `ProductSearchFromName` | Temu | `sorftime api ProductSearchFromName '{"Name": "bluetooth earphones"}' --domain 701` |

> **Shopee and Walmart do not support category search by name**; Temu supports searching products and categories by name but not a keyword module. You need to first get the nodeId via CategoryTree.

---

## 1. Basics

### 1.1 Account and quota management

```bash
# Query credit balance
sorftime api CoinQuery '{}' --domain 1

# Query request balance and monthly consumption
sorftime api RequestStreamMonth '{}' --domain 1

# Query credit consumption stream
sorftime api CoinStream '{"QueryDate": ["2025-01-01", "2025-01-31"]}' --domain 1
```

### 1.2 Core method basic calls

```bash
# Query a single product's details (most common)
sorftime api ProductRequest '{"asin": "B0CVM8TXHP"}' --domain 1

# Query category Best Seller Top 100
sorftime api CategoryRequest '{"nodeId": "7073960011"}' --domain 1

# Multi-condition combined filtering (keyword + price + sales + star rating)
sorftime api ProductSearch '{"keyword":"Power Bank","priceRangeMin":20,"priceRangeMax":50,"monthSaleVolumeRangeMin":500}' --domain 1

# Query variant sales distribution
sorftime api AsinSalesVolume '{"asin": "B0CVM8TXHP"}' --domain 1

# Query keyword traffic data
sorftime api KeywordRequest '{"keyword": "power bank"}' --domain 1
```

### 1.3 Natural language search

When you don't know the nodeId or ASIN, start with a fuzzy name search.

```bash
# Find products (Amazon)
sorftime api ProductSearchFromName '{"name": "water bottle"}' --domain 1

# Find categories (Amazon)
sorftime api CategorySearchFromName '{"name": "kitchen"}' --domain 1

# Find sourcing (1688)
sorftime api ProductSearchFromName '{"name": "water bottle"}' --domain 601
```

### 1.4 Batch execution

```bash
# Batch query ASIN details (with Python environment)
python3 scripts/sf-batch.py ProductRequest --input-file asins.txt --param-field asin --domain 1

# Batch query ASIN details (pure CLI)
while read asin; do
  sorftime api ProductRequest "{\"asin\":\"$asin\"}" --domain 1
  sleep 1
done < asins.txt

# Batch query variant sales
python3 scripts/sf-batch.py AsinSalesVolume --input-file asins.txt --param-field asin --domain 1

# Paginate through all products in a category
for page in $(seq 1 5); do
  sorftime api CategoryProducts '{"nodeId": "7073960011", "page": '$page'}' --domain 1
  sleep 1
done
```

---

## 2. Product selection

### 2.1 New high-potential products

**Idea**: New products, with some sales, high star rating (customer satisfaction), few reviews.

| Metric | Requirement | ProductSearch support |
|------|------|-------------------|
| Monthly sales | 500+ (some sales) | ✅ `monthSaleVolumeRangeMin/Max` |
| Listed in last 3-6 months | <6 months | ✅ `onlineDateRangeMin` |
| Few reviews (low competition) | ≤200 | ✅ `commentCountRangeMax` |
| Good star rating | ≥4.0 | ✅ `starRangeMin` |

---

### 2.3 Hot potential bestsellers (market breakthrough)

**Idea**: High sales but low rating or high negative rating rate; existing products don't fully satisfy users; suitable for factory-type or supply-chain-type sellers.

| Metric | Requirement | ProductSearch support |
|------|------|-------------------|
| Monthly sales | 5000+ | ✅ `monthSaleVolumeRangeMin` |
| Overall rating | ≤4.0 | ✅ `starRangeMax` |

---

### 2.4 Seasonal hot sellers

**Idea**: View seasonal hot-selling products, plan ahead, capture traffic.

| Metric | Requirement | ProductSearch support |
|------|------|-------------------|
| Hot in a specific month | Custom month | ✅ `PeakSellingSeason` |

---

### 2.5 High-price, low-competition potential hits

**Idea**: Large market size, low rating (product has room to break through), high price (filters out competitors and yields good profit).

| Metric | Requirement | ProductSearch support |
|------|------|-------------------|
| Monthly sales | 5000+ | ✅ `monthSaleVolumeRangeMin/Max` |
| Rating | <4 | ✅ `starRangeMax` |
| Price | >$60 USD | ✅ `priceRangeMin` |

---

### 2.6 FBM hot sellers

**Idea**: FBM (merchant-fulfilled) can sell well, indicating an FBA launch would be even more advantageous.

| Metric | Requirement | ProductSearch support |
|------|------|-------------------|
| Monthly sales | 500+ | ✅ `monthSaleVolumeRangeMin` |
| Shipping method | FBM | ✅ `shippingType` |

---

## 3. Operations

### 3.1 Find competitors (via product name search)

**Scenario**: I have a product concept and want to find the top competitors in the niche.

```bash
# Step 1: Fuzzy search by product name, returns hot-selling products
sorftime api ProductSearchFromName '{"name": "water bottle"}' --domain 1

# Step 2: From the returned results, pick the Top 20 with the highest monthly sales as target competitors
# (Manually extract the ASIN and title of the top 20 products)

# Step 3: Batch query these 20 competitors' details (at most 10 ASINs per request, so 2 calls)
sorftime api ProductRequest '{"asin": "B0XXXXX01,B0XXXXX02,B0XXXXX03,B0XXXXX04,B0XXXXX05,B0XXXXX06,B0XXXXX07,B0XXXXX08,B0XXXXX09,B0XXXXX10"}' --domain 1
sorftime api ProductRequest '{"asin": "B0XXXXX11,B0XXXXX12,B0XXXXX13,B0XXXXX14,B0XXXXX15,B0XXXXX16,B0XXXXX17,B0XXXXX18,B0XXXXX19,B0XXXXX20"}' --domain 1
```

---

### 3.2 Competitor keyword reverse lookup (find common core keywords)

**Scenario**: For which keywords do these competitors get exposure? What core keywords do they all depend on?

```bash
# For each competitor ASIN, reverse-lookup the last 30 days' exposure keywords
sorftime api ASINRequestKeyword '{"asin": "B0XXXXX01", "pageIndex": 1, "pageSize": 100}' --domain 1
sorftime api ASINRequestKeyword '{"asin": "B0XXXXX02", "pageIndex": 1, "pageSize": 100}' --domain 1
sorftime api ASINRequestKeyword '{"asin": "B0XXXXX03", "pageIndex": 1, "pageSize": 100}' --domain 1
# ... continue for the Top 20 competitors

# Look up details of common keywords (to understand search volume and CPC)
sorftime api KeywordRequest '{"keyword": "water bottle"}' --domain 1
sorftime api KeywordRequest '{"keyword": "sports water bottle"}' --domain 1
sorftime api KeywordRequest '{"keyword": "insulated water bottle"}' --domain 1
```

> **Analytical tip**: Merge the 20 competitors' keyword results and count how many competitors share each keyword. Keywords shared by most competitors = core keywords; keywords only exposed by a few competitors = differentiation opportunities.

---

### 3.3 Discover keywords via category

**Scenario**: Don't go through competitors; find the keywords buyers commonly search for, directly from the category dimension.

```bash
# Step 1: Find the target category
sorftime api CategorySearchFromName '{"name": "water bottle"}' --domain 1
# Returns: [{"NodeId": "XXXXXXX", "CategoryName": "Sports Water Bottles"}]

# Step 2: Reverse-lookup keywords by category
sorftime api CategoryRequestKeyword '{"nodeid": "XXXXXXX", "pageIndex": 1, "pageSize": 100}' --domain 1
sorftime api CategoryRequestKeyword '{"nodeid": "XXXXXXX", "pageIndex": 2, "pageSize": 100}' --domain 1
```

> **Difference from 3.2**: 3.2 starts from a specific product's exposure keywords (more precise); this method starts from the category as a whole (broader coverage, suitable when you have a new product and no competitors to reference).

---

### 3.4 Long-tail keyword extension + CPC analysis

**Scenario**: After finding 3-5 core keywords, dig for more long-tail opportunities and understand the CPC cost.

```bash
# Step 1: Find extended (long-tail) keywords from a core keyword
sorftime api KeywordExtends '{"keyword": "water bottle", "pageIndex": 1, "pageSize": 100}' --domain 1
sorftime api KeywordExtends '{"keyword": "sports water bottle", "pageIndex": 1, "pageSize": 100}' --domain 1

# Step 2: Look up CPC and search-volume trend for keywords of interest
sorftime api KeywordRequest '{"keyword": "insulated water bottle 32oz"}' --domain 1
sorftime api KeywordRequest '{"keyword": "water bottle with time marker"}' --domain 1
# Returns include: weekly rank, search volume trend, CPC price trend, related categories

# Step 3: Look at the keyword search results to see which products are on top
sorftime api KeywordSearchResults '{"keyword": "insulated water bottle 32oz", "pageIndex": 1, "pageSize": 50}' --domain 1
```

---

### 3.5 Track your/competitor's exposure rank changes for a keyword

**Scenario**: I want to know whether my product (or a competitor's) is rising or falling in the exposure position for a core keyword.

```bash
MY_ASIN="B0CVM8TXHP"
COMPETITOR_ASIN="B0XXXXX01"

# Track your own product's rank change (last 1 year)
sorftime api ASINKeywordRanking '{"keyword": "water bottle", "ASIN": "'"$MY_ASIN"'", "queryStart": "2025-05-01", "queryEnd": "2026-05-21"}' --domain 1

# Compare a competitor's rank change for the same keyword
sorftime api ASINKeywordRanking '{"keyword": "water bottle", "ASIN": "'"$COMPETITOR_ASIN"'", "queryStart": "2025-05-01", "queryEnd": "2026-05-21"}' --domain 1

# Track long-tail keyword rank (usually long-tail keywords rank higher)
sorftime api ASINKeywordRanking '{"keyword": "insulated water bottle 32oz", "ASIN": "'"$MY_ASIN"'"}' --domain 1
```

> **Analytical tip**: Compare your and your competitor's rank trend for the same keyword. If the competitor's rank is consistently rising while yours is falling, you need to adjust your listing optimization strategy.

---

### 3.6 Keyword competition analysis

**Scenario**: For a given keyword, which products occupy the top positions? What are their sales, star rating, reviews, and brand distribution? Which keywords are less competitive?

```bash
# Compare the competition intensity of different keywords

# Word A: head term "water bottle"
sorftime api KeywordSearchResults '{"keyword": "water bottle", "pageSize": 50}' --domain 1

# Word B: long-tail "insulated water bottle 32oz"
sorftime api KeywordSearchResults '{"keyword": "insulated water bottle 32oz", "pageSize": 50}' --domain 1

# Word C: more specific long-tail "water bottle with straw"
sorftime api KeywordSearchResults '{"keyword": "water bottle with straw", "pageSize": 50}' --domain 1

# Analyze key metrics in the returned results:
# - monthlySales: are the top products' monthly sales too high?
# - ratings: do the top products all have high review counts?
# - score: are the top products' star ratings all 4.5+?
# - brand: are the top products dominated by a few brands?

# Look up the details of a competitor you're interested in
sorftime api ProductRequest '{"asin": "B0XXXXX01"}' --domain 1
```

> **Judgement method**:
> - If the top 50 mostly have reviews >1000, star ratings >4.5, monthly sales >5000 → highly competitive
> - If the top 50 have many with reviews <200, star ratings <4.0, monthly sales 500-2000 → moderately competitive, good opportunity to enter
> - Compare multiple keywords to find the least competitive but with decent search volume

---

### 3.7 Build your own keyword library

**Scenario**: High-value keywords filtered out during research, categorized and saved, used later for listing optimization and ad placement.

```bash
# Step 1: View existing folders
sorftime api GetFavoriteKeyword '{"Command": "dict"}' --domain 1

# Step 2: Save core keywords (high search volume, high relevance)
sorftime api FavoriteKeyword '{"keyword": "water bottle", "dict": "core-words"}' --domain 1
sorftime api FavoriteKeyword '{"keyword": "sports water bottle", "dict": "core-words"}' --domain 1
sorftime api FavoriteKeyword '{"keyword": "insulated water bottle", "dict": "core-words"}' --domain 1

# Step 3: Save long-tail keywords (low competition, high conversion)
sorftime api FavoriteKeyword '{"keyword": "insulated water bottle 32oz", "dict": "long-tail-words"}' --domain 1
sorftime api FavoriteKeyword '{"keyword": "water bottle with time marker", "dict": "long-tail-words"}' --domain 1

# Step 4: View all keywords in a folder
sorftime api GetFavoriteKeyword '{"Command": "dict=core-words"}' --domain 1
sorftime api GetFavoriteKeyword '{"Command": "dict=long-tail-words"}' --domain 1

# Step 5: Re-categorize a keyword by moving it
sorftime api ChangeFavoriteKeyword '{"keyword": "water bottle with straw", "command": "move=high-priority"}' --domain 1

# Step 6: Delete a keyword you no longer need
sorftime api ChangeFavoriteKeyword '{"keyword": "old keyword", "command": "del"}' --domain 1

# Step 7: View all saved keywords
sorftime api GetFavoriteKeyword '{"Command": "all", "Page": 1}' --domain 1
```

> **Library management tips**:
> - **Core words**: search volume >10000/week, used in title and core copy
> - **Long-tail words**: search volume 1000-10000/week, used in five-point description and Search Terms
> - **Low-CPC words**: CPC < $0.50, used for ad placement testing
> - **High-priority words**: words with both decent search volume and low competition, focus on optimization

---

### 3.8 Full keyword research workflow (from finding competitors to building a library)

**Scenario**: Chain 3.1-3.7 together to complete a one-shot full keyword research.

```bash
# Step 1: Find competitors (search by product name → take Top 20)
sorftime api ProductSearchFromName '{"name": "water bottle"}' --domain 1

# Step 2: Reverse-lookup competitor keywords (find common keywords)
sorftime api ASINRequestKeyword '{"asin": "B0XXXXX01", "pageSize": 50}' --domain 1
sorftime api ASINRequestKeyword '{"asin": "B0XXXXX02", "pageSize": 50}' --domain 1

# Step 3: Look up extended keywords from core keywords (dig for long-tail)
sorftime api KeywordExtends '{"keyword": "water bottle", "pageSize": 50}' --domain 1

# Step 4: Look up keyword details (CPC and search volume)
sorftime api KeywordRequest '{"keyword": "insulated water bottle 32oz"}' --domain 1

# Step 5: Analyze keyword search results (evaluate competition)
sorftime api KeywordSearchResults '{"keyword": "insulated water bottle 32oz", "pageSize": 50}' --domain 1

# Step 6: Track rank change (understand your product's exposure ability)
sorftime api ASINKeywordRanking '{"keyword": "water bottle", "ASIN": "B0CVM8TXHP", "queryStart": "2025-05-01", "queryEnd": "2026-05-21"}' --domain 1

# Step 7: Add valuable keywords to your folder
sorftime api FavoriteKeyword '{"keyword": "water bottle", "dict": "core-words"}' --domain 1
sorftime api FavoriteKeyword '{"keyword": "insulated water bottle 32oz", "dict": "long-tail-words"}' --domain 1
```

---

### 3.9 Listing creation (from competitor analysis to copy / images output)

**Scenario**: Have chosen a product direction and want to create a new listing. By analyzing top competitor features and negative reviews, optimize the title, five-point description, and images in a targeted way.

```bash
# Step 1: Find the core category by name
sorftime api CategorySearchFromName '{"name": "water bottle"}' --domain 1
# Returns: [{"NodeId": "XXXXXXX", "CategoryName": "Sports Water Bottles"}]

# Step 2: Get the top 20 best-selling products in this category
sorftime api CategoryRequest '{"nodeId": "XXXXXXX"}' --domain 1
# Extract the top 20 ASINs from the returned Top 100

# Step 3: Batch get these 20 competitors' details, extract product features
sorftime api ProductRequest '{"asin": "B0XXXXX01,B0XXXXX02,B0XXXXX03,B0XXXXX04,B0XXXXX05,B0XXXXX06,B0XXXXX07,B0XXXXX08,B0XXXXX09,B0XXXXX10"}' --domain 1
sorftime api ProductRequest '{"asin": "B0XXXXX11,B0XXXXX12,B0XXXXX13,B0XXXXX14,B0XXXXX15,B0XXXXX16,B0XXXXX17,B0XXXXX18,B0XXXXX19,B0XXXXX20"}' --domain 1
# Extract key points: material, capacity, selling points, price range, FBA/FBM, variant count

# Step 4: Directly pull competitors' negative reviews (1-3 stars), get the user pain points
# star parameter: 1/2/3/4/5=corresponding star rating, 10=negative reviews (1-3 stars), 11=positive reviews (4-5 stars)
sorftime api ProductReviewsQuery '{"asin": "B0XXXXX01", "star": "10", "pageIndex": 1}' --domain 1
sorftime api ProductReviewsQuery '{"asin": "B0XXXXX01", "star": "10", "pageIndex": 2}' --domain 1
sorftime api ProductReviewsQuery '{"asin": "B0XXXXX02", "star": "10", "pageIndex": 1}' --domain 1
sorftime api ProductReviewsQuery '{"asin": "B0XXXXX03", "star": "10", "pageIndex": 1}' --domain 1
# To collect separately by star rating, e.g. 1, 2, 3 stars each with 3 pages:
sorftime api ProductReviewsQuery '{"asin": "B0XXXXX01", "star": "1", "pageIndex": 3}' --domain 1
sorftime api ProductReviewsQuery '{"asin": "B0XXXXX01", "star": "2", "pageIndex": 3}' --domain 1
sorftime api ProductReviewsQuery '{"asin": "B0XXXXX01", "star": "3", "pageIndex": 3}' --domain 1
```

**Steps 5-6 output (generated based on data)**:

> Step 5: Based on the product common features extracted in Step 3 + the negative review pain points in Step 4, generate the title and five-point description.
>
> **Title formula**: `[core brand word] + [core keyword] + [key selling point / material] + [spec / capacity] + [use case]`
>
> **Five-point description framework**:
> - Point 1: Core selling point (solves the biggest competitor pain point)
> - Point 2: Material / craft advantage
> - Point 3: Use case / target audience
> - Point 4: Differentiated feature (user wanted but missing from competitors' negative reviews)
> - Point 5: After-sales guarantee / quality commitment
>
> Step 6: Based on product features and review pain points, plan 5 e-commerce style image prompts:
>
> | Image # | Type | Prompt direction |
> |---------|------|-----------|
> | Image 1 | Main image | White background, front view of the product, highlighting the core appearance |
> | Image 2-3 | Selling point | Target the core pain points in competitors' negative reviews, showcase the solution |
> | Image 4 | Scene | Target user using the product in a real scenario |
> | Image 5 | Detail / material | Close-up of key craft details, emphasizing quality |
>
> **Analytical tip**: High-frequency items in negative reviews = real user pain points, which must be emphasized in copy and images as how your product solves these problems. This is the most direct differentiation weapon for a new product to enter the market.

---

## Temu Special

### Temu Basic Calls

```bash
# Get Temu US site category tree
sorftime api CategoryTree --domain 701

# Search Temu category by name
sorftime api CategorySearchFromName '{"Name": "bluetooth earphones"}' --domain 701

# Query category market Best Seller Top 100
sorftime api CategoryRequest '{"NodeId": "1001"}' --domain 701

# Multi-dimensional filter on category market (monthly sales 10000-250000)
sorftime api CategorySearch '{"SaleCountMin": 10000, "SaleCountMax": 250000}' --domain 701
```

### Temu Product Query

```bash
# Search products by name (up to 200 returned)
sorftime api ProductSearchFromName '{"Name": "bluetooth earphones"}' --domain 701

# Product details
sorftime api ProductRequest '{"ProductId": "601100479336513"}' --domain 701

# Multi-dimensional filter on products (fully-managed, monthly sales 100-50000, star rating 4.0+)
sorftime api ProductSearch '{"ManageType": 2, "SaleCountMin": 100, "SaleCountMax": 50000, "StarMin": 4.0}' --domain 701

# Product historical trend
sorftime api ProductTrendRequest '{"ProductId": "601100479336513"}' --domain 701
```

### Temu Shop Query

```bash
# Shop details
sorftime api ShopRequest '{"ShopId": "SHOP123456"}' --domain 701
```

### Temu vs Amazon Cross-Platform Comparison

```bash
# Same keyword comparison on Amazon US and Temu US markets
sorftime api ProductSearchFromName '{"name": "water bottle"}' --domain 1       # Amazon
sorftime api ProductSearchFromName '{"Name": "water bottle"}' --domain 701    # Temu

# Category target market comparison
sorftime api CategorySearchFromName '{"name": "kitchen"}' --domain 1          # Amazon
sorftime api CategorySearchFromName '{"Name": "kitchen"}' --domain 701       # Temu
```

> **Temu vs Amazon field naming differences**:
> - Temu uses `ProductId` rather than `asin`
> - Monthly sales → `MonthlySaleCount` (Amazon is `ListingSalesVolumeOfMonth`)
> - Cumulative sales → `CumulativeSaleCount`
> - Price → `Price` (Amazon is `SalesPrice`)
> - Review count → `ReviewCount` (Amazon is `RatingsCount`)
> - Management type → `ManagedType` (fully-managed / semi-managed, Temu-specific field)
>
> **Note**: Temu does not provide a keyword module or any keyword-related endpoints.

---

## 4. Research

### 4.1 Product research

#### 4.1.1 One-shot pull of all data for a competitor

**Question**: Competitor ASIN is known, I want to know all their data.

```bash
# Product details (including last 15 days trend)
sorftime api ProductRequest '{"asin": "B0CVM8TXHP"}' --domain 1

# Officially disclosed variant sales (see which color / size sells best)
sorftime api AsinSalesVolume '{"asin": "B0CVM8TXHP"}' --domain 1

# Variant change history (check whether they merge variants to consolidate reviews)
sorftime api ProductVariations '{"asin": "B0CVM8TXHP"}' --domain 1

# Which keywords the competitor gets exposure on
sorftime api ASINRequestKeyword '{"asin": "B0CVM8TXHP", "pageSize": 100}' --domain 1

# Find similar products (competitor benchmark)
sorftime api ProductSearch '{"asin": "B0CVM8TXHP"}' --domain 1
```

#### 4.1.2 Batch comparison of multiple competitors

**Question**: I have 5 competitor ASINs, I want a quick comparison.

```bash
# Query 10 ASINs at once (max 10), 1 request
sorftime api ProductRequest '{"asin": "B0CVM8TXHP,B0ASIN002,B0ASIN003,B0ASIN004,B0ASIN005"}' --domain 1

# Query each competitor's variant sales separately
sorftime api AsinSalesVolume '{"asin": "B0CVM8TXHP"}' --domain 1
sorftime api AsinSalesVolume '{"asin": "B0ASIN002"}' --domain 1
```

#### 4.1.3 Cross-platform comparison

```bash
# Amazon US vs Walmart US same-keyword price-difference analysis (US)
sorftime api KeywordSearchResults '{"keyword": "power bank", "pageSize": 50}' --domain 1
sorftime api KeywordSearchResults '{"keyword": "power bank", "pageSize": 50}' --domain 21

# Amazon US vs 1688 sourcing price comparison (selling price vs sourcing cost)
sorftime api ProductSearchFromName '{"name": "water bottle"}' --domain 1
sorftime api ProductSearchFromName '{"name": "water bottle"}' --domain 601

# Amazon same-category comparison across sites (US vs UK vs DE)
sorftime api CategoryRequest '{"nodeId": "7073960011"}' --domain 1
sorftime api CategoryRequest '{"nodeId": "7073960011"}' --domain 2
sorftime api CategoryRequest '{"nodeId": "7073960011"}' --domain 3
```

#### 4.1.4 Walmart Special

```bash
# Walmart keyword research
sorftime api KeywordQuery '{"pattern": {"rankCondition": ["1", "5000"]}, "pageSize": 100}' --domain 21
sorftime api KeywordRequest '{"keyword": "power bank"}' --domain 21
sorftime api KeywordExtends '{"keyword": "power bank", "pageSize": 100}' --domain 21

# Walmart product reverse-lookup keywords
sorftime api ProductRequestKeyword '{"productId": "3319869184", "pageSize": 100}' --domain 21

# Walmart product details + trend + variant sales
sorftime api ProductRequest '{"productId": "3319869184"}' --domain 21
sorftime api ProductTrendRequest '{"productId": "3319869184"}' --domain 21
sorftime api ProductSalesVolume '{"productId": "3319869184"}' --domain 21
```

---

### 4.2 Market research

#### 4.2.1 Category Best Seller analysis

**Question**: What do the Top 100 products in this category look like? What's the price band, sales, and brand distribution?

```bash
# Find the target category first
sorftime api CategorySearchFromName '{"name": "water bottle"}' --domain 1
# Returns: [{"NodeId": "XXXXXXX", "CategoryName": "Sports Water Bottles"}]

# Query the category Best Seller Top 100
sorftime api CategoryRequest '{"nodeId": "XXXXXXX"}' --domain 1

# For a more complete long-tail market view, query Top400
for page in $(seq 1 4); do
  sorftime api CategoryProducts '{"nodeId": "XXXXXXX", "page": '$page'}' --domain 1
  sleep 1
done
```

> **Analytical tip**: Calculate from the Top 100 data:
> - Price band distribution ($10-20 / $20-40 / $40+)
> - Brand concentration (top 3 brands' sales share)
> - Seller concentration (top 3 sellers' sales share)
> - New product share (how many listed within 3 months)

#### 4.2.2 Category market trend analysis

**Question**: Is this category rising or falling? How monopolized is it? Are new products still finding opportunities?

```bash
NODE_ID="XXXXXXX"

# Core metrics one-key query
# Sales trend (judge overall category rise/fall)
sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": 0}' --domain 1

# Average price trend (judge whether price is rolling down)
sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": 3}' --domain 1

# Top 3 listing monopoly index (judge top concentration)
sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": 28}' --domain 1

# Top 10 brand monopoly index (judge brand competition)
sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": 34}' --domain 1

# 1-month new product share trend (judge new product entry difficulty)
sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": 6}' --domain 1

# Amazon self-operated share trend (judge self-operated squeeze)
sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": 9}' --domain 1

# FBM product share trend (judge merchant-fulfilled opportunity)
sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": 10}' --domain 1

# Average per-product profit trend
sorftime api CategoryTrend '{"nodeId": "'"$NODE_ID"'", "trendIndex": 12}' --domain 1
```

> **Trend type cheat sheet**:
> | trendIndex | Meaning | Analytical use |
> |------------|------|---------|
> | 0 | Sales trend | Judge overall category rise/fall |
> | 3 | Average price trend | Whether the price band is moving down |
> | 6 | 1-month new product share | New product entry difficulty |
> | 9 | Amazon self-operated share | Self-operated squeeze |
> | 10 | FBM product share | Merchant-fulfilled room |
> | 12 | Average per-product profit | Profit space change |
> | 28 | Top 3 listing monopoly | Top concentration |
> | 34 | Top 10 brand monopoly | Brand competition |

#### 4.2.3 Historical Best Seller comparison

**Question**: What's the difference between this category half a year ago and now? Which brands rose, which dropped?

```bash
# Query historical Best Seller (2026-01-01 to 2026-01-10)
sorftime api CategoryRequest '{"NodeId": "XXXXXXX", "queryStart": "2026-01-01", "queryDate": "2026-01-10"}' --domain 1

# Query current Best Seller
sorftime api CategoryRequest '{"NodeId": "XXXXXXX"}' --domain 1

# Compare the two datasets:
# - Which ASINs disappeared from the Top 100? (products may have been delisted or surpassed)
# - Which ASINs are new to the Top 100? (signal of new product opportunity)
# - Brand and seller rank changes
```

---

### 4.3 Keyword ad-investment research

#### 4.3.1 Keyword search volume and CPC research

**Question**: What's the search volume of the keyword I want to bid on? What's the CPC cost? What's the trend?

```bash
# Query core keyword details (search volume, CPC, related categories)
sorftime api KeywordRequest '{"keyword": "water bottle"}' --domain 1
sorftime api KeywordRequest '{"keyword": "sports water bottle"}' --domain 1
sorftime api KeywordRequest '{"keyword": "insulated water bottle"}' --domain 1

# Query keyword search volume trend (judge seasonality)
sorftime api KeywordRequest '{"keyword": "water bottle"}' --domain 1
# Returns include search volume trend and CPC price trend
```

#### 4.3.2 Long-tail keyword discovery

**Question**: The core keyword's CPC is too high; are there long-tail keywords with decent search volume but lower competition?

```bash
# Find extended keywords from a core keyword
sorftime api KeywordExtends '{"keyword": "water bottle", "pageIndex": 1, "pageSize": 100}' --domain 1

# Look up details for keywords of interest
sorftime api KeywordRequest '{"keyword": "insulated water bottle 32oz"}' --domain 1
sorftime api KeywordRequest '{"keyword": "water bottle with time marker"}' --domain 1
```

#### 4.3.3 Keyword competition analysis

**Question**: What products occupy the front row of the search results page for a keyword? Is competition fierce?

```bash
# Query keyword search results, see the front-row products
sorftime api KeywordSearchResults '{"keyword": "water bottle", "pageIndex": 1, "pageSize": 50}' --domain 1
sorftime api KeywordSearchResults '{"keyword": "insulated water bottle 32oz", "pageIndex": 1, "pageSize": 50}' --domain 1

# Analyze key metrics in the returned results:
# - monthlySales: are the top products' monthly sales too high?
# - ratings: do the top products all have high review counts?
# - score: are the top products' star ratings all 4.5+?
# - brand: are the top products dominated by a few brands?
```

> **Judgement method**:
> - If the top 50 mostly have reviews >1000, star ratings >4.5, monthly sales >5000 → highly competitive, high CPC investment
> - If the top 50 have many with reviews <200, star ratings <4.0, monthly sales 500-2000 → moderately competitive, suitable for new product placement

#### 4.3.4 Competitor keyword reverse lookup (to guide placement strategy)

**Question**: What keywords are the competitors bidding on? What should I bid on?

```bash
# Reverse-lookup which keywords a competitor ASIN gets exposure on
sorftime api ASINRequestKeyword '{"asin": "B0CVM8TXHP", "pageIndex": 1, "pageSize": 100}' --domain 1

# View the competitor's exposure rank trend for a core keyword
sorftime api ASINKeywordRanking '{"keyword": "water bottle", "ASIN": "B0CVM8TXHP", "queryStart": "2025-05-01", "queryEnd": "2026-05-21"}' --domain 1
```

> **Analytical tip**:
> - Keywords where the competitor gets exposure = their traffic sources
> - Keywords where the competitor's rank is consistently rising = the keywords they are focusing on optimizing / bidding on
> - Keywords where the competitor has exposure but a low rank = your differentiation opportunity

#### 4.3.5 Trending keyword discovery

**Question**: What's hot right now? Is there a trend I can ride?

```bash
# View the real-time trending keyword list (sorted by weekly search volume)
sorftime api KeywordList --domain 1

# View the details of a specific trending keyword
sorftime api KeywordRequest '{"keyword": "trending keyword here"}' --domain 1

# View extended keywords of a trending keyword
sorftime api KeywordExtends '{"keyword": "trending keyword here", "pageSize": 50}' --domain 1
```

---

## API name quick reference

Don't know the endpoint name? Locate quickly by scenario:

| You want to... | Endpoint | Description |
|--------|------|------|
| **Basics** | | |
| Query product details | `ProductRequest` | Query up to 10 ASINs at once, includes 15-day trend |
| Query category hot-sellers | `CategoryRequest` | Category Best Seller Top 100 |
| Search products (no ASIN) | `ProductSearchFromName` | Fuzzy search by name |
| Search categories (no nodeId) | `CategorySearchFromName` | Fuzzy search by name |
| Filter products by conditions | `ProductSearch` | Category + price + sales + star rating |
| Query credit / request balance | `CoinQuery` / `RequestStreamMonth` | Common to all platforms |
| **Product selection** | | |
| Multi-dimensional product filtering | `ProductSearch` | Monthly sales / price / star rating / reviews / listing date / shipping method |
| Historical month products | `ProductSearch queryMonth` | Look back at historical hot-sellers |
| Seasonal products | `ProductSearch peakSellingSeason` | Specify a peak-season month |
| Query variant sales | `AsinSalesVolume` | Officially disclosed data |
| Top 100 / Top 400 | `CategoryRequest` / `CategoryProducts` | Long-tail market share calculation |
| **Operations** | | |
| Query product reviews | `ProductReviewsQuery` | Pull directly, no need to collect first |
| Reverse-lookup competitor keywords | `ASINRequestKeyword` | Last 30 days exposure keywords |
| Query keyword traffic | `KeywordRequest` | Search volume, CPC, related categories |
| Long-tail keyword discovery | `KeywordExtends` | Long-tail words |
| Register keyword monitoring | `KeywordBatchSubscription` | Scheduled rank tracking |
| Keyword library | `FavoriteKeyword` / `GetFavoriteKeyword` | Favorite management |
| Register hijacker monitoring | `ProductSellerSubscription` | Consumes credits |
| Register Best Seller list monitoring | `BestSellerListSubscription` | Scheduled list collection |
| Subscribe ASIN tracking | `ASINSubscription` | Up to 100 per call |
| Query real-time data | `ProductRealtimeRequest` | Triggers if not updated in 24h |
| Image-search product | `SimilarProductRealtimeRequest` | Consumes credits |
| **Research** | | |
| Query variant change history | `ProductVariations` | Variant data |
| Find similar products | `ProductSearch` (with asin) | Competitor benchmark |
| Shopee shop | `ShopRequest` | Product line layout |
| Walmart product trend | `ProductTrendRequest` | Historical trend |
| Walmart variant sales | `ProductSalesVolume` | Query by productId |
| Sourcing | `ProductSearchFromName` (1688) | domain=601 |
| **Temu product details** | `ProductRequest` | Query by ProductId |
| **Temu product search** | `ProductSearch` | Multi-dimensional filtering (management type / sales / price / star rating) |
| **Temu product trend** | `ProductTrendRequest` | Sales / price / review / star rating trend |
| **Temu category market** | `CategorySearch` | Multi-dimensional category market filtering |
| **Temu shop query** | `ShopRequest` | Shop details (fans / type / management type) |
| **Temu vs Amazon** | Cross-platform comparison | Same keyword comparison on domain 1 vs 701 |
