# Walmart Endpoints (17)


## Table of Contents

- [Call Conventions](#call-conventions)
- [1. Category Tree (CategoryTree)](#1-category-tree-categorytree)
- [2. Category Market Report (CategoryRequest)](#2-category-market-report-categoryrequest)
- [3. Product Data Query (ProductRequest)](#3-product-data-query-productrequest)
- [4. Product Historical Trend Query (ProductTrendRequest)](#4-product-historical-trend-query-producttrendrequest)
- [5. Product Officially Disclosed Variant Sales (ProductSalesVolume)](#5-product-officially-disclosed-variant-sales-productsalesvolume)
- [6. Query This Month's Remaining Credits (CoinQuery)](#6-query-this-months-remaining-credits-coinquery)
- [7. Query Credit Usage Details (CoinStream)](#7-query-credit-usage-details-coinstream)
- [8. Query Monthly Request Usage Details (RequestStreamMonth)](#8-query-monthly-request-usage-details-requeststreammonth)
- [9. Keyword & Library (9 endpoints)](#9-keyword--library-9-endpoints)
- [9.0 Common notes for keyword & library endpoints](#90-common-notes-for-keyword--library-endpoints)
- [9.1 Keyword Query (KeywordQuery)](#91-keyword-query-keywordquery)
- [9.2 Search Keywords by Name (KeywordSearchFromName)](#92-search-keywords-by-name-keywordsearchfromname)
- [9.3 Keyword (Last 15 Days) Search Result Products (KeywordSearchResults)](#93-keyword-last-15-days-search-result-products-keywordsearchresults)
- [9.4 Keyword Details (KeywordRequest)](#94-keyword-details-keywordrequest)
- [9.5 Product Reverse-lookup Keywords (ProductRequestKeyword)](#95-product-reverse-lookup-keywords-productrequestkeyword)
- [9.6 Find Related Keywords (KeywordExtends)](#96-find-related-keywords-keywordextends)
- [9.7 Add Keyword to My Library (FavoriteKeyword)](#97-add-keyword-to-my-library-favoritekeyword)
- [9.8 Move / Delete Keyword Library Keyword (ChangeFavoriteKeyword)](#98-move--delete-keyword-library-keyword-changefavoritekeyword)
- [9.9 Query Keyword Library (GetFavoriteKeyword)](#99-query-keyword-library-getfavoritekeyword)
- [Notes](#notes)
- [Best Practices](#best-practices)
- [1. Category to Product Analysis](#1-category-to-product-analysis)
- [2. Product Comparison Analysis](#2-product-comparison-analysis)
- [3. Account Quota Monitoring](#3-account-quota-monitoring)
- [4. Keyword Research Workflow](#4-keyword-research-workflow)
- [5. Keyword Filtering](#5-keyword-filtering)
- [6. Library Management](#6-library-management)

**Endpoints in this file**: CategoryTree, CategoryRequest, ProductRequest, ProductTrendRequest, ProductSalesVolume, CoinQuery, CoinStream, RequestStreamMonth, KeywordQuery, KeywordSearchFromName, KeywordSearchResults, KeywordRequest, ProductRequestKeyword, KeywordExtends, FavoriteKeyword, ChangeFavoriteKeyword, GetFavoriteKeyword

## Call Conventions

- Walmart currently only supports the US site, i.e. `domain=21`.
- CLI call format: `sorftime api <Endpoint> '<json-params>' --domain 21`. Endpoint names are case-sensitive.
- All endpoints share a common response envelope: `RequestLeft`, `RequestConsumed`, `RequestCount`, `Code`, `Message`, `Data`. The Walmart response additionally includes the `RequestCount: 0` field. The "Response data" sections below describe only the business fields within each endpoint's `data`.
- Request parameters do not have a separate Required flag; whether a parameter is optional should be judged from the "Optional" label or default value in the field description.

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table (Walmart domain=21), error codes, response structure, rate limits & concurrency.
For data type definitions, see [`walmart-data-types.md`](./walmart-data-types.md); this document uses the new response fields inline as the source of truth.

---

## 1. Category Tree (CategoryTree)

- **Endpoint description**: Returns the Best Seller category tree structure
- **Requests consumed**: 5
- **Supported domains**: 21(us)
- **Note**:
  - Response data is large (approx. 10MB+); it is recommended to set a long request timeout
  - Categories not suitable for third-party sellers are excluded, e.g. apps, audio/video, books, music, food, number games, etc.
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api CategoryTree --domain 21
  ```
- **Response data**:
  - `Id`: Category ID.
  - `ParentId`: Parent category ID; 0 indicates the top level.
  - `NodeId`: Category nodeid.
  - `Name`: Category name.
  - `CNName`: Chinese name of the category.
  - `URL`: Category URL.

---

## 2. Category Market Report (CategoryRequest)

- **Endpoint description**: Query the Best Seller Top 80 products of a category
- **Requests consumed**: 5
- **Supported domains**: 21(us)
- **Note**: Categories not suitable for third-party sellers are excluded, e.g. apps, audio/video, books, music, food, number games, etc.
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | NodePath | String | The NodeId to query |
- **Usage example**:
  ```bash
  sorftime api CategoryRequest '{"NodePath": "4044_90548_90546"}' --domain 21
  ```
- **Response data**:
  - `Data` is directly a ProductObject array (no `Products` wrapper; corrected 2026-07-20):
    - `Title`: Product name.
    - `Photo`: This product's main image, URL format.
    - `ListingSalesVolumeOfMonth`: Estimated link-level monthly sales (variants not distinguished). Recommended for product sales evaluation.
    - `ListingSalesOfMonth`: Estimated link-level monthly sales amount, in local minor units (e.g. on the US site, in cents), e.g. 10000.
    - `ProductId`: This product's ProductId.
    - `ParentProductId`: Parent product's ProductId.
    - `Price`: ASIN's selling price (coupon not deducted), in local minor units (e.g. on the US site, in cents), e.g. 1999 = 19.99 USD on the US site.
    - `Brand`: The current product's brand.
    - `Seller`: The seller at the time of our collection.
    - `Shipedby`: The shipping method obtained at the time of our collection.
    - `WFSFee`: If the logistics method is FBA, this product's FBA fee, in local minor units (e.g. on the US site, in cents), e.g. 1999.
    - `Attribute`: The product's attributes, value description: `["<attribute1>", "<value1>", "<attribute2>", "<value2>", ...]`.
    - `FirstReviewsDate`: The product's first review date, format yyyy-MM-dd.
    - `ReviewsCount`: This product's review count.
    - `Ratings`: This product's star rating, e.g. 4.8.
    - `NodePath`: Category nodes the product belongs to, value description: `["Category node name", "Category node", "Rank time", "Rank", "Category node name", "Category node", "Rank time", "Rank", ...]`.
    - `Label`: Product labels, e.g. `["pickup","savewith","bestsell"]`.
    - `PopularPick`: Product label; 1 when present.
    - `Clearance`: Product label; 1 when present.
    - `ReducedPrice`: Product label; 1 when present.
    - `Rollback`: Product label; 1 when present.
    - `FlashDeal`: Product label; 1 when present.
    - `Size`: This product's outer package dimensions, `["longest side", "second longest side", "shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
    - `Weight`: This product's weight; if the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.
    - `Variants`: The current product's variant ProductIds, attributes, and product URLs; value description: `[{ "VariantId":"", "Url":"", "Property":["","",...], "PriceUpdate":"yyyy-MM-dd", "DetailUpdate":"yyyy-MM-dd" // when the detail update time is greater than 30 days, this is shown as -}, ...]`.
    - `NumberOfStar`: The review count per star rating for the product. Value description: `["<star rating1>","<review count for star rating1>";"<star rating2>","<review count for star rating2>";...]`. E.g. `["<5>","<101>";"<4>","<90>";....]`.

---

## 3. Product Data Query (ProductRequest)

- **Endpoint description**: Product data query
- **Requests consumed**: 1
- **Supported domains**: 21(us)
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | ProductId | String | The product ID to query |
- **Usage example**:
  ```bash
  sorftime api ProductRequest '{"ProductId": "1275613286"}' --domain 21
  ```
- **Response data**:
  - `Title`: Product name.
  - `Photo`: This product's main image, URL format.
  - `ListingSalesVolumeOfMonth`: Estimated link-level monthly sales (variants not distinguished). Recommended for product sales evaluation.
  - `ListingSalesOfMonth`: Estimated link-level monthly sales amount, in local minor units (e.g. on the US site, in cents), e.g. 10000.
  - `ProductId`: This product's ProductId.
  - `ParentProductId`: Parent product's ProductId.
  - `Price`: ASIN's selling price (coupon not deducted), in local minor units (e.g. on the US site, in cents), e.g. 1999 = 19.99 USD on the US site.
  - `Brand`: The current product's brand.
  - `Seller`: The seller at the time of our collection.
  - `Shipedby`: The shipping method obtained at the time of our collection.
  - `WFSFee`: If the logistics method is FBA, this product's FBA fee, in local minor units (e.g. on the US site, in cents), e.g. 1999.
  - `Attribute`: The product's attributes, value description: `["<attribute1>", "<value1>", "<attribute2>", "<value2>", ...]`.
  - `FirstReviewsDate`: The product's first review date, format yyyy-MM-dd.
  - `ReviewsCount`: This product's review count.
  - `Ratings`: This product's star rating, e.g. 4.8.
  - `NodePath`: Category nodes the product belongs to, value description: `["Category node name", "Category node", "Rank time", "Rank", "Category node name", "Category node", "Rank time", "Rank", ...]`.
  - `Label`: Product labels, e.g. `["pickup","savewith","bestsell"]`.
  - `PopularPick`: Product label; 1 when present.
  - `Clearance`: Product label; 1 when present.
  - `ReducedPrice`: Product label; 1 when present.
  - `Rollback`: Product label; 1 when present.
  - `FlashDeal`: Product label; 1 when present.
  - `Size`: This product's outer package dimensions, `["longest side", "second longest side", "shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
  - `Weight`: This product's weight; if the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.
  - `Variants`: The current product's variant ProductIds, attributes, and product URLs; value description: `[{ "VariantId":"", "Url":"", "Property":["","",...], }, ...]`.
  - `NumberOfStar`: The review count per star rating for the product. Value description: `["<star rating1>","<review count for star rating1>";"<star rating2>","<review count for star rating2>";...]`. E.g. `["<5>","<101>";"<4>","<90>";....]`.

---

## 4. Product Historical Trend Query (ProductTrendRequest)

- **Endpoint description**: Product historical trend query
- **Requests consumed**: 2
- **Supported domains**: 21(us)
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | ProductId | String | The product ID to query |
- **Usage example**:
  ```bash
  sorftime api ProductTrendRequest '{"ProductId": "1275613286"}' --domain 21
  ```
- **Response data**:
  - `ProductId`: This product's ProductId.
  - `ListingSalesVolumeOfMonth`: Estimated link-level monthly sales (variants not distinguished). Recommended for product sales evaluation.
  - `ListingSalesOfMonth`: Estimated link-level monthly sales amount, in local minor units (e.g. on the US site, in cents), e.g. 10000.
  - `ListingSalesVolumeOfMonthTrend`: Link-level monthly sales historical trend (variants not distinguished). Value description: `[2025-01-01,1000,2025-01-02,2000,2025-01-02,3000,.....]`. Even array indices are dates (e.g. 20201001), odd array indices are estimated monthly sales.
  - `ListingSalesOfMonthTrend`: Link-level monthly sales amount historical trend (variants not distinguished). Value description: `[2025-01-01,10000,2025-01-02,20000,2025-01-02,30000,.....]`. Even array indices are dates (e.g. 20201001), odd array indices are estimated monthly sales amount, in local minor units (e.g. on the US site, in cents), e.g. 10000.
  - `PriceTrend`: Product price trend.
  - `ReviewsTrend`: Review count trend. Value description: `[2020-10-01,1251,2020-10-02,1252,2020-10-03,1301.....]`. Even array indices are dates (e.g. 20201001), odd array indices are review count.
  - `StarTrend`: Star rating trend. Value description: `[2020-10-01,450,2020-10-02,450,2020-10-03,440.....]`. Even array indices are dates (e.g. 20201001), odd array indices are star ratings; 450 = 4.5 stars.
  - `RankTrend`: The product's rank in each category. Value description: `[ [ "<Category node name>", "<Category node>", "<Date(yyyy-MM-dd)>", "<Rank>", "<Date(yyyy-MM-dd)>", "<Rank>", "<Date(yyyy-MM-dd)>", "<Rank>",.... ],.... ]`.

---

## 5. Product Officially Disclosed Variant Sales (ProductSalesVolume)

- **Endpoint description**: Query the officially disclosed variant sales history of a product, earliest from 2023-11
- **Requests consumed**: 1
- **Supported domains**: 21(us)
- **Note**: The endpoint description says data is available from 2023-11, while the `QueryDate` parameter description says earliest support is 2023-09-01; this document preserves both original statements without merging them.
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | ProductId | String | The product ID to query |
  | QueryDate | String | Query start time, format `yyyy-MM-dd`. The parameter description says earliest support is 2023-09-01; when not passed or invalid, returns the last 30 days of data |
  | QueryEndDate | String | Query end time, format `yyyy-MM-dd`; when not passed or invalid, ends at the current time |
  | PageIndex | Integer | Query result page index, default 1, at most 100 per page |
- **Usage example**:
  ```bash
  # Query the last 30 days
  sorftime api ProductSalesVolume '{"ProductId": "1275613286"}' --domain 21

  # Query a specific time range
  sorftime api ProductSalesVolume '{"ProductId": "1275613286", "QueryDate": "2025-02-01", "QueryEndDate": "2025-02-28", "PageIndex": 1}' --domain 21
  ```
- **Response data**:
  - `Data`: value description `[ [ "2023-10-05", // record date 100, // sales record 2, // 2: yesterday's daily sales ],.... ]`.

---

## 6. Query This Month's Remaining Credits (CoinQuery)

- **Endpoint description**: Query remaining credits
- **Requests consumed**: 0
- **Supported domains**: 21(us)
- **Note**: Credit balance is not differentiated by site or platform; querying through any site or platform returns the total credit balance.
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api CoinQuery --domain 21
  ```
- **Response data**:
  - `Coin`: This month's remaining credits.

---

## 7. Query Credit Usage Details (CoinStream)

- **Endpoint description**: Query the credit usage details on the current query site
- **Requests consumed**: 0
- **Supported domains**: 21(us)
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | Querydate | Array | A 2-element array: element 0 is the query start time, element 1 is the query end time, format `yyyy-MM-dd`. Default is the last 6 months, max range is the last 12 months |
  | PageIndex | Integer | Query result page index, default page 1 |
  | PageSize | Integer | Items per page, min 20, default 20, max 200 |
- **Usage example**:
  ```bash
  sorftime api CoinStream '{"Querydate": ["2026-01-01", "2026-06-30"], "PageIndex": 1, "PageSize": 50}' --domain 21
  ```
- **Response data**:
  - `Data`: credit consumption details. Example: `[6, 202010010300, -1000, 190000, 6, 202010010400, -1010, 180000, 6, 202010010530, -1050, 170000, .....]`. `array index % 4 = 0` is the task type: 1=keyword monitoring, 3=hijacker & stock monitoring, 9=ASIN real-time collection, 10=review real-time collection, 12=Best Seller list monitoring, 15=ASIN subscription update, 27=image-search similar product. `array index % 4 = 1` is the date (e.g. 20201001), format `yyyyMMddHHmm`. `array index % 4 = 2` is credits spent. `array index % 4 = 3` is credits remaining.

---

## 8. Query Monthly Request Usage Details (RequestStreamMonth)

- **Endpoint description**: Query remaining request count and purchased request pack usage; for detailed call history, please contact Sorftime. For user privacy, only the last 3 days of call records are retained.
- **Requests consumed**: 0
- **Supported domains**: 21(us)
- **Note**: Request query is not differentiated by site; querying through any site returns the total request balance.
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api RequestStreamMonth --domain 21
  ```
- **Response data**:
  - `Purchase`: Purchase details. Value description: `[ [ "20241001", // purchase time "420000", // requests obtained "0", // current remaining requests "20240930" // expiration time ],... ]`.
  - `Consume`: Monthly consumption details. Value description: `[ [ "202411", // month "1000" // requests used this month ], [ "202410", // month "1000" // requests used this month ] ]`.

---

## 9. Keyword & Library (9 endpoints)

### 9.0 Common notes for keyword & library endpoints

1. **Pagination range**: Most keyword pagination endpoints have a `PageSize` min 20, default 20, max 200; `GetFavoriteKeyword` allows at most 100 per page.
2. **Keyword update convention**: `Update` is the latest update time of the keyword, usually corresponding to the previous week of the update (e.g. an update time of 20250421 corresponds to keywords from 20250413 to 20250419).
3. **Library isolation**: The API library is not shared with the Sorftime web favorites; a keyword cannot be added twice to the same folder, and a single folder holds at most 2000 keywords.

### 9.1 Keyword Query (KeywordQuery)

- **Endpoint description**: Current trending keyword list
- **Requests consumed**: 5
- **Supported domains**: 21(us)
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | Pattern | Object | Query pattern, see Pattern child fields below |
  | Pattern.Keyword | String | The keyword to query |
  | Pattern.RankCondition | String | Weekly rank filter condition; a string array of length up to 2 representing the minimum and maximum values, e.g. `[1,5000]`, `[0,10000]`, or `[10000]` |
  | Pattern.SearchVolumeCondition | String | 30-day search volume filter condition; a string array of length 2 representing the minimum and maximum values |
  | PageIndex | Integer | Query result page index, default page 1 |
  | PageSize | Integer | Items per page, min 20, default 20, max 200 |
- **Usage example**:
  ```bash
  sorftime api KeywordQuery '{"Pattern": {"Keyword": "storage", "RankCondition": ["1", "3000"], "SearchVolumeCondition": ["5000", "50000"]}, "PageIndex": 1, "PageSize": 40}' --domain 21
  ```
- **Response data**:
  - `Keyword`: Keyword.
  - `KeywordCNName`: Chinese name of the keyword.
  - `Images`: Top 10 product images in search results, for quick keyword identification.
  - `Update`: Latest update time of the keyword. Usually corresponds to the previous week of the update. E.g. if the update time is 20250421, the keywords updated are from 20250413 to 20250419.
  - `Rank`: Weekly search rank.
  - `SearchVolume`: Search volume in the last 30 days.
  - `ProductCount`: Number of competitors; the number of competitors shown by Walmart on the keyword search page.
  - `SearchFirstPageAvgPrice`: Average price of products in organic positions on the first page, e.g. 1999 in local minor units. Represents 19.99 USD on the US site.
  - `SearchFirstPageAvgReviews`: Average review count of products in organic positions on the first page.
  - `SearchFirstPageAvgStar`: Average star rating of products in organic positions on the first page, e.g. 4.5.

---

### 9.2 Search Keywords by Name (KeywordSearchFromName)

- **Endpoint description**: Use natural language to search Walmart trending keywords
- **Requests consumed**: 1
- **Supported domains**: 21(us)
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | Name | String | The keyword name to search |
  | PageIndex | Integer | Paginated query, at most 200 keywords per page; default 1, all results start from page 1 (not page 0) |
- **Usage example**:
  ```bash
  sorftime api KeywordSearchFromName '{"Name": "kitchen storage", "PageIndex": 1}' --domain 21
  ```
- **Response data**:
  - `Keyword`: Keyword.
  - `KeywordCNName`: Chinese name of the keyword.
  - `Images`: Top 10 product images in search results, for quick keyword identification.
  - `Update`: Latest update time of the keyword. Usually corresponds to the previous week of the update. E.g. if the update time is 20250421, the keywords updated are from 20250413 to 20250419.
  - `Rank`: Weekly search rank.
  - `SearchVolume`: Search volume in the last 30 days.
  - `ProductCount`: Number of competitors; the number of competitors shown by Walmart on the keyword search page.
  - `SearchFirstPageAvgPrice`: Average price of products in organic positions on the first page, e.g. 1999 in local minor units. Represents 19.99 USD on the US site.
  - `SearchFirstPageAvgReviews`: Average review count of products in organic positions on the first page.
  - `SearchFirstPageAvgStar`: Average star rating of products in organic positions on the first page, e.g. 4.5.

---

### 9.3 Keyword (Last 15 Days) Search Result Products (KeywordSearchResults)

- **Endpoint description**: Query the products in the search results for the last 15 days for the keyword; only currently trending keywords are supported
- **Requests consumed**: 5
- **Supported domains**: 21(us)
- **Note**: Only currently trending keywords are supported
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | Keyword | String | The keyword to query |
  | PageIndex | Integer | Query result page index, default page 1 |
  | PageSize | Integer | Items per page, min 20, default 20, max 200 |
- **Usage example**:
  ```bash
  sorftime api KeywordSearchResults '{"Keyword": "desk organizer", "PageIndex": 1, "PageSize": 40}' --domain 21
  ```
- **Response data**:
  - `Title`: Product name.
  - `Photo`: This product's main image, URL format.
  - `ListingSalesVolumeOfMonth`: Estimated link-level monthly sales (variants not distinguished). Recommended for product sales evaluation.
  - `ListingSalesOfMonth`: Estimated link-level monthly sales amount, in local minor units (e.g. on the US site, in cents), e.g. 10000.
  - `ProductId`: This product's ProductId.
  - `ParentProductId`: Parent product's ProductId.
  - `Price`: ASIN's selling price (coupon not deducted), in local minor units (e.g. on the US site, in cents), e.g. 1999 = 19.99 USD on the US site.
  - `Brand`: The current product's brand.
  - `Seller`: The seller at the time of our collection.
  - `Shipedby`: The shipping method obtained at the time of our collection.
  - `WFSFee`: If the logistics method is FBA, this product's FBA fee, in local minor units (e.g. on the US site, in cents), e.g. 1999.
  - `Attribute`: The product's attributes, value description: `["<attribute1>", "<value1>", "<attribute2>", "<value2>", ...]`.
  - `FirstReviewsDate`: The product's first review date, format yyyy-MM-dd.
  - `ReviewsCount`: This product's review count.
  - `Ratings`: This product's star rating, e.g. 4.8.
  - `NodePath`: Category nodes the product belongs to, value description: `["Category node name", "Category node", "Rank time", "Rank", "Category node name", "Category node", "Rank time", "Rank", ...]`.
  - `Label`: Product labels, e.g. `["pickup","savewith","bestsell"]`.
  - `PopularPick`: Product label; 1 when present.
  - `Clearance`: Product label; 1 when present.
  - `ReducedPrice`: Product label; 1 when present.
  - `Rollback`: Product label; 1 when present.
  - `FlashDeal`: Product label; 1 when present.
  - `Size`: This product's outer package dimensions, `["longest side", "second longest side", "shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
  - `Weight`: This product's weight; if the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.
  - `Variants`: The current product's variant ProductIds, attributes, and product URLs; value description: `[{ "VariantId":"", "Url":"", "Property":["","",...], }, ...]`.
  - `NumberOfStar`: The review count per star rating for the product. Value description: `["<star rating1>","<review count for star rating1>";"<star rating2>","<review count for star rating2>";...]`. E.g. `["<5>","<101>";"<4>","<90>;"<3>"..."....]`.

---

### 9.4 Keyword Details (KeywordRequest)

- **Endpoint description**: Keyword details query
- **Requests consumed**: 1
- **Supported domains**: 21(us)
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | Keyword | String | The keyword to query |
- **Usage example**:
  ```bash
  sorftime api KeywordRequest '{"Keyword": "portable fan"}' --domain 21
  ```
- **Response data**:
  - `Keyword`: Keyword.
  - `KeywordCNName`: Chinese name of the keyword.
  - `Images`: Top 10 product images in search results, for quick keyword identification.
  - `Update`: Latest update time of the keyword. Usually corresponds to the previous week of the update. E.g. if the update time is 20250421, the keywords updated are from 20250413 to 20250419.
  - `Rank`: Weekly search rank.
  - `SearchVolume`: Search volume in the last 30 days.
  - `ProductCount`: Number of competitors; the number of competitors shown by Walmart on the keyword search page.
  - `SearchFirstPageAvgPrice`: Average price of products in organic positions on the first page, e.g. 1999 in local minor units. Represents 19.99 USD on the US site.
  - `SearchFirstPageAvgReviews`: Average review count of products in organic positions on the first page.
  - `SearchFirstPageAvgStar`: Average star rating of products in organic positions on the first page, e.g. 4.5.

---

### 9.5 Product Reverse-lookup Keywords (ProductRequestKeyword)

- **Endpoint description**: Query the keywords in whose search-result first 3 pages the product gained exposure in the last 30 days
- **Requests consumed**: 1
- **Supported domains**: 21(us)
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | ProductId | String | The ProductId to query |
  | PageIndex | Integer | Query result page index, default page 1 |
  | PageSize | Integer | Items per page, min 20, default 20, max 200 |
- **Usage example**:
  ```bash
  sorftime api ProductRequestKeyword '{"ProductId": "1234567890", "PageIndex": 1, "PageSize": 60}' --domain 21
  ```
- **Response data**:
  - `ShowShare`: The traffic share contributed by this keyword in the product's reverse-lookup keywords.
  - `RecentlyPosition`: Recent exposure rank, format `"1,2/18"` = page 1, position 2 of 18.
  - `OrganicPosition`: Recent organic exposure rank, format `"1,2/18"` = page 1, position 2 of 18.
  - `AdPosition`: Recent ad exposure rank, format `"1,2/18"` = page 1, position 2 of 18.
  - `Keyword.Keyword`: Keyword.
  - `Keyword.KeywordCNName`: Chinese name of the keyword.
  - `Keyword.Images`: Top 10 product images in search results, for quick keyword identification.
  - `Keyword.Update`: Latest update time of the keyword. Usually corresponds to the previous week of the update. E.g. if the update time is 20250421, the keywords updated are from 20250413 to 20250419.
  - `Keyword.Rank`: Weekly search rank.
  - `Keyword.SearchVolume`: Search volume in the last 30 days.
  - `Keyword.ProductCount`: Number of competitors; the number of competitors shown by Walmart on the keyword search page.
  - `Keyword.SearchFirstPageAvgPrice`: Average price of products in organic positions on the first page, e.g. 1999 in local minor units. Represents 19.99 USD on the US site.
  - `Keyword.SearchFirstPageAvgReviews`: Average review count of products in organic positions on the first page.
  - `Keyword.SearchFirstPageAvgStar`: Average star rating of products in organic positions on the first page, e.g. 4.5.

---

### 9.6 Find Related Keywords (KeywordExtends)

- **Endpoint description**: Find related keywords
- **Requests consumed**: 5
- **Supported domains**: 21(us)
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | Keyword | String | The ABA keyword to query, used to find related keywords based on the keyword |
  | PageIndex | Integer | Query result page index, default page 1 |
  | PageSize | Integer | Items per page, min 20, default 20, max 200 |
- **Usage example**:
  ```bash
  sorftime api KeywordExtends '{"Keyword": "camping chair", "PageIndex": 1, "PageSize": 80}' --domain 21
  ```
- **Response data**:
  - `Keyword`: Keyword.
  - `KeywordCNName`: Chinese name of the keyword.
  - `Images`: Top 10 product images in search results, for quick keyword identification.
  - `Update`: Latest update time of the keyword. Usually corresponds to the previous week of the update. E.g. if the update time is 20250421, the keywords updated are from 20250413 to 20250419.
  - `Rank`: Weekly search rank.
  - `SearchVolume`: Search volume in the last 30 days.
  - `ProductCount`: Number of competitors; the number of competitors shown by Walmart on the keyword search page.
  - `SearchFirstPageAvgPrice`: Average price of products in organic positions on the first page, e.g. 1999 in local minor units. Represents 19.99 USD on the US site.
  - `SearchFirstPageAvgReviews`: Average review count of products in organic positions on the first page.
  - `SearchFirstPageAvgStar`: Average star rating of products in organic positions on the first page, e.g. 4.5.

---

### 9.7 Add Keyword to My Library (FavoriteKeyword)

- **Endpoint description**: Add a keyword to my keyword library, not limited to trending keywords
- **Requests consumed**: 1
- **Supported domains**: 21(us)
- **Note**:
  - The API library (favorites) is not shared with the Sorftime web favorites
  - A keyword cannot be added twice to the same folder, but the same keyword can be added to different folders
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | Keyword | String | The keyword to favorite, not limited to trending keywords |
  | Dict | String | Optional; if specified, the keyword is added to the corresponding folder (created if it does not exist); if not specified, the keyword is added to the `Uncategorized` folder |
- **Usage example**:
  ```bash
  sorftime api FavoriteKeyword '{"Keyword": "foldable wagon", "Dict": "outdoor-candidates"}' --domain 21
  ```
- **Response data**:
  - `Data`: Actually returns an Integer.

---

### 9.8 Move / Delete Keyword Library Keyword (ChangeFavoriteKeyword)

- **Endpoint description**: Move a keyword to a specified folder or delete a keyword; a single folder can hold up to 2000 keywords
- **Requests consumed**: 0
- **Supported domains**: 21(us)
- **Note**: The API library (favorites) is not shared with the Sorftime web favorites
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | Keyword | String | The keyword that has been favorited |
  | Dict | String | Optional; when specified, the operation (move or delete) is performed on the keyword in this folder; when not specified, the keyword in the `Uncategorized` folder is operated on |
  | Command | String | For delete, pass `del`; when `Dict` is specified, only the keyword in that folder is deleted; when not specified, the keyword in all folders is deleted. For move, pass `move=<folder name>`; the target folder is created if it does not exist |
- **Usage example**:
  ```bash
  # Move a keyword from a specified folder to a new folder
  sorftime api ChangeFavoriteKeyword '{"Keyword": "foldable wagon", "Dict": "outdoor-candidates", "Command": "move=outdoor-core"}' --domain 21

  # Delete a keyword from all folders
  sorftime api ChangeFavoriteKeyword '{"Keyword": "foldable wagon", "Command": "del"}' --domain 21
  ```
- **Response data**:
  - `Data`: Actually returns an Integer.

---

### 9.9 Query Keyword Library (GetFavoriteKeyword)

- **Endpoint description**: Query the keyword library
- **Requests consumed**: 1
- **Supported domains**: 21(us)
- **Note**: The API library (favorites) is not shared with the Sorftime web favorites
- **Request parameters**:
  | Parameter | Type | Description |
  |------|------|------|
  | Command | String | Pass `dict=<folder name>` to query a specified folder; pass `all` to query all keywords; pass `dict` to query only the folder list |
  | Page | Integer | Paginated query, default starts from 1, at most 100 per page |
- **Usage example**:
  ```bash
  # Query all keywords
  sorftime api GetFavoriteKeyword '{"Command": "all", "Page": 1}' --domain 21

  # Query a specified folder
  sorftime api GetFavoriteKeyword '{"Command": "dict=outdoor-core", "Page": 1}' --domain 21

  # Query the folder list
  sorftime api GetFavoriteKeyword '{"Command": "dict"}' --domain 21
  ```
- **Response data**:
  - `Data`: Query result, keyword list or folder name list in JSON format: `["kw1","kw2",...]`.

---

## Notes

1. **Fixed site**: Walmart only supports `domain=21` (US site).
2. **Judge success by `code`**: In the common response, `code=0` indicates success; when not 0, combine with `message` to troubleshoot.
3. **Large data endpoints**: `CategoryTree` returns approx. 10MB+ of data; client timeouts should be increased and you should avoid repeated calls when the full category tree is not needed.
4. **Category scope**: `CategoryTree` and `CategoryRequest` exclude categories not suitable for third-party sellers (apps, audio/video, books, music, food, number games, etc.).
5. **Currency unit**: Price, sales amount, fees, and other monetary fields use local minor units; on the US site this is typically cents, so `1999` represents 19.99 USD.
6. **Sales convention**: For link-level sales evaluation, use `ListingSalesVolumeOfMonth`; this value does not distinguish variants.
7. **Pagination range**: `ProductSalesVolume` allows at most 100 per page.
8. **Account convention**: The credit balance and request balance are both cross-site, cross-platform totals; do not interpret a `domain=21` query result as a Walmart-specific balance.
9. **Unsupported endpoint (confirmed 2026-07-22)**: Walmart **does not** provide the `ProductSearchFromName` (search product by name) endpoint (that endpoint belongs to Amazon / Shopee / Temu / TikTok). If you call `sorftime api ProductSearchFromName '{"Name":"..."}' --domain 21` following Amazon conventions, it will return HTTP 404. "Search product by name" on Walmart can be approximated using `KeywordSearchResults` (keyword search results) + `ProductRequestKeyword` (product reverse keyword lookup).

## Best Practices

### 1. Category to Product Analysis
```bash
# Step 1: Get the category tree and determine the NodePath
sorftime api CategoryTree --domain 21

# Step 2: Query the category Best Seller Top 80
sorftime api CategoryRequest '{"NodePath": "4044_90548_90546"}' --domain 21

# Step 3: Query details and trends for the candidate products
sorftime api ProductRequest '{"ProductId": "1275613286"}' --domain 21
sorftime api ProductTrendRequest '{"ProductId": "1275613286"}' --domain 21

# Step 4: Query the officially disclosed variant sales by date
sorftime api ProductSalesVolume '{"ProductId": "1275613286", "QueryDate": "2025-02-01", "QueryEndDate": "2025-02-28", "PageIndex": 1}' --domain 21
```

### 2. Product Comparison Analysis
```bash
# Batch query multiple products
sorftime api ProductRequest '{"ProductId": "prod1"}' --domain 21
sorftime api ProductRequest '{"ProductId": "prod2"}' --domain 21
sorftime api ProductRequest '{"ProductId": "prod3"}' --domain 21

# Compare their price, sales, reviews and other metrics
```

### 3. Account Quota Monitoring
```bash
# Query remaining credits and request usage
sorftime api CoinQuery --domain 21
sorftime api RequestStreamMonth --domain 21

# Query credit usage details
sorftime api CoinStream '{"Querydate": ["2026-01-01", "2026-06-30"], "PageIndex": 1, "PageSize": 50}' --domain 21
```

### 4. Keyword Research Workflow
```bash
# Step 1: Use natural language to find trending keywords
sorftime api KeywordSearchFromName '{"Name": "kitchen storage", "PageIndex": 1}' --domain 21

# Step 2: View keyword details and last 15 days search result products
sorftime api KeywordRequest '{"Keyword": "kitchen storage"}' --domain 21
sorftime api KeywordSearchResults '{"Keyword": "kitchen storage", "PageIndex": 1, "PageSize": 40}' --domain 21

# Step 3: Extend related keywords and reverse-lookup product exposure keywords
sorftime api KeywordExtends '{"Keyword": "kitchen storage", "PageIndex": 1, "PageSize": 80}' --domain 21
sorftime api ProductRequestKeyword '{"ProductId": "1234567890", "PageIndex": 1, "PageSize": 60}' --domain 21

# Step 4: Favorite high-value keywords
sorftime api FavoriteKeyword '{"Keyword": "kitchen storage", "Dict": "storage-candidates"}' --domain 21
```

### 5. Keyword Filtering
```bash
# Filter keywords with weekly rank 1-3000 and search volume 5000-50000
sorftime api KeywordQuery '{"Pattern": {"Keyword": "storage", "RankCondition": ["1", "3000"], "SearchVolumeCondition": ["5000", "50000"]}, "PageIndex": 1, "PageSize": 40}' --domain 21
```

### 6. Library Management
```bash
# Favorite candidate keywords
sorftime api FavoriteKeyword '{"Keyword": "kitchen storage", "Dict": "storage-candidates"}' --domain 21

# Query the folder and move high-value keywords
sorftime api GetFavoriteKeyword '{"Command": "dict=storage-candidates", "Page": 1}' --domain 21
sorftime api ChangeFavoriteKeyword '{"Keyword": "kitchen storage", "Dict": "storage-candidates", "Command": "move=storage-core"}' --domain 21

# Delete invalid keywords from all folders
sorftime api ChangeFavoriteKeyword '{"Keyword": "old keyword", "Command": "del"}' --domain 21
```
