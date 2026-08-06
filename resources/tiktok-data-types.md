# TikTok Data Type Definitions

> Data field type definitions for all TikTok endpoints. Each endpoint document only describes the type of the `data` field; for individual fields, see this document.
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
| URL | String | Category URL (seller.tiktok.com) |

---

## CategoryObject

A category market object. Returned in the `data` field of CategoryRequest.

| Field | Type | Description |
|------|------|------|
| IsSubCategory | Boolean | Whether the category is a sub-category |
| Products | Array of [ProductSummeryObject](#productsummeryobject) | Best Seller list products in the category |

---

## CategoryListObject

A category search result object. Returned in the `data` field of CategorySearch.

| Field | Type | Description |
|------|------|------|
| Name | String | Category name |
| NodeId | String | Category NodeId |
| Photo | String Array | Product image URL array under the category |
| MonthlySaleCount | Integer | Monthly sales |
| MonthlySaleCountMoM | Number | Month-over-month change in monthly sales (%, negative = falling) |
| MonthlySaleAmount | Number | Monthly sales amount |
| MonthlySaleAmountMOM | Number | Month-over-month change in monthly sales amount (%, negative = falling) |
| CumulativeSaleCount | Integer | Cumulative sales |
| WeeklySaleCount | Integer | Weekly sales |
| WeeklySaleCountMoM | Number | Week-over-week change in weekly sales (%, negative = falling) |
| WeeklySaleAmount | Number | Weekly sales amount |
| WeeklySaleAmountMOM | Number | Week-over-week change in weekly sales amount (%, negative = falling) |
| AvgPrice | Number | Average selling price |
| AvgPriceMoM | Number | Month-over-month change in average selling price (%, negative = falling) |
| AvgReviewCount | Integer | Average review count |
| AvgStar | Number | Average star rating |
| ShopCount | Integer | Count of source shops for products |
| Top10ProductMonthlySaleCountShare | Number | Top 10 products' share of monthly sales (%) |
| Top10SellerMonthlySaleCountShare | Number | Top 10 sellers' share of monthly sales (%) |
| Top10ProductWeeklySaleCountShare | Number | Top 10 products' share of weekly sales (%) |
| Top10SellerWeeklySaleCountShare | Number | Top 10 sellers' share of weekly sales (%) |
| NewProductCount | Integer | Count of new products listed within 3 months |
| NewProductMonthlySaleCount | Integer | Monthly sales of new products listed within 3 months |
| NewProductMonthlySaleAmount | Number | Monthly sales amount of new products listed within 3 months |
| NewProductMonthlySaleCountShare | Number | Share of monthly sales of new products listed within 3 months (%) |
| NewProducAvgStar | Number | Average star rating of new products listed within 3 months |
| NewProductAvgReviewCount | Integer | Average review count of new products listed within 3 months |
| NewProductWeeklySaleCount | Integer | Weekly sales of new products listed within 3 months |
| NewProductWeeklySaleAmount | Number | Weekly sales amount of new products listed within 3 months |
| AvgVariationCount | Integer | Average variant count |

---

## ProductSummeryObject

A product summary object. Returned in the `data` field or as array element of ProductRequest, ProductSearchFromName, ProductSearch. Also returned as the `Products` array element of CategoryRequest.

| Field | Type | Description |
|------|------|------|
| ProductId | String | Product ID |
| ProductName | String | Product name |
| Photo | String | Product main image URL |
| StoreName | String | Shop name |
| ShopType | String | Shop type: official shop / gold seller / silver seller / regular seller |
| BrandName | String | Brand name |
| MonthlySaleCount | Integer | Monthly sales |
| MonthlySaleAmount | Number | Monthly sales amount |
| WeeklySaleCount | Integer | Weekly sales |
| WeeklySaleAmount | Number | Weekly sales amount |
| CumulativeSaleCount | Integer | Cumulative sales |
| Price | Number | Selling price (local currency) |
| AuthorCount | Integer | Number of creator affiliates (data only on US site) |
| VideoCount | Integer | Number of affiliate videos (data only on US site) |
| SubCategory | String | Sub-category the product belongs to (JSON format `{"Name":"...", "NodeId":"..."}`) |
| Star | Number | Star rating |
| ReviewCount | Integer | Review count |
| IsFreeShipping | Boolean | Whether free shipping is offered |
| ShippingFee | Number | Postage (local currency) |
| Location | String | Shipping origin |
| ExposureTime | String | Product exposure time (yyyy-MM-dd) |

---

## ProductTrendObject

A product historical trend object. Returned in the `data` field of ProductTrendRequest.

| Field | Type | Description |
|------|------|------|
| ProductId | String | Product ID |
| SaleCountTrend | String Array | Sales trend (even indices are period identifiers, odd indices are sales) |
| CumulativeSaleCountTrend | String Array | Cumulative sales trend |
| SaleAmountTrend | String Array | Sales amount trend (local currency) |
| AvgPriceTrend | String Array | Average price trend (recorded only on price change) |
| ReviewCountTrend | String Array | Review count trend |
| StarTrend | String Array | Star rating trend (470 = 4.7 stars) |
| VideoCountTrend | String Array | New affiliate video count trend |
| InfluencerCountTrend | String Array | New affiliate creator count trend |

> **Trend array format**:
> - Type=1 (weekly): period identifier format is `"YYYY-MM Week-WW"` (e.g. `"2026-04 Week-01"`)
> - Type=2 (monthly): period identifier format is `"YYYY-MM"` (e.g. `"2026-04"`)
> - Array structure: `["period1", value1, "period2", value2, ...]`
> - AvgPriceTrend records data points only when the price changes; the last data point is the cut-off point

---

## ShopObject

A shop object. Returned in the `data` field or as array element of ShopRequest, ShopSearch.

| Field | Type | Description |
|------|------|------|
| SellerId | String | Seller ID |
| StoreName | String | Shop name |
| Photo | String | Shop main image URL |
| ShopType | String | Shop type: official shop / regular merchant / gold merchant / silver merchant |
| FansCount | Integer | Fans count |
| SellerProductCount | Integer | Seller's product count |
| SellerCumulativeSaleCount | Integer | Seller's cumulative sales |
| SellerReviewCount | Integer | Seller's review count |
| SellerStar | Number | Seller rating |
| ProductCount | Integer | Number of the seller's products in the top 300 of the sub-category |
| NewProductCount | Integer | Number of the seller's new products in the top 300 of the sub-category |
| MonthlySaleCount | Integer | Monthly sales of the seller's products in the top 300 of the sub-category |
| MonthlySaleAmount | Number | Monthly sales amount of the seller's products in the top 300 of the sub-category |
| WeeklySaleCount | Integer | Weekly sales of the seller's products in the top 300 of the sub-category |
| WeeklySaleAmount | Integer | Weekly sales amount of the seller's products in the top 300 of the sub-category |
| MaxCategory | String | The top operating category (JSON format `{"Name":"...", "NodeId":"..."}`) |
| SecondCategory | String | The second operating category (JSON format) |
| ThirdCategory | String | The third operating category (JSON format) |

---

## AuthorObject (US site only)

A creator object. Returned in the `data` field of AuthorRequest.

| Field | Type | Description |
|------|------|------|
| AuthorId | String | Creator ID |
| AuthorName | String | Creator name |
| AuthorCategory | String | Creator category |
| Avatar | String | Creator avatar URL |
| FansCount | Integer | Fans count |
| Recent30DayFansGrowth | Integer | 30-day fans growth |
| LikeCount | Integer | Total likes |
| Recent30DayLikeCount | Integer | 30-day likes |
| VideoCount | Integer | Number of published videos |
| PromoVideoCount | Integer | Number of affiliate videos |
| Recent30DayVideoCount | Integer | 30-day published video count |
| PromoProductCount | Integer | Number of affiliate products |
| Recent30DayNewPromoCount | Integer | 30-day new affiliate count |
| MaxCategory | String | The top affiliate category (JSON format) |
| SecondCategory | String | The second affiliate category (JSON format) |
| ThirdCategory | String | The third affiliate category (JSON format) |
| Recent15VideoAvgViews | Number | Average views of the recent 15 videos |
| Recent15VideoAvgLikes | Number | Average likes |
| Recent15LikeInteractionRate | Number | Like interaction rate (percentage) |
| Recent15AvgReviewCount | Number | Average review count |
| Recent15ReviewInteractionRate | Number | Review interaction rate (percentage) |
| IsBlueVerified | Boolean | Blue V certified |
| IsMCN | Boolean | Organization account |
| IsRelationShop | Boolean | Whether there is a related shop |

---

## VideoObject (US site only)

A video object. Returned in the `data` field of VideoRequest.

| Field | Type | Description |
|------|------|------|
| VideoId | String | Video ID |
| VideoTitle | String | Video title |
| Thumbnail | String | Video thumbnail URL |
| PublishTime | datetime | Video publish time |
| Tags | String Array | Video tag list |
| AuthorId | String | Creator ID |
| AuthorName | String | Creator name |
| AuthorAvatar | String | Creator avatar URL |
| AuthorCategory | String | Creator category |
| AuthorFansCount | Integer | Creator fans count |
| AuthorRecent30DayFansGrowth | Integer | Creator's 30-day fans growth |
| AuthorLikeCount | Integer | Creator's total likes |
| AuthorRecent30DayLikeCount | Integer | Creator's 30-day likes |
| AuthorVideoCount | Integer | Creator's published video count |
| AuthorRecent30DayVideoCount | Integer | Creator's 30-day published video count |
| Views | Integer | View count |
| Likes | Integer | Like count |
| LikeInteractionRate | Number | Like interaction rate (percentage) |
| ReviewCount | Integer | Review count |
| ReviewInteractionRate | Number | Review interaction rate (percentage) |
| Shares | Integer | Share count |
| EstimatedPromoSales | Integer | Estimated affiliate product sales |
| EstimatedPromoSalesAmount | Integer | Estimated affiliate product sales amount |
| ProductId | String | Affiliate product ID |

---

## TagObject (US site only)

A video tag object. Array element of the `data` field of VideoTagSearch.

| Field | Type | Description |
|------|------|------|
| TagName | String | Tag name |
| RelatedVideoCount | Integer | Number of related affiliate videos |
| MonthlyViews | Integer | Monthly views of affiliate videos |
| MonthlyLikes | Integer | Monthly likes of affiliate videos |
| IsNewTag | Boolean | Whether it is a new tag |
| RelatedProductCount | Integer | Number of related affiliate products |
| MaxCategory | String | The top affiliate category (JSON format) |
| SecondCategory | String | The second affiliate category (JSON format) |
| ThirdCategory | String | The third affiliate category (JSON format) |
