# Amazon Product Endpoints (18)

**Amazon Domains**: 1=US, 2=UK, 3=DE, 4=FR, 5=IN, 6=CA, 7=JP, 8=ES, 9=IT, 10=MX, 11=AE, 12=AU, 13=BR, 14=SA

**Endpoints in this file**: ProductRequest, ProductSearch, AsinSalesVolume, ProductVariations, ProductReviewsCollection, ProductReviewsCollectionStatusQuery, ProductReviewsQuery, ProductSearchFromName, ProductCustomersSay, ASINSubscription, ASINSubscriptionQuery, ASINSubscriptionCollection, ProductAssistant, ProductRealtimeRequest, ProductRealtimeRequestStatusQuery, SimilarProductRealtimeRequest, SimilarProductRealtimeRequestStatusQuery, SimilarProductRealtimeRequestCollection

> **Endpoint rename**:
> - `ProductVariationHistory` has been renamed to `ProductVariations` (the old name still works, but the new name is recommended).

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency. This document covers only parameters and fields unique to the Amazon product core endpoints.
Field names in this file are PascalCase (e.g. `Asin`, `NodeId`, `PageIndex`); other Amazon endpoint fields are described in camelCase in [amazon-data-types.md](./amazon-data-types.md).

---

## Table of Contents

