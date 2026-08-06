# Amazon Keyword Endpoints (12)

**Amazon Domains**: 1=US, 2=UK, 3=DE, 4=FR, 6=CA, 7=JP, 8=ES, 9=IT, 10=MX, 11=AE, 12=AU, 13=BR, 14=SA

**Endpoints in this file**: KeywordQuery, KeywordSearchResults, KeywordRequest, KeywordSearchResultTrend, KeywordExtends, CategoryRequestKeyword, ASINRequestKeyword, KeywordProductRanking, ASINKeywordRanking, FavoriteKeyword, ChangeFavoriteKeyword, GetFavoriteKeyword

**Site limitations**: domain 5 (in/India) is not in the keyword-endpoint support list.

> **Endpoint rename**:
> - `ASINRequestKeywordv2` has been renamed to `ASINRequestKeyword` (the old name still works, but the new name is recommended).

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency. This document covers only parameters and fields unique to the Amazon keyword endpoints.
Field names in this file are PascalCase (e.g. `Asin`, `NodeId`, `PageIndex`); other Amazon endpoint fields are described in camelCase in [amazon-data-types.md](./amazon-data-types.md).

---

## Table of Contents

- [1. Keyword basic queries](#1-keyword-basic-queries)
  - [1.1 KeywordQuery (KeywordQuery)](#11-keywordquery-keywordquery)
  - [1.2 Keyword (last 15 days) search-result products (KeywordSearchResults)](#12-keyword-last-15-days-search-result-products-keywordsearchresults)
  - [1.3 Keyword details (with search volume, CPC trend) (KeywordRequest)](#13-keyword-details-with-search-volume-cpc-trend-keywordrequest)
  - [1.4 Keyword search-result product trend (KeywordSearchResultTrend)](#14-keyword-search-result-product-trend-keywordsearchresulttrend)
- [2. Keyword extension and reverse lookup](#2-keyword-extension-and-reverse-lookup)
  - [2.1 Find extended keywords (KeywordExtends)](#21-find-extended-keywords-keywordextends)
  - [2.2 Category reverse-lookup keywords (CategoryRequestKeyword)](#22-category-reverse-lookup-keywords-categoryrequestkeyword)
  - [2.3 ASIN reverse-lookup keywords (ASINRequestKeyword)](#23-asin-reverse-lookup-keywords-asinrequestkeyword)
- [3. Keyword ranking tracking](#3-keyword-ranking-tracking)
  - [3.1 Keyword historical search-result products (KeywordProductRanking)](#31-keyword-historical-search-result-products-keywordproductranking)
  - [3.2 ASIN's rank trend under a keyword (ASINKeywordRanking)](#32-asins-rank-trend-under-a-keyword-asinkeywordranking)
- [4. Keyword library management](#4-keyword-library-management)
  - [4.1 Add keyword to my library (FavoriteKeyword)](#41-add-keyword-to-my-library-favoritekeyword)
  - [4.2 Move / delete library keyword (ChangeFavoriteKeyword)](#42-move--delete-library-keyword-changefavoritekeyword)
  - [4.3 Query library keywords (GetFavoriteKeyword)](#43-query-library-keywords-getfavoritekeyword)

---

## 1. Keyword basic queries

### 1.1 KeywordQuery (KeywordQuery)

- **Endpoint description**: Current ABA trending keyword list. Supported keyword count per site: US=2 million, GB/DE=300K, IT/FR/JP=150K, ES/CA/MX=100K, AU=50K, other sites = all ABA keywords.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Pattern | Object | Yes | Query pattern, see `KeywordQueryPatternObject` |
  | PageIndex | Integer | No | Query result page index, default page 1 |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200. |
- **KeywordQueryPatternObject structure**:
  | Field | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The keyword to query |
  | NodeIdRange | String | No | Specify nodeId to search for category-related keywords; nodeid only supports sub-categories; comma-separated |
  | RankCondition | String | No | Use this parameter when you need to set the weekly rank search. The value is a 2-element String Array: element 0 is the minimum value of the filter, element 1 is the maximum value. E.g. `[1,5000]` / `[0,10000]` / `[10000]` |
  | SearchVolumeCondition | String | No | Use this parameter when you need to set the 30-day search volume search. The value is a 2-element String Array. |
  | RankChangeOfWeeklyCondition | String | No | Use this parameter when you need to set the weekly search rank change search. The value is a 3-element String Array; the 3rd element is the sort method (1=rising 2=falling). |
  | History | String | No | Optional, default query real-time data (weekly keywords from the previous ABA week). When a valid value is specified, queries historical list data. Format: `{queryType},{date}`. queryType: 1 query weekly keywords; 2 query monthly keywords. date: yyyy-MM-dd. The earliest weekly keyword query is 2025-03-04; the earliest monthly keyword query is 2025-04; the latest monthly keyword is data from the most recent month before the current date. |
- **Usage example**:
  ```bash
  # Query trending keywords (page 1, 50 records)
  sorftime api KeywordQuery '{"pattern": {"keyword": "power bank"}, "pageIndex": 1, "pageSize": 50}' --domain 1
  ```
- **Response data**:
  - `Keyword`: The keyword.
  - `KeywordCNName`: Chinese name of the keyword.
  - `Images`: Top 10 product images from search results.
  - `ImagesFromAsin`: The ASINs of the top 10 product images in search results (order matches the `Images` field).
  - `Update`: When querying weekly keywords, the latest time the keyword's ABA rank was updated. When querying monthly keywords, this value is empty.
  - `Rank`: Weekly search rank.
  - `SearchVolume`: 30-day search volume.
  - `SearchVolumeTrend`: Keyword search volume trend. E.g. `[202201,1000,202202,1010,202203,1050,.....]`. Even array indices are dates, e.g. `20201001`; odd array indices are estimated monthly search volumes.
  - `SearchRankTrend`: Keyword search rank trend. E.g. `[202201,10,202202,15,202203,20,.....]`. Even array indices are dates, e.g. `20201001`; odd array indices are search ranks.
  - `ClickOf90D`: 90-day purchase count.
  - `SalesVolumeOf90D`: 90-day click count. Currently only supports the US site; data comes from the Amazon backend. Amazon only discloses about 900K keywords' data; undisclosed keywords show `-1`.
  - `WordCount`: Word count.
  - `SearchConversionRateD90`: 90-day search conversion rate. E.g. 18.44 means 18.44%. Currently only supports the US site; data comes from the Amazon backend. Amazon only discloses about 900K keywords' data; undisclosed keywords show `-1`.
  - `ClickConversionRateD90`: 90-day click conversion rate. E.g. 18.44 means 18.44%. Currently only supports the US site; data comes from the Amazon backend. Amazon only discloses about 900K keywords' data; undisclosed keywords show `-1`.
  - `SearchConversionRate`: Past 360-day search conversion ratio. E.g. 18.44 means 18.44%.
  - `ProductCount`: Number of competitors, i.e. the number of competitors shown on Amazon's keyword search page.
  - `RankChangeOfWeekly`: The keyword's rank change vs. last week. E.g. 20 means a change of 20; negative means falling.
  - `Cpc`: CPC precise bid, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `CpcRange`: CPC precise bid range, value description: `<min>,<max>`. In local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `SearchVolumeGrowthRateTrend`: The 3/6/12-month compound search-volume growth rate. E.g. `[22.26,-19.76,17.00]` means the last 3 months' compound search volume growth rate is 22.26%, the last 6 months' compound search volume growth rate is -19.86%, and the last 12 months' compound search volume growth rate is 17.00%.
  - `ShareClickRate`: The top 3 products with the most clicks after the buyer searches this keyword have a click-through rate share. E.g. 20.00 means 20.00%.
  - `ShareConversionRate`: The top 3 products with the most clicks after the buyer searches this keyword have a conversion rate share (the conversion on the top 3 products after searching this keyword / the conversion on all products). E.g. 20.00 means 20.00%.
  - `Top3asin`: Top 3 ASINs with the most click-through rate, in JSON String Array format. Data format: `["<top1Asin>,<click share>,<conversion share>","<top2Asin>,<click share>,<conversion share>","<top3Asin>,<click share>,<conversion share>"]`.
  - `Season`: Peak season.
  - `Department`: The sub-categories related to this keyword; data source is the related categories shown by Amazon's front-end when the keyword is searched. JSON format.
  - `Top3Brand`: Top 3 brands with the most clicks, in JSON String Array format. For weekly keywords, the calls after 2024-04-28 return valid values; for monthly keywords, the calls after 2024-04 return valid values. Data format: `["top1Brand","top2Brand","top3Brand"]`.
  - `Top3Category`: Top 3 category names with the most clicks, in JSON String Array format. For weekly keywords, the calls after 2024-04-28 return valid values; for monthly keywords, the calls after 2024-04 return valid values. Data format: `["top1 Category name","top2 Category name","top3 Category name"]`.

---

### 1.2 Keyword (last 15 days) search-result products (KeywordSearchResults)

- **Endpoint description**: Last 15 days of keyword search-result products, only supports ABA trending keywords. Supported keyword count per site: US=2 million, GB/DE=300K, IT/FR/JP=150K, ES/CA/MX=100K, AU=50K, other sites = all ABA keywords.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The keyword to query |
  | PositionType | Integer | No | Exposure position type, 0: all, 1: only organic position (default), 2: only ad |
  | PageIndex | Integer | No | Query result page index, default page 1 |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200. |
- **Usage example**:
  ```bash
  sorftime api KeywordSearchResults '{"keyword": "power bank", "pageIndex": 1, "pageSize": 50}' --domain 1
  ```
- **Response data**:
  - `Page`: Current page number.
  - `PageCount`: Total number of pages.
  - `Products`: Product list.
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
  - `Products.VariationASINCount`: Integer.
  - `Products.SellerCount`: How many sellers this product has.
  - `Products.HasVideo`: Whether this product has a main image video.
  - `Products.APlus`: Whether this product has an A+ page.
  - `Products.HasBrandStore`: Whether this product has a brand store.
  - `Products.Size`: This product's outer package dimensions, `["longest side","second longest side","shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
  - `Products.Weight`: This product's weight; when the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.

---

### 1.3 Keyword details (with search volume, CPC trend) (KeywordRequest)

- **Endpoint description**: Keyword details query. Supported keyword count per site: US=2 million, GB/DE=300K, IT/FR/JP=150K, ES/CA/MX=100K, AU=50K, other sites = all ABA keywords.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The keyword to query |
- **Usage example**:
  ```bash
  sorftime api KeywordRequest '{"keyword": "power bank"}' --domain 1
  ```
- **Response data**:
  - `Keyword`: The keyword.
  - `KeywordCNName`: Chinese name of the keyword.
  - `Images`: Top 10 product images from search results.
  - `ImagesFromAsin`: The ASINs of the top 10 product images in search results (order matches the `Images` field).
  - `Season`: Peak season.
  - `WordCount`: Word count.
  - `SalesVolumeOf90D`: 90-day purchase count.
  - `Rank`: Weekly search rank.
  - `SearchVolume`: 30-day search volume.
  - `SearchVolumeTrend`: Keyword search volume trend. E.g. `[202201,1000,202202,1010,202203,1050,.....]`. Even array indices are dates, e.g. `20201001`; odd array indices are estimated monthly search volumes.
  - `SearchConversionRate`: Past 360-day search conversion ratio. E.g. 18.44 means 18.44%.
  - `ProductCount`: Number of competitors, i.e. the number of competitors shown on Amazon's keyword search page.
  - `RankChangeOfWeekly`: The keyword's rank change vs. last week. E.g. 20 means a change of 20; negative means falling.
  - `SearchVolumeGrowthTrend`: The next 12 months (each month vs. the previous month) search volume growth trend. E.g. `[202201,9612,202202,-4217,202203,-226,.....]`. Even array indices are months, e.g. `202201` represents 2022-01; odd array indices are the keyword's search volume growth in the current month vs. the previous month. 9612 means a 96.12% growth; -226 means a 2.26% decline.
  - `Cpc`: CPC precise bid, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `CpcRange`: CPC precise bid range, value description: `<min>,<max>`. In local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `CpcTrend`: CPC precise bid history. E.g. `[202201,112,96,195,202202,194,115,207,.....]`. `array index % 4 = 0` is the month, e.g. `202201` represents 2022-01; `array index % 4 = 1` is CPC precise bid; `array index % 4 = 2` is CPC precise bid minimum value; `array index % 4 = 3` is CPC precise bid maximum value.
  - `SearchVolumeGrowthRateTrend`: The 3/6/12-month compound search-volume growth rate. E.g. `[22.26,-19.76,17.00]` means the last 3 months' compound search volume growth rate is 22.26%, the last 6 months' compound search volume growth rate is -19.86%, and the last 12 months' compound search volume growth rate is 17.00%.
  - `SearchResultOfFP`: The last 15 days' first-page product top-100 sales data report. `array index 0`: product count; 1: organic position product count; 2: ad position product count; 3: organic position not in top 100 product count share; 4: organic position review count < 100/300/500 product count share (e.g. `2500|6350|7115`); 5: ad position review count < 100/300/500 product count share; 6: no star rating product count; 7: average star rating; 8: average review count; 9: coupon product count/share (e.g. `2/588` means 2 products have coupons, product count share is 5.88%); 10: hijacker product count/share (e.g. `2/5.88` means 2 products are hijacked, product count share is 5.88%); 11: 30-day lowest-price product count/share (e.g. `2/5.88` means 2 products are marked as 30-day lowest price, product count share is 5.88%).
  - `ShareClickRate`: The top 3 products with the most clicks after the buyer searches this keyword have a click-through rate share. E.g. 20.00 means 20.00%.
  - `ShareConversionRate`: The top 3 products with the most clicks after the buyer searches this keyword have a conversion rate share (the conversion on the top 3 products after searching this keyword / the conversion on all products). E.g. 20.00 means 20.00%.
  - `Top3asin`: Top 3 ASINs with the most click-through rate.
  - `AssociatedWithCategory`: Related sub-category node IDs.
  - `AssociatedWithCategoryDetail`: Related sub-category top 100 data. Value description: `[[<Category nodeid>,<Category name>,<top100 monthly sales>,<average price>,<average review count>,<share of ASINs with reviews <= 100>,<share of sales by ASINs with reviews <= 100>,<average star rating>,<share of ASINs with rating <= 3 stars>,<share of sales by ASINs with rating <= 3 stars>,<brand count>,<top 3 brand monopoly>,<seller count>,<top 3 seller monopoly>,<share of new products listed in the last 3 months>,<share of sales by new products listed in the last 3 months>,<Amazon self-operated share>,<FBA count share>],...]`.

---

### 1.4 Keyword search-result product trend (KeywordSearchResultTrend)

- **Endpoint description**: Statistical data trend of the top 3 pages of products in keyword search results. Supported keyword count per site: US=2 million, GB/DE=300K, IT/FR/JP=150K, ES/CA/MX=100K, AU=50K, other sites = all ABA keywords.
- **Requests consumed**: 10
- **Supported domains**: 1(us), 2(gb), 3(de), 6(ca), 7(jp), 8(es), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | ABA keyword |
  | QueryStart | String | No | Trend data query start month, earliest supports data from 2024-01. FR and IT sites support data from 2025-01. Optional, format: yyyy-MM, default: 2024-01 |
  | QueryEnd | String | No | Trend data query end month. Optional, format: yyyy-MM |
- **Usage example**:
  ```bash
  sorftime api KeywordSearchResultTrend '{"keyword": "power bank"}' --domain 1
  ```
- **Response data**:
  - `RecordDate`: Record time, format: yyyy-MM-dd.
  - `Top100SalesVolume`: Sum of monthly sales of the top 100 products (by sales) in the first 3 pages.
  - `Top100Sales`: Record time, format: yyyy-MM-dd.
  - `ProductCount`: Number of competitors, based on the number shown in the search results.
  - `BrandCount`: Number of brands among the top 100 products (by sales) in the first 3 pages.
  - `SellerCount`: Number of sellers among the top 100 products (by sales) in the first 3 pages.
  - `AvgStar`: Average star rating of the top 100 products (by sales) in the first 3 pages.
  - `AvgPrice`: Average price of the top 100 products (by sales) in the first 3 pages.
  - `AvgRatings`: Average review count of the top 100 products (by sales) in the first 3 pages.
  - `NoRatingProductCount`: Number of products with no star rating in the first 3 pages.

---

## 2. Keyword extension and reverse lookup

### 2.1 Find extended keywords (KeywordExtends)

- **Endpoint description**: Find extended keywords. Supported keyword count per site: US=2 million, GB/DE=300K, IT/FR/JP=150K, ES/CA/MX=100K, AU=50K, other sites = all ABA keywords.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The ABA keyword to query, used to find related keywords based on the keyword |
  | PageIndex | Integer | No | Query result page index, default page 1 |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200. |
- **Usage example**:
  ```bash
  sorftime api KeywordExtends '{"keyword": "power bank", "pageIndex": 1, "pageSize": 50}' --domain 1
  ```
- **Response data**: Same as `KeywordQuery`; returns a keyword summary object array (see the field descriptions above).

---

### 2.2 Category reverse-lookup keywords (CategoryRequestKeyword)

- **Endpoint description**: Query category-related ABA keywords by category. Supported keyword count per site: US=2 million, GB/DE=300K, IT/FR/JP=150K, ES/CA/MX=100K, AU=50K, other sites = all ABA keywords.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Nodeid | String | Yes | The category nodeid to query (only supports leaf category nodeids) |
  | PageIndex | Integer | No | Query result page index, default page 1 |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200. |
- **Usage example**:
  ```bash
  sorftime api CategoryRequestKeyword '{"nodeid": "7073960011", "pageIndex": 1, "pageSize": 50}' --domain 1
  ```
- **Response data**: Same as `KeywordQuery`; returns a keyword summary object array (see the field descriptions above).

---

### 2.3 ASIN reverse-lookup keywords (ASINRequestKeyword)

- **Endpoint description**: Query the keywords in whose search-result first 3 pages this ASIN gained exposure in the last 30 days. Supported keyword count per site: US=2 million, GB/DE=300K, IT/FR/JP=150K, ES/CA/MX=100K, AU=50K, other sites = all ABA keywords.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ASIN | String | Yes | The ASIN to query |
  | PageIndex | Integer | No | Query result page index, default page 1 |
  | PageSize | Integer | No | Items per page, min 20, default 20, max 200. |
- **Usage example**:
  ```bash
  sorftime api ASINRequestKeyword '{"asin": "B0CVM8TXHP", "pageIndex": 1, "pageSize": 50}' --domain 1
  ```
- **Response data**:
  - `ShowType`: Exposure type.
  - `ShowShare`: The traffic share contributed by this keyword in this ASIN's reverse-lookup keywords.
  - `PositionType`: Array — Exposure position type. E.g. `["organic traffic", "platform recommended"]`.
  - `AdPosition`: String — Ad exposure position.
  - `AdPositionDate`: String — Latest ad exposure time (format: yyyy-MM-dd HH:mm). Returns empty if no ad exposure.
  - `SearchPosition`: Array — Organic exposure position.
  - `SearchPositionDate`: String — Latest organic exposure time (format: yyyy-MM-dd HH:mm). Returns empty if no organic exposure.
  - `Keyword`: For data structure, see `KeywordSummeryObject`.
  - `Keyword.Keyword`: The keyword.
  - `Keyword.KeywordCNName`: Chinese name of the keyword.
  - `Keyword.Images`: Top 10 product images from search results.
  - `Keyword.Rank`: Weekly search rank.
  - `Keyword.SearchVolume`: 30-day search volume.
  - `Keyword.SearchVolumeTrend`: Keyword search volume trend. E.g. `[202201,1000,202202,1010,202203,1050,.....]`. Even array indices are dates, e.g. `20201001`; odd array indices are estimated monthly search volumes.
  - `Keyword.SearchRankTrend`: Keyword search rank trend. E.g. `[202201,10,202202,15,202203,20,.....]`. Even array indices are dates, e.g. `20201001`; odd array indices are search ranks.
  - `Keyword.ClickOf90D`: 90-day purchase count.
  - `Keyword.SalesVolumeOf90D`: 90-day click count. Currently only supports the US site; data comes from the Amazon backend. Amazon only discloses about 900K keywords' data; undisclosed keywords show `-1`.
  - `Keyword.WordCount`: Word count.
  - `Keyword.SearchConversionRateD90`: 90-day search conversion rate. E.g. 18.44 means 18.44%. Currently only supports the US site; data comes from the Amazon backend. Amazon only discloses about 900K keywords' data; undisclosed keywords show `-1`.
  - `Keyword.ClickConversionRateD90`: 90-day click conversion rate. E.g. 18.44 means 18.44%. Currently only supports the US site; data comes from the Amazon backend. Amazon only discloses about 900K keywords' data; undisclosed keywords show `-1`.
  - `Keyword.SearchConversionRate`: Past 360-day search conversion ratio. E.g. 18.44 means 18.44%.
  - `Keyword.ProductCount`: Number of competitors, i.e. the number of competitors shown on Amazon's keyword search page.
  - `Keyword.RankChangeOfWeekly`: The keyword's rank change vs. last week. E.g. 20 means a change of 20; negative means falling.
  - `Keyword.Cpc`: CPC precise bid, in local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Keyword.CpcRange`: CPC precise bid range, value description: `<min>,<max>`. In local minor units (e.g. cents on the US site). E.g. 1999 = 19.99 USD on the US site.
  - `Keyword.SearchVolumeGrowthRateTrend`: The 3/6/12-month compound search-volume growth rate. E.g. `[22.26,-19.76,17.00]` means the last 3 months' compound search volume growth rate is 22.26%, the last 6 months' compound search volume growth rate is -19.86%, and the last 12 months' compound search volume growth rate is 17.00%.
  - `Keyword.ShareClickRate`: The top 3 products with the most clicks after the buyer searches this keyword have a click-through rate share. E.g. 20.00 means 20.00%.
  - `Keyword.ShareConversionRate`: The top 3 products with the most clicks after the buyer searches this keyword have a conversion rate share (the conversion on the top 3 products after searching this keyword / the conversion on all products). E.g. 20.00 means 20.00%.
  - `Keyword.Top3asin`: Top 3 ASINs with the most click-through rate.
  - `Keyword.Season`: Peak season.

> **Endpoint rename**: `ASINRequestKeywordv2` has been renamed to `ASINRequestKeyword`. The old name still works, but the new name is recommended.

---

## 3. Keyword ranking tracking

### 3.1 Keyword historical search-result products (KeywordProductRanking)

- **Endpoint description**: Keyword historical monthly search-result products, up to the last 2 years. Currently only supports US-site ABA keywords. Supported keyword count per site: US=2 million, GB/DE=300K, IT/FR/JP=150K, ES/CA/MX=100K, AU=50K, other sites = all ABA keywords.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The ABA keyword to query |
  | Month | String | Conditional | The month to query; valid only for the US site, other sites do not need to fill this in. Format: yyyy-MM, e.g. 2024-12 |
  | Page | Integer | No | Page number, default page 1. At most 200 records per page |
- **Usage example**:
  ```bash
  # US site: query a specific month
  sorftime api KeywordProductRanking '{"keyword": "power bank", "month": "2024-12"}' --domain 1

  # Other sites: month parameter is invalid, returns the last 30 days of data
  sorftime api KeywordProductRanking '{"keyword": "power bank"}' --domain 2
  ```
- **Response data**:
  - `Data`: JSON array. Example: `[page:"x/y, e.g. 1/100, means the current query is on page 1 of 100 total pages", record:[{"asin":"<asin>","keyword":"<keyword>","page":"<exposed on page n>","position":"<position on the page: x/y, e.g. 1/68, means position 1 on a page with 68 products>","positionType":"<0: organic exposure, 1: ad exposure>","positionName":"<0: organic position, 1: SP ad, 2: brand ad, 3: video ad>","adID":"<if it is an SP ad, the ad ID, used to determine which keywords belong to the same ad group; otherwise empty>","recordDate":"record time, format: yyyy-MM-dd HH:mm (UTC+8, Beijing time)"}, ...]]`.

---

### 3.2 ASIN's rank trend under a keyword (ASINKeywordRanking)

- **Endpoint description**: ASIN's rank history under a specified keyword, up to the last 2 years. Currently only supports US-site ABA keywords. Supported keyword count per site: US=2 million, GB/DE=300K, IT/FR/JP=150K, ES/CA/MX=100K, AU=50K, other sites = all ABA keywords.
- **Requests consumed**: 2
- **Supported domains**: 1(us)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The ABA keyword to query |
  | ASIN | String | Yes | The Asin to query |
  | QueryStart | String | No | Optional, query start time. Supports up to two years. When empty, only the last 1 month of data is returned |
  | QueryEnd | String | No | Optional, query end time |
  | Page | Integer | No | Page number, default page 1. At most 200 records per page |
- **Usage example**:
  ```bash
  sorftime api ASINKeywordRanking '{"keyword": "power bank", "ASIN": "B0CVM8TXHP"}' --domain 1
  ```
- **Response data**:
  - `Data`: JSON array. Example: `[page:"x/y, e.g. 1/100, means the current query is on page 1 of 100 total pages", record:[{"asin":"<asin>","keyword":"<keyword>","page":"<exposed on page n>","position":"<position on the page: x/y, e.g. 1/68, means position 1 on a page with 68 products>","positionType":"<0: organic exposure, 1: ad exposure>","positionName":"<0: organic position, 1: SP ad, 2: brand ad, 3: video ad>","adID":"<if it is an SP ad, the ad ID, used to determine which keywords belong to the same ad group; otherwise empty>","recordDate":"record time, format: yyyy-MM-dd HH:mm (UTC+8, Beijing time)"}, ...]]`.

---

## 4. Keyword library management

### 4.1 Add keyword to my library (FavoriteKeyword)

- **Endpoint description**: Add a keyword to your keyword library (not limited to ABA keywords). Note: the API library (favorites) is not shared with the Sorftime Pro favorites.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The keyword to favorite (not limited to ABA keywords) |
  | Dict | String | No | Optional. If specified, the keyword is added to the specified folder (the folder is created if it does not exist). The same keyword cannot be added twice to the same folder (but it can exist in different folders). If not specified, the keyword is added to the `Uncategorized` folder. |
- **Usage example**:
  ```bash
  sorftime api FavoriteKeyword '{"keyword": "power bank", "dict": "core-words"}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Integer.

---

### 4.2 Move / Delete library keyword (ChangeFavoriteKeyword)

- **Endpoint description**: Move a keyword to a specified folder or delete a keyword. A single folder can hold at most 2000 keywords. Note: the API library (favorites) is not shared with the Sorftime Pro favorites.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | The keyword that has been favorited |
  | Dict | String | No | Optional. If specified, the keyword is moved / deleted in the specified folder. If not specified, the keyword in the `Uncategorized` folder is moved / deleted. |
  | Command | String | Yes | To delete a keyword: pass `del`. When a folder is specified, only the keyword in that folder is deleted; when no folder is specified, the keyword in all folders is deleted. To move a keyword: pass `move=<folder name>`; the target folder is created if it does not exist. |
- **Usage example**:
  ```bash
  sorftime api ChangeFavoriteKeyword '{"keyword": "power bank", "command": "move=high-priority"}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Integer.

---

### 4.3 Query library keywords (GetFavoriteKeyword)

- **Endpoint description**: Query the keyword library. Note: the API library (favorites) is not shared with the Sorftime Pro favorites.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Command | String | Yes | Pass `dict=<folder name>` to query the keywords in a specified folder; pass `all` to query all keywords; pass `dict` to query only the folder list (returns the list, not the keywords). |
  | Page | Integer | No | Paginated query, default starts from 1, at most 100 records per page. |
- **Usage example**:
  ```bash
  sorftime api GetFavoriteKeyword '{"command": "all", "page": 1}' --domain 1
  ```
- **Response data**:
  - `Data`: Query result, keyword list or folder name list, in JSON format: `["kw1","kw2",...]`.

---

## Notes

1. **ABA keyword**: Most endpoints only support Amazon Brand Analytics keywords.
2. **Historical data limitations**:
   - US site: up to the last 2 years
   - Other sites: only the last 30 days
   - FR, IT: keyword trend starts from 2025-01
   - `KeywordSearchResultTrend` does not support sites 4/5/9.
3. **Site supplement**: `KeywordQuery` / `KeywordSearchResults` / `KeywordExtends` / `CategoryRequestKeyword` / `ASINRequestKeyword` / `KeywordProductRanking` / `FavoriteKeyword` / `ChangeFavoriteKeyword` / `GetFavoriteKeyword` do not support domain 5 (in).
4. **Library management**: The API library is not shared with Sorftime Pro; a single folder can hold at most 2000 keywords.
5. **Paginated query**: At most 200 records per page; it is recommended to set `PageSize` reasonably.
6. **Endpoint rename**: `ASINRequestKeywordv2` has been renamed to `ASINRequestKeyword`. The old name still works, but the new name is recommended.

---

## Best Practices

### 1. Complete keyword research workflow

```bash
# Step 1: ASIN reverse-lookup keywords, find out which keywords the competitor is exposed on
sorftime api ASINRequestKeyword '{"asin": "B0CVM8TXHP"}' --domain 1

# Step 2: Query keyword details
sorftime api KeywordRequest '{"keyword": "power bank"}' --domain 1

# Step 3: Extend related keywords
sorftime api KeywordExtends '{"keyword": "power bank", "pageSize": 100}' --domain 1

# Step 4: Query keyword search-result products
sorftime api KeywordSearchResults '{"keyword": "power bank", "pageSize": 50}' --domain 1

# Step 5: Add valuable keywords to your folder
sorftime api FavoriteKeyword '{"keyword": "power bank", "dict": "core-words"}' --domain 1
```

### 2. Category keyword discovery

```bash
# Reverse-lookup keywords by category
sorftime api CategoryRequestKeyword '{"nodeid": "7073960011", "pageSize": 100}' --domain 1
```

### 3. Keyword rank monitoring

```bash
# Query the ASIN's historical rank under a keyword
sorftime api ASINKeywordRanking '{"keyword": "power bank", "ASIN": "B0CVM8TXHP", "queryStart": "2024-01-01", "queryEnd": "2024-12-31"}' --domain 1
```

### 4. Keyword trend analysis

```bash
# Query the trend of products in keyword search results
sorftime api KeywordSearchResultTrend '{"keyword": "power bank", "queryStart": "2024-01", "queryEnd": "2024-12"}' --domain 1
```

### 5. Library management

```bash
# Batch add keywords to different folders
sorftime api FavoriteKeyword '{"keyword": "power bank", "dict": "core-words"}' --domain 1
sorftime api FavoriteKeyword '{"keyword": "portable charger", "dict": "long-tail-words"}' --domain 1
sorftime api FavoriteKeyword '{"keyword": "bluetooth earbuds", "dict": "related-products"}' --domain 1

# Query all keywords in a folder
sorftime api GetFavoriteKeyword '{"command": "dict=core-words", "page": 1}' --domain 1

# Move a keyword to another folder
sorftime api ChangeFavoriteKeyword '{"keyword": "power bank", "command": "move=high-priority"}' --domain 1
```
