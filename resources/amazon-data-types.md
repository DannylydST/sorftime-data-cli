# Amazon Data Type Definitions

> Data field type definitions for all Amazon endpoints. Each endpoint document only describes the type of the `data` field; for individual fields, see this document.
> All endpoints share a common outer response structure: `requestLeft`, `requestConsumed`, `requestCount`, `code`, `message`, `data`.

> **Field-naming convention**: This document uses **camelCase** (e.g. `parentAsin`, `listingSalesOfMonth`) to describe data types. Newer endpoint parameters and response fields are described in **PascalCase** (e.g. `ParentAsin`, `ListingSalesOfMonth`); treat camelCase and PascalCase spellings as the same field (the API returns them inconsistently — always check both). The old name `ProductVariationHistory` has been renamed to `ProductVariations`; `ASINRequestKeywordv2` has been renamed to `ASINRequestKeyword`. The old names still work in requests.

---

## Table of Contents

### Category & Product
- [CategoryTreeObject](#categorytreeobject) — Category tree node
- [CategoryObject](#categoryobject) — Category node
- [ProductListObject](#productlistobject) — Product list
- [ProductSummeryObject](#productsummeryobject) — Product summary
- [ProductObject](#productobject) — Product details
- [AsinSalesVolumeObject](#asinsalesvolumeobject) — Variant sales
- [ProductVariationHistoryObject](#productvariationhistoryobject) — Variant history
- [SimilarProductObject](#similarproductobject) — Image-search similar products
- [AsinSummaryObject](#asinsummaryobject) — ASIN summary

### Review
- [ReviewsObject](#reviewsobject) — Review object

### Keyword
- [KeywordSummeryObject](#keywordsummeryobject) — Keyword summary
- [KeywordObject](#keywordobject) — Keyword details
- [ASINKeywordItemObject](#asinkeyworditemobject) — ASIN reverse-lookup keyword item
- [KeywordSearchResultItem](#keywordsearchresultitem) — Search result item

### Rank
- [KeywordProductRankingObject](#keywordproductrankingobject) — Keyword historical product rank

### Monitoring (task / batch / detail)
- [KeywordTaskObject](#keywordtaskobject) — Keyword monitoring task
- [KeywordBatchScheduleObject](#keywordbatchscheduleobject) — Monitoring batch
- [KeywordBatchScheduleDetailObject](#keywordbatchscheduledetailobject) — Batch details
- [BestSellerListItemObject](#bestsellerlistitemobject) — Best Seller list item
- [ProductSellerTaskObject](#productsellertaskobject) — Hijacker monitoring task
- [ProductSellerScheduleDetailObject](#productsellerscheduledetailobject) — Hijacker monitoring details

### Account
- [CoinQueryObject](#coinqueryobject) — Credit balance
- [RequestStreamMonthObject](#requeststreammonthobject) — Monthly request usage

---

## CategoryTreeObject

A category tree node. The CategoryTree endpoint returns an array of this object.

| Field | Type | Description |
|------|------|------|
| Id | Integer | Category ID |
| ParentId | Integer | Parent category ID; 0 = top-level category |
| NodeId | String | Platform-native category ID (used for subsequent queries) |
| Name | String | English name of the category |
| CNName | String | Chinese name of the category |
| URL | String | Platform page URL for the category |

---

## CategoryObject

A category Best Seller object. Returned in the `data` field of CategoryRequest.

| Field | Type | Description |
|------|------|------|
| products | Array of [ProductSummeryObject](#productsummeryobject) | Best Seller list products |

---

## ProductListObject

A product list object. Returned in the `data` field of CategoryProducts, ProductSearch, etc.

| Field | Type | Description |
|------|------|------|
| page | Integer | Current page number |
| pageCount | Integer | Total number of pages |
| products | Array of [ProductSummeryObject](#productsummeryobject) | Product list |

---

## ProductSummeryObject

A product summary object. Used by all endpoints that return a product list.

| Field | Type | Description |
|------|------|------|
| asin | String | Product ASIN |
| parentAsin | String / null | Parent ASIN; null when there is no variant |
| title | String | Product name |
| brand | String | Brand |
| price | Integer | Selling price (coupon not deducted), in local minor units |
| listPrice | Integer | List price (strikethrough), in local minor units |
| coupon | Integer | > 0 is a fixed amount discount, < 0 is a percentage discount (e.g. -10 = 10%), in local minor units |
| salesPrice | Integer | Actual selling price (after coupon), in local minor units |
| ratings | Number | Star rating |
| ratingsCount | Integer | Review count |
| listingSalesVolumeOfMonth | Integer | Estimated monthly sales; -1 means cannot be estimated |
| listingSalesVolumeOfDaily | Integer | Daily sales; -1 means cannot be estimated |
| listingSalesOfMonth | Integer | Estimated monthly sales amount, in local minor units |
| onlineDate | String | Listing date, format yyyy-MM-dd |
| onlineDays | Integer | Days listed |
| variationASINCount | Integer | Variant count |
| sellerCount | Integer | Seller count |
| isFBA | Boolean | Whether the buybox seller uses FBA |
| hasVideo | Boolean | Whether the main image has a video |
| APlus | Boolean | Whether the product has an A+ page |
| hasBrandStore | Boolean | Whether the product has a brand store |
| photo | String Array | Main image URL list |
| EBCPhoto | String Array | A+ page images |
| buyboxSeller | String | Buybox seller name |
| buyboxSellerId | String | Buybox seller ID |
| buyboxSellerAddress | String | Buybox seller country (2-letter code, e.g. CN/US/GB) |
| category | String Array | Top-level category: [name, nodeId] |
| bsrCategory | String Array | Sub-category: [["name", "NodeId", "Rank"]] |
| rank | Integer | Top-level category rank |
| size | String Array | Outer package dimensions: [longest side, second longest side, shortest side] |
| weight | Integer | Weight (unit: g) |
| profit | Integer | Gross profit, in local minor units |
| profitRate | Number | Profit margin (percentage, e.g. 25.83 = 25.83%) |
| fbaFee | Integer | FBA fee, in local minor units |
| fbaDetetail | String Array | FBA fee breakdown: [shipping fee, "1-9-month: storage fee", "10-12-month: storage fee"] |
| platformFee | Integer | Platform commission, in local minor units |
| shipCost | Integer | FBM shipping fee, in local minor units |
| DealType | String | Promotion tag |
| StoreName | String | Store name |
| variationASIN | String Array | Variant ASIN list |
| refreshAsin | String | Refresh redirect target ASIN; empty if no redirect |
| ExtraSavings | Object Array | Related promotion content: `[{"Asin":"...", "Text":"..."}]` |

---

## ProductObject

A product details object. Returned in the `data` field of ProductRequest. Adds the following fields on top of [ProductSummeryObject](#productsummeryobject):

| Field | Type | Description |
|------|------|------|
| Description | String | Five-point description |
| ProductBadge | String Array | Product badges, e.g. `["Amazon Choice", "Best Seller", "New Release"]` |
| updateDate | String | Current ASIN update time |
| AsinSalesCount | Integer | Amazon-disclosed ASIN monthly sales; the latest value within the last 7 calendar days is returned, otherwise 0 |
| OffSale | Integer | Whether the product is off-sale; 1 = off-sale, 0 = on-sale |
| attribute | String Array | Variant attributes: `[["variant asin", "attribute name", "attribute value", ...]]` |
| shipsFrom | String | Shipper name |
| feature | String Array | Product features and star ratings: `["FromAsin", "Easy to clean:4.6", "Easy to use:4.4"]` |
| productInfo | String Array | Product information description: `["Manufacturer", "Amazon Basics", "Country of Origin", "China"]` |
| property | String Array | Attribute list: `["FromAsin", "Brand:Toshiba", "Color:Black"]` |
| oneStartRatings | Number | 1-star rating share (%) |
| twoStartRatings | Number | 2-star rating share (%) |
| threeStartRatings | Number | 3-star rating share (%) |
| fourStartRatings | Number | 4-star rating share (%) |
| fiveStartRatings | Number | 5-star rating share (%) |
| bsrCategory | String Array | Sub-category with the "last time on the list" added: `[["name", "NodeId", "Rank", "yyyyMMdd"]]` |

**Trend fields** (returned when `trend != 2`):

| Field | Type | Description |
|------|------|------|
| listingSalesVolumeOfDailyTrend | Integer Array | Daily sales trend: `[yyyyMMdd, sales, ...]`; -1 means no estimated sales |
| listingSalesOfDailyTrend | Integer Array | Daily sales amount trend: `[yyyyMMdd, sales amount, ...]`, in local minor units |
| listingSalesVolumeOfMonthTrend | Integer Array | Monthly sales trend: `[yyyyMM, sales, ...]` |
| listingSalesOfMonthTrend | Integer Array |ちなみにMonthly sales amount trend: `[yyyyMM, sales amount, ...]`, in local minor units |
| RankTrend | String Array | Top-level category rank change: `["Date", "Top-level category nodeId:Top-level category rank", ...]` |
| BsrRankTrend | String | Sub-category rank history JSON: `[{"nodeid":"xxx","rank":["Date","Rank",...]}]` |
| DealTrend | Integer Array | Deal status: `[yyyyMMdd, 1/0, ...]`, 1 = has deal, 0 = no deal |
| priceTrend | Integer Array | Selling price trend: `[yyyyMMdd, price, ...]`, in local minor units |
| listPriceTrend | Integer Array | List price (strikethrough) trend: `[yyyyMMdd, price, ...]` |
| couponTrend | Integer Array | Coupon trend: `[yyyyMMdd, value, ...]`, > 0 is amount, < 0 is percentage, -1 is no coupon |

---

## AsinSalesVolumeObject

ASIN officially disclosed variant sales. Returned in the `data` field of AsinSalesVolume.

A 2-D String/Integer array, each row in the format `[date, sales, sales type]`.

| Column | Type | Description |
|----|------|------|
| [0] | String | Record date, format yyyy-MM-dd |
| [1] | Integer | Sales record |
| [2] | Integer | 1 = weekly sales, 2 = monthly sales |

---

## ProductVariationHistoryObject

Product variant change history. Returned in the `data` field of ProductVariationHistory.

A 2-D String array, each row in the format `[record time, parent ASIN, variant ASIN 1, variant ASIN 2, ...]`.

---

## ReviewsObject

Product reviews. Returned in the `data` field of ProductReviewsQuery.

| Field | Type | Description |
|------|------|------|
| reviewsLink | String | Review detail link |
| consumerName | String | Reviewer nickname |
| consumerURL | String | Reviewer profile link |
| consumerBadge | String Array | Reviewer badges, e.g. `["Top 10 Reviewer"]` |
| star | Number | Star rating given |
| title | String | Review title |
| ReviewedCountry | String | Reviewer's country/region |
| reviewsDate | String | Review time |
| isVP | Boolean | Whether it is a Verified Purchase review |
| asin | String | The variant ASIN the review points to; empty if no variant |
| asinProperty | String | The variant attribute the review points to, e.g. `Color: Black` |
| helpful | Integer | Number of people who found this review helpful |
| content | String | Review text |
| resource | String | Review image URL; multiple images separated by `\|\|` |
| videos | String | Review video link |
| itemIndex | String | Data index, e.g. `156/5000` |

---

## KeywordSummeryObject

A keyword summary object. Returned in the `data` field of KeywordQuery, KeywordExtends, CategoryRequestKeyword, etc.

| Field | Type | Description |
|------|------|------|
| keyword | String | Keyword |
| keywordCNName | String | Chinese name of the keyword |
| Images | String Array | Top 10 product images in search results |
| ImagesFromAsin | String Array | Image source ASINs (order matches Images) |
| update | String | Latest ABA rank update time (valid for weekly keywords, empty for monthly) |
| rank | Integer | Weekly search rank |
| Department | String Array | Related category node IDs: `["17659096011","289937"]` |
| searchVolume | Integer | Search volume in the last 30 days |
| searchVolumeTrend | String Array | Search volume trend: `[yyyyMM, search volume, ...]` |
| searchRankTrend | String | Search rank trend: `[yyyyMM, rank, ...]` |
| ClickOf90D | Integer | Last 90 days click count (US site only; -1 = undisclosed) |
| SalesVolumeOf90D | Integer | Last 90 days purchase count |
| wordCount | Integer | Word count |
| searchConversionRateD90 | Number | Last 90 days search conversion rate (US site only) |
| ClickConversionRateD90 | Number | Last 90 days click conversion rate (US site only) |
| searchConversionRate | Number | Last 360 days search conversion rate (e.g. 18.44 = 18.44%) |
| ProductCount | Integer | Number of competitors (as shown on the Amazon search page) |
| rankChangeOfWeekly | Number | Rank change vs. last week (negative = falling) |
| cpc | Integer | CPC precise bid, in local minor units |
| cpcRange | String | CPC bid range: min, max |
| searchVolumeGrowthRateTrend | Number Array | Last 3/6/12-month compound monthly search volume growth rate: `[3-month, 6-month, 12-month]` |
| shareClickRate | Number | Top 3 product click share (%) |
| shareConversionRate | Number | Top 3 product conversion share (%) |
| top3asin | String Array | Top 3 ASINs by click: `["asin, click share, conversion share"]` |
| top3Brand | String Array | Top 3 brands by click |
| top3Category | String Array | Top 3 category names by click |
| season | String | Peak season |

---

## KeywordObject

Keyword details. Returned in the `data` field of KeywordRequest. Adds the following fields on top of [KeywordSummeryObject](#keywordsummeryobject):

| Field | Type | Description |
|------|------|------|
| salesVolumeOf90d | Integer | Last 90 days purchase count |
| searchVolumeGrowthTrend | String Array | Next 12 months search volume growth trend: `[yyyyMM, growth rate, ...]`; 9612 = 96.12% growth |
| cpcTrend | String Array | CPC precise bid history: `[yyyyMM, cpc, min, max, ...]` |
| searchResultOfFP | String Array | First page product data report (see description below) |
| searchResultOfFPTrend | String Array | First page product historical trend (see description below) |
| associatedWithCategory | String Array | Related sub-category node IDs |
| associatedWithCategoryDetail | String Array | Related sub-category top 100 data: `[[nodeid, name, monthly sales, average price, average review count, ...]]` |

**searchResultOfFP array index description**:
0 = product count, 1 = organic position count, 2 = ad position count, 3 = organic position not in top 100 share,
4 = organic position review count < 100/300/500 share, 5 = ad position review count < 100/300/500 share,
6 = no star rating count, 7 = average star rating, 8 = average review count,
9 = coupon count/share (e.g. `2/588`), 10 = hijacker count/share, 11 = 30-day lowest price count/share

**searchResultOfFPTrend array format**: `[yyyyMM, average star rating, average review count, average price, no star rating count, ...]`

---

## ASINKeywordItemObject

An ASIN reverse-lookup keyword item. Array element of the `data` field of ASINRequestKeywordv2.

| Field | Type | Description |
|------|------|------|
| keyword | [KeywordSummeryObject](#keywordsummeryobject) | Keyword details |
| ShowType | String | Exposure type |
| ShowShare | Number | The traffic share contributed by this keyword in the ASIN's reverse-lookup keywords |
| PositionType | String Array | Exposure position type, e.g. `["organic traffic", "platformcode recommended"] |
| SearchPosition | String | Organic exposure position |
| searchPositionDate | String | Recent organic exposure time, format yyyy-MM-dd HH:mm |
| AdPosition | String | Ad exposure position |
| AdPositionDate | String | Recent ad exposure time, format yyyy-MM-dd HH:mm |

---

## KeywordProductRankingObject

Keyword search-result product rank. Returned in the `data` field of KeywordProductRanking, ASINKeywordRanking.

| Field | Type | Description |
|------|------|------|
| page | String | Pagination info, e.g. `1/100` |
| records | Array | Rank record list |

**records array element**:

| Field | Type | Description |
|------|------|------|
| asin | String | Product ASIN |
| keyword | String | Keyword |
| page | String | Page where exposure occurred |
| position | String | Position on the page, e.g. `1/68` |
| positionType | String | 0 = organic exposure, 1 = ad exposure |
| positionName | String | 0 = organic position, 1 = SP ad, 2 = brand ad, 3 = video ad |
| adID | String | Ad group ID; empty when not an ad |
| campaignID | String | Ad campaign ID (available from 2025-03 onwards); empty when not an ad |
| recordDate | String | Record time, format yyyy-MM-dd HH:mm (UTC+8 Beijing time) |

---

## KeywordSearchResultItem

Keyword search-result product trend item. Array element of the `data` field of KeywordSearchResultTrend.

| Field | Type | Description |
|------|------|------|
| RecordDate | String | Record time, format yyyy-MM-dd |
| Top100SalesVolume | Integer | Sum of monthly sales of the top 100 products (by sales) in the first 3 pages |
| Top100Sales | Integer | Sum of monthly sales amount of the top 100 products (by sales) in the first 3 pages, in local minor units |
| ProductCount | Integer | Number of competitors (based on the number shown in the search result) |
| BrandCount | Integer | Brand count of the top 100 products |
| SellerCount | Integer | Seller count of the top 100 products |
| AvgStar | Integer | Average star rating of the top 100 products |
| AvgPrice | Integer | Average price of the top 100 products, in local minor units |
| AvgRatings | Integer | Average review count of the top 100 products |
| NoRatingProductCount | Integer | Number of products with no star rating |

---

## KeywordTaskObject

A keyword monitoring task. Array element of the `data` field of KeywordTasks.

| Field | Type | Description |
|------|------|------|
| taskId | String | Task ID |
| status | Integer | 1 = normal, 2 = paused |
| createDate | String | Task creation date |
| keyword | String | Monitored keyword |
| mode | Integer | 0 = PC browser, 1 = mobile browser |
| area | String | Monitoring area postal code used |
| page | Integer | First N pages to monitor (1, 3, 5, 7) |
| period | String | Monitoring frequency expression |

---

## KeywordBatchScheduleObject

A keyword monitoring execution batch. Array element of the `data` field of KeywordBatchScheduleList.

Format string: `<execution time yyyyMMddHHmm>:<batchId>:<status>:<finish time>`

| Segment | Description |
|----|------|
| Execution time | Format yyyyMMddHHmm |
| Batch ID | Unique batch identifier |
| Status | 0 = running, 1 = execution completed |
| Finish time | yyyyMMddHHmm when finished, or `--` if not yet finished |

---

## KeywordBatchScheduleDetailObject

Keyword monitoring batch detail data. Array element of the `data` field of KeywordBatchScheduleDetail.

A CSV-format string, with each row containing the following fields:

| # | Field | Description |
|------|------|------|
| 1 | asin | Product ASIN |
| 2 | Main image link | Main image URL |
| 3 | Product title | Product title |
| 4 | Exposure type | 0 = organic exposure, 1 = ad exposure |
| 5 | Badge | AC/BS/Deal/Lowest |
| 6 | Exposure rank | Page x, position y/z |
| 7 | Exposure position | Brand Ad/Video Ad/... |
| 8 | Coupon | Coupon information |
| 9 | Star rating | Star rating |
| 10 | Review count | Review count |
| 11 | Selling price | Local minor units |
| 12 | Hijacker count | Number of hijackers |
| 13 | Seller name | Seller name (from Sorftime library) |
| 14 | Seller ID | Seller ID (from Sorftime library) |
| 15 | Ships from | Shipper (from Sorftime library) |
| 16 | Shipping fee | Shipping fee |
| 17 | Brand | Brand name |
| 18 | Variant count | Variant count (from Sorftime library) |
| 19 | Prime flag | Prime flag |
| 20 | scheduleId | Batch task ID |

---

## BestSellerListItemObject

A Best Seller list monitoring data item. Array element of the `data` field of BestSellerListDataCollect.

| Field | Type | Description |
|------|------|------|
| asin | String | Product ASIN |
| parentAsin | String / null | Parent ASIN; null when there is no variant |
| title | String | Product name |
| brand | String | Brand |
| price | Integer | Selling price, in local minor units |
| onlineDate | String | Listing date, format yyyy-MM-dd |
| ratings | Number | Star rating |
| ratingsCount | Integer | Review count |
| listingSalesVolumeOfMonth | Integer | Estimated monthly sales; -1 means cannot be estimated |
| listingSalesOfMonth | Integer | Estimated monthly sales amount, in local minor units |
| photo | String Array | Main image URL list |
| bsrCategory | String Array | Sub-category: `[["name", "NodeId", "Rank"]]` |
| Category | String Array | Top-level category: `[["name", "NodeId", "Rank"]]` |

---

## ProductSellerTaskObject

A hijacker monitoring task. Array element of the `data` field of ProductSellerTasks.

| Field | Type | Description |
|------|------|------|
| taskId | String | Task ID |
| status | Integer | 1 = normal, 2 = paused |
| createDate | String | Task creation date |
| asin | String | Monitored ASIN |
| period | String | Monitoring frequency expression |

---

## ProductSellerScheduleDetailObject

Hijacker monitoring execution result. Array element of the `data` field of ProductSellerTaskScheduleDetail.

CSV-format string: `<collection time>,<asin>,<seller name>,<seller ID>,<is buybox>,<shipping method>,<type>,<selling price>,<stock>,<is limited purchase>`

| # | Field | Description |
|------|------|------|
| 1 | Collection time | Collection time |
| 2 | asin | Product ASIN |
| 3 | Seller name | Seller name |
| 4 | Seller ID | Seller ID |
| 5 | Is buybox | 1 = yes, 0 = no |
| 6 | Shipping method | FBA / FBM |
| 7 | Type | New / Used / etc. |
| 8 | Selling price | Local minor units |
| 9 | Stock | Stock count when `checkstock` is enabled; otherwise -1 |
| 10 | Is limited purchase | 1 = limited, 0 = not limited |

---

## SimilarProductObject

An image-search similar product. Array element of the `data` field of SimilarProductRealtimeRequestCollection.

| Field | Type | Description |
|------|------|------|
| asin | String | Product ASIN |
| brand | String | Brand name |
| star | Number | Star rating |
| ratings | Integer | Review count |
| price | Integer | Price, in local minor units |
| listPrice | Integer | List price (strikethrough), in local minor units |

---

## CoinQueryObject

Credit balance query. Returned in the `data` field of CoinQuery.

| Field | Type | Description |
|------|------|------|
| credit | Integer | Current credit balance |

---

## RequestStreamMonthObject

Request stream query. Returned in the `data` field of RequestStreamMonth.

| Field | Type | Description |
|------|------|------|
| Purchase | Array | Purchase records, currently an empty array |
| Consume | Array (2-D) | Consumption records: each row `[month, requests spent]`, e.g. `["202605", 510]` |

---

## AsinSummaryObject

ASIN subscription data summary. Array element of the `data` field of ASINSubscriptionCollection.

| Field | Type | Description |
|------|------|------|
| asin | String | Product ASIN |
| parentAsin | String | Parent ASIN |
| title | String | Product name |
| brand | String | Brand |
| price | Integer | Selling price, in local minor units |
| ratings | Number | Star rating |
| ratingsCount | Integer | Review count |
| listingSalesVolumeOfMonth | Integer | Estimated monthly sales |
| photo | String Array | Main image URL list |
| bsrCategory | String Array | Sub-category |
| category | String Array | Top-level category |