- [1. Product basic queries](#1-product-basic-queries)
  - [1.1 Product Details (with Product Trend) (ProductRequest)](#11-product-details-with-product-trend-productrequest)
  - [1.2 Product Search (ProductSearch)](#12-product-search-productsearch)
- [2. Product historical data](#2-product-historical-data)
  - [2.1 Officially Disclosed Variant Sales (AsinSalesVolume)](#21-officially-disclosed-variant-sales-asinsalesvolume)
  - [2.2 Product Variant Data (ProductVariations)](#22-product-variant-data-productvariations)
  - [2.3 Product Reviews CustomerSay Query (ProductCustomersSay)](#23-product-reviews-customersay-query-productcustomerssay)
- [3. Product reviews](#3-product-reviews)
  - [3.1 Real-time Collection of Product Reviews (ProductReviewsCollection)](#31-real-time-collection-of-product-reviews-productreviewscollection)
  - [3.2 Real-time Review Task Status Query (ProductReviewsCollectionStatusQuery)](#32-real-time-review-task-status-query-productreviewscollectionstatusquery)
  - [3.3 Product Reviews (ProductReviewsQuery)](#33-product-reviews-productreviewsquery)
- [4. Product search & ASIN subscription](#4-product-search--asin-subscription)
  - [4.1 Search Product by Name (ProductSearchFromName)](#41-search-product-by-name-productsearchfromname)
  - [4.2 ASIN Update Subscription (ASINSubscription)](#42-asin-update-subscription-asinsubscription)
  - [4.3 ASIN Subscription Query (ASINSubscriptionQuery)](#43-asin-subscription-query-asinsubscriptionquery)
  - [4.4 ASIN Subscription Data Query (ASINSubscriptionCollection)](#44-asin-subscription-data-query-asinsubscriptioncollection)
- [5. AI product interpretation](#5-ai-product-interpretation)
  - [5.1 AI Product Interpretation (ProductAssistant)](#51-ai-product-interpretation-productassistant)
- [6. Product real-time & image search](#6-product-real-time--image-search)
  - [6.1 Real-time Data Refresh](#61-real-time-data-refresh)
    - [6.1.1 Product Realtime Update (ProductRealtimeRequest)](#611-product-realtime-update-productrealtimerequest)
    - [6.1.2 Realtime Update Status (ProductRealtimeRequestStatusQuery)](#612-realtime-update-status-productrealtimerequeststatusquery)
  - [6.2 Image Search for Similar Products](#62-image-search-for-similar-products)
    - [6.2.1 Image Search Submit (SimilarProductRealtimeRequest)](#621-image-search-submit-similarproductrealtimerequest)
    - [6.2.2 Image Search Status (SimilarProductRealtimeRequestStatusQuery)](#622-image-search-status-similarproductrealtimerequeststatusquery)
    - [6.2.3 Image Search Result (SimilarProductRealtimeRequestCollection)](#623-image-search-result-similarproductrealtimerequestcollection)

---

## 1. Product basic queries

### 1.1 Product Details (with Product Trend) (ProductRequest)

- **Endpoint description**: Product (listing) details query. Note: when the ASIN does not exist or the link is broken, no data is returned (in this scenario, to confirm the product status, we will fetch the product details in real time); the request still consumes quota.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ASIN | String | Yes | The ASIN to query. Supports querying up to 10 ASINs at once. When calculating request consumption, fees are charged according to the actual number of ASINs called (2 ASINs charged at 2x, 3 ASINs at 3x, and so on). |
  | Trend | Integer | No | Whether to include trend data in the result (see the fields ending in `trend` in `ProductObject`). 1: includes (default includes), 2: excludes |
  | QueryTrendStartDt | String | No | Optional, valid when `trend=1`. If you want to query trend data after a specific date, set this value. Format: yyyy-MM-dd. Default (when trend is enabled but this parameter is not specified) trend only returns the last 15 days of data; if you need more data, you must specify this parameter. When the requested historical trend exceeds 15 days, request consumption = 2 |
  | QueryTrendEndDt | String | No | Optional, valid when `QueryTrendStartDt` is set (with `trend=1`), represents the query end date, format: yyyy-MM-dd. According to the actual number of days queried from `QueryTrendStartDt` to `QueryTrendEndDt`, when less than or equal to 15 days, request consumption = 1; when greater than 15 days, request consumption = 2 |
- **Usage example**:
  ```bash
  sorftime api ProductRequest '{"asin": "B0CVM8TXHP"}' --domain 1
  ```
- **Response data**:
  - `Title`: Product name.
  - `Photo`: This product's main image, URL format.
  - `EBCPhoto`: Images in this product's A+ page.
  - `StoreName`: Store name.
  - `Description`: Five-point description.
  - `ProductBadge`: Product badges, e.g. `["Amazon Choice", "Best Seller", "New Release"]`.
  - `UpdateDate`: Current ASIN update time; if you need to update the data, you can call `ProductRealtimeRequest` for a real-time update.
  - `AsinSalesCount`: This ASIN's monthly sales as disclosed by Amazon. If there is a disclosed value in the last 7 natural days, the latest value is returned; otherwise 0 is returned.
  - `ListingSalesVolumeOfDaily`: Listing daily sales historical trend from as early as 2021-01-01. For common categories, this field's value is null. When value is -1, it means sales cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). Example: `[20210101,1000,20210102,1010,20210103,1050,.....]`. Even array indices are dates, e.g. 20210101; odd array indices are estimated daily sales, e.g. 1000. When value is `-1`, it means that day has no estimated sales.
  - `ListingSalesOfDaily`: Listing daily sales amount historical trend from as early as 2020-10-01. When value is -1, it means the sales amount cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). In local minor units (e.g. cents on the US site). Example: 1999 = 19.99 USD on the US site. When value is `-1`, it means that day has no estimated sales amount.
  - `ListingSalesVolumeOfMonthTrend`: Listing monthly sales (last 30-day sales) historical trend from as early as 2020-10. When value is -1, it means sales cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). Example: `[20210101,1000,20210102,1010,20210103,1050,.....]`. Even array indices are dates, e.g. 20201001; odd array indices are monthly sales (last 30-day sales), e.g. 1000. When value is `-1`, it means that month has no estimated sales. Note: the response data is the last 30-day sales statistics per day; to view the natural month's monthly sales, you can read the data for the last day of each month.
  - `ListingSalesOfMonthTrend`: Listing monthly sales amount historical trend from as early as 2020-10-01. When value is -1, it means the sales amount cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). In local minor units (e.g. cents on the US site). Example: 1999 = 19.99 USD on the US site. When value is `-1`, it means that day has no estimated sales amount. Note: the response data is the last 30-day sales amount per day; to view the natural month's monthly sales amount, you can read the data for the last day of each month.
  - `RankTrend`: This product's top-level category change history. Value description: `["Date", "Top-level category NodeId:Top-level category rank", "Date", "Top-level category NodeId:Top-level category rank", ....]`.
  - `BsrRankTrend`: This product's sub-category rank history. JSON format. Example: `[{"NodeId":"7073960011","Rank":[20250101,1,20250102,10,......]},{"NodeId":"510114","Rank":[20250301,1,20250302,10,......]},......]`.
  - `DealTrend`: Deal status history, based on the ASIN update frequency. When we update the ASIN data, if there is a deal, we record the deal status. If you want more accurate Deal trend data, please subscribe to the update via the `AsinSubscription` endpoint. Example: `[20240501,1,20240502,1,20250503,0,.....]`. Even array indices are dates, e.g. 20201001; odd array indices are the deal status flag, 1: has deal, 0: no deal.
  - `OffSale`: Whether the current product is not for sale; value = 1 means not for sale, otherwise 0.
  - `Asin`: This product's ASIN.
  - `ParentAsin`: Parent ASIN. When the product has variants, this represents the product's parent ASIN; when the product has no variants, this field is null. When a listing has multiple variants, every variant's ParentASIN is the same, while ASIN is different.
  - `VariationASIN`: Variant ASIN list. If the product has variants, this is the product's variant ASIN list; if the product has no variants, this field is null.
  - `Attribute`: The product's attributes; if the product has variants, this represents the variant's attributes. If not, the data is null. Value description: `[["<variant asin>", "Style", "1.2 Cu. Ft.-Smart Sensor", "Color", "Black Stainless Steel"], [...]]`.
  - `VariationASINCount`: Variant count.
  - `PriceTrend`: This ASIN's selling price (coupon not deducted) historical trend from as early as 2020-10-01. Example: `[20201001,1999,20201002,1999,20201003,1899,.....]`. Even array indices are dates, e.g. 20201001; odd array indices are the ASIN selling price, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site. When value is `-1`, it means that day has no available price.
  - `ListPriceTrend`: This ASIN's list price (strikethrough) historical trend from as early as 2020-10-01. Example: `[20201001,1999,20201002,1999,20201003,1899,.....]`. Even array indices are dates, e.g. 20201001; odd array indices are the ASIN list price, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site. When value is `-1`, it means that day has no available price.
  - `ProductType`: The category this product belongs to.
  - `Coupon`: The coupon policy applied to the product's one-time purchase at the time of our collection. When value > 0, it represents a specific discount amount, in local minor units (e.g. cents on the US site), e.g. 500 = $5 USD coupon. When value < 0, it represents a discount percentage, e.g. -10 = 10% off.
  - `SalesPrice`: The actual selling price at the time of our collection (after coupon), in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Brand`: The current product's brand.
  - `BuyboxSeller`: The seller that got the Buybox at the time of our collection.
  - `BuyboxSellerId`: The ID of the seller that got the Buybox at the time of our collection.
  - `BuyboxSellerAddress`: The country/region of the Buybox seller at the time of our collection. When the seller is Amazon itself, this field is null. 2-letter country code. E.g. China: CN, USA: US, UK: GB.
  - `IsFBA`: Whether the Buybox seller's logistics method is FBA at the time of our collection.
  - `ShipCost`: When FBM, shows the shipping fee (shows 0 when no shipping fee is shown on the page), in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `ShipsFrom`: Shipper name.
  - `FbaFee`: If the product's logistics method is FBA, this product's FBA fee, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `FbaDetetail`: If the product's logistics method is FBA, the FBA fee breakdown details, in local minor units. US site example: `["475","1-9:5","10-12:15"]` represents: shipping fee $4.75, 1-9 month storage fee $0.05, 10-12 month storage fee $0.15. The first value is the shipping fee, and the values after that are in the format `<month>: <storage fee>`; -1 means not charged.
  - `PlatformFee`: Platform commission, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Profit`: Product gross profit, actual price - FBA fee - platform commission. If the product's logistics method is not FBA, the FBA fee is counted as 0, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `ProfitRate`: Profit margin, (gross profit / actual price) * 100. E.g. 25.83 means the profit rate is 25.83%.
  - `OnlineDate`: This product's listing date, format: yyyy-MM-dd.
  - `OnlineDays`: Number of days from this product's listing date to today.
  - `RatingsCount`: This product's review count.
  - `OneStartRatings`: Share of 1-star ratings in all Amazon-counted ratings for this product. E.g. 80.57 means the share is 80.57%.
  - `TwoStartRatings`: Share of 2-star ratings in all Amazon-counted ratings for this product. E.g. 80.57 means the share is 80.57%.
  - `ThreeStartRatings`: Share of 3-star ratings in all Amazon-counted ratings for this product. E.g. 80.57 means the share is 80.57%.
  - `FourStartRatings`: Share of 4-star ratings in all Amazon-counted ratings for this product. E.g. 80.57 means the share is 80.57%.
  - `FiveStartRatings`: Share of 5-star ratings in all Amazon-counted ratings for this product. E.g. 80.57 means the share is 80.57%.
  - `Category`: This product's top-level category, value is a 2-element String Array; the first value is the top-level category name, the second is the top-level category's nodeid. E.g. `["Clothing, Shoes & Jewelry","fashion"]`.
  - `BsrCategory`: This product's sub-category, value is a 2-D array `[["Category name","NodeId","Sub-category rank"],...]`. E.g. `[["Baby","baby-products","1"],...]`.
  - `Rank`: This product's top-level category rank at the time of our collection. E.g. 1467.
  - `SellerCount`: How many sellers this product has.
  - `HasVideo`: Whether this product has a main image video.
  - `APlus`: Whether this product has an A+ page.
  - `HasBrandStore`: Whether this product has a brand store.
  - `Size`: This product's outer package dimensions, `["longest side","second longest side","shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
  - `Weight`: This product's weight; when the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.
  - `ExtraSavings`: Records the related promotion content of the product and the related ASINs in the content. E.g. `[{"Asin": "B0BZS461JG", "Text": "..."},...]`.
  - `Feature`: The features this product has according to Amazon's statistics, and the star rating for each feature, e.g. `["Easy to clean":"4.6","Easy to use":"4.4","Value for money":"4.4","Noise level":"4.3","For small spaces":"4.2","Alexa integration":"3.4"]`. Note: the first element is the source ASIN of the update (when there is a multi-variant relationship, it is the most recently updated ASIN under the listing; when there is no multi-variant relationship, the ASIN is the current requested ASIN itself).
  - `ProductInfo`: The product description in the "Product Information" section of the product Listing Details page. E.g. `["Manufacturer","Amazon Basics","Country of Origin","China","Item model number","1702"]`.
  - `Property`: This product's attribute list, including the variant's optional attributes and the attribute description above the five-point description. E.g. `["Style":"1.2 Cu. Ft.-Smart Sensor","Model Name":"ML2-EM12EA(BS)","Brand":"Toshiba","Color":"Black Stainless Steel","Material":"Metal","Human Interface Input":"Buttons, Numeric Keypad","Installation Type":"Countertop","Capacity":"1.2 Cubic Feet","Item Dimensions LxWxH":"17.1 x 20.5 x 12.8 inches","Item Weight":"33.5 Pounds","Lock Type":"Child Lock Available"]`. Note: the first element is the source ASIN of the update (when there is a multi-variant relationship, it is the most recently updated ASIN under the listing; when there is no multi-variant relationship, the ASIN is the current requested ASIN itself).
  - `BrandPromotion`: This product's brand promotion.
  - `DealType`: Product promotion tag; if there is a deal, we record the deal tag.

---

### 1.2 Product Search (ProductSearch)

- **Endpoint description**: Multi-dimensional product search.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | QueryMonth | String | No | Look back at historical monthly product data, supports up to 2 years of data from 2024-01. Optional, format: yyyy-MM. When not specified, real-time data is queried; when the time is earlier than the current month, historical data is queried. AU/BR/IN currently do not support historical lookup; US/GB/DE support the "unlimited" mode of historical lookup; other sites support the Top 100 product historical lookup. |
  | Page | Integer | No | Paginated query, at most 100 products per page. Default 1, representing page 1 (all result pagination starts from 1, not 0). |
  | ASIN | String | No | Optional. If specified: query similar products based on ASIN (note: not only this ASIN; if you need this product, call the `ProductRequest` endpoint). E.g. B0CVM8TXHP |
  | NodeId | String | No | Optional. If specified: query by category (not limited to sub-categories). E.g. 7073960011 |
  | Brand | String | No | Optional. If specified: query hot-selling products of the brand. E.g. Anker |
  | SellerName | String | No | Optional. If specified: query hot-selling products by seller name. E.g. AnkerDirect |
  | SellerId | String | No | Optional. If specified: query hot-selling products by seller ID. E.g. A294P4X9EWVXLJ |
  | Keyword | String | No | Optional. If specified: query hot-selling products by ABA keyword (currently only ABA keywords are supported). E.g. Power Bank |
  | AttributeName | String | No | Optional. If specified: query products whose title (or product attributes) contains the word (matches products where the title / product attributes include a specific word). E.g. 10000mAh |
  | PeakSellingSeason | String | No | Optional. If specified: limit the query to seasonal products, only returns the seasonal products of the queried month(s). If multiple months are the hot season, use commas to separate them, e.g. `2,3,4` |
  | ShippingType | String | No | Optional. If specified: limit products by shipping method. E.g. FBA |
  | PriceRangeMin | Number | No | Optional. If specified: limit minimum selling price (val >= set value). E.g. 20.00 |
  | PriceRangeMax | Number | No | Optional. If specified: limit maximum selling price (val <= set value). E.g. 50.00 |
  | MonthSaleVolumeRangeMin | Integer | No | Optional. If specified: limit minimum monthly sales (val >= set value). E.g. 500 |
  | MonthSaleVolumeRangeMax | Integer | No | Optional. If specified: limit maximum monthly sales (val <= set value). E.g. 1000 |
  | OnlineDateRangeMin | String | No | Optional. If specified: limit minimum listing date, date format: yyyy-MM-dd. E.g. 2025-01-01 |
  | OnlineDateRangeMax | String | No | Optional. If specified: limit maximum listing date, date format: yyyy-MM-dd. E.g. 2026-01-01 |
  | StarRangeMin | Number | No | Optional. If specified: limit minimum star rating. E.g. 4.0 |
  | StarRangeMax | Number | No | Optional. If specified: limit maximum star rating. E.g. 4.8 |
  | CommentCountRangeMin | Integer | No | Optional. If specified: limit minimum review count. E.g. 50 |
  | CommentCountRangeMax | Integer | No | Optional. If specified: limit maximum review count. E.g. 500 |
  | SubCategoryRankRangeMin | Integer | No | Optional. If specified: limit minimum sub-category rank (actual rank, 1st place, value is 1). E.g. 1 |
  | SubCategoryRankRangeMax | Integer | No | Optional. If specified: limit maximum sub-category rank (actual rank, 100th place, value is 100). E.g. 100 |
  | VariationCountRangeMin | Integer | No | Optional. If specified: limit minimum variant count. E.g. 1 |
  | VariationCountRangeMax | Integer | No | Optional. If specified: limit maximum variant count. E.g. 10 |
  | CategoryRankRangeMin | Integer | No | Optional. If specified: limit minimum top-level category rank (actual rank, 1st place, value is 1). E.g. 1 |
  | CategoryRankRangeMax | Integer | No | Optional. If specified: limit maximum top-level category rank (actual rank, 100th place, value is 100). E.g. 100 |
- **Usage example**:
  ```bash
  # Query US site products with monthly sales > 500 under a category
  sorftime api ProductSearch '{"nodeId": "7073960011", "monthSaleVolumeRangeMin": 500}' --domain 1

  # Query Anker products by brand
  sorftime api ProductSearch '{"brand": "Anker"}' --domain 1
  ```
- **Response data**:
  - `Page`: Current page number.
  - `PageCount`: Total number of pages (at most 200).
  - `Products`: Category best-seller list products.
  - `Products.Title`: Product name.
  - `Products.Photo`: This product's main image, URL format.
  - `Products.ListingSalesVolumeOfDaily`: Listing daily sales (variants not distinguished). When value is -1, it means sales cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). E.g. 1000.
  - `Products.ListingSalesOfDaily`: Listing daily sales amount. When value is -1, it means the sales amount cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). In local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Products.ListingSalesVolumeOfMonth`: Listing monthly sales (last 30-day sales; variants not distinguished). Recommended for product sales evaluation. When value is -1, it means sales cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). E.g. 1000.
  - `Products.ListingSalesOfMonth`: Listing estimated monthly sales amount. When value is -1, it means the sales amount cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). In local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Products.ASIN`: This product's ASIN.
  - `Products.ParentAsin`: Parent ASIN. When the product has variants, this represents the product's parent ASIN; when the product has no variants, this field is null. When a listing has multiple variants, every variant's ParentASIN is the same, while ASIN is different.
  - `Products.Price`: ASIN's selling price (coupon not deducted), in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Products.ListPrice`: ASIN's list price (strikethrough), in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Products.Coupon`: The coupon policy applied to the product's one-time purchase at the time of our collection. When value > 0, it represents a specific discount amount, in local minor units (e.g. cents on the US site), e.g. 500 = $5 USD coupon. When value < 0, it represents a discount percentage, e.g. -10 = 10% off.
  - `Products.SalesPrice`: The actual selling price at the time of our collection (after coupon), in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Products.Brand`: The current product's brand.
  - `Products.BuyboxSeller`: The seller that got the Buybox at the time of our collection.
  - `Products.BuyboxSellerId`: The ID of the seller that got the Buybox at the time of our collection.
  - `Products.BuyboxSellerAddress`: The country/region of the Buybox seller at the time of our collection. When the seller is Amazon itself, this field is null. 2-letter country code. E.g. China: CN, USA: US, UK: GB.
  - `Products.IsFBA`: Whether the Buybox seller's logistics method is FBA at the time of our collection.
  - `Products.FbaFee`: If the product's logistics method is FBA, this product's FBA fee, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Products.FbaDetetail`: If the product's logistics method is FBA, the FBA fee breakdown details, in local minor units. US site example: `["475","1-9:5","10-12:15"]` represents: shipping fee $4.75, 1-9 month storage fee $0.05, 10-12 month storage fee $0.15. The first value is the shipping fee, and the values after that are in the format `<month>: <storage fee>`; -1 means not charged.
  - `Products.PlatformFee`: Platform commission, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Products.Profit`: Product gross profit, actual price - FBA fee - platform commission. If the product's logistics method is not FBA, the FBA fee is counted as 0, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Products.ProfitRate`: Profit margin, (gross profit / actual price) * 100. E.g. 25.83 means the profit rate is 25.83%.
  - `Products.OnlineDate`: This product's listing date, format: yyyy-MM-dd.
  - `Products.OnlineDays`: Number of days from this product's listing date to today.
  - `Products.RatingsCount`: This product's review count.
  - `Products.Category`: This product's top-level category, value is a 2-element String Array; the first value is the top-level category name, the second is the top-level category's nodeid. E.g. `["Clothing, Shoes & Jewelry","fashion"]`.
  - `Products.BsrCategory`: This product's sub-category, value is a 2-D array `[["Category name","NodeId","Sub-category rank"],...]`. E.g. `[["Baby","baby-products","1"],...]`.
  - `Products.Rank`: This product's top-level category rank at the time of our collection. E.g. 1467.
  - `Products.Ratings`: This product's star rating. E.g. 4.8.
  - `Products.VariationASINCount`: Variant count.
  - `Products.SellerCount`: How many sellers this product has.
  - `Products.HasVideo`: Whether this product has a main image video.
  - `Products.APlus`: Whether this product has an A+ page.
  - `Products.HasBrandStore`: Whether this product has a brand store.
  - `Products.Size`: This product's outer package dimensions, `["longest side","second longest side","shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
  - `Products.Weight`: This product's weight; when the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.

---

## 2. Product historical data

### 2.1 Officially Disclosed Variant Sales (AsinSalesVolume)

- **Endpoint description**: Query the officially disclosed variant sales history of a product. The earliest data start from 2023-07 for the following sites: 13:br | 12:au | 10:mx | 8:es | 7:jp | 6:ca | 3:de | 2:uk | 1:us. The earliest data start from 2023-08 for the following sites: 11:ae | 9:it | 5:in | 4:fr. The earliest data start from 2023-10 for the following site: 14:sa.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ASIN | String | Yes | The ASIN to query |
  | Page | Integer | No | Paginated query, default starts from 1, at most 100 records per page |
  | QueryDate | String | No | Query start time, format: yyyy-MM-dd, earliest supports 2023-09-01. Default (when not passed or parameter invalid) returns the last 30 days of data |
  | QueryEndDate | String | No | Query end time, format: yyyy-MM-dd. Default (when not passed or parameter invalid) returns data up to the current time |
- **Usage example**:
  ```bash
  sorftime api AsinSalesVolume '{"asin": "B0CVM8TXHP"}' --domain 1
  ```
- **Response data**:
  - `Data`: Value description `[ [<Record date>, <Sales record>, <Type (1: weekly sales; 2: monthly sales)>], .... ]`.

---

### 2.2 Product Variant Data (ProductVariations)

- **Endpoint description**: Query all variants of an ASIN.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Asin | String | Yes | The ASIN to query |
  | PageIndex | Integer | No | Paginated query, at most 100 variants per page. Default 1, representing page 1 (all result pagination starts from 1, not 0). |
  | IsSalesVolume | Boolean | No | Optional, default: false. If set to true, request consumption becomes 2. Whether to include the latest page-disclosed variant sales (within 15 days). Variants that are not hot-selling may have missing sales; you can call `ProductRequest` for an ASIN to check variant sales. |
- **Usage example**:
  ```bash
  sorftime api ProductVariations '{"asin": "B0CVM8TXHP"}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Array (elements are objects).

---

### 2.3 Product Reviews CustomerSay Query (ProductCustomersSay)

- **Endpoint description**: Get the Amazon-summarized product reviews (CustomerSay) data.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Asin | String | Yes | The ASIN to query |
- **Usage example**:
  ```bash
  sorftime api ProductCustomersSay '{"asin": "B0CVM8TXHP"}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Object, including 1 field:
  - `Data.CustomerSay`: String — The text of the Amazon-summarized product reviews (CustomerSay).

---

## 3. Product reviews

### 3.1 Real-time Collection of Product Reviews (ProductReviewsCollection)

- **Endpoint description**: Real-time collection of product reviews (does not return the collected review content; you need to pull the data through the `ProductReviewsQuery` endpoint. After successful collection of the same product, re-collection is not allowed within 2 hours). Review fetching is divided into two parts: the first step is real-time collection (this step is only collection, not returning specific review content). The real-time collected reviews will be merged with the reviews we have already collected. If you need the latest reviews, we recommend performing collection first; if you don't need the latest reviews, you can skip this step. Credits are deducted based on your collection requirements: 5 credits for each page of reviews successfully collected (10 reviews), and at least 5 credits per launch (even if no reviews are collected, 5 credits will still be deducted). The second step is to pull the review data, through the `ProductReviewsQuery` endpoint to pull all the product reviews we have collected. Since Amazon's control over review data is increasingly strict, the actual collection completion time is at least 2 hours, and at most 7 days.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ASIN | String | Yes | The ASIN to query |
  | Mode | Integer | Yes | Collection method: 0: top reviews mode, 1: most recent mode |
  | Star | Integer | No | Filter the collected reviews by star rating. When not passed, it means collection is performed without star rating filtering. When star rating filtering is needed, pass the desired star ratings, supporting multiple filters (comma-separated):<br>1: filter 1-star review collection<br>2: filter 2-star review collection<br>3: filter 3-star review collection<br>4: filter 4-star review collection<br>5: filter 5-star review collection<br>10: negative reviews (1-3 stars)<br>11: positive reviews (4-5 stars)<br>E.g. input: 1,2,3,4,5 means 1-5 stars are collected independently `<page>` pages. Note: credits are deducted on collection: 5 credits for each page (10 reviews) successfully collected. `star` parameter = 1,2,3,4,5 and `page` parameter = 10, then 1-5 star reviews are collected independently, successfully collecting 10 reviews per page (regardless of whether the product has that many reviews, the system still executes the collection task), which would consume 5*10*5 = 250 credits. |
  | OnlyPurchase | Integer | Yes | Whether to only collect reviews from users who have purchased the product, 0: no limit, 1: only reviews from users who have purchased the product. |
  | Page | Integer | Yes | Number of collection pages, optional values: 1 - 10 |
- **Usage example**:
  ```bash
  sorftime api ProductReviewsCollection '{"asin": "B0CVM8TXHP", "mode": 0, "onlyPurchase": 0, "page": 1}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Integer.

---

### 3.2 Real-time Review Task Status Query (ProductReviewsCollectionStatusQuery)

- **Endpoint description**: Query the task execution status of the real-time collection of "Ask Alexa" preset questions.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ASIN | String | Yes | The ASIN to collect Alexa preset questions for, e.g. B0CVM8TXHP |
  | Update | Integer | No | Time range (in hours) to check for executed collection tasks, valid values: 1 - 240. E.g. 48 means check real-time Alexa collection task status for `<ASIN>` within the last 48 hours |
- **Usage example**:
  ```bash
  sorftime api ProductReviewsCollectionStatusQuery '{"asin": "B0CVM8TXHP", "update": 48}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Array (elements are objects).

---

### 3.3 Product Reviews (ProductReviewsQuery)

- **Endpoint description**: Query product reviews.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ASIN | String | Yes | The ASIN to query |
  | Querystartdt | String | No | Query reviews start time, format yyyy-MM-dd |
  | PageIndex | Integer | No | Query result page index, default page 1. Returns 100 records per page. |
  | Star | String | No | Filter by star rating, 1: filter 1-star review collection; 2: filter 2-star review collection; 3: filter 3-star review collection; 4: filter 4-star review collection; 5: filter 5-star review collection; 10: negative reviews (1-3 stars); 11: positive reviews (4-5 stars). For multiple filters, use comma-separated, e.g. 1,2,3,4,5 means 1-5 stars are collected independently `<page>` pages |
  | OnlyPurchase | Integer | No | Whether to only collect reviews from users who have purchased the product, 0: no limit, 1: only reviews from users who have purchased the product. |
- **Usage example**:
  ```bash
  sorftime api ProductReviewsQuery '{"asin": "B0CVM8TXHP", "pageIndex": 1}' --domain 1
  ```
- **Response data**:
  - `ReviewsLink`: Review details link.
  - `ConsumerName`: Reviewer nickname.
  - `ConsumerURL`: Reviewer profile link.
  - `ConsumerBadge`: Reviewer badges, e.g. `["Top Contributor: Pets", "Top 10 Reviewer"]`.
  - `Star`: Star rating given by the reviewer.
  - `Title`: Review title.
  - `ReviewedCountry`: Reviewer's country/region.
  - `ReviewsDate`: Review time.
  - `IsVP`: Whether it is a Verified Purchase review.
  - `Asin`: The variant ASIN this review points to; empty if there is no variant.
  - `AsinProperty`: The variant attribute this review points to.
  - `Helpful`: Number of people who found this review helpful.
  - `Content`: Review text.
  - `Resource`: If the review has images. Multiple images separated by `||` (double vertical bar).
  - `Videos`: If the review has a video, shows the video thumbnail image URL here.
  - `ItemIndex`: Data index. Value description: `<current data index>/<total rows>`; e.g. `156/5000` means there are 5000 records in total, this is the 156th.
  - `UpdateTime`: The time when this review was first fetched (not updated on re-collection), format yyyy-MM-dd HH:mm.

---

## 4. Product search & ASIN subscription

### 4.1 Search Product by Name (ProductSearchFromName)

- **Endpoint description**: Search Amazon for related products by name.
- **Requests consumed**: 2
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Name | String | Yes | The product name to search |
  | PageIndex | Integer | No | Paginated query, at most 100 products per page. Default 1, representing page 1 (all result pagination starts from 1, not 0). |
- **Usage example**:
  ```bash
  sorftime api ProductSearchFromName '{"name": "bluetooth earbuds"}' --domain 1
  ```
- **Response data**:
  - `Title`: Product name.
  - `Photo`: This product's main image, URL format.
  - `ListingSalesVolumeOfMonth`: Estimated link-level monthly sales (variants not distinguished). Recommended for product sales evaluation.
  - `ListingSalesOfMonth`: Estimated link-level monthly sales amount, in local minor units (e.g. cents on the US site). E.g. 10000.
  - `Price`: ASIN's selling price (coupon not deducted), in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Brand`: The current product's brand.
  - `ReviewsCount`: This product's review count.
  - `Ratings`: This product's star rating. E.g. 4.8.
  - `Size`: This product's outer package dimensions, `["longest side","second longest side","shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
  - `Weight`: This product's weight; when the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.

---

### 4.2 ASIN Update Subscription (ASINSubscription)

- **Endpoint description**: Subscribe to ASIN update; we ensure that the subscribed ASIN is updated at least once within the set time range. Credits are deducted based on the update frequency: 1 credit for every ASIN successfully updated (2 credits on the JP site). Up to 100 ASINs can be subscribed at a time; to subscribe more than 100 ASINs, please initiate multiple subscription requests. To view the data, use the `ASINSubscriptionCollection` endpoint.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Asins | String | Yes | Value description: `+|-,asin,time range`. The first parameter `+\|-`: `+` means subscribe to add the ASIN, `-` means unsubscribe to remove the ASIN. The second parameter `asin`: the ASIN to subscribe / unsubscribe. The third parameter `time range`: valid value is 1, meaning update once per day. Currently only one update per day is supported. E.g. `"+,B081P4LF73,1\|+,B083V76MM7,1\|...."` |
- **Usage example**:
  ```bash
  sorftime api ASINSubscription '{"asins": "+,B0CVM8TXHP,1"}' --domain 1
  ```
- **Response data**:
  - `Data`: The list of subscribed ASINs.

---

### 4.3 ASIN Subscription Query (ASINSubscriptionQuery)

- **Endpoint description**: The list of subscribed ASINs.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api ASINSubscriptionQuery --domain 1
  ```
- **Response data**:
  - `Data`: The list of subscribed ASINs.

---

### 4.4 ASIN Subscription Data Query (ASINSubscriptionCollection)

- **Endpoint description**: View the subscribed ASIN product data (only the data of currently valid subscribed ASINs can be viewed).
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Asins | String | Yes | The data of already-subscribed ASINs, multiple ASINs separated by commas, up to 100 ASINs per query. Value description: `<asin>,<asin>....` |
- **Usage example**:
  ```bash
  sorftime api ASINSubscriptionCollection '{"asins": "B0CVM8TXHP,B08N5WRWWW"}' --domain 1
  ```
- **Response data**:
  - `Title`: Product name.
  - `Photo`: This product's main image, URL format.
  - `EBCPhoto`: Images in this product's A+ page.
  - `StoreName`: Store name.
  - `AsinSalesCount`: If there is a disclosed ASIN monthly sales, the disclosed monthly sales is shown.
  - `ASIN`: This product's ASIN.
  - `ParentAsin`: Parent ASIN. When the product has variants, this represents the product's parent ASIN; when the product has no variants, this field is null. When a listing has multiple variants, every variant's ParentASIN is the same, while ASIN is different.
  - `Price`: ASIN's list price (strikethrough). E.g. 2399, in local minor units.
  - `ListPrice`: ASIN's selling price (coupon not deducted), in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `ListingSaleCount`: Listing monthly sales.
  - `ListingSaleCountOfDaily`: Estimated listing daily sales. JSON format, data format: `["yyyy-MM-dd","<estimated listing daily sales>"]`.
  - `Coupon`: The coupon policy applied to the product's one-time purchase at the time of our collection. When value > 0, it represents a specific discount amount, in local minor units (e.g. cents on the US site), e.g. 500 = $5 USD coupon. When value < 0, it represents a discount percentage, e.g. -10 = 10% off.
  - `SalesPrice`: The actual selling price at the time of our collection (after coupon), in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Brand`: The current product's brand.
  - `Description`: The current product's five-point description.
  - `BuyboxSeller`: The seller that got the Buybox at the time of our collection.
  - `BuyboxSellerId`: The ID of the seller that got the Buybox at the time of our collection.
  - `IsFBA`: Whether the Buybox seller's logistics method is FBA at the time of our collection.
  - `ShipCost`: When FBM, shows the shipping fee (shows 0 when no shipping fee is shown on the page), in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `OnlineDate`: This product's listing date, format: yyyy-MM-dd.
  - `OnlineDays`: Number of days from this product's listing date to today.
  - `RatingsCount`: This product's review count.
  - `Category`: This product's top-level category, value is a 2-element String Array; the first value is the top-level category name, the second is the top-level category's nodeid. E.g. `["Clothing, Shoes & Jewelry","fashion"]`.
  - `BsrCategory`: This product's sub-category, value is a 2-D array `[["Category name","NodeId","Sub-category rank"],...]`. E.g. `[["Baby","baby-products","1"],...]`.
  - `Rank`: This product's top-level category rank at the time of our collection. E.g. 1467.
  - `Ratings`: This product's star rating. E.g. 4.8.
  - `VariationASINCount`: Variant count.
  - `SellerCount`: How many sellers this product has.
  - `HasVideo`: Whether this product has a main image video.
  - `APlus`: Whether this product has an A+ page.
  - `HasBrandStore`: Whether this product has a brand store.
  - `Size`: This product's outer package dimensions, `["longest side","second longest side","shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
  - `Weight`: This product's weight; when the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.
  - `ExtraSavings`: Records the related promotion content of the product and the related ASINs in the content. E.g. `[{"Asin": "B0BZS461JG", "Text": "..."},...]`.
  - `Property`: This product's attribute list, including the variant's optional attributes and the attribute description above the five-point description. E.g. `["Style":"1.2 Cu. Ft.-Smart Sensor","Model Name":"ML2-EM12EA(BS)","Brand":"Toshiba","Color":"Black Stainless Steel","Material":"Metal","Human Interface Input":"Buttons, Number Keypad","Installation Type":"Countertop","Capacity":"1.2 Cubic Feet","Item Dimensions LxWxH":"17.1 x 20.5 x 12.8 inches","Item Weight":"33.5 Pounds","Lock Type":"Child Lock Available"]`.

---

## 5. AI product interpretation

### 5.1 AI Product Interpretation (ProductAssistant)

- **Endpoint description**: Sorftime Agent interprets the product (currently only supports products with monthly sales greater than 500; products with monthly sales less than 500 will fail directly and return the request), and the generation takes about 5 minutes. Results can be obtained via the `AIResult` endpoint. Supports both text and text+graphic versions (request cost: 75).
- **Requests consumed**: 25
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Asin | String | Yes | The product to analyze |
  | Type | Integer | Yes | Report type. 0: text only (markdown format); 1: includes both text and text+graphic (text in markdown format, text+graphic in HTML format) |
- **Usage example**:
  ```bash
  sorftime api ProductAssistant '{"asin": "B0CVM8TXHP", "type": 1}' --domain 1
  ```
- **Response data**:
  - `Data`: The task ID of this run's task.

> Get the analysis result via the `AIResult` endpoint. For result query, see [amazon-ai-api.md](./amazon-ai-api.md).

---

## 6. Product real-time & image search

### Common notes for real-time endpoints

1. **Credit cost**: `ProductRealtimeRequest` consumes credits (2 credits on the JP site, 1 credit on other sites); suitable for real-time monitoring of key products.
2. **Image search**: Only 9 sites are supported (US/GB/DE/FR/IN/JP/ES/IT), and the credit cost is higher (5 credits, 6 credits on the JP site). Note that `SimilarProductRealtimeRequest` and `SimilarProductRealtimeRequestStatusQuery` only support these 9 sites, but `SimilarProductRealtimeRequestCollection` supports all 14 sites.
3. **Real-time fetch time**: All real-time endpoints are expected to take about 5 minutes; for some sites (Middle East (AE) / Australia (AU) / Saudi Arabia (SA) / Brazil (BR)), some trend fields (e.g. ListingSalesVolumeOfDailyTrend) are not yet supported.
4. **Image search tips**: The searched product should occupy greater than 80% of the image and the background should be as clean as possible to improve recognition accuracy.

### 6.1 Real-time Data Refresh

#### 6.1.1 Product Realtime Update (ProductRealtimeRequest)

- **Endpoint description**: If the product has not been updated within the set time (e.g. require the product to be updated within 24 hours, set the `update` parameter to 24), this triggers a real-time product fetch and consumes 1 credit (2 credits on the JP site). If it has been updated, use `ProductRequest` to pull the product detail data. Use `ProductRealtimeRequestStatusQuery` to check completion status; after a successful fetch, use `ProductRequest` to query this ASIN.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ASIN | String | Yes | The ASIN to query |
  | Update | Integer | No | If the product has not been updated within the set time, update it immediately; otherwise return the product directly. Unit: hours. Default 24, valid range 1 - 120. E.g. 48 means: if the product has not been updated within 48 hours of the query time, update it immediately. |
- **Usage example**:
  ```bash
  sorftime api ProductRealtimeRequest '{"asin": "B0CVM8TXHP", "update": 24}' --domain 1
  ```
- **Response data**: The complete field structure is the same as `ProductRequest`; when the product requires a real-time fetch, some fields (e.g. trend fields for Middle East / Australia / Saudi Arabia / Brazil sites) have platform-specific limitations.

---

#### 6.1.2 Realtime Update Status (ProductRealtimeRequestStatusQuery)

- **Endpoint description**: If the product has triggered a real-time collection, use this endpoint to query the completion status.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | QueryDate | String | Yes | Query all real-time data tasks created on this date. Format: yyyy-MM-dd |
- **Usage example**:
  ```bash
  sorftime api ProductRealtimeRequestStatusQuery '{"queryDate": "2026-07-19"}' --domain 1
  ```
- **Response data**:
  - `Data`: `["<product asin>:<status>:<finish time>", "<product asin>:<status>:<finish time>", ...]`. Status: 0=querying, 1=completed, 3=collection failed, 4=insufficient credits, 5=ASIN does not exist. Finish time: when the status is success, this is the collection finish time; otherwise shown as `--`.

---

### 6.2 Image Search for Similar Products

#### 6.2.1 Image Search Submit (SimilarProductRealtimeRequest)

- **Endpoint description**: Real-time search for similar products on the Amazon platform via a product image. The searched product should occupy greater than 80% of the image and the background should be as clean as possible. The real-time fetch takes about 5 minutes. After a successful fetch, use `SimilarProductRealtimeRequestCollection` to query (each query consumes 5 credits, 6 credits on the JP site) and is expected to return 20+ products.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 7(jp), 8(es), 9(it)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Image | String | Yes | The image to query, encoded in Base64. Image size should be around 1MB or so. |
- **Usage example**:
  ```bash
  sorftime api SimilarProductRealtimeRequest '{"image": "<base64-data>"}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Integer.

---

#### 6.2.2 Image Search Status (SimilarProductRealtimeRequestStatusQuery)

- **Endpoint description**: Query the execution status of the image-search similar product task.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 7(jp), 8(es), 9(it)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Update | Integer | No | Data valid range 1 - 240; check image-search similar product collection task status within 1 - 240 hours of the current time. E.g. 48 means check real-time review collection task status within 48 hours of the current time. |
- **Usage example**:
  ```bash
  sorftime api SimilarProductRealtimeRequestStatusQuery '{"update": 48}' --domain 1
  ```
- **Response data**:
  - `Data`: JSON array format, e.g. `[{ taskId:<task ID returned by ProductReviewsCollection>, status:<task status; 0=collection completed, 4=insufficient credit balance, 11=no collection task, 97=ASIN does not exist, 98=collection failed, 99=collecting>}, ...]`.

---

#### 6.2.3 Image Search Result (SimilarProductRealtimeRequestCollection)

- **Endpoint description**: Query the result of an image search.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | TaskId | String | Yes | Task ID |
- **Usage example**:
  ```bash
  sorftime api SimilarProductRealtimeRequestCollection '{"taskId": "abc123"}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Array (elements are objects).

---

## Notes

1. **Batch query optimization**: `ProductRequest` supports querying up to 10 ASINs at once. When multiple ASINs are passed, the fees are charged according to the actual number of ASINs called.
2. **Trend data**: Default returns the last 15 days; to get more data, you must specify `QueryTrendStartDt` and `QueryTrendEndDt`. When the requested historical trend exceeds 15 days, request consumption = 2.
3. **Endpoint rename**: `ProductVariationHistory` has been renamed to `ProductVariations`. The old name still works, but the new name is recommended in new code.
4. **Alexa questions**: See [amazon-alexa-api.md](./amazon-alexa-api.md).
5. **AI result query**: See [amazon-ai-api.md](./amazon-ai-api.md).

---

## Best Practices

### 1. Batch query ASINs

```bash
# Query multiple ASINs at once (up to 10), saving request count
sorftime api ProductRequest '{"asin": "B0ASIN1,B0ASIN2,B0ASIN3,B0ASIN4,B0ASIN5"}' --domain 1
```

### 2. Competitor analysis workflow

```bash
# Step 1: Query similar products based on an ASIN
sorftime api ProductSearch '{"asin": "B0CVM8TXHP"}' --domain 1

# Step 2: Query the competitor's detailed information
sorftime api ProductRequest '{"asin": "B0CVM8TXHP"}' --domain 1

# Step 3: Query all variants
sorftime api ProductVariations '{"asin": "B0CVM8TXHP"}' --domain 1

# Step 4: Query the Amazon-summarized reviews
sorftime api ProductCustomersSay '{"asin": "B0CVM8TXHP"}' --domain 1

# Step 5: Query the officially disclosed variant sales
sorftime api AsinSalesVolume '{"asin": "B0CVM8TXHP"}' --domain 1

# Step 6: Pull the latest reviews in real time
sorftime api ProductReviewsQuery '{"asin": "B0CVM8TXHP", "pageIndex": 1}' --domain 1

# Step 7: AI-interpret the product
sorftime api ProductAssistant '{"asin": "B0CVM8TXHP", "type": 1}' --domain 1
```

### 3. Real-time update + pull latest data

```bash
# Step 1: Trigger a real-time update (if not updated within 24h)
sorftime api ProductRealtimeRequest '{"asin": "B0CVM8TXHP", "update": 24}' --domain 1

# Step 2: Query the real-time task status
sorftime api ProductRealtimeRequestStatusQuery '{"queryDate": "2026-07-19"}' --domain 1

# Step 3: Pull the latest product detail
sorftime api ProductRequest '{"asin": "B0CVM8TXHP"}' --domain 1
```

### 4. Image search for similar products

```bash
# Step 1: Submit the image search request
sorftime api SimilarProductRealtimeRequest '{"image": "<base64-data>"}' --domain 1

# Step 2: Query the task status
sorftime api SimilarProductRealtimeRequestStatusQuery '{"update": 48}' --domain 1

# Step 3: Get the similar product results
sorftime api SimilarProductRealtimeRequestCollection '{"taskId": "<taskId>"}' --domain 1
```
