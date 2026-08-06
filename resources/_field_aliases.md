# Sorftime API Field Alias Mapping

> When you can't find a field in an API response, consult this table first. Do not directly conclude "the endpoint doesn't return this data".

## Usage

```bash
# Method 1: Search this file directly (recommended — this is the single source of truth)
grep -i "sales" resources/_field_aliases.md
# Method 2: Inspect the actual fields an endpoint returns
sorftime api <Endpoint> '<json>' --domain <N> --profile <name> | jq '.data | keys'
```

## Product-related (ProductRequest / ProductQuery)

| What you're looking for | Actual field name | Type | Description |
|---------|-----------|------|------|
| ASIN, asin | `Asin` | string | Product identifier |
| title, product name | `Title` | string | Product title |
| price, selling price | `SalesPrice` | number | Selling price (local currency) |
| monthly sales | `ListingSalesVolumeOfMonth` | number | Monthly sales |
| sales trend | `ListingSalesVolumeOfMonthTrend` | array | Monthly sales trend array |
| ratings, reviews, review count | `Ratings` | number | Rating count |
| stars, star rating | `Star` | number | Star rating (some endpoints) |
| brand | `Brand` | string | Brand name |
| seller | `BuyboxSeller` | string | Buybox seller name |
| FBA, shipping method | `IsFBA` | number | 1=FBA, 0=FBM |
| category, BSR category | `BsrCategory` | string | BSR category path |
| node id, category node | `NodeId` or `nodeId` | string | Category node ID |
| sub-asin, variant | `VariationList` | array | Variant list |
| dimensions, size | `Dimensions` | string | Product dimensions |
| weight | `Weight` | string | Product weight |
| listing time, listing date | `ListingTime` | string | Listing date |
| seller id | `SellerId` | string | Seller ID |
| sales rank | `SalesRank` | number | Sales rank |

## Keyword-related (KeywordRequest / ASINRequestKeywordv2 / KeywordQuery)

| What you're looking for | Actual field name | Type | Description |
|---------|-----------|------|------|
| keyword | `Keyword` | string/object | Keyword text (Note: in ASINRequestKeywordv2, Keyword is a nested object) |
| search volume | `SearchVolume` | number | Search volume |
| share, click share | `ShowShare` | number | Click share percentage |
| competition | `competition` | number | Competition index |
| trend | `trend` | array | Keyword trend |
| related keywords | `KeywordExtends` | array | Keyword extension (KeywordExtends endpoint) |
| ABA ranking | `ABARank` | number | ABA rank |

## Category-related (CategoryRequest / CategoryTree / CategoryTrend)

| What you're looking for | Actual field name | Type | Description |
|---------|-----------|------|------|
| asin list | `asinList` | array | ASIN list under the category |
| product count | `ProductCount` | number | Total product count in the category |
| avg price | `AvgPrice` | number | Category average price |
| products, product list | `Products` | array | Product detail list (Note casing) |
| node id, node ID | `nodeId` | string | Category node ID |
| node name | `nodeName` | string | Category node name |
| parent id, parent node | `parentId` | string | Parent node ID |
| trend index | `trendIndex` | number | Trend index (0-39) |
| has children | `hasChildren` | boolean | Whether the category has child categories |

## Variant Sales (AsinSalesVolume)

| What you're looking for | Actual field name | Type | Description |
|---------|-----------|------|------|
| date | (array element [0]) | string | Date |
| sales | (array element [1]) | number | Sales |
| type | (array element [2]) | string | Data type |
| asin, variant ASIN | (outer key) | string | Each variant's ASIN is the outer key |

## Shopee-Specific Fields

| What you're looking for | Actual field name | Type | Description |
|---------|-----------|------|------|
| sale correction | `saleIsCorrection` | number | 1=corrected (reliable), 0=uncorrected |
| shop id, shop ID | `shopId` | string | Shopee shop ID |
| product id, product ID | `productId` | string | Shopee product ID |

## Walmart-Specific Fields

| What you're looking for | Actual field name | Type | Description |
|---------|-----------|------|------|
| product id, product ID | `productId` | string | Walmart product ID |
| sales volume | (returned by ProductSalesVolume) | — | Requires gzip+base64 decoding |

## Monitoring-related (Monitoring series)

| What you're looking for | Actual field name | Type | Description |
|---------|-----------|------|------|
| task id, task ID | `taskId` | string | Monitoring task ID |
| schedule | `scheduleList` | array | Schedule list |
| status | `status` or `Status` | number | Task status code |
| period | `period` | string | Monitoring period expression |

## Common response fields

| What you're looking for | Actual field name | Type | Description |
|---------|-----------|------|------|
| code, status code | `Code` or `code` | number | 0=success, non-zero=error. Casing is inconsistent |
| message, error message | `Message` or `message` | string | Error description |
| data | `Data` or `data` | object/array | Business data |
| request id, request ID | `RequestId` | string | For tech-support troubleshooting |

## Casing traps

The same response may contain both casing variants:
- `Code` / `code` — check `Code` (PascalCase) first, fall back to `code`
- `Data` / `data` — check `Data` (PascalCase) first, fall back to `data`
