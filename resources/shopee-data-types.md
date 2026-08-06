# Shopee Data Type Definitions

> Data field type definitions for all Shopee endpoints. Each endpoint document only describes the type of the `data` field; for individual fields, see this document.
> All endpoints share a common outer response structure: `RequestLeft`, `RequestConsumed`, `RequestCount`, `Code`, `Message`, `Data`.

---

## CategoryTreeObject

A category tree node. The CategoryTree endpoint returns an array of this object.

| Field | Type | Description |
|------|------|------|
| Id | Integer | Category ID |
| ParentId | Integer | Parent category ID; 0 indicates the top level |
| NodeId | String | Category NodeId |
| Name | String | Category name |
| CNName | String | Chinese name of the category |
| URL | String | Category URL (shopee.xxx) |

---

## CategoryObject

A category market object. Returned in the `data` field of CategoryRequest.

| Field | Type | Description |
|------|------|------|
| SubCategory | Boolean | Whether the category is a sub-category |
| Products | Array of [ProductSummeryObject](#productsummeryobject) | Products in the category |

---

## ProductSummeryObject

A product summary object. Returned in the `data` field of ProductRequest; as the `Products` array element of CategoryRequest; as array element of ProductSearchFromName.

| Field | Type | Description |
|------|------|------|
| Title | String | Product name |
| Photo | String Array | Product main image URL array |
| ProductId | String | Product ID |
| UpdateTime | String | Data update time |
| SalesCount | Integer | Last 30-day sales |
| SalesAmount | Number | Last 30-day sales amount |
| SalesCalcTime | String | Time at which product sales were calculated |
| SaleIsCorrection | Boolean | Whether sales correction was performed (true means corrected; in this case it is recommended to call ProductTrend to re-pull) |
| HisSalesCount | Integer | Cumulative sales |
| ShopId | String | Seller shop ID |
| ShopName | String | Seller shop name |
| ShopLocation | String | Shop source city |
| ShopLocType | String | Whether the shop is a local shop or a cross-border shop |
| ShopType | String | Shop type: regular shop, preferred shop, flagship store |
| Price | Number | Product selling price |
| ListPrice | Number | List price (strikethrough) |
| Discount | Number | Discount rate (e.g. 46.00 means 46% off) |
| Brand | String | Product brand |
| BrandId | String | Brand ID |
| Ratings | Number | Star rating (e.g. 4.8) |
| RatingCount | Integer | Review count |
| SaleTime | String | Product launch time |
| RatingDetail | String | Star rating breakdown as a JSON array: `[1-star count, 2-star count, 3-star count, 4-star count, 5-star count]` |
| BSRCategory | String | Sub-category as a JSON array: `[["Category name", "NodeId", "Rank"], ...]` |

---

## ProductItemObject

A product list item object. Array element of the `Products` field of ProductSearch.

| Field | Type | Description |
|------|------|------|
| Title | String | Product name |
| Photo | String Array | Product main image URL array |
| ProductId | String | Product ID |
| SalesCountOf7D | Integer | Last 7-day sales |
| SalesCount | Integer | Monthly sales (last 30-day sales) |
| MonthlySalesGrowth | Number | Month-over-month sales change (%, positive = rising, negative = falling) |
| SalesAmount | Number | Monthly sales amount (last 30-day sales amount), in local currency |
| HisSalesCount | Integer | Cumulative sales |
| Price | Number | Selling price |
| ShopType | String | Shop type: regular shop, preferred shop, flagship store |
| ShopLocType | String | Seller origin: local shop, cross-border shop |
| SalesTime | String | Listing date (yyyy-MM-dd) |
| RatingCount | Integer | Review count |
| LikeCount | Integer | Like count |
| GoodRate | Number | Positive rating rate (%) |
| BadRate | Number | Negative rating rate (%) |
| Category | String | Top-level category |
| SubCategory | Array | Sub-category array |
| Ratings | Number | Star rating |
| VariationCount | Integer | Variant count |

---

## ProductRelatedObject

A keyword-related product object. Array element of KeywordRelationResults.

| Field | Type | Description |
|------|------|------|
| Title | String | Product name |
| Photo | String Array | Product main image URL array |
| ProductId | String | Product ID |
| SalesCount | Integer | Monthly sales (last 30-day sales) |
| HisSalesCount | Integer | Cumulative sales |
| SalesAmount | Number | Monthly sales amount (last 30-day sales), in local currency |
| SalesTime | String | Listing date (yyyy-MM-dd) |
| RatingCount | Integer | Review count |
| Ratings | Number | Star rating |
| LikeCount | Integer | Like count |
| ShopName | String | Shop name |
| Price | Number | Selling price |
| VariationCount | Integer | Variant count |
| Saleshare | Number | Product sales share in the monthly traffic chart (%) |
| Category | String | Category (top-level) |
| HasMainVideo | Boolean | Whether the product has a main image video |
| IsOfficialStore | Boolean | Whether it is an official flagship store |

---

## ProductArrayObject

A product list container. Returned in the `data` field of ProductSearch.

| Field | Type | Description |
|------|------|------|
| Page | Integer | Current page number |
| PageCount | Integer | Total number of pages |
| Products | Array of [ProductItemObject](#productitemobject) | Product list |

---

## ProductTrendObject

A product historical trend object. Returned in the `data` field of ProductTrend.

| Field | Type | Description |
|------|------|------|
| ProductId | String | Product ID |
| SaleCountTrend | String | Daily last 30-day sales trend array: `["20231001","775","20231002","765",...]` |
| SaleTotalCountTrend | String | Cumulative sales trend array: `["20231001","100","20231002","200",...]` |
| PriceTrend | String | Price trend array (recorded only on price change): `["20241001","19.99","20241102","18.99",...]` |
| ReviewCountTrend | String | Monthly review count trend array: `["202310","1251","202311","1252",...]` |
| StarTrend | String | Monthly star rating trend array (450 = 4.5 stars): `["202310","450","202311","450",...]` |

**Trend data format notes**:

- Array format: even indices are dates/months, odd indices are corresponding data values
- PriceTrend: recorded only when the price changes; the last data point is the cut-off date
  - e.g. `["20241001","19.99","20241102","18.99","20250402","18.99"]`
- Star rating trend: 450 represents 4.5 stars

---

## KeywordQueryPatternObject

A KeywordQuery pattern. The `Pattern` parameter of the KeywordQuery endpoint.

| Field | Type | Description |
|------|------|------|
| Keyword | String | The keyword to query |
| RankCondition | String Array | Monthly search rank filter condition; a 2-element array: `[minimum value, maximum value]`. E.g. `[1,5000]` filters ranks 1-5000; `[0,10000]` filters ranks less than 10000; `[10000]` filters ranks greater than 10000 |
| SearchVolumeCondition | String Array | 30-day search volume filter condition; a 2-element array: `[minimum value, maximum value]` |

---

## KeywordSummeryObject

A keyword summary object. Array element of KeywordQuery, KeywordSearch.

| Field | Type | Description |
|------|------|------|
| Keyword | String | Keyword |
| KeywordCNName | String | Chinese name of the keyword |
| Images | String Array | Top 10 product images from a search result (for quick keyword identification) |
| Rank | Integer | Monthly search rank |
| SearchVolume | Integer | 30-day search volume |
| ProductCount | Integer | Number of competitors |
| SearchVolumeTrend | String Array | Keyword search volume trend: `[202201,1000,202202,1010,...]` (even indices are months, odd indices are estimated monthly search volumes) |
| SearchRankTrend | String | Keyword search rank trend: `[202201,10,202202,15,...]` (even indices are months, odd indices are search ranks) |
| CPC | Integer | CPC precise bid, in local minor units |
| Season | String | Peak season flag |

---

## ShopObject

A shop object. Returned in the `data` field of ShopRequest.

| Field | Type | Description |
|------|------|------|
| ShopId | String | Shop ID |
| ShopName | String | Shop name |
| ShopLocation | String | Shop source location |
| ShopImage | String | Shop main image URL |
| ShopType | String | Shop type: regular shop, preferred shop, flagship store |
| ShopLocType | String | Whether the shop is a local shop or a cross-border shop |
| SaleDate | String | Shop opening date (e.g. 2020-09-20) |
| ShopStar | Integer | Shop star rating (e.g. 4.50 = 4.5 stars) |
| ShopRating | Integer Array | Shop review count JSON array: `[positive review count, neutral review count, negative review count]` |
| Top500ProductCount | Integer | Number of products in the top 500 of the shop |
| Top500SalesCount | Integer | Monthly sales of products in the top 500 of the shop |
| Top500SalesAmount | Number | Monthly sales amount of products in the top 500 of the shop |
| Top500Products | String | JSON array of product IDs of products in the top 500 of the shop (max 500) |
