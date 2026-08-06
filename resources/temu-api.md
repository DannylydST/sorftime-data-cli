# Temu API (12 endpoints)

**Domains**: 701 = US (United States), 705 = EU (Europe). Temu only supports these two sites.

**Endpoints in this file**: CategoryTree, CategoryRequest, CategorySearchFromName, CategorySearch, ProductRequest, ProductSearchFromName, ProductTrendRequest, ProductSearch, ShopRequest, CoinQuery, CoinStream, RequestStreamMonth

> **Keyword module not provided** — Temu does not offer any keyword-related endpoints.

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency.
For data type definitions, see [`temu-data-types.md`](./temu-data-types.md). This document covers only parameters and fields unique to Temu endpoints.

---

## Table of Contents

- [1. Category Market](#1-category-market)
  - [1.1 Category Tree (CategoryTree)](#11-category-tree-categorytree)
  - [1.2 Category Market (CategoryRequest)](#12-category-market-categoryrequest)
  - [1.3 Search Category by Name (CategorySearchFromName)](#13-search-category-by-name-categorysearchfromname)
  - [1.4 Category Search (CategorySearch)](#14-category-search-categorysearch)
- [2. Product](#2-product)
  - [2.1 Product Details (ProductRequest)](#21-product-details-productrequest)
  - [2.2 Search Product by Name (ProductSearchFromName)](#22-search-product-by-name-productsearchfromname)
  - [2.3 Product Historical Trend Query (ProductTrendRequest)](#23-product-historical-trend-query-producttrendrequest)
  - [2.4 Product Search (ProductSearch)](#24-product-search-productsearch)
- [3. Seller](#3-seller)
  - [3.1 Seller Query (ShopRequest)](#31-seller-query-shoprequest)
- [4. Credits and Request](#4-credits-and-request)
  - [4.1 Query This Month's Remaining Credits (CoinQuery)](#41-query-this-months-remaining-credits-coinquery)
  - [4.2 Query Credit Usage Details (CoinStream)](#42-query-credit-usage-details-coinstream)
  - [4.3 Query Monthly Request Usage Details (RequestStreamMonth)](#43-query-monthly-request-usage-details-requeststreammonth)

---

## 1. Category Market

### 1.1 Category Tree (CategoryTree)

- **Endpoint description**: Category tree structure. **Note: this endpoint's response data is very large (approx. 10MB+); it is recommended to set a long request timeout.**
- **Requests consumed**: 5
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**: none
- **Usage example**:
  ```bash
  # Get the Temu US site category tree
  sorftime api CategoryTree --domain 701

  # Get the Temu Europe site category tree
  sorftime api CategoryTree --domain 705
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
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NodeId | String | Yes | The category ID to query. E.g. 601281 |

- **Usage example**:
  ```bash
  sorftime api CategoryRequest '{"NodeId": "601281"}' --domain 701
  ```
- **Response data**:
  - `IsSubCategory`: Whether it is a sub-category. E.g. false.
  - `Products`: Category best-seller list products.
  - `Products.ProductId`: Product ID. E.g. 123456789.
  - `Products.ProductName`: Product name. E.g. Wireless Earbuds Bluetooth 5.3.
  - `Products.Photo`: Product main image, URL format. E.g. `"https://p16-oec-general-useast5.ttcdn-us.com/tos-useast5-i-omjb5zjo8w-tx/cad4b7c7409f459a87c54baf31ff8a20~tplv-fhlh96nyum-crop-webp:2000:2000.webp?dr=12190&t=555f072d&ps=933b5bde&shp=8dbd94bf&shcp=607f11de&idc=useast8&from=2378011839"`.
  - `Products.StoreName`: Store name. E.g. TechStore.
  - `Products.BrandName`: Brand name. E.g. Anker.
  - `Products.CumulativeSaleCount`: Cumulative sales. E.g. 50000.
  - `Products.MonthlySaleCount`: Monthly sales. E.g. 3000.
  - `Products.MonthlySaleAmount`: Monthly sales amount. E.g. 450000.
  - `Products.MonthlySaleCountGrowth`: Month-over-month monthly sales change, unit: %. E.g. +15, meaning rising 15%.
  - `Products.Price`: Product selling price (unit: local currency). E.g. 4.88.
  - `Products.ManagedType`: Management type: fully-managed, semi-managed. E.g. fully-managed.
  - `Products.ReviewCount`: Product cumulative review count. E.g. 8500.
  - `Products.Star`: This product's star rating. E.g. 4.8.
  - `Products.SaleTime`: Listing date. E.g. 2025-08-14.
  - `Products.Department`: Top-level category the product belongs to, JSON format. E.g. `{"name":"Electronics", "nodeid":36}`.
  - `Products.BsrCategory`: Sub-category the product belongs to, JSON format. E.g. `{"name":"Electronics", "nodeid":100,"rank":15}`.

---

### 1.3 Search Category by Name (CategorySearchFromName)

- **Endpoint description**: Use natural language to search Temu-related category markets.
- **Requests consumed**: 1
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Name | String | Yes | The category name to search |

- **Usage example**:
  ```bash
  sorftime api CategorySearchFromName '{"Name": "bluetooth earphones"}' --domain 701
  ```
- **Response data**:
  - `Data`: Actually returns an Array (elements are objects).

---

### 1.4 Category Search (CategorySearch)

- **Endpoint description**: Multi-dimensional category selection.
- **Requests consumed**: 5
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Page | Integer | No | Paginated query, at most 100 categories per page. Default 1, representing page 1 (all result pagination starts from 1, not 0). E.g. 1 |
  | NodeId | String | No | Limit search scope to the specified category and its sub-categories (the specified category nodeId is not limited to sub-categories). E.g. 7073960011 |
  | SaleCountMin / SaleCountMax | Integer | No | Top 100 product category monthly sales range (larger value indicates higher product sales monopoly). E.g. 10000 ~ 250000 |
  | SaleCountShareRatioMin / SaleCountShareRatioMax | Number | No | Top 100 products' share of Top 600 products' monthly sales (larger value indicates more concentrated sales), unit: %. E.g. 30 ~ 80 |
  | SaleCountMOMMin / SaleCountMOMMax | Number | No | Top 100 products' month-over-month sales range, unit: %. E.g. -10 ~ 50 |
  | SaleAmountMin / SaleAmountMax | Number | No | Top 100 products' sales amount range. E.g. 100000.00 ~ 10000000.00 |
  | PriceMin / PriceMax | Number | No | Top 100 products' selling price range. E.g. 5.00 ~ 50.00 |
  | AvgReviewCountMin / AvgReviewCountMax | Number | No | Top 100 products' average review count range. E.g. 100 ~ 5000 |
  | AvgStarMin / AvgStarMax | Number | No | Top 100 products' average star rating range. E.g. 4.0 ~ 4.9 |
  | SellerCountMin / SellerCountMax | Integer | No | Top 100 products' seller count range. E.g. 5 ~ 50 |
  | BrandCountMin / BrandCountMax | Integer | No | Top 100 products' brand count range. E.g. 5 ~ 30 |
  | Top10ProductSaleCountShareRatioMin / Max | Number | No | Top 10 products' share of Top 100 products' sales (larger value indicates higher product sales monopoly), unit: %. E.g. 10 ~ 60 |
  | Top10SellerSaleCountShareRatioMin / Max | Number | No | Among the Top 100 products, group by seller; the sales share range of the top 10 sellers, unit: %. E.g. 30 ~ 90 |
  | SemiManagedShopCountMin / Max | Integer | No | Semi-managed shop count range in the Top 100 products. E.g. 1 ~ 100 |
  | SemiManagedShopSaleCountMin / Max | Integer | No | Semi-managed shop monthly sales range in the Top 100 products. E.g. 100 ~ 50000 |
  | SemiManagedShopCumulativeSaleCountMin / Max | Integer | No | Semi-managed shop cumulative sales range in the Top 100 products. E.g. 1000 ~ 100000 |
  | StarSellerCountMin / Max | Integer | No | Star seller count range in the Top 100 products. E.g. 1 ~ 50 |
  | StarSellerMonthlySaleCountMin / Max | Integer | No | Star seller monthly sales range in the Top 100 products. E.g. 100 ~ 50000 |
  | NewProductCountMin / Max | Integer | No | New product count range (listed within 30 days) in the Top 600 products. E.g. 5 ~ 500 |
  | NewProductSaleCountMin / Max | Integer | No | New product monthly sales range (listed within 30 days) in the Top 600 products. E.g. 100 ~ 1000 |
  | NewProductSaleCountShareRatioMin / Max | Number | No | New product monthly sales share in Top 600 range (listed within 30 days), unit: %. E.g. 5.64 |

- **Usage example**:
  ```bash
  # Search categories with monthly sales between 10000 and 250000
  sorftime api CategorySearch '{"SaleCountMin": 10000, "SaleCountMax": 250000}' --domain 701

  # Search markets under a specified category with average star rating 4.0-4.9
  sorftime api CategorySearch '{"NodeId": "7073960011", "AvgStarMin": 4.0, "AvgStarMax": 4.9}' --domain 701
  ```
- **Response data**:
  - `Page`: Paginated query, at most 100 categories per page. Default 1, representing page 1 (all result pagination starts from 1, not 0). E.g. 1.
  - `NodeId`: Optional. If specified: limit search scope to the specified category and its sub-categories. (The specified category nodeId is not limited to sub-categories). E.g. 7073960011.
  - `SaleCountMin`: Optional. If specified: limit the minimum value of Top 100 product category monthly sales; a larger value indicates higher product sales monopoly (val >= set value) when querying markets. E.g. 10000.
  - `SaleCountMax`: Optional. If specified: limit the maximum value of Top 100 product category monthly sales; a larger value indicates higher product sales monopoly (val <= set value) when querying markets. E.g. 250000.
  - `SaleCountShareRatioMin`: Optional. If specified: limit the share of Top 100 products' monthly sales within Top 600 products; a larger value indicates that sales are concentrated in the top 100 products, otherwise sales are more distributed (long-tail category); the minimum value (val >= set value) when querying markets, unit: %. E.g. 30, meaning 30%.
  - `SaleCountShareRatioMax`: Optional. If specified: limit the share of Top 100 products' monthly sales within Top 600 products; a larger value indicates that sales are concentrated in the top 100 products, otherwise sales are more distributed (long-tail category); the maximum value (val <= set value) when querying markets, unit: %. E.g. 80, meaning 80%.
  - `SaleCountMOMMin`: Optional. If specified: limit the month-over-month sales range of Top 100 products; a larger value indicates faster sales growth; the minimum value (val >= set value) when querying markets, unit: %. E.g. -10, meaning falling 10%.
  - `SaleCountMOMMax`: Optional. If specified: limit the month-over-month sales range of Top 100 products; a larger value indicates faster sales growth; the maximum value (val <= set value) when querying markets, unit: %. E.g. 50, meaning 50%.
  - `SaleAmountMin`: Optional. If specified: limit the minimum value of Top 100 product sales amount (val >= set value) when querying markets. E.g. 100000.00.
  - `SaleAmountMax`: Optional. If specified: limit the maximum value of Top 100 product sales amount (val <= set value) when querying markets. E.g. 10000000.00.
  - `PriceMin`: Optional. If specified: limit the minimum value of Top 100 product selling price (val >= set value) when querying markets. E.g. 5.00.
  - `PriceMax`: Optional. If specified: limit the maximum value of Top 100 product selling price (val <= set value) when querying markets. E.g. 50.00.
  - `AvgReviewCountMin`: Optional. If specified: limit the minimum value of Top 100 products' average review count (val >= set value) when querying markets. E.g. 100.
  - `AvgReviewCountMax`: Optional. If specified: limit the maximum value of Top 100 products' average review count (val <= set value) when querying markets. E.g. 5000.
  - `AvgStarMin`: Optional. If specified: limit the minimum value of Top 100 products' average star rating (val >= set value) when querying markets. E.g. 4.0.
  - `AvgStarMax`: Optional. If specified: limit the maximum value of Top 100 products' average star rating (val <= set value) when querying markets. E.g. 4.9.
  - `SellerCountMin`: Optional. If specified: limit the minimum value of Top 100 products' seller count (val >= set value) when querying markets. E.g. 5.
  - `SellerCountMax`: Optional. If specified: limit the maximum value of Top 100 products' seller count (val <= set value) when querying markets. E.g. 50.
  - `BrandCountMin`: Optional. If specified: limit the minimum value of Top 100 products' brand count (val >= set value) when querying markets. E.g. 5.
  - `BrandCountMax`: Optional. If specified: limit the maximum value of Top 100 products' brand count (val <= set value) when querying markets. E.g. 30.
  - `Top10ProductSaleCountShareRatioMin`: Optional. If specified: limit the sales share range of Top 10 products within Top 100 products; a larger value indicates higher product sales monopoly; the minimum value (val >= set value) when querying markets, unit: %. E.g. 10, meaning 10%.
  - `Top10ProductSaleCountShareRatioMax`: Optional. If specified: limit the sales share range of Top 10 products within Top 100 products; a larger value indicates higher product sales monopoly; the maximum value (val <= set value) when querying markets, unit: %. E.g. 60, meaning 60%.
  - `Top10SellerSaleCountShareRatioMin`: Optional. If specified: among the Top 100 products, group by seller; the sales share range of the top 10 sellers; a larger value indicates higher product sales monopoly; the minimum value (val >= set value) when querying markets, unit: %. E.g. 30, meaning 30%.
  - `Top10SellerSaleCountShareRatioMax`: Optional. If specified: among the Top 100 products, group by seller; the sales share range of the top 10 sellers; a larger value indicates higher product sales monopoly; the maximum value (val <= set value) when querying markets, unit: %. E.g. 90, meaning 90%.
  - `SemiManagedShopCountMin`: Optional. If specified: limit the minimum value of semi-managed shop count in Top 100 products (val >= set value) when querying markets. E.g. 1.
  - `SemiManagedShopCountMax`: Optional. If specified: limit the maximum value of semi-managed shop count in Top 100 products (val <= set value) when querying markets. E.g. 100.
  - `SemiManagedShopSaleCountMin`: Optional. If specified: limit the minimum value of semi-managed shop monthly sales in Top 100 products (val >= set value) when querying markets. E.g. 100.
  - `SemiManagedShopSaleCountMax`: Optional. If specified: limit the maximum value of semi-managed shop monthly sales in Top 100 products (val <= set value) when querying markets. E.g. 50000.
  - `SemiManagedShopCumulativeSaleCountMin`: Optional. If specified: limit the minimum value of semi-managed shop cumulative sales in Top 100 products (val >= set value) when querying markets. E.g. 1000.
  - `SemiManagedShopCumulativeSaleCountMax`: Optional. If specified: limit the maximum value of semi-managed shop cumulative sales in Top 100 products (val <= set value) when querying markets. E.g. 100000.
  - `StarSellerCountMin`: Optional. If specified: limit the minimum value of star seller count in Top 100 products (val >= set value) when querying markets. E.g. 1.
  - `StarSellerCountMax`: Optional. If specified: limit the maximum value of star seller count in Top 100 products (val <= set value) when querying markets. E.g. 50.
  - `StarSellerMonthlySaleCountMin`: Optional. If specified: limit the minimum value of star seller monthly sales in Top 100 products (val >= set value) when querying markets. E.g. 100.
  - `StarSellerMonthlySaleCountMax`: Optional. If specified: limit the maximum value of star seller monthly sales in Top 100 products (val <= set value) when querying markets. E.g. 50000.
  - `NewProductCountMin`: Optional. If specified: limit the minimum value of new product count (listed within 30 days) in products that enter the Top 600 (val >= set value) when querying markets. E.g. 5.
  - `NewProductCountMax`: Optional. If specified: limit the maximum value of new product count (listed within 30 days) in products that enter the Top 600 (val <= set value) when querying markets. E.g. 500.
  - `NewProductSaleCountMin`: Optional. If specified: limit the minimum value of new product monthly sales (listed within 30 days) in products that enter the Top 600 (val >= set value) when querying markets. E.g. 100.
  - `NewProductSaleCountMax`: Optional. If specified: limit the maximum value of new product monthly sales (listed within 30 days) in products that enter the Top 600 (val <= set value) when querying markets. E.g. 1000.
  - `NewProductSaleCountShareRatioMin`: Optional. If specified: limit the minimum value of new product monthly sales share in Top 600 (listed within 30 days); (val >= set value) when querying markets, unit: %. E.g. 5.64, meaning 5.64%.
  - `NewProductSaleCountShareRatioMax`: Optional. If specified: limit the maximum value of new product monthly sales share in Top 600 (listed within 30 days); (val <= set value) when querying markets, unit: %. E.g. 5.64, meaning 5.64%.

---

## 2. Product

### 2.1 Product Details (ProductRequest)

- **Endpoint description**: Product (listing) details query.
- **Requests consumed**: 1
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ProductId | String | Yes | The product ID to query |

- **Usage example**:
  ```bash
  sorftime api ProductRequest '{"ProductId": "123456789"}' --domain 701
  ```
- **Response data**:
  - `ProductId`: Product ID. E.g. 123456789.
  - `ProductName`: Product name. E.g. Wireless Earbuds Bluetooth 5.3.
  - `Photo`: Product main image, URL format. E.g. `"https://p16-oec-general-useast5.ttcdn-us.com/tos-useast5-i-omjb5zjo8w-tx/cad4b7c7409f459a87c54baf31ff8a20~tplv-fhlh96nyum-crop-webp:2000:2000.webp?dr=12190&t=555f072d&ps=933b5bde&shp=8dbd94bf&shcp=607f11de&idc=useast8&from=2378011839"`.
  - `StoreName`: Store name. E.g. TechStore.
  - `BrandName`: Brand name. E.g. Anker.
  - `CumulativeSaleCount`: Cumulative sales. E.g. 50000.
  - `MonthlySaleCount`: Monthly sales. E.g. 3000.
  - `MonthlySaleAmount`: Monthly sales amount. E.g. 450000.
  - `MonthlySaleCountGrowth`: Month-over-month monthly sales change, unit: %. E.g. +15, meaning rising 15%.
  - `Price`: Product selling price (unit: local currency). E.g. 4.88.
  - `ManagedType`: Management type: fully-managed, semi-managed. E.g. fully-managed.
  - `ReviewCount`: Product cumulative review count. E.g. 8500.
  - `Star`: This product's star rating. E.g. 4.8.
  - `SaleTime`: Listing date. E.g. 2025-08-14.
  - `Department`: Top-level category the product belongs to, JSON format. E.g. `{"name":"Electronics", "nodeid":36}`.
  - `BsrCategory`: Sub-category the product belongs to, JSON format. E.g. `{"name":"Electronics", "nodeid":100,"rank":15}`.

> **Field-naming tips** (Temu vs Amazon differences):
> - Temu uses `ProductId` rather than Amazon's `asin`
> - Monthly sales → `MonthlySaleCount` (Amazon is `ListingSalesVolumeOfMonth`)
> - Cumulative sales → `CumulativeSaleCount`
> - Price → `Price` (Amazon is `SalesPrice`)
> - Review count → `ReviewCount` (Amazon is `RatingsCount`)
> - Management type → `ManagedType` (fully-managed / semi-managed, Temu-specific field)

---

### 2.2 Search Product by Name (ProductSearchFromName)

- **Endpoint description**: Search Temu for related products by name.
- **Requests consumed**: 2
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Name | String | Yes | The product name to search. E.g. Summer Dress |
  | Page | Integer | No | Paginated query, at most 100 products per page. Default 1, representing page 1 (all result pagination starts from 1, not 0). E.g. 1 |

- **Usage example**:
  ```bash
  sorftime api ProductSearchFromName '{"Name": "Summer Dress"}' --domain 701
  ```
- **Response data**:
  - `ProductId`: Product ID. E.g. 123456789.
  - `ProductName`: Product name. E.g. Wireless Earbuds Bluetooth 5.3.
  - `Photo`: Product main image, URL format. E.g. `"https://p16-oec-general-useast5.ttcdn-us.com/tos-useast5-i-omjb5zjo8w-tx/cad4b7c7409f459a87c54baf31ff8a20~tplv-fhlh96nyum-crop-webp:2000:2000.webp?dr=12190&t=555f072d&ps=933b5bde&shp=8dbd94bf&shcp=607f11de&idc=useast8&from=2378011839"`.
  - `StoreName`: Store name. E.g. TechStore.
  - `BrandName`: Brand name. E.g. Anker.
  - `CumulativeSaleCount`: Cumulative sales. E.g. 50000.
  - `MonthlySaleCount`: Monthly sales. E.g. 3000.
  - `MonthlySaleAmount`: Monthly sales amount. E.g. 450000.
  - `MonthlySaleCountGrowth`: Month-over-month monthly sales change, unit: %. E.g. +15, meaning rising 15%.
  - `Price`: Product selling price (unit: local currency). E.g. 4.88.
  - `ManagedType`: Management type: fully-managed, semi-managed. E.g. fully-managed.
  - `ReviewCount`: Product cumulative review count. E.g. 8500.
  - `Star`: This product's star rating. E.g. 4.8.
  - `SaleTime`: Listing date. E.g. 2025-08-14.
  - `Department`: Top-level category the product belongs to, JSON format. E.g. `{"name":"Electronics", "nodeid":36}`.
  - `BsrCategory`: Sub-category the product belongs to, JSON format. E.g. `{"name":"Electronics", "nodeid":100,"rank":15}`.

---

### 2.3 Product Historical Trend Query (ProductTrendRequest)

- **Endpoint description**: Query a product's historical trend data. Returns the product's weekly-aggregated sales trend, weekly-aggregated cumulative sales trend, weekly-aggregated sales amount trend, weekly-aggregated average price trend, weekly-aggregated review count trend, weekly-aggregated star rating trend, weekly-aggregated new affiliate video count trend, and weekly-aggregated new affiliate creator count trend.
- **Requests consumed**: 5
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ProductId | String | Yes | The product ID to query |

- **Usage example**:
  ```bash
  sorftime api ProductTrendRequest '{"ProductId": "1729508370969629931"}' --domain 701
  ```
- **Response data**:
  - `ProductId`: This product's ProductId. E.g. 1729508370969629931.
  - `SaleCountTrend`: Monthly-aggregated sales trend. Value description: `["202604","268055","202605","300000".....]`. `array index % 2 = 0` is the month, e.g. 202604. `array index % 2 = 1` is the month's sales. E.g. `["202604","268055","202605","300000"]`.
  - `CumulativeSaleCountTrend`: Monthly-aggregated cumulative sales trend (the cumulative value as of the end of the month). Value description: `["202604","344825","202605","400000".....]`. `array index % 2 = 0` is the month, e.g. 202604. `array index % 2 = 1` is the cumulative sales. E.g. `["202604","344825","202605","400000"]`.
  - `SaleAmountTrend`: Monthly-aggregated sales amount trend (unit: local currency). Value description: `["202604","9381925","202605","10000000".....]`. `array index % 2 = 0` is the month, e.g. 202604. `array index % 2 = 1` is the month's sales amount. E.g. `["202604","9381925","202605","10000000"]`.
  - `AvgPriceTrend`: Monthly-aggregated average price trend. Value description: `["202604","35","202605","35".....]`. `array index % 2 = 0` is the month, e.g. 202604. `array index % 2 = 1` is the average price. E.g. `["202604","35","202605","35"]`.
  - `ReviewCountTrend`: Monthly-aggregated review count trend (data taken from the product's review count at the last fetch of the natural month). Value description: `["202604","6951","202605","7000".....]`. `array index % 2 = 0` is the month, e.g. 202604. `array index % 2 = 1` is the review count. E.g. `["202604","6951","202605","7000"]`.
  - `StarTrend`: Monthly-aggregated star rating trend (data taken from the product's star rating at the last fetch of the natural month). Value description: `["202604","460","202605","460".....]`. `array index % 2 = 0` is the month, e.g. 202604. `array index % 2 = 1` is the star rating; 460 = 4.6 stars. E.g. `["202604","460","202605","460"]`.

---

### 2.4 Product Search (ProductSearch)

- **Endpoint description**: Multi-dimensional product search.
- **Requests consumed**: 5
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ProductId | String | No | Query similar products by ProductId. E.g. B0CVM8TXHP |
  | NodeId | String | No | Limit search scope to the specified category and its sub-categories (the specified category nodeId is not limited to sub-categories). E.g. 7073960011 |
  | Brand | String | No | Query hot-selling products of the brand. E.g. Anker |
  | SellerName | String | No | Query hot-selling products by seller name. E.g. AnkerDirect |
  | CumulativeSaleCountMin / Max | Integer | No | Cumulative sales range. E.g. 1000 ~ 100000 |
  | SaleCountMin / SaleCountMax | Integer | No | Monthly sales range. E.g. 100 ~ 50000 |
  | SaleAmountMin / SaleAmountMax | Number | No | Monthly sales amount range. E.g. 1000.00 ~ 500000.00 |
  | SaleCountMoMMin / SaleCountMoMMax | Number | No | Monthly sales MoM range, unit: %. E.g. 20 ~ 20 |
  | PriceMin / PriceMax | Number | No | Selling price range. E.g. 5 ~ 10 |
  | ManageType | Integer | No | Query products by management type. Optional values: 0=All, 1=semi-managed, 2=fully-managed. E.g. 0 |
  | CommentCountMin / CommentCountMax | Integer | No | Review count range. E.g. 10 ~ 5000 |
  | StarMin / StarMax | Number | No | Star rating range. E.g. 4.0 ~ 4.9 |
  | SaleTimeMin / SaleTimeMax | String | No | Listing date range, date format yyyy-MM-dd. E.g. 2025-01-01 ~ 2026-01-01 |

- **Usage example**:
  ```bash
  # Search fully-managed, monthly sales 100-50000, star rating 4.0+ products
  sorftime api ProductSearch '{"ManageType": 2, "SaleCountMin": 100, "SaleCountMax": 50000, "StarMin": 4.0}' --domain 701

  # Search products under a specified category
  sorftime api ProductSearch '{"NodeId": "7073960011", "PriceMin": 5, "PriceMax": 50}' --domain 701
  ```
- **Response data**:
  - `ProductId`: Product ID. E.g. 123456789.
  - `ProductName`: Product name. E.g. Wireless Earbuds Bluetooth 5.3.
  - `Photo`: Product main image, URL format. E.g. `"https://p16-oec-general-useast5.ttcdn-us.com/tos-useast5-i-omjb5zjo8w-tx/cad4b7c7409f459a87c54baf31ff8a20~tplv-fhlh96nyum-crop-webp:2000:2000.webp?dr=12190&t=555f072d&ps=933b5bde&shp=8dbd94bf&shcp=607f11de&idc=useast8&from=2378011839"`.
  - `StoreName`: Store name. E.g. TechStore.
  - `BrandName`: Brand name. E.g. Anker.
  - `CumulativeSaleCount`: Cumulative sales. E.g. 50000.
  - `MonthlySaleCount`: Monthly sales. E.g. 3000.
  - `MonthlySaleAmount`: Monthly sales amount. E.g. 450000.
  - `MonthlySaleCountGrowth`: Month-over-month monthly sales change, unit: %. E.g. +15, meaning rising 15%.
  - `Price`: Product selling price (unit: local currency). E.g. 4.88.
  - `ManagedType`: Management type: fully-managed, semi-managed. E.g. fully-managed.
  - `ReviewCount`: Product cumulative review count. E.g. 8500.
  - `Star`: This product's star rating. E.g. 4.8.
  - `SaleTime`: Listing date. E.g. 2025-08-14.
  - `Department`: Top-level category the product belongs to, JSON format. E.g. `{"name":"Electronics", "nodeid":36}`.
  - `BsrCategory`: Sub-category the product belongs to, JSON format. E.g. `{"name":"Electronics", "nodeid":100,"rank":15}`.

---

## 3. Seller

### 3.1 Seller Query (ShopRequest)

- **Endpoint description**: Query shop details.
- **Requests consumed**: 1
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ShopId | String | Yes | The shop ID to query |

- **Usage example**:
  ```bash
  sorftime api ShopRequest '{"ShopId": "634418218841082"}' --domain 701
  ```
- **Response data**:
  - `ShopId`: Shop ID. E.g. 634418218841082.
  - `ShopName`: Shop name. E.g. TechStore.
  - `ShopPhoto`: Shop main image URL. E.g. `https://img.kwcdn.com/shop/logo-123.jpg`.
  - `ShopType`: Shop type: regular seller, star seller. E.g. star seller.
  - `ShopStar`: Shop star rating. E.g. 4.5.
  - `FansCount`: Fans count. E.g. 44.
  - `SellerStar`: Seller star rating. E.g. 4.6.
  - `ShopFansCount`: Shop fans count. E.g. 44.
  - `ProductCount`: Number of the shop's products that entered the Top 500. E.g. 25.
  - `SaleCount`: Monthly sales of the shop's products that entered the Top 500. E.g. 15000.
  - `SaleAmount`: Monthly sales amount of the shop's products that entered the Top 500. E.g. 299999.99.
  - `MaxSaleCategory`: Among all the brand's products that entered the Top 500, shows the sub-category, nodeid, and corresponding monthly sales of the highest-selling one. JSON format. E.g. `{"Name":"Camping & Hiking", "NodeId":"1628", "SaleCount":"2000"}`.
  - `SecondSaleCategory`: Among all the brand's products that entered the Top 500, shows the sub-category, nodeid, and corresponding monthly sales of the second-highest-selling one. JSON format. E.g. `{"Name":"Camping & Hiking", "NodeId":"1628", "SaleCount":"2000"}`.
  - `ThirdSaleCategory`: Among all the brand's products that entered the Top 500, shows the sub-category, nodeid, and corresponding monthly sales of the third-highest-selling one. JSON format. E.g. `{"Name":"Camping & Hiking", "NodeId":"1628", "SaleCount":"2000"}`.
  - `ManagedType`: Management type: fully-managed, semi-managed. E.g. fully-managed.
  - `Top500Products`: A JSON array of the product IDs of the shop's products that entered the Top 500 (at most the top 500 by monthly sales). Data format: `["<productid>","<productid>","<productid>",...]`. E.g. `["123456789","987654321","111222333"]`.

---

## 4. Credits and Request

### 4.1 Query This Month's Remaining Credits (CoinQuery)

- **Endpoint description**: Query remaining credits. **Note: credit balance is not differentiated by site or platform. The credits obtained by querying through any site or platform is the total credit balance.**
- **Requests consumed**: 0
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api CoinQuery --domain 701
  ```
- **Response data**:
  - `Coin`: This month's remaining credits.

---

### 4.2 Query Credit Usage Details (CoinStream)

- **Endpoint description**: Query the credit usage details on the queried site.
- **Requests consumed**: 0
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Querydate | Array | No | A 2-element array; element 0 is the query start time, element 1 is the query end time. Format yyyy-MM-dd. Queries by week, default the most recent 6 months, max range is the most recent 12 months |
  | PageIndex | Integer | No | Query result page index, default page 1 |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200 |

- **Usage example**:
  ```bash
  sorftime api CoinStream '{"Querydate": ["2026-01-01", "2026-07-01"], "PageIndex": 1, "PageSize": 20}' --domain 701
  ```

- **Response data**:
  - `Data`: Credit consumption details. Example: `[6, 202010010300, -1000, 190000, 6, 202010010400, -1010, 180000, 6, 202010010530, -1050, 170000, .....]`. `array index % 4 = 0` is the task type: 1=keyword monitoring, 3=hijacker & stock monitoring, 9=ASIN real-time collection, 10=review real-time collection, 12=Best Seller list monitoring, 15=ASIN subscription update, 27=image-search similar product. `array index % 4 = 1` is the date (e.g. 20201001), format yyyyMMddHHmm. `array index % 4 = 2` is credits spent. `array index % 4 = 3` is credits remaining.

---

### 4.3 Query Monthly Request Usage Details (RequestStreamMonth)

- **Endpoint description**: Query remaining request count, and the usage of purchased request packs. **Note: request query is not differentiated by site. The values obtained by querying through any site is the total request balance.** For detailed call history, please contact us. For user privacy, we only retain the last 3 days of call records.
- **Requests consumed**: 0
- **Supported domains**: 701(us), 705(eur)
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api RequestStreamMonth --domain 701
  ```
- **Response data**:
  - `Purchase`: Purchase details. Value description: `[["20241001", // purchase time "420000", // requests obtained "0", // current remaining requests "20240930" // expiration time], ...]`.
  - `Consume`: Monthly consumption details. Value description: `[["202411", // month "1000" // requests used this month], ["202410", // month "1000" // requests used this month]]`.
