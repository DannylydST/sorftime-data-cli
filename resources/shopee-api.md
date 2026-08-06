# Shopee Endpoints (17)

**Endpoints in this file**: CategoryTree, CategorySearchFromName, CategoryRequest, CategoryTrend, ProductRequest, ProductSearchFromName, ProductTrend, ProductSearch, ShopRequest, KeywordSearch, KeywordRelationResults, FavoriteKeyword, ChangeFavoriteKeyword, GetFavoriteKeyword, CoinQuery, CoinStream, RequestStreamMonth

**Site support (domain)**: Shopee supports 8 sites; domain values are `201` (VN Vietnam) / `202` (ID Indonesia) / `203` (SG Singapore) / `204` (TH Thailand) / `205` (MY Malaysia) / `206` (TW Taiwan, China) / `207` (PH Philippines) / `208` (BR Brazil). All endpoints support these 8 sites.

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table (Shopee 201-208), error codes, response structure, Shopee gzip+base64 decoding notes, rate limits & concurrency.
For data type definitions, see [`shopee-data-types.md`](./shopee-data-types.md). This document covers Shopee-specific parameters, response fields, and calling notes.

---

## Table of Contents

- [1. Category Market](#1-category-market)
  - [1.1 Category Tree (CategoryTree)](#11-category-tree-categorytree)
  - [1.2 Search Category by Name (CategorySearchFromName)](#12-search-category-by-name-categorysearchfromname)
  - [1.3 Category Best Sellers (supports historical lookup) (CategoryRequest)](#13-category-best-sellers-supports-historical-lookup-categoryrequest)
  - [1.4 Category Historical Trend (CategoryTrend)](#14-category-historical-trend-categorytrend)
- [2. Product Endpoints](#2-product-endpoints)
  - [2.1 Product Details (ProductRequest)](#21-product-details-productrequest)
  - [2.2 Search Product by Name (ProductSearchFromName)](#22-search-product-by-name-productsearchfromname)
  - [2.3 Product Historical Trend (ProductTrend)](#23-product-historical-trend-producttrend)
  - [2.4 Product Search (ProductSearch)](#24-product-search-productsearch)
- [3. Shop Endpoints](#3-shop-endpoints)
  - [3.1 Shop Query (ShopRequest)](#31-shop-query-shoprequest)
- [4. Keyword Endpoints](#4-keyword-endpoints)
  - [4.1 Keyword Query (KeywordSearch)](#41-keyword-query-keywordsearch)
  - [4.2 Keyword-related Products (KeywordRelationResults)](#42-keyword-related-products-keywordrelationresults)
  - [4.3 Add Keyword to My Library (FavoriteKeyword)](#43-add-keyword-to-my-library-favoritekeyword)
  - [4.4 Move / Delete Library Keyword (ChangeFavoriteKeyword)](#44-move--delete-library-keyword-changefavoritekeyword)
  - [4.5 Query Library Keywords (GetFavoriteKeyword)](#45-query-library-keywords-getfavoritekeyword)
- [5. Account / Resource Endpoints](#5-account--resource-endpoints)
  - [5.1 Query This Month's Remaining Credits (CoinQuery)](#51-query-this-months-remaining-credits-coinquery)
  - [5.2 Query Credit Usage Details (CoinStream)](#52-query-credit-usage-details-coinstream)
  - [5.3 Query Monthly Request Usage Details (RequestStreamMonth)](#53-query-monthly-request-usage-details-requeststreammonth)

---

### 1. Category Market

#### 1.1 Category Tree (CategoryTree)

- **Endpoint description**: Returns the Shopee category tree structure. The system excludes categories that are not suitable for third-party sellers, e.g. apps, audio/video, books, music, food, number games, etc.
- **Requests consumed**: 5
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Note**: Response data is very large (approx. 10MB+); it is recommended to set a long request timeout.
- **Request parameters**: none
- **Usage example**:
  ```bash
  # Shopee Vietnam site category tree
  sorftime api CategoryTree --domain 201

  # Shopee Indonesia site category tree
  sorftime api CategoryTree --domain 202
  ```
- **Response data**:
  - `Id`: Category ID.
  - `ParentId`: Parent category ID; 0 indicates the top level.
  - `NodeId`: Category NodeId.
  - `Name`: Category name.
  - `CNName`: Chinese name of the category.
  - `URL`: Category URL.

---

#### 1.2 Search Category by Name (CategorySearchFromName)

- **Endpoint description**: Use natural language to search Shopee-related category markets.
- **Requests consumed**: 1
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Name | String | Yes | The category name to search |

- **Usage example**:
  ```bash
  sorftime api CategorySearchFromName '{"Name": "dress"}' --domain 201
  ```
- **Response data**:
  - `Data`: Actually returns an Array.

---

#### 1.3 Category Best Sellers (supports historical lookup) (CategoryRequest)

- **Endpoint description**: Query the Best Seller Top 500 products in a category. The system excludes categories that are not suitable for third-party sellers, e.g. apps, audio/video, books, music, food, number games, etc.
- **Requests consumed**: 10
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Note**:
  - Data scope is Best Seller Top 500.
  - Only sub-categories support historical lookup; non-sub-categories always return current data.
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NodeId | String | Yes | The NodeId to query |
  | QueryDate | String | No | End time, format yyyy-MM-dd. When not specified, the latest data is queried; when specified, the historical list for the natural week containing this date is queried. E.g. `2025-03-10` represents querying the data for the natural week from 2025-03-10 to 2025-03-16. Only sub-categories support historical lookup; this parameter is invalid for non-sub-categories. |

- **Usage example**:
  ```bash
  # Query the current Best Seller data
  sorftime api CategoryRequest '{"NodeId": "11035813"}' --domain 201

  # Query historical data (the natural week containing 2025-03-10)
  sorftime api CategoryRequest '{"NodeId": "11035813", "QueryDate": "2025-03-10"}' --domain 203
  ```
- **Response data**:
  - `SubCategory`: Whether it is a sub-category.
  - `Products`: Category Best Seller list products.
  - `Products.Title`: Product name.
  - `Products.Photo`: Product main image, URL format. The image is a thumbnail; to get the full image, replace the `_tn` suffix in the URL with `@resize_w900_nl`.
  - `Products.ProductId`: The product's ProductId.
  - `Products.SalesCount`: Last 30-day sales.
  - `Products.SalesAmount`: Last 30-day sales amount.
  - `Products.HisSalesCount`: Cumulative sales.
  - `Products.ShopId`: Seller shop ID.
  - `Products.ShopName`: Seller shop name.
  - `Products.ShopLocation`: Shop source city.
  - `Products.ShopLocType`: Whether the shop is a local shop or a cross-border shop.
  - `Products.ShopType`: Shop type: regular shop, preferred shop, flagship store.
  - `Products.Price`: Product selling price.
  - `Products.ListPrice`: List price (strikethrough).
  - `Products.Discount`: Discount rate. E.g. `46.00` means a 46.00% price reduction.
  - `Products.Brand`: Product brand.
  - `Products.BrandId`: Product brand ID.
  - `Products.Ratings`: Product star rating. E.g. `4.8`.
  - `Products.SaleTime`: Product launch time.
  - `Products.CouponStr`: Promotion coupon.
  - `Products.RatingDetail`: Star rating breakdown, JSON format `["1-star count", "2-star count", "3-star count", "4-star count", "5-star count"]`.
  - `Products.BsrCategory`: Sub-category the product belongs to, value is a 2-D array `[["category name", "NodeId", "sub-category rank"], ...]`.
  - `Products.SalesCalcTime`: The time at which the product's sales were calculated, format yyyy-MM-dd. Shopee may release fake data from time to time; when fake data is found, it is not counted, and after a real data point is collected the sales difference for the intermediate time points is backfilled. Sales before this time are fixed; sales after this time may change, so it is recommended to implement an appropriate sales data backfill mechanism.

---

#### 1.4 Category Historical Trend (CategoryTrend)

- **Endpoint description**: Query the last 2 years of historical trend of a category market.
- **Requests consumed**: 2
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NodeId | String | Yes | The NodeId to query |
  | TrendIndex | Integer | Yes | The historical trend type to query, see the table below for details |

- **TrendIndex mapping table**:

  | Value | Trend type | Value | Trend type |
  |----|---------|----|---------|
  | 0 | Monthly sales trend | 1 | Monthly sales amount trend |
  | 2 | Average price trend | 3 | Average review count trend |
  | 4 | Average star rating trend | 5 | Seller count trend |
  | 6 | Average variant count trend | 7 | Brand count trend |
  | 8 | Flagship store count trend | 9 | Flagship store share trend |
  | 10 | Flagship store monthly sales trend | 11 | Flagship store monthly sales share trend |
  | 12 | Preferred store count trend | 13 | Preferred store share trend |
  | 14 | Preferred store monthly sales trend | 15 | Preferred store monthly sales share trend |
  | 16 | Regular store count trend | 17 | Regular store share trend |
  | 18 | Regular store monthly sales trend | 19 | Regular store monthly sales share trend |
  | 20 | Products-listed-within-1-month count trend | 21 | Products-listed-within-1-month count share trend |
  | 22 | Products-listed-within-1-month sales trend | 23 | Products-listed-within-1-month sales share trend |
  | 24 | Products-listed-within-1-month sales amount trend | 25 | Products-listed-within-1-month sales amount share trend |
  | 26 | Products-listed-within-1-month average star rating trend | 27 | Products-listed-within-1-month average review count trend |
  | 28 | Products-listed-within-1-month average price trend | 29 | Products-listed-within-3-months count trend |
  | 30 | Products-listed-within-3-months count share trend | 31 | Products-listed-within-3-months sales trend |
  | 32 | Products-listed-within-3-months sales share trend | 33 | Products-listed-within-3-months sales amount trend |
  | 34 | Products-listed-within-3-months sales amount share trend | 35 | Products-listed-within-3-months average star rating trend |
  | 36 | Products-listed-within-3-months average review count trend | 37 | Products-listed-within-3-months average price trend |
  | 38 | Products-listed-within-6-months count trend | 39 | Products-listed-within-6-months count share trend |
  | 40 | Products-listed-within-6-months sales trend | 39 | Products-listed-within-6-months sales share trend |
  | 40 | Products-listed-within-6-months sales amount trend | 41 | Products-listed-within-6-months sales amount share trend |
  | 42 | Products-listed-within-6-months average star rating trend | 43 | Products-listed-within-6-months average review count trend |
  | 44 | Products-listed-within-6-months average price trend | 45 | Products-listed-within-12-months count trend |
  | 46 | Products-listed-within-12-months count share trend | 47 | Products-listed-within-12-months sales trend |
  | 48 | Products-listed-within-12-months sales share trend | 49 | Products-listed-within-12-months sales amount trend |
  | 50 | Products-listed-within-12-months sales amount share trend | 51 | Products-listed-within-12-months average star rating trend |
  | 52 | Products-listed-within-12-months average review count trend | 53 | Products-listed-within-12-months average price trend |
  | 54 | Products-listed-within-24-months count trend | 55 | Products-listed-within-24-months count share trend |
  | 56 | Products-listed-within-24-months sales trend | 57 | Products-listed-within-24-months sales amount trend |
  | 58 | Products-listed-within-24-months sales amount trend | 59 | Products-listed-within-24-months sales amount share trend |
  | 60 | Products-listed-within-24-months average star rating trend | 61 | Products-listed-within-24-months average review count trend |
  | 62 | Products-listed-within-24-months average price trend | 63 | Top 3 product sales share trend |
  | 64 | Top 3 product sales amount share trend | 65 | Top 3 seller sales share trend |
  | 66 | Top 3 seller sales amount share trend | 67 | Top 5 product sales share trend |
  | 68 | Top 5 product sales amount share trend | 69 | Top 5 seller sales share trend |
  | 70 | Top 5 seller sales amount share trend | 71 | Top 10 product sales share trend |
  | 72 | Top 10 product sales amount share trend | 73 | Top 10 seller sales share trend |
  | 74 | Top 10 seller sales amount share trend | | |

- **Usage example**:
  ```bash
  # Query category monthly sales trend
  sorftime api CategoryTrend '{"NodeId": "11035813", "TrendIndex": 0}' --domain 201

  # Query flagship store monthly sales share trend
  sorftime api CategoryTrend '{"NodeId": "11035813", "TrendIndex": 11}' --domain 202
  ```
- **Response data**:
  - `Data`: At most returns the last 2 years of Top 500 category market trend. For percentage trends, the unit is a percentage, e.g. 50% returns `50`.
  - Data format example: `[202010, 1000, 202011, 1010, 202012, 1050, ...]`.
  - Elements at array index % 2 == 0 are months, e.g. `202010`; elements at array index % 2 == 1 are the corresponding data.

> Note: The new version of the source data has duplicate index numbers 39/40. 39 represents both "Products-listed-within-6-months count share trend" and "Products-listed-within-6-months sales share trend"; 40 represents both "Products-listed-within-6-months sales trend" and "Products-listed-within-6-months sales amount trend". When actually calling, please refer to the server-returned description as the source of truth.

---

### 2. Product Endpoints

#### 2.1 Product Details (ProductRequest)

- **Endpoint description**: Query the product (listing) details.
- **Requests consumed**: 1
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ProductId | String | Yes | The product ID to query |

- **Usage example**:
  ```bash
  sorftime api ProductRequest '{"ProductId": "21584486278"}' --domain 201
  ```
- **Response data**:
  - `Title`: Product name.
  - `Photo`: Product main image, URL format. The image is a thumbnail; to get the full image, replace the `_tn` suffix in the URL with `@resize_w900_nl`.
  - `ProductId`: The product's ProductId.
  - `SalesCount`: Monthly sales, i.e. last 30-day sales.
  - `SalesAmount`: Monthly sales amount, i.e. last 30-day sales amount.
  - `HisSalesCount`: Cumulative sales.
  - `ShopId`: Seller shop ID.
  - `ShopName`: Seller shop name.
  - `ShopLocation`: Shop source city.
  - `ShopLocType`: Whether the shop is a local shop or a cross-border shop.
  - `ShopType`: Shop type: regular shop, preferred shop, flagship store.
  - `Price`: Product selling price.
  - `ListPrice`: List price (strikethrough).
  - `Discount`: Discount rate. E.g. `46.00` means a 46.00% price reduction.
  - `Brand`: Product brand.
  - `BrandId`: Product brand ID.
  - `Ratings`: Product star rating. E.g. `4.8`.
  - `SaleTime`: Product launch time.
  - `CouponStr`: Promotion coupon.
  - `RatingDetail`: Star rating breakdown, JSON format `["1-star count", "2-star count", "3-star count", "4-star count", "5-star count"]`.
  - `BsrCategory`: Sub-category the product belongs to, value is a 2-D array `[["category name", "NodeId", "sub-category rank"], ...]`.
  - `SalesCalcTime`: The time at which the product's sales were calculated, format yyyy-MM-dd. Shopee may release fake data from time to time; when fake data is found, it is not counted, and after a real data point is collected the sales difference for the intermediate time points is backfilled. Sales before this time are fixed; sales after this time may change, so it is recommended to implement an appropriate sales data backfill mechanism.

---

#### 2.2 Search Product by Name (ProductSearchFromName)

- **Endpoint description**: Search Shopee for related products by name.
- **Requests consumed**: 2
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Name | String | Yes | The category name to search |
  | Page | Integer | No | Paginated query, at most 100 products per page. Default 1, representing page 1; all result pagination starts from 1, not 0. |

- **Usage example**:
  ```bash
  sorftime api ProductSearchFromName '{"Name": "summer dress"}' --domain 201

  # Pagination query
  sorftime api ProductSearchFromName '{"Name": "summer dress", "Page": 2}' --domain 203
  ```
- **Response data**:
  - `Title`: Product name. E.g. `Summer Dress Women 2026`.
  - `Photo`: Product main image, URL format. E.g. `["https://cf.shopee.sg/file/1234567890abcdef"]`.
  - `ProductId`: The product's ProductId. E.g. `123456789012345`.
  - `SalesCount`: Last 30-day sales. E.g. `1500`.
  - `SalesAmount`: Last 30-day sales amount. E.g. `29999.99`.
  - `SalesCalcTime`: Time at which the product's sales were calculated. E.g. `2026-05-20`.
  - `HisSalesCount`: Cumulative sales. E.g. `50000`.
  - `ShopId`: Seller shop ID. E.g. `283391369`.
  - `ShopName`: Seller shop name. E.g. `FashionStore`.
  - `ShopLocation`: Shop source city. E.g. `Nước ngoài`.
  - `ShopLocType`: Whether the shop is a local shop or a cross-border shop. E.g. `cross-border shop`.
  - `ShopType`: Shop type, including regular shop, preferred shop, flagship store. E.g. `preferred shop`.
  - `Price`: Product selling price. E.g. `19.99`.
  - `ListPrice`: List price (strikethrough). E.g. `39.99`.
  - `Discount`: Discount rate. E.g. `46.00` means a 46.00% price reduction.
  - `Brand`: Product brand. E.g. `Zara`.
  - `BrandId`: Product brand ID. E.g. `123456`.
  - `Ratings`: Product star rating. E.g. `4.8`.
  - `RatingDetail`: Star rating breakdown, JSON format `["1-star count", "2-star count", "3-star count", "4-star count", "5-star count"]`. E.g. `[120, 80, 150, 500, 6500]`.
  - `BsrCategory`: Sub-category the product belongs to, JSON format, 2-D array `[["category name", "NodeId", "sub-category rank"], ...]`. E.g. `[["Dresses","11012001","15"],["Summer Dresses","11012002","8"]]`.

---

#### 2.3 Product Historical Trend (ProductTrend)

- **Endpoint description**: Query the product's historical trend.
- **Requests consumed**: 2
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ProductId | String | Yes | The product ID to query |

- **Usage example**:
  ```bash
  sorftime api ProductTrend '{"ProductId": "21584486278"}' --domain 201
  ```
- **Response data**:
  - `ProductId`: The product's ProductId.
  - `SaleCountTrend`: Daily last 30-day sales trend. E.g. `["20231001","775","20231002","765","20231003","711",...]`. Elements at array index % 2 == 0 are dates, elements at array index % 2 == 1 are the last 30-day sales.
  - `SaleTotalCountTrend`: Daily cumulative sales trend. E.g. `["20231001","100","20231002","200","20231003","300",...]`. Elements at array index % 2 == 0 are dates, elements at array index % 2 == 1 are cumulative sales.
  - `PriceTrend`: Price trend. E.g. `["20231001","19.99","20231002","19.99","20231003","19.99",...]`. Elements at array index % 2 == 0 are dates, elements at array index % 2 == 1 are prices.
  - `ReviewCountTrend`: Monthly review count trend, data taken from the product's review count at the last fetch of the natural month. E.g. `["202310","1251","202311","1252","202312","1301",...]`. Elements at array index % 2 == 0 are months, elements at array index % 2 == 1 are review counts.
  - `StarTrend`: Monthly star rating trend, data taken from the product's star rating at the last fetch of the natural month. E.g. `["202310","450","202311","450","202312","440",...]`. Elements at array index % 2 == 0 are months, elements at array index % 2 == 1 are star ratings; `450` = 4.5 stars.

---

#### 2.4 Product Search (ProductSearch)

- **Endpoint description**: Multi-dimensional product query.
- **Requests consumed**: 5
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | QueryWeek | String | No | Look back at historical product data; supports up to 2 years of data from week 3 of June 2024. Format: yyyyMM + week number. When not specified, real-time data is queried; when specified and the time is earlier than the current month, historical data is queried. |
  | Page | Integer | No | Paginated query, at most 100 products per page. Default 1, representing page 1; all result pagination starts from 1, not 0. |
  | ASIN | String | No | Query similar products by ASIN, not limited to this ASIN. If you need to query a single product, call `ProductRequest`. E.g. `B0CVM8TXHP`. |
  | NodeId | String | No | Query by category, not limited to sub-categories. E.g. `7073960011`. |
  | PriceRangeMin | Number | No | Limit minimum selling price; query products whose selling price is greater than or equal to the set value. E.g. `20.00`. |
  | PriceRangeMax | Number | No | Limit maximum selling price; query products whose selling price is less than or equal to the set value. E.g. `50.00`. |
  | MonthSaleVolumeRangeMin | Integer | No | Limit minimum monthly sales; query products whose monthly sales is greater than or equal to the set value. E.g. `500`. |
  | MonthSaleVolumeRangeMax | Integer | No | Limit maximum monthly sales; query products whose monthly sales is less than or equal to the set value. E.g. `1000`. |
  | OnlineDateRangeMin | String | No | Limit minimum listing date, format yyyy-MM-dd. E.g. `2025-01-01`. |
  | OnlineDateRangeMax | String | No | Limit maximum listing date, format yyyy-MM-dd. E.g. `2026-01-01`. |
  | StarRangeMin | Number | No | Limit minimum star rating. E.g. `4.0`. |
  | StarRangeMax | Number | No | Limit maximum star rating. E.g. `4.8`. |
  | CommentCountRangeMin | Integer | No | Limit minimum review count. E.g. `50`. |
  | CommentCountRangeMax | Integer | No | Limit maximum review count. E.g. `500`. |
  | VariationCountRangeMin | Integer | No | Limit minimum variant count. E.g. `1`. |
  | VariationCountRangeMax | Integer | No | Limit maximum variant count. E.g. `10`. |
  | ShopLocation | Integer | No | Seller origin: `1`=local shop, `2`=cross-border shop. |
  | ShopType | Integer | No | Shop type: `1`=regular shop, `2`=preferred shop, `3`=flagship store. |

- **Usage example**:
  ```bash
  # Search local shops, monthly sales >= 500, star rating >= 4
  sorftime api ProductSearch '{"ShopLocation": 1, "MonthSaleVolumeRangeMin": 500, "StarRangeMin": 4.0}' --domain 201

  # Search a specified category, price 20-50
  sorftime api ProductSearch '{"NodeId": "11035813", "PriceRangeMin": 20, "PriceRangeMax": 50}' --domain 202
  ```
- **Response data**:
  - `Page`: Current page number.
  - `PageCount`: Total number of pages, at most 200.
  - `Products`: Product list.
  - `Products.Title`: Product name. E.g. `CHERIFER PGM 10-22 For Teenagers with Chlorella`.
  - `Products.Photo`: Product main image, URL format. E.g. `["https://cf.shopee.sg/file/abc123def456"]`.
  - `Products.ProductId`: The product's ProductId. E.g. `123456789012345`.
  - `Products.SalesCountOf7D`: Last 7-day sales. E.g. `5625`.
  - `Products.SalesCount`: Monthly sales, i.e. last 30-day sales. E.g. `33747`.
  - `Products.MonthlySalesGrowth`: Month-over-month sales change, percentage format; positive means rising, negative means falling. E.g. `9.69`.
  - `Products.SalesAmount`: Monthly sales amount, i.e. last 30-day sales amount, unit: local currency. E.g. `607446`.
  - `Products.HisSalesCount`: Cumulative sales. E.g. `254244`.
  - `Products.Price`: Selling price. E.g. `18`.
  - `Products.ShopType`: Shop type, including regular shop, preferred shop, flagship store. E.g. `regular shop`.
  - `Products.ShopLocType`: Seller origin, including local shop, cross-border shop. E.g. `local shop`.
  - `Products.LikeCount`: Like count. E.g. `1650`.
  - `Products.GoodRate`: Positive rating rate, percentage format. E.g. `92.07`.
  - `Products.BadRate`: Negative rating rate, percentage format. E.g. `7.93`.
  - `Products.Category`: Top-level category. E.g. `Health & Personal Care`.
  - `Products.SubCategory`: Sub-category. E.g. `["General Health Well Being"]`.
  - `Products.Ratings`: Star rating. E.g. `4.70`.
  - `Products.VariationCount`: Variant count. E.g. `6`.

> Note: The new version of the source data has the ProductSearch parameter name as `ASIN`, which seems to be a mix-up with the Amazon interface. Shopee actually uses `ProductId` for similar queries; before calling, please refer to the server-side description as the source of truth, but the request parameter name should be `ASIN` as in the new version of the document.

---

### 3. Shop Endpoints

#### 3.1 Shop Query (ShopRequest)

- **Endpoint description**: Query Shopee shop information.
- **Requests consumed**: 5
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ShopId | String | Yes | The shop ID to query |

- **Usage example**:
  ```bash
  sorftime api ShopRequest '{"ShopId": "123456"}' --domain 201
  ```
- **Response data**:
  - `ShopId`: Shop ID.
  - `ShopName`: Shop name.
  - `ShopLocation`: Shop source location.
  - `ShopImage`: Shop main image link.
  - `ShopType`: Shop type: regular shop, preferred shop, flagship store.
  - `SaleDate`: Shop opening date, e.g. `2020-09-20`.
  - `ShopStar`: Shop star rating.
  - `ShopRating`: Shop review count, JSON format `["positive review count", "neutral review count", "negative review count"]`.
  - `Top500ProductCount`: Number of products in the shop's Top 500.
  - `Top500SalesCount`: Monthly sales of products in the shop's Top 500.
  - `Top500SalesAmount`: Monthly sales amount of products in the shop's Top 500.
  - `Top500Products`: Product ID list in the shop's Top 500, at most the top 500 by monthly sales. Data format: `["productId", "productId", ...]`.

---

### 4. Keyword Endpoints

#### 4.1 Keyword Query (KeywordSearch)

- **Endpoint description**: Query the current trending keyword list.
- **Requests consumed**: 5
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | No | The keyword to query |
  | RankMin | Integer | No | Minimum monthly rank |
  | RankMax | Integer | No | Maximum monthly rank |
  | SearchVolumeMin | Integer | No | Minimum monthly search volume |
  | SearchVolumeMax | Integer | No | Maximum monthly search volume |
  | Page | Integer | No | Query result page index, default page 1 |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200 |

- **Usage example**:
  ```bash
  # Query trending keywords
  sorftime api KeywordSearch --domain 201

  # Search keywords containing "summer dress"
  sorftime api KeywordSearch '{"Keyword": "summer dress"}' --domain 203

  # Search keywords with rank <= 1000 and search volume >= 5000
  sorftime api KeywordSearch '{"RankMax": 1000, "SearchVolumeMin": 5000}' --domain 202
  ```
- **Response data**:
  - `Keyword`: Keyword. E.g. `summer dress`.
  - `KeywordCNName`: Chinese name of the keyword. E.g. `summer dress`.
  - `Images`: Top 10 product images from a search result, for quick keyword identification. E.g. `["https://cf.shopee.sg/file/1234567890abcdef"]`.
  - `Rank`: Monthly search rank. E.g. `150`.
  - `SearchVolume`: 30-day search volume. E.g. `50000`.
  - `ProductCount`: Number of competitors. E.g. `2000`.
  - `SearchVolumeTrend`: Keyword search volume trend. E.g. `[202201,1000,202202,1010,202203,1050,...]`. Elements at array index % 2 == 0 are dates, elements at array index % 2 == 1 are estimated monthly search volumes.
  - `SearchRankTrend`: Keyword search rank trend. E.g. `[202201,10,202202,15,202203,20,...]`. Elements at array index % 2 == 0 are dates, elements at array index % 2 == 1 are search ranks.
  - `Cpc`: CPC precise bid, in local minor units. E.g. `936`.
  - `Season`: Peak season. E.g. `January`.

---

#### 4.2 Keyword-related Products (KeywordRelationResults)

- **Endpoint description**: Query products related to a keyword.
- **Requests consumed**: 5
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The keyword to query |
  | Page | Integer | No | Query result page index, default page 1 |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200 |

- **Usage example**:
  ```bash
  sorftime api KeywordRelationResults '{"Keyword": "summer dress", "PageSize": 50}' --domain 201
  ```
- **Response data**:
  - `Title`: Product name. E.g. `CHERIFER PGM 10-22 For Teenagers with Chlorella`.
  - `Photo`: Product main image, URL format. E.g. `["https://cf.shopee.sg/file/abc123def456"]`.
  - `ProductId`: The product's ProductId. E.g. `123456789012345`.
  - `SalesCount`: Monthly sales, i.e. last 30-day sales. E.g. `33747`.
  - `HisSalesCount`: Cumulative sales. E.g. `254244`.
  - `SalesAmount`: Monthly sales amount, i.e. last 30-day sales amount, unit: local currency. E.g. `607446`.
  - `Ratings`: Star rating. E.g. `4.70`.
  - `LikeCount`: Like count. E.g. `1650`.
  - `ShopName`: Shop name. E.g. `Shopee Choice Fashion`.
  - `Price`: Selling price. E.g. `18`.
  - `VariationCount`: Variant count. E.g. `6`.
  - `Saleshare`: Product's sales share in the monthly traffic chart, percentage format. E.g. `8.05`.
  - `Category`: Top-level category. E.g. `Health & Personal Care`.
  - `HasMainVideo`: Whether the product has a main image video. E.g. `false`.
  - `IsOfficialStore`: Whether it is an official flagship store. E.g. `false`.

---

#### 4.3 Add Keyword to My Library (FavoriteKeyword)

- **Endpoint description**: Add a keyword to your keyword library. The API library (favorites) is not shared with the Sorftime Pro favorites.
- **Requests consumed**: 1
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The keyword to favorite, not limited to trending keywords |
  | Dict | String | No | The folder. When specified, the keyword is added to that folder (the folder is created if it does not exist). The same keyword cannot be added twice to the same folder, but the same keyword can exist in different folders. When not specified, the keyword is added to the `Uncategorized` folder. |

- **Usage example**:
  ```bash
  # Add to the default folder (Uncategorized)
  sorftime api FavoriteKeyword '{"Keyword": "summer dress"}' --domain 201

  # Add to a specified folder
  sorftime api FavoriteKeyword '{"Keyword": "summer dress", "Dict": "womens-clothing"}' --domain 202
  ```
- **Response data**:
  - `Data`: Actually returns an Integer.

---

#### 4.4 Move / Delete Library Keyword (ChangeFavoriteKeyword)

- **Endpoint description**: Move a keyword to a specified folder or delete a keyword. The API library (favorites) is not shared with the Sorftime Pro favorites.
- **Requests consumed**: 0
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Note**: A single folder can hold at most 2000 keywords.
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The keyword that has been favorited |
  | Dict | String | No | The folder whose keyword is to be moved or deleted. When not specified, operates on the keyword in the `Uncategorized` folder. |
  | Command | String | Yes | For delete, pass `del`. When a folder is specified, only the keyword in that folder is deleted; when no folder is specified, the keyword in all folders is deleted. For move, pass `move=<folder name>`; the target folder is created if it does not exist. |

- **Usage example**:
  ```bash
  # Delete a keyword
  sorftime api ChangeFavoriteKeyword '{"Keyword": "summer dress", "Command": "del"}' --domain 201

  # Move a keyword to a specified folder
  sorftime api ChangeFavoriteKeyword '{"Keyword": "summer dress", "Command": "move=womens-clothing"}' --domain 203
  ```
- **Response data**:
  - `Data`: Actually returns an Integer.

---

#### 4.5 Query Library Keywords (GetFavoriteKeyword)

- **Endpoint description**: Query the API keyword library. The API library (favorites) is not shared with the Sorftime Pro favorites.
- **Requests consumed**: 1
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Command | String | Yes | Pass `dict=<folder name>` to query a specified folder; pass `all` to query all keywords; pass `dict` to query only the folder list. |
  | Page | Integer | No | Paginated query, default starts from 1, at most 100 records per page. |

- **Usage example**:
  ```bash
  # Query the folder list
  sorftime api GetFavoriteKeyword '{"Command": "dict"}' --domain 201

  # Query the keywords in a specified folder
  sorftime api GetFavoriteKeyword '{"Command": "dict=womens-clothing"}' --domain 202

  # Query all keywords
  sorftime api GetFavoriteKeyword '{"Command": "all"}' --domain 203
  ```
- **Response data**:
  - `Data`: Query result, a keyword list or folder name list, JSON format `["kw1","kw2",...]`.

---

### 5. Account / Resource Endpoints

#### 5.1 Query This Month's Remaining Credits (CoinQuery)

- **Endpoint description**: Query remaining credits. The credit balance is not differentiated by site or platform; the balance obtained by querying through any site or platform is the total credit balance.
- **Requests consumed**: 0
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api CoinQuery --domain 201
  ```
- **Response data**:
  - `Coin`: This month's remaining credits.

---

#### 5.2 Query Credit Usage Details (CoinStream)

- **Endpoint description**: Query the credit usage details on the currently queried site.
- **Requests consumed**: 0
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Querydate | Array | No | A 2-element array: element 0 is the query start date, element 1 is the query end date. Date format: yyyy-MM-dd. Default: the most recent 6 months, max range is the most recent 12 months. |
  | PageIndex | Integer | No | Query result page index, default page 1. |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200. |

- **Usage example**:
  ```bash
  # Query the most recent 6 months of credit usage details (default)
  sorftime api CoinStream --domain 201

  # Query a specific time range
  sorftime api CoinStream '{"Querydate": ["2025-01-01", "2025-06-30"], "PageIndex": 1, "PageSize": 50}' --domain 203
  ```
- **Response data**:
  - `Data`: Credit consumption details, format example: `[6, 202010010300, -1000, 190000, 6, 202010010400, -1010, 180000, ...]`.
  - Every 4 elements form a record:
    - The 1st element is the task type: `1`=keyword monitoring, `3`=hijacker & stock monitoring, `9`=ASIN real-time collection, `10`=review real-time collection, `12`=Best Seller list monitoring, `15`=ASIN subscription update, `27`=image-search similar product.
    - The 2nd element is a date, format yyyyMMddHHmm, e.g. `202010010300`.
    - The 3rd element is credits spent.
    - The 4th element is credits remaining.

---

#### 5.3 Query Monthly Request Usage Details (RequestStreamMonth)

- **Endpoint description**: Query the remaining request count and the usage of purchased request packs. Request query is not differentiated by site; the balance obtained by querying through any site is the total request balance. For detailed call history, please contact Sorftime. For user privacy, only the last 3 days of call records are retained.
- **Requests consumed**: 0
- **Supported domains**: 201(vn), 202(id), 203(sg), 204(th), 205(my), 206(tw), 207(ph), 208(br)
- **Note**: Request query is not differentiated by site; the balance obtained by querying through any site is the account total request balance.
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api RequestStreamMonth --domain 201
  ```
- **Response data**:
  - `Purchase`: Purchase details. Each record contains the purchase time, the number of requests obtained from the purchase, the current number of available requests, and the expiration time. Example: `[["20241001","420000","0","20240930"], ...]`.
  - `Consume`: Monthly consumption details. Each record contains the month and the number of requests used this month. Example: `[["202411","1000"],["202410","1000"]]`.

---

## Notes and Best Practices

1. **Request rate**: At most 10 requests/second; control the rate when batch querying.
2. **Account configuration**: All endpoints use the Account-SK of the currently active profile by default.
3. **Data decoding**: Shopee endpoint returns are gzip+base64 encoded data; the CLI automatically decodes and decompresses them.
4. **Credits and Request**: `CoinQuery`, `CoinStream`, `RequestStreamMonth` do not consume request count, and the balance is not differentiated by site or platform — the result is the account global balance.
5. **Library isolation**: The API library (favorites) is not shared with the Sorftime Pro favorites; the two are maintained independently.
6. **Historical lookup range**: `CategoryRequest` historical lookup only supports sub-categories; `QueryDate` is invalid for non-sub-categories. `CategoryTrend` and `ProductSearch` historical lookup supports up to the most recent 2 years.
7. **Large-data endpoints**: `CategoryTree` response is approx. 10MB+; set a long request timeout.
8. **Sales data backfill**: Sales data before the `SalesCalcTime` returned by `CategoryRequest` and `ProductRequest` is fixed; data after that time may change, so it is recommended to implement an appropriate sales data backfill mechanism.
9. **Trend index verification**: In the new version of the source data for `CategoryTrend`, the index numbers 39/40 are duplicated. When actually calling, please refer to the server-returned description as the source of truth.
