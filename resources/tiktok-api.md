# TikTok API (17 endpoints)

**Domains**: 301 = US (United States), 304 = PH (Philippines), 305 = VN (Vietnam), 306 = TH (Thailand), 307 = ID (Indonesia), 309 = GB (United Kingdom), 312 = JP (Japan)

> **US-only endpoints**: AuthorRequest, VideoRequest, VideoTagSearch are limited to domain=301 (US site).
>
> **Account endpoints are not differentiated by domain**: CoinQuery, CoinStream, RequestStreamMonth can be called on all 7 sites; the result is account-level data.

**Endpoints in this file (17)**: CategoryTree, CategoryRequest, CategorySearchFromName, CategorySearch, CategoryTrend, ProductRequest, ProductSearchFromName, ProductTrendRequest, ProductSearch, ShopSearch, ShopRequest, AuthorRequest, VideoRequest, VideoTagSearch, CoinQuery, CoinStream, RequestStreamMonth

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency.
For data type definitions, see [`tiktok-data-types.md`](./tiktok-data-types.md). This document covers only parameters and fields unique to TikTok endpoints.

---

## Table of Contents

- [1. Category Market](#1-category-market)
  - [1.1 Category Tree (CategoryTree)](#11-category-tree-categorytree)
  - [1.2 Category Market (CategoryRequest)](#12-category-market-categoryrequest)
  - [1.3 Search Category by Name (CategorySearchFromName)](#13-search-category-by-name-categorysearchfromname)
  - [1.4 Category Search (CategorySearch)](#14-category-search-categorysearch)
  - [1.5 Query Market Historical Trend (CategoryTrend)](#15-query-market-historical-trend-categorytrend)
- [2. Product](#2-product)
  - [2.1 Product Details (ProductRequest)](#21-product-details-productrequest)
  - [2.2 Search Product by Name (ProductSearchFromName)](#22-search-product-by-name-productsearchfromname)
  - [2.3 Product Historical Trend Query (ProductTrendRequest)](#23-product-historical-trend-query-producttrendrequest)
  - [2.4 Product Search (ProductSearch)](#24-product-search-productsearch)
- [3. Seller](#3-seller)
  - [3.1 Seller Search (ShopSearch)](#31-seller-search-shopsearch)
  - [3.2 Seller Query (ShopRequest)](#32-seller-query-shoprequest)
- [4. Creator (US site only)](#4-creator-us-site-only)
  - [4.1 Creator Query (AuthorRequest)](#41-creator-query-authorrequest)
- [5. Video (US site only)](#5-video-us-site-only)
  - [5.1 Video Query (VideoRequest)](#51-video-query-videorequest)
  - [5.2 Video Tag Search (VideoTagSearch)](#52-video-tag-search-videotagsearch)
- [6. Account](#6-account)
  - [6.1 Query This Month's Remaining Credits (CoinQuery)](#61-query-this-months-remaining-credits-coinquery)
  - [6.2 Query Credit Usage Details (CoinStream)](#62-query-credit-usage-details-coinstream)
  - [6.3 Query Monthly Request Usage Details (RequestStreamMonth)](#63-query-monthly-request-usage-details-requeststreammonth)

---

## 1. Category Market

### 1.1 Category Tree (CategoryTree)

- **Endpoint description**: Category tree structure. Note: this endpoint's response data is very large (approx. 10MB+); it is recommended to set a long request timeout.
- **Requests consumed**: 5
- **Request parameters**: none
- **Usage example**:
  ```bash
  # Get the TikTok US site category tree
  sorftime api CategoryTree --domain 301

  # Get the TikTok Japan site category tree
  sorftime api CategoryTree --domain 312
  ```
- **Response data**:
  - `Id`: Category ID.
  - `ParentId`: Parent category ID; 0 indicates the top level.
  - `NodeId`: Category nodeid.
  - `Name`: Category name.
  - `CNName`: Chinese name of the category.
  - `URL`: Category URL.

---

### 1.2 Category Market (CategoryRequest)

- **Endpoint description**: Query the Best Seller products in a category market, which can be used for category data analysis. Supports up to Top 300 products.
- **Requests consumed**: 5
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NodeId | String | Yes | The NodeId to query. E.g. 601281 |

- **Usage example**:
  ```bash
  # Get the Best Seller products under a category
  sorftime api CategoryRequest '{"NodeId": "601281"}' --domain 301

  # Cross-site query (Philippines / Japan)
  sorftime api CategoryRequest '{"NodeId": "601281"}' --domain 304
  sorftime api CategoryRequest '{"NodeId": "601281"}' --domain 312
  ```
- **Response data**:
  - `IsSubCategory`: Whether it is a sub-category. E.g. false.
  - `Products`: Category best-seller list products.
  - `Products.ProductId`: Product ID. E.g. 1729508370969629931.
  - `Products.ProductName`: Product name. E.g. Summer Dress Women 2026.
  - `Products.Photo`: Product main image, URL format.
  - `Products.StoreName`: Store name. E.g. FashionStore.
  - `Products.ShopType`: Shop type. E.g. Gold Seller.
  - `Products.BrandName`: Brand name. E.g. Zara.
  - `Products.MonthlySaleCount`: Monthly sales. E.g. 15000.
  - `Products.MonthlySaleAmount`: Monthly sales amount. E.g. 450000.
  - `Products.WeeklySaleCount`: Weekly sales. E.g. 3500.
  - `Products.WeeklySaleAmount`: Weekly sales amount. E.g. 105000.
  - `Products.CumulativeSaleCount`: Cumulative sales. E.g. 500000.
  - `Products.Price`: Product selling price (unit: local currency). E.g. 2999.
  - `Products.AuthorCount`: Number of affiliate creators (data only on US site). E.g. 1250.
  - `Products.VideoCount`: Number of affiliate videos (data only on US site). E.g. 3500.
  - `Products.Category`: Top-level category the product belongs to, JSON format. E.g. `{"Name":"Women's Clothing", "NodeId":"..."}`.
  - `Products.SubCategory`: Sub-category the product belongs to, JSON format. E.g. `{"Name":"Dresses", "NodeId":"..."}`.
  - `Products.Star`: Star rating. E.g. 4.7.
  - `Products.ReviewCount`: Review count. E.g. 8500.
  - `Products.IsFreeShipping`: Whether free shipping is offered. E.g. true.
  - `Products.ShippingFee`: Postage (unit: local currency). E.g. 0.
  - `Products.Location`: Shipping origin. E.g. China.
  - `Products.ExposureTime`: Product exposure time (format: yyyy-MM-dd). E.g. 2025-01-01.

---

### 1.3 Search Category by Name (CategorySearchFromName)

- **Endpoint description**: Use natural language to search TikTok-related category markets.
- **Requests consumed**: 1
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Name | String | Yes | The category name to search. E.g. dress |

- **Usage example**:
  ```bash
  # Search category by natural language
  sorftime api CategorySearchFromName '{"Name": "dress"}' --domain 301

  # Cross-site search
  sorftime api CategorySearchFromName '{"Name": "dress"}' --domain 312
  ```
- **Response data**:
  - `Data`: Actually returns an Array (elements are objects `[{NodeId, categoryName}, ...]`, at most 5 related categories).

---

### 1.4 Category Search (CategorySearch)

- **Endpoint description**: Multi-dimensional category selection (30+ filter dimensions: sales, price, review, star rating, monopoly, new product, etc.).
- **Requests consumed**: 5
- **Request parameters** (approx. 30 fields, listed in blocks):

  **Pagination / scope**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Page | Integer | No | Paginated query, at most 100 categories per page. Default 1, representing page 1 (all result pagination starts from 1, not 0). E.g. 1 |
  | NodeId | String | No | Optional. If specified: limit search scope to the specified category and its sub-categories (not limited to sub-categories). E.g. 601281 |

  **Review and star rating**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | AvgReviewCountMin | Integer | No | Optional, limit minimum average review count (val >= set value). E.g. 10 |
  | AvgReviewCountMax | Integer | No | Optional, limit maximum average review count (val <= set value). E.g. 5000 |
  | AvgStarMin | Number | No | Optional, limit minimum average star rating (val >= set value). E.g. 4.0 |
  | AvgStarMax | Number | No | Optional, limit maximum average star rating (val <= set value). E.g. 4.9 |

  **Monopoly indicators**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | SourceShopCountMin | Integer | No | Optional, limit minimum shop count of the top 300 products' source shops; a lower count indicates higher shop monopoly (val >= set value). E.g. 5 |
  | SourceShopCountMax | Integer | No | Optional, limit maximum shop count of the top 300 products' source shops (val <= set value). E.g. 100 |
  | Top10ProductMonthlySaleCountShareRatioMin | Number | No | Optional, limit Top 10 products' monthly sales share; a higher value indicates higher product sales monopoly (val >= set value), unit: %. E.g. 10 |
  | Top10ProductMonthlySaleCountShareRatioMax | Number | No | Optional, Top 10 products' monthly sales share maximum value (val <= set value), unit: %. E.g. 60 |
  | Top10SellerMonthlySaleCountShareRatioMin | Number | No | Optional, Top 10 sellers' monthly sales share; a higher value indicates higher top-10-seller sales monopoly (val >= set value), unit: %. E.g. 10 |
  | Top10SellerMonthlySaleCountShareRatioMax | Number | No | Optional, Top 10 sellers' monthly sales share maximum value (val <= set value), unit: %. E.g. 50 |
  | Top10ProductWeeklySaleCountShareRatioMin | Number | No | Optional, Top 10 products' weekly sales share; a higher value indicates higher product sales monopoly (val >= set value), unit: %. E.g. 10 |
  | Top10ProductWeeklySaleCountShareRatioMax | Number | No | Optional, Top 10 products' weekly sales share maximum value (val <= set value), unit: %. E.g. 60 |

  **Sales scale**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | MonthlySaleCountMin | Integer | No | Optional, limit minimum Top 300 monthly sales (val >= set value). E.g. 1000 |
  | MonthlySaleCountMax | Integer | No | Optional, limit maximum Top 300 monthly sales (val <= set value). E.g. 100000 |
  | MonthlySaleCountMoMMin | Number | No | Optional, limit minimum Top 300 monthly sales MoM (val >= set value). E.g. -20 |
  | MonthlySaleCountMoMMax | Number | No | Optional, limit maximum Top 300 monthly sales MoM (val <= set value). E.g. 50 |
  | MonthlySaleAmountMin | Number | No | Optional, limit minimum Top 300 monthly sales amount (val >= set value). E.g. 100 |
  | MonthlySaleAmountMax | Number | No | Optional, limit maximum Top 300 monthly sales amount (val <= set value). E.g. 1000 |
  | MonthlySaleAmountMoMMin | Number | No | Optional, limit minimum Top 300 monthly sales amount MoM (val >= set value). E.g. -20 |
  | MonthlySaleAmountMoMMax | Number | No | Optional, limit maximum Top 300 monthly sales amount MoM (val <= set value). E.g. 50 |
  | CumulativeSaleCountMin | Integer | No | Optional, limit minimum Top 300 cumulative sales (val >= set value). E.g. 5000 |
  | CumulativeSaleCountMax | Integer | No | Optional, limit maximum Top 300 cumulative sales (val <= set value). E.g. 500000 |

  **Price**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | AvgPriceMin | Number | No | Optional, limit minimum average selling price (val >= set value). E.g. 10.00 |
  | AvgPriceMax | Number | No | Optional, limit maximum average selling price (val <= set value). E.g. 100.00 |
  | AvgPriceMoMMin | Number | No | Optional, limit minimum average selling price MoM (val >= set value). E.g. -10 |
  | AvgPriceMoMMax | Number | No | Optional, limit maximum average selling price MoM (val <= set value). E.g. 20 |

  **New product indicators**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NewProductCountMin | Integer | No | Optional, limit minimum number of products listed within 3 months (val >= set value). E.g. 1 |
  | NewProductCountMax | Integer | No | Optional, limit maximum number of products listed within 3 months (val <= set value). E.g. 50 |
  | NewProductMonthlySaleCountMin | Integer | No | Optional, limit minimum monthly sales of products listed within 3 months (val >= set value). E.g. 100 |
  | NewProductMonthlySaleCountMax | Integer | No | Optional, limit maximum monthly sales of products listed within 3 months (val <= set value). E.g. 10000 |
  | NewProductMonthlySaleAmountMin | Number | No | Optional, limit minimum monthly sales amount of products listed within 3 months (val >= set value). E.g. 1000.00 |
  | NewProductMonthlySaleAmountMax | Number | No | Optional, limit maximum monthly sales amount of products listed within 3 months (val <= set value, unit: local currency). E.g. 5000 |
  | NewProductMonthlySaleCountShareRatioMin | Number | No | Optional, limit minimum monthly sales share of products listed within 3 months (val >= set value), unit: %. E.g. 10 |
  | NewProductMonthlySaleCountShareRatioMax | Number | No | Optional, limit maximum monthly sales share of products listed within 3 months (val <= set value), unit: %. E.g. 30 |

- **Usage example**:
  ```bash
  # Search categories with monthly sales between 1000 and 100000
  sorftime api CategorySearch '{"MonthlySaleCountMin": 1000, "MonthlySaleCountMax": 100000}' --domain 301

  # Search categories with average star rating >= 4.0 and new product monthly sales share between 10%-30%
  sorftime api CategorySearch '{"AvgStarMin": 4.0, "NewProductMonthlySaleCountShareRatioMin": 10, "NewProductMonthlySaleCountShareRatioMax": 30}' --domain 301

  # Limit to a specified category and its sub-categories
  sorftime api CategorySearch '{"NodeId": "601281", "MonthlySaleCountMin": 5000}' --domain 301
  ```
- **Response data**:
  - `Name`: Category name. E.g. Casual Dresses.
  - `NodeId`: Category NodeId. E.g. 601281.
  - `MonthlySaleCount`: Monthly sales. E.g. 535747.
  - `MonthlySaleCountMoM`: Month-over-month monthly sales change, negative indicates falling. E.g. -19.85, meaning falling 19.85%.
  - `MonthlySaleAmount`: Monthly sales amount. E.g. 11957858.96.
  - `MonthlySaleAmountMOM`: Month-over-month monthly sales amount change, negative indicates falling. E.g. -3.33, meaning falling 3.33%.
  - `CumulativeSaleCount`: Cumulative sales. E.g. 5058433.
  - `WeeklySaleCount`: Weekly sales. E.g. 92406.
  - `WeeklySaleCountMoM`: Week-over-week weekly sales change, negative indicates falling. E.g. -14.54, meaning falling 14.54%.
  - `WeeklySaleAmount`: Weekly sales amount. E.g. 1965147.01.
  - `WeeklySaleAmountMoM`: Week-over-week weekly sales amount change, negative indicates falling. E.g. -15.29, meaning falling 15.29%.
  - `AvgPrice`: Average selling price. E.g. 22.65.
  - `AvgPriceMoM`: Month-over-month average selling price change, negative indicates falling. E.g. -4.43, meaning falling 4.43%.
  - `AvgReviewCount`: Average review count. E.g. 1512.
  - `AvgStar`: Average star rating. E.g. 4.44.
  - `ShopCount`: Number of source shops for the products. E.g. 176.
  - `Top10ProductMonthlySaleCountShare`: Top 10 products' monthly sales share. E.g. 22.88, meaning 22.88%.
  - `Top10SellerMonthlySaleCountShare`: Top 10 sellers' monthly sales share. E.g. 30.06, meaning 30.06%.
  - `Top10ProductWeeklySaleCountShare`: Top 10 products' weekly sales share. E.g. 27.87, meaning 27.87%.
  - `Top10SellerWeeklySaleCountShare`: Top 10 sellers' weekly sales share. E.g. 33.69, meaning 33.69%.
  - `NewProductCount`: Number of products listed within 3 months. E.g. 39.
  - `NewProductMonthlySaleCount`: Monthly sales of products listed within 3 months. E.g. 44903.
  - `NewProductMonthlySaleAmount`: Monthly sales amount of products listed within 3 months. E.g. 804795.88.
  - `NewProductMonthlySaleCountShare`: Monthly sales share of products listed within 3 months (relative to current category's Top 300 product monthly sales). E.g. 8.38, meaning 8.38%.
  - `NewProducAvgStar`: Average star rating of products listed within 3 months. E.g. 4.40.
  - `NewProductAvgReviewCount`: Average review count of products listed within 3 months. E.g. 218.
  - `NewProductWeeklySaleCount`: Weekly sales of products listed within 3 months. E.g. 6727.
  - `NewProductWeeklySaleAmount`: Weekly sales amount of products listed within 3 months. E.g. 134437.98.
  - `AvgVariationCount`: Average variant count. E.g. 44.

---

### 1.5 Query Market Historical Trend (CategoryTrend)

- **Endpoint description**: Query the historical trend of a category market, covering 30+ dimensions including monthly sales, monthly sales amount, average price, review star rating, etc.
- **Requests consumed**: 2
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NodeId | String | Yes | The NodeId to query. E.g. 601281 |
  | TrendIndex | Integer | Yes | The historical trend type to query (0-33, see mapping table below). E.g. 0 |

- **TrendIndex mapping table**:

  | Value | Trend type | Value | Trend type |
  |----|---------|----|---------|
  | 0 | Monthly sales trend | 1 | Monthly sales MoM trend |
  | 2 | Monthly sales amount trend | 3 | Monthly sales amount MoM trend |
  | 4 | Weekly sales trend | 5 | Weekly sales MoM trend |
  | 6 | Weekly sales amount trend | 7 | Weekly sales amount MoM trend |
  | 8 | Cumulative sales trend | 9 | Average selling price trend |
  | 10 | Average selling price MoM trend | 11 | Median selling price trend |
  | 12 | Median selling price MoM trend | 13 | Average review count trend |
  | 14 | Average star rating trend | 15 | Top 10 products' monthly sales share trend |
  | 16 | Top 10 products' weekly sales share trend | 17 | Top 10 sellers' monthly sales share trend |
  | 18 | Top 10 sellers' weekly sales share trend | 19 | Products-listed-within-3-months count trend |
  | 20 | Products-listed-within-3-months monthly sales trend | 21 | Products-listed-within-3-months monthly sales amount trend |
  | 22 | Products-listed-within-3-months average price trend | 23 | Products-listed-within-3-months monthly sales share trend |
  | 24 | Products-listed-within-3-months average star rating trend | 25 | Products-listed-within-3-months average review count trend |
  | 26 | Products-listed-within-6-months count trend | 27 | Products-listed-within-6-months monthly sales trend |
  | 28 | Products-listed-within-6-months monthly sales amount trend | 29 | Products-listed-within-6-months average price trend |
  | 30 | Products-listed-within-6-months monthly sales share trend | 31 | Products-listed-within-6-months average star rating trend |
  | 32 | Products-listed-within-6-months average review count trend | 33 | Average variant count trend |

- **Usage example**:
  ```bash
  # Query category monthly sales trend
  sorftime api CategoryTrend '{"NodeId": "601281", "TrendIndex": 0}' --domain 301

  # Query category average star rating trend
  sorftime api CategoryTrend '{"NodeId": "601281", "TrendIndex": 14}' --domain 301

  # Cross-site query (UK)
  sorftime api CategoryTrend '{"NodeId": "601281", "TrendIndex": 2}' --domain 309
  ```
- **Response data**:
  - `Data`: At most returns the last 2 years of Top 100 category market trend. Array format: `[date, value, date, value, ...]`, even indices are dates (format `yyyyMMdd`, week start date, e.g. `20251019`), odd indices are the corresponding data. For percentage trends, the unit is percentage (e.g. 50% returns 50).

---

## 2. Product

### 2.1 Product Details (ProductRequest)

- **Endpoint description**: Product (listing) details query.
- **Requests consumed**: 1
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ProductId | String | Yes | The product ID to query. E.g. 1729508370969629931 |

- **Usage example**:
  ```bash
  # Query product details
  sorftime api ProductRequest '{"ProductId": "1729508370969629931"}' --domain 301

  # Cross-site query (Japan)
  sorftime api ProductRequest '{"ProductId": "1729508370969629931"}' --domain 312
  ```
- **Response data**:
  - `ProductId`: Product ID. E.g. 1729508370969629931.
  - `ProductName`: Product name. E.g. Summer Dress Women 2026.
  - `Photo`: Product main image, URL format.
  - `StoreName`: Store name. E.g. FashionStore.
  - `ShopType`: Shop type. E.g. Gold Seller.
  - `BrandName`: Brand name. E.g. Zara.
  - `MonthlySaleCount`: Monthly sales. E.g. 15000.
  - `MonthlySaleAmount`: Monthly sales amount. E.g. 450000.
  - `WeeklySaleCount`: Weekly sales. E.g. 3500.
  - `WeeklySaleAmount`: Weekly sales amount. E.g. 105000.
  - `CumulativeSaleCount`: Cumulative sales. E.g. 500000.
  - `Price`: Product selling price (unit: local currency). E.g. 2999.
  - `AuthorCount`: Number of affiliate creators (data only on US site). E.g. 1250.
  - `VideoCount`: Number of affiliate videos (data only on US site). E.g. 3500.
  - `Category`: Top-level category the product belongs to, JSON format. E.g. `{"Name":"Women's Clothing", "NodeId":"..."}`.
  - `SubCategory`: Sub-category the product belongs to, JSON format. E.g. `{"Name":"Dresses", "NodeId":"..."}`.
  - `Star`: Star rating. E.g. 4.7.
  - `ReviewCount`: Review count. E.g. 8500.
  - `IsFreeShipping`: Whether free shipping is offered. E.g. true.
  - `ShippingFee`: Postage (unit: local currency). E.g. 0.
  - `Location`: Shipping origin. E.g. China.
  - `ExposureTime`: Product exposure time (format: yyyy-MM-dd). E.g. 2025-01-01.

> **Field-naming tips** (TikTok vs Amazon differences):
> - TikTok uses `ProductId` rather than Amazon's `asin`
> - Monthly sales → `MonthlySaleCount` (Amazon is `ListingSalesVolumeOfMonth`)
> - Weekly sales → `WeeklySaleCount` (TikTok-specific dimension)
> - Cumulative sales → `CumulativeSaleCount`
> - Price → `Price` (Amazon is `SalesPrice`)
> - Review count → `ReviewCount` (Amazon is `RatingsCount`)
> - Affiliate creator count → `AuthorCount` (data only on US site, TikTok-specific)
> - Affiliate video count → `VideoCount` (data only on US site, TikTok-specific)
> - Shipping origin → `Location` (TikTok-specific)
> - Top-level category → `Category` (TikTok-specific, parent of `SubCategory`)
> - Shop type → `ShopType` (Gold Seller / Silver Seller / Official Store / Regular Seller)

---

### 2.2 Search Product by Name (ProductSearchFromName)

- **Endpoint description**: Search TikTok for related products by name.
- **Requests consumed**: 2
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Name | String | Yes | The product name to search. E.g. summer dress |
  | Page | Integer | No | Paginated query, at most 100 products per page. Default 1 (all result pagination starts from 1, not 0) |

- **Usage example**:
  ```bash
  # Search products by name
  sorftime api ProductSearchFromName '{"Name": "summer dress"}' --domain 301

  # Cross-site search (Thailand)
  sorftime api ProductSearchFromName '{"Name": "summer dress", "Page": 1}' --domain 306
  ```
- **Response data**: Each element in the array has the same fields as `ProductRequest` (see above).

---

### 2.3 Product Historical Trend Query (ProductTrendRequest)

- **Endpoint description**: Query a product's historical trend data. Returns 8 trend dimensions: sales / cumulative sales / sales amount / average price / review count / star rating / new affiliate video count / new affiliate creator count, aggregated by week or month.
- **Requests consumed**: 5 (Type=2, monthly query) / 10 (Type=1, weekly query)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ProductId | String | Yes | The product ID to query. E.g. 1729508370969629931 |
  | Type | Integer | Yes (omitting returns `Code: 10 Invalid request parameter`) | Type=1 weekly query (10 requests); Type=2 monthly query (5 requests). E.g. 1 |

- **Usage example**:
  ```bash
  # Monthly trend (5 requests)
  sorftime api ProductTrendRequest '{"ProductId": "1729508370969629931", "Type": 2}' --domain 301

  # Weekly trend (10 requests, finer granularity)
  sorftime api ProductTrendRequest '{"ProductId": "1729508370969629931", "Type": 1}' --domain 301
  ```
- **Response data**:
  - `ProductId`: This product's ProductId. E.g. 1729508370969629931.
  - `SaleCountTrend`: Sales trend. `array index % 2 = 0` is the period identifier (weekly is `YYYY-MM Week-WW`, e.g. `2026-04 Week-01`; monthly is `YYYYMM`, e.g. `202604`), `array index % 2 = 1` is the period sales.
  - `CumulativeSaleCountTrend`: Cumulative sales trend (cumulative value as of the end of the period), array format same as above.
  - `SaleAmountTrend`: Sales amount trend (unit: local currency), array format same as above.
  - `AvgPriceTrend`: Average price trend. **Records data points only when the average price changes** (does not record if unchanged); the last data point is the record cutoff.
  - `ReviewCountTrend`: Review count trend (uses the product's review count at the last fetch of the period).
  - `StarTrend`: Star rating trend (uses the product's star rating at the last fetch of the period; `470` = `4.7` stars).
  - `VideoCountTrend`: New affiliate video count trend.
  - `InfluencerCountTrend`: New affiliate creator count trend.

---

### 2.4 Product Search (ProductSearch)

- **Endpoint description**: Multi-dimensional product selection (24 filter dimensions: pagination/scope, price/sales, time/rating/review, shop/shipping/affiliate).
- **Requests consumed**: 5
- **Request parameters** (24 dimensions, listed in blocks):

  **Pagination / scope**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Page | Integer | No | Paginated query, at most 100 products per page. Default 1. E.g. 1 |
  | ProductId | String | No | Optional. If specified: query similar products by ProductId (rather than the product itself). E.g. B0CVM8TXHP |
  | NodeId | String | No | Optional. If specified: limit search scope to the specified category and its sub-categories (not limited to sub-categories). E.g. 7073960011 |
  | Brand | String | No | Optional. If specified: query hot-selling products of the brand. E.g. Anker |
  | SellerName | String | No | Optional. If specified: query hot-selling products by seller name. E.g. AnkerDirect |
  | SellerId | String | No | Optional. If specified: query hot-selling products by seller ID. E.g. A294P4X9EWVXLJ |

  **Price and sales**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | PriceMin | Number | No | Optional, limit minimum selling price. E.g. 20.00 |
  | PriceMax | Number | No | Optional, limit maximum selling price. E.g. 50.00 |
  | MonthSaleCountMin | Integer | No | Optional, limit minimum monthly sales. E.g. 500 |
  | MonthSaleCountMax | Integer | No | Optional, limit maximum monthly sales. E.g. 1000 |
  | WeeklySaleCountMin | Integer | No | Optional, limit minimum weekly sales. E.g. 500 |
  | WeeklySaleCountMax | Integer | No | Optional, limit maximum weekly sales. E.g. 1000 |

  **Time / rating / review**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ExposureTimeMin | String | No | Optional, limit minimum product exposure time, date format yyyy-MM-dd. E.g. 2025-01-01 |
  | ExposureTimeMax | String | No | Optional, limit maximum product exposure time, date format yyyy-MM-dd. E.g. 2026-01-01 |
  | StarMin | Number | No | Optional, limit minimum star rating. E.g. 4.0 |
  | StarMax | Number | No | Optional, limit maximum star rating. E.g. 4.8 |
  | ReviewCountMin | Integer | No | Optional, limit minimum review count. E.g. 50 |
  | ReviewCountMax | Integer | No | Optional, limit maximum review count. E.g. 500 |
  | VariationCountMin | Integer | No | Optional, limit minimum variant count. E.g. 1 |
  | VariationCountMax | Integer | No | Optional, limit maximum variant count. E.g. 10 |

  **Shop / shipping / affiliate**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ShipLocation | Integer | No | Shipping origin: `1`=local, `2`=overseas. E.g. 1 |
  | ShopType | Integer | No | Shop type: `1`=Gold Seller, `2`=Silver Seller, `3`=Official Store, `4`=Regular Seller. E.g. 1 |
  | AuthorCountCountMin | Integer | No | Optional, limit minimum affiliate creator count (data only on US site). E.g. 1 |
  | AuthorCountCountMax | Integer | No | Optional, limit maximum affiliate creator count (data only on US site). E.g. 10 |
  | VideoCountCountMin | Integer | No | Optional, limit minimum affiliate video count (data only on US site). E.g. 1 |
  | VideoCountCountMax | Integer | No | Optional, limit maximum affiliate video count (data only on US site). E.g. 10 |

- **Usage example**:
  ```bash
  # Local shipping, monthly sales >= 500, star rating >= 4.0
  sorftime api ProductSearch '{"ShipLocation": 1, "MonthSaleCountMin": 500, "StarMin": 4.0}' --domain 301

  # Official store, affiliate creator count >= 10
  sorftime api ProductSearch '{"ShopType": 3, "AuthorCountCountMin": 10}' --domain 301

  # Combined category and brand filter
  sorftime api ProductSearch '{"NodeId": "7073960011", "Brand": "Anker", "PriceMin": 20, "PriceMax": 50}' --domain 301
  ```
- **Response data**: Each array element has the same fields as `ProductRequest` (additionally includes `SellerId`: seller ID. E.g. 7495830785034323995).

---

## 3. Seller

### 3.1 Seller Search (ShopSearch)

- **Endpoint description**: Multi-dimensional seller search.
- **Requests consumed**: 5
- **Request parameters** (listed in blocks):

  **Pagination / scope**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Page | Integer | No | Paginated query, at most 100 products per page. Default 1. E.g. 1 |
  | NodeId | String | No | Optional. If specified: query by category (not limited to sub-categories). E.g. 7073960011 |

  **Seller self indicators**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | SellerProductCountMin | Integer | No | Optional, limit minimum seller product count. E.g. 10 |
  | SellerProductCountMax | Integer | No | Optional, limit maximum seller product count. E.g. 1000 |
  | SellerCumulativeSaleCountMin | Integer | No | Optional, limit minimum seller cumulative sales. E.g. 5000 |
  | SellerCumulativeSaleCountMax | Integer | No | Optional, limit maximum seller cumulative sales. E.g. 500000 |
  | SellerReviewCountMin | Integer | No | Optional, limit minimum seller review count. E.g. 100 |
  | SellerReviewCountMax | Integer | No | Optional, limit maximum seller review count. E.g. 10000 |

  **Sub-category Top 300 dimension**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ProductCountMin | Integer | No | Optional, limit minimum number of the seller's products in the sub-category Top 300. E.g. 1 |
  | ProductCountMax | Integer | No | Optional, limit maximum number of the seller's products in the sub-category Top 300. E.g. 50 |
  | WeeklySaleCountMin | Integer | No | Optional, limit minimum weekly sales of the seller's products in the sub-category Top 300. E.g. 100 |
  | WeeklySaleCountMax | Integer | No | Optional, limit maximum weekly sales of the seller's products in the sub-category Top 300. E.g. 10000 |
  | WeeklySaleAmountMin | Number | No | Optional, limit minimum weekly sales amount of the seller's products in the sub-category Top 300. E.g. 1000.00 |
  | WeeklySaleAmountMax | Number | No | Optional, limit maximum weekly sales amount of the seller's products in the sub-category Top 300. E.g. 100000.00 |
  | MonthlySaleCountMin | Integer | No | Optional, limit minimum monthly sales of the seller's products in the sub-category Top 300. E.g. 500 |
  | MonthlySaleCountMax | Integer | No | Optional, limit maximum monthly sales of the seller's products in the sub-category Top 300. E.g. 50000 |
  | MonthlySaleAmountMin | Number | No | Optional, limit minimum monthly sales amount of the seller's products in the sub-category Top 300. E.g. 5000.00 |
  | MonthlySaleAmountMax | Number | No | Optional, limit maximum monthly sales amount of the seller's products in the sub-category Top 300. E.g. 500000.00 |

  **Rating / shop type / fans**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | StarMin | Number | No | Optional, limit minimum seller rating. E.g. 4.0 |
  | StarMax | Number | No | Optional, limit maximum seller rating. E.g. 4.9 |
  | ShopType | String | No | Optional. If specified: query sellers by shop type. E.g. Official Store |
  | FansCountMin | Integer | No | Optional, limit minimum fans count. E.g. 1000 |
  | FansCountMax | Integer | No | Optional, limit maximum fans count. E.g. 1000000 |

- **Usage example**:
  ```bash
  # Fans count >= 1000, rating >= 4.0
  sorftime api ShopSearch '{"FansCountMin": 1000, "StarMin": 4.0}' --domain 301

  # Official store under a specified category
  sorftime api ShopSearch '{"NodeId": "601281", "ShopType": "official-store"}' --domain 301

  # Sellers with monthly sales >= 500 and weekly sales >= 100
  sorftime api ShopSearch '{"MonthlySaleCountMin": 500, "WeeklySaleCountMin": 100}' --domain 301
  ```
- **Response data**:
  - `SellerId`: Seller ID. E.g. 7495830785034323995.
  - `StoreName`: Store name. E.g. FashionStore.
  - `Photo`: Store main image URL.
  - `ShopType`: Shop type. E.g. Gold Seller (values: Official Store / Regular Seller / Gold Seller / Silver Seller).
  - `FansCount`: Fans count. E.g. 500000.
  - `SellerProductCount`: Seller product count. E.g. 1200.
  - `SellerCumulativeSaleCount`: Seller cumulative sales. E.g. 2000000.
  - `SellerReviewCount`: Seller review count. E.g. 85000.
  - `SellerStar`: Seller rating. E.g. 4.8.
  - `ProductCount`: Number of the seller's products in the sub-category Top 300. E.g. 15.
  - `NewProductCount`: Number of the seller's new products in the sub-category Top 300. E.g. 3.
  - `MonthlySaleCount`: Monthly sales of the seller's products in the sub-category Top 300. E.g. 50000.
  - `MonthlySaleAmount`: Monthly sales amount of the seller's products in the sub-category Top 300. E.g. 1500000.
  - `WeeklySaleCount`: Weekly sales of the seller's products in the sub-category Top 300. E.g. 12000.
  - `WeeklySaleAmount`: Weekly sales amount of the seller's products in the sub-category Top 300. E.g. 360000.
  - `MaxCategory`: The largest operating category, JSON object `{Name, NodeId}`.
  - `SecondCategory`: The second largest operating category, JSON object `{Name, NodeId}`.
  - `ThirdCategory`: The third largest operating category, JSON object `{Name, NodeId}`.

---

### 3.2 Seller Query (ShopRequest)

- **Endpoint description**: Query shop details.
- **Requests consumed**: 1
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ShopId | String | Yes | The shop ID to query. E.g. 7495830785034323995 |

- **Usage example**:
  ```bash
  # Query shop details
  sorftime api ShopRequest '{"ShopId": "7495830785034323995"}' --domain 301

  # Cross-site query (Philippines)
  sorftime api ShopRequest '{"ShopId": "7495830785034323995"}' --domain 304
  ```
- **Response data**: Same as `ShopSearch` (see above).

---

## 4. Creator (US site only)

### 4.1 Creator Query (AuthorRequest)

- **Endpoint description**: Query affiliate creator details.
- **Requests consumed**: 1
- **Limitations**: **Limited to domain=301 (US site) only**
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | AuthorId | String | Yes | The creator ID to query. E.g. diegolinkk |

- **Usage example**:
  ```bash
  sorftime api AuthorRequest '{"AuthorId": "diegolinkk"}' --domain 301
  ```
- **Response data**:
  - `AuthorId`: Creator ID. E.g. diegolinkk.
  - `AuthorName`: Creator name. E.g. FashionLisa.
  - `AuthorCategory`: Creator category. E.g. Fashion.
  - `Avatar`: Creator avatar URL.
  - `FansCount`: Fans count. E.g. 2000000.
  - `Recent30DayFansGrowth`: 30-day fans growth. E.g. 50000.
  - `LikeCount`: Total likes. E.g. 15000000.
  - `Recent30DayLikeCount`: 30-day likes. E.g. 500000.
  - `VideoCount`: Number of published videos. E.g. 800.
  - `PromoVideoCount`: Number of affiliate videos. E.g. 300.
  - `Recent30DayVideoCount`: 30-day published video count. E.g. 45.
  - `PromoProductCount`: Number of affiliate products. E.g. 150.
  - `Recent30DayNewPromoCount`: 30-day new affiliate count. E.g. 20.
  - `MaxCategory`: The creator's most-frequent affiliate sub-category, **JSON Object** `{Name, NodeId}`.
  - `SecondCategory`: The creator's second affiliate sub-category, **JSON Object** `{Name, NodeId}`.
  - `ThirdCategory`: The creator's third affiliate sub-category, **JSON Object** `{Name, NodeId}`.
  - `Recent15VideoAvgViews`: Average views of the recent 15 videos. E.g. 150000.
  - `Recent15VideoAvgLikes`: Average likes. E.g. 15000.
  - `Recent15LikeInteractionRate`: Like interaction rate, unit is a percentage (e.g. `50%` returns `50`), e.g. `0.08` (note: stored as a decimal ratio in JSON).
  - `Recent15AvgReviewCount`: Average review count. E.g. 800.
  - `Recent15ReviewInteractionRate`: Review interaction rate, unit is a percentage, e.g. `0.005`.
  - `IsBlueVerified`: Blue V certified. E.g. true.
  - `IsMCN`: Organization account. E.g. false.
  - `IsRelationShop`: Whether there is a related shop. E.g. true.

---

## 5. Video (US site only)

### 5.1 Video Query (VideoRequest)

- **Endpoint description**: Query TikTok video details, synchronously returning video, creator data, and its affiliate product ID.
- **Requests consumed**: 1
- **Limitations**: **Limited to domain=301 (US site) only**
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | VideoId | String | Yes | The video ID to query. E.g. 7635920838302141727 |

- **Usage example**:
  ```bash
  sorftime api VideoRequest '{"VideoId": "7635920838302141727"}' --domain 301
  ```
- **Response data**:
  - `VideoId`: Video ID. E.g. 7635920838302141727.
  - `VideoTitle`: Video title. E.g. Summer Outfit Ideas 2026.
  - `Thumbnail`: Video thumbnail URL.
  - `PublishTime`: Video publish time. E.g. 2026-05-15.
  - `Tags`: Video tag list. E.g. `["fashion", "summer", "outfit", "tiktokfashion"]`.
  - `AuthorId`: Creator ID. E.g. diegolinkk.
  - `AuthorName`: Creator name. E.g. FashionLisa.
  - `AuthorAvatar`: Creator avatar URL.
  - `AuthorCategory`: Creator category. E.g. Fashion.
  - `AuthorFansCount`: Creator fans count. E.g. 2000000.
  - `AuthorRecent30DayFansGrowth`: Creator's 30-day fans growth. E.g. 50000.
  - `AuthorLikeCount`: Creator's total likes. E.g. 15000000.
  - `AuthorRecent30DayLikeCount`: Creator's 30-day likes. E.g. 500000.
  - `AuthorVideoCount`: Creator's published video count. E.g. 800.
  - `AuthorRecent30DayVideoCount`: Creator's 30-day published video count. E.g. 45.
  - `Views`: View count. E.g. 500000.
  - `Likes`: Like count. E.g. 35000.
  - `LikeInteractionRate`: Like interaction rate. E.g. `0.07`.
  - `ReviewCount`: Review count. E.g. 1200.
  - `ReviewInteractionRate`: Review interaction rate. E.g. `0.0024`.
  - `Shares`: Share count. E.g. 5000.
  - `EstimatedPromoSales`: Estimated affiliate product sales. E.g. 3000.
  - `EstimatedPromoSalesAmount`: Estimated affiliate product sales amount. E.g. 90000.
  - `ProductId`: Affiliate product ID. E.g. 1729674451578163426.

---

### 5.2 Video Tag Search (VideoTagSearch)

- **Endpoint description**: Based on the statistics of videos with a given tag, can be used to analyze popular videos, new tags, related video views, and the count of affiliate products.
- **Requests consumed**: 5
- **Limitations**: **Limited to domain=301 (US site) only**
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | TagName | String | Yes | The tag name to query. E.g. `#SummerFashion` |
  | Page | Integer | No | Paginated query, at most 100 tags per page. Default 1 (all result pagination starts from 1, not 0) |

- **Usage example**:
  ```bash
  sorftime api VideoTagSearch '{"TagName": "#SummerFashion"}' --domain 301

  # Page 2
  sorftime api VideoTagSearch '{"TagName": "#SummerFashion", "Page": 2}' --domain 301
  ```
- **Response data**:
  - `TagName`: Tag name. E.g. `#SummerFashion`.
  - `RelatedVideoCount`: Number of related affiliate videos. E.g. 50000.
  - `MonthlyViews`: Monthly views of affiliate videos. E.g. 10000000.
  - `MonthlyLikes`: Monthly likes of affiliate videos. E.g. 500000.
  - `IsNewTag`: Whether the tag is new. E.g. false.
  - `RelatedProductCount`: Number of related affiliate products. E.g. 15000.
  - `MaxCategory`: The largest affiliate category, JSON object `{Name, NodeId}`.
  - `SecondCategory`: The second affiliate category, JSON object `{Name, NodeId}`.
  - `ThirdCategory`: The third affiliate category, JSON object `{Name, NodeId}`.

---

## 6. Account

### 6.1 Query This Month's Remaining Credits (CoinQuery)

- **Endpoint description**: Query remaining credits. Note: credit balance is not differentiated by site or platform; the credits obtained by querying through any site or platform is the total credit balance.
- **Requests consumed**: 0 (does not consume requests)
- **Request parameters**: none
- **Usage example**:
  ```bash
  # Not differentiated by site; any domain works; the result is the account total balance
  sorftime api CoinQuery --domain 301
  sorftime api CoinQuery --domain 312
  ```
- **Response data**:
  - `Coin`: This month's remaining credits.

---

### 6.2 Query Credit Usage Details (CoinStream)

- **Endpoint description**: Query the credit usage details on the current site.
- **Requests consumed**: 0 (does not consume requests)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Querydate | Array | No | A 2-element array: element 0 is the query start time, element 1 is the query end time. Format yyyy-MM-dd. Queries by week, default the most recent 6 months, max range is the most recent 12 months |
  | PageIndex | Integer | No | Query result page index, default page 1 |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200 |

- **Usage example**:
  ```bash
  # Query credit usage details from 2025-01-01 to 2025-03-31
  sorftime api CoinStream '{"Querydate": ["2025-01-01", "2025-03-31"], "PageIndex": 1, "PageSize": 20}' --domain 301
  ```
- **Response data**:
  - `Data`: Credit consumption details array, with the following index meanings:
    - **% 4 = 0**: Task type (1=keyword monitoring, 3=hijacker & stock monitoring, 9=ASIN real-time collection, 10=review real-time collection, 12=Best Seller list monitoring, 15=ASIN subscription update, 27=image-search similar product)
    - **% 4 = 1**: Date, format `yyyyMMddHHmm`
    - **% 4 = 2**: Credits spent
    - **% 4 = 3**: Credits remaining

---

### 6.3 Query Monthly Request Usage Details (RequestStreamMonth)

- **Endpoint description**: Query remaining request count and the usage of purchased request packs. Note: request query is not differentiated by site; the values obtained by querying through any site is the total request balance. For detailed call history, please contact us. For user privacy, we only retain the last 3 days of call records.
- **Requests consumed**: 0 (does not consume requests)
- **Request parameters**: none
- **Usage example**:
  ```bash
  # Not differentiated by site; any domain works; the result is the account total balance
  sorftime api RequestStreamMonth --domain 301
  sorftime api RequestStreamMonth --domain 312
  ```
- **Response data**:
  - `Purchase`: Purchase details. Format: `[["20241001", "420000", "0", "20240930"], ...]` corresponding to `[purchase time, requests obtained, current remaining requests, expiration time]`.
  - `Consume`: Monthly consumption details. Format: `[["202411", "1000"], ["202410", "1000"]]` corresponding to `[month, requests used this month]`.

---

## Notes

1. **Domain support**: The available domains for the 17 endpoints in this file come from the `SiteStr` field of the JSON, which has been converted to `301: us | 304: ph | 305: vn | 306: th | 307: id | 309: uk | 312: jp`. The `303=MY` listed in `_common.md` has no mapping in the JSON and has been omitted.
2. **US-only endpoints**: The `SiteStr` of `AuthorRequest`, `VideoRequest`, `VideoTagSearch` only has `301: us`; passing other domains usually returns 401/404.
3. **Account endpoints are not differentiated by domain**: The data of `CoinQuery`, `CoinStream`, `RequestStreamMonth` is account-level (total credits / total request balance); the 7 domains listed in the `SiteStr` field can all be called, and the result is the same.
4. **Endpoints that consume 0 requests**: The `RequestNum` of `CoinQuery`, `CoinStream`, `RequestStreamMonth` is `0`, and the call does not consume requests. The remaining 14 endpoints all deduct from the account's request balance according to `RequestNum`.
5. **Category tree response is large**: The `CategoryTree` endpoint response is approx. 10MB+; please set a long request timeout.
6. **ProductTrend Type is required**: `ProductTrendRequest` must include `Type` (omitting returns `Code: 10 Invalid request parameter`). Type=2 monthly query consumes 5 requests; Type=1 weekly query consumes 10 requests.
7. **Affiliate-related fields are data-only on US site**: `AuthorCount` (affiliate creator count) and `VideoCount` (affiliate video count) may be empty on other domains.

## Best Practices

1. **Pagination consistency**: The `Page` field of all search endpoints (CategorySearch, ProductSearch, ProductSearchFromName, ShopSearch, VideoTagSearch) starts from `1`, not `0`; at most 100 results per page.
2. **Percentage field unit**: For fields involving percentages (MoM, Top 10 share, interaction rate, etc.), the JSON directly returns the percentage value when explicitly noted (e.g. `50` means `50%`), and the caller does not need to divide by 100; but interaction rate fields (e.g. `LikeInteractionRate`) are actually stored as decimal ratios, so be careful to distinguish when using.
3. **Trend timestamp format**: `CategoryTrend` returns the month as `yyyyMM` (e.g. `202010`); `ProductTrendRequest` returns the week/month identifier (weekly is `YYYY-MM Week-WW`, monthly is `YYYYMM`).
4. **Get category nodeId first**: When querying products/sellers, usually use it together with `NodeId`. You can first call `CategoryTree` to get all categories, then call `CategorySearch` to narrow the scope, and finally use `CategoryRequest` to pull Best Sellers.
