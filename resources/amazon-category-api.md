# Amazon Category Endpoints (7)


## Table of Contents

- [1. Category Tree (CategoryTree)](#1-category-tree-categorytree)
- [2. Category Best Sellers (supports historical lookup) (CategoryRequest)](#2-category-best-sellers-supports-historical-lookup-categoryrequest)
- [3. All Hot-selling Products in a Category (CategoryProducts)](#3-all-hot-selling-products-in-a-category-categoryproducts)
- [4. Query Market Historical Trend (CategoryTrend)](#4-query-market-historical-trend-categorytrend)
- [5. Search Category by Name (CategorySearchFromName)](#5-search-category-by-name-categorysearchfromname)
- [6. AI Interpret Category Market (CategoryAssistant)](#6-ai-interpret-category-market-categoryassistant)
- [7. Same-category Product Feature Analysis (SimilarProductFeature)](#7-same-category-product-feature-analysis-similarproductfeature)
- [Notes](#notes)
- [Best Practices](#best-practices)
- [1. Complete Category Market Analysis Workflow](#1-complete-category-market-analysis-workflow)
- [2. Historical Data Analysis](#2-historical-data-analysis)
- [3. Multi-site Comparison Analysis](#3-multi-site-comparison-analysis)

**Amazon Domains**: 1=US, 2=UK, 3=DE, 4=FR, 5=IN, 6=CA, 7=JP, 8=ES, 9=IT, 10=MX, 11=AE, 12=AU, 13=BR, 14=SA

**Endpoints in this file**: CategoryTree, CategoryRequest, CategoryProducts, CategoryTrend, CategorySearchFromName, CategoryAssistant, SimilarProductFeature

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency. This document covers only parameters and fields unique to the Amazon category endpoints.
Field names in this file are PascalCase (e.g. `NodeId`, `TrendIndex`, `Asin`); other Amazon endpoint fields are described in camelCase in [amazon-data-types.md](./amazon-data-types.md).

---

## 1. Category Tree (CategoryTree)

- **Endpoint description**: Returns the Best Seller category tree structure. Note: this endpoint's response data is very large (approx. 10MB+); it is recommended to set a long request timeout. Note: we exclude some categories that are not suitable for third-party sellers, e.g. apps, audio/video, books, music, food, number games, etc.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**: none
- **Usage example**:
  ```bash
  # Get the Amazon US site category tree
  sorftime api CategoryTree --domain 1

  # Get the Amazon UK site category tree
  sorftime api CategoryTree --domain 2

  # Get the Amazon Japan site category tree
  sorftime api CategoryTree --domain 7
  ```
- **Response data**:
  - `Id`: Category ID.
  - `ParentId`: Parent category ID; 0 indicates the top level.
  - `NodeId`: Category nodeid.
  - `Name`: Category name.
  - `CNName`: Chinese name of the category.
  - `URL`: Category URL.

---

## 2. Category Best Sellers (supports historical lookup) (CategoryRequest)

- **Endpoint description**: Query the Best Seller Top 100 products of a category. Real-time category data is supported for all 14 major sites. Historical lookup supports up to 2 years of data (sites 5/in, 12/au, 14/sa are not supported for historical lookup). Note: we exclude some categories that are not suitable for third-party sellers, e.g. apps, audio/video, books, music, food, number games, etc. Combined data description: the data sample is the Top 100 per day within the chosen time range, deduplicated by ParentAsin, with combined product sales: take the product's last 30-day sales statistics on the last day of the time range. Request cost for historical lookup: every 3 days of span costs 10 (day span rounded up). E.g. querying 3 days costs 10, querying 4 days costs 20.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NodeId | String | Yes | The NodeId to query |
  | QueryStart | String | No | Optional, format: yyyy-MM-dd. To combine historical Top 100 products, specify this parameter as the query start time. The longest available range is the last 2 years; valid day span range is 3 - 40 days |
  | QueryDate | String | No | Optional, format: yyyy-MM-dd. To combine historical Top 100 products, specify this parameter as the query end time. The most recent available is 2 days before the current date; valid day span range is 3 - 40 days |
  | QueryDays | Integer | No | (Legacy version compatibility) Optional. To combine historical Top 100 products, when `queryDate` is specified but `queryStart` is not, the data for N days back from the specified `queryDate` will be combined. E.g. for 2023-01-03 with 3 days, data for 2023-01-01, 2022-12-31, 2022-12-30 will be returned |
- **Usage example**:
  ```bash
  # Query the current Best Seller data
  sorftime api CategoryRequest '{"nodeId": "7073960011"}' --domain 1

  # Query historical data (2024-01-01 to 2024-01-10, 10 days)
  sorftime api CategoryRequest '{"nodeId": "7073960011", "queryStart": "2024-01-01", "queryDate": "2024-01-10"}' --domain 1
  ```
- **Response data**:
  - `Products`: List of products in the Best Seller list.
  - `Products.Title`: Product name.
  - `Products.Photo`: This product's main image, URL format.
  - `Products.EBCPhoto`: This product's A+ page images.
  - `Products.StoreName`: Store name.
  - `Products.ListingSalesVolumeOfDaily`: Listing daily sales (variants not distinguished). When value is -1, it means sales cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). Example: 1000.
  - `Products.ListingSalesOfDaily`: Listing daily sales amount. When value is -1, it means the sales amount cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). In local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.ListingSalesVolumeOfMonth`: Listing monthly sales (last 30-day sales; variants not distinguished). Recommended for product sales evaluation. When value is -1, it means sales cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). Example: 1000.
  - `Products.ListingSalesOfMonth`: Listing estimated monthly sales amount. When value is -1, it means the sales amount cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). In local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.ASIN`: This product's ASIN.
  - `Products.ParentAsin`: Parent ASIN. When the product has variants, this represents the product's parent ASIN; when the product has no variants, this field is null. When a listing has multiple variants, every variant's ParentASIN is the same, while ASIN is different.
  - `Products.Price`: ASIN's selling price (coupon not deducted), in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.ListPrice`: ASIN's list price (strikethrough), in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.ProductType`: The category this product belongs to.
  - `Products.Coupon`: At the time of our collection of this product, the coupon policy applied to the product's one-time purchase. When value > 0, it represents a specific discount amount, in local minor units (e.g. on the US site, in cents), e.g. 500 = $5 USD coupon. When value < 0, it represents a discount percentage, e.g. -10 = 10% off.
  - `Products.SalesPrice`: The actual selling price at the time of our collection of this product (after coupon), in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.Brand`: The current product's brand.
  - `Products.BuyboxSeller`: At the time of our collection of this product, the seller that got the Buybox.
  - `Products.BuyboxSellerId`: At the time of our collection of this product, the ID of the seller that got the Buybox.
  - `Products.BuyboxSellerAddress`: At the time of our collection of this product, the country/region of the Buybox seller. When the seller is Amazon itself, this field is null. 2-letter country code. E.g. China: CN, USA: US, UK: GB.
  - `Products.IsFBA`: At the time of our collection of this product, whether the Buybox seller's logistics method is FBA.
  - `Products.FbaFee`: If the product's logistics method is FBA, this product's FBA fee, in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.FbaDetetail`: If the product's logistics method is FBA, the FBA fee breakdown details, in local minor units. US site example: `["475","1-9:5","10-12:15"]` represents: shipping fee $4.75, 1-9 month storage fee $0.05, 10-12 month storage fee $0.15. The first value is the shipping fee, and the values after that are in the format `<month>: <storage fee>`; -1 means not charged.
  - `Products.ShipCost`: When FBM, shows the shipping fee (shows 0 when no shipping fee is shown on the page), in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.PlatformFee`: Platform commission, in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.Profit`: Product gross profit, actual price - FBA fee - platform commission. If the product's logistics method is not FBA, the FBA fee is counted as 0, in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.ProfitRate`: Profit margin, (gross profit / actual price) * 100. Example: 25.83 means the profit rate is 25.83%.
  - `Products.OnlineDate`: This product's listing date, format: yyyy-MM-dd.
  - `Products.OnlineDays`: Number of days from this product's listing date to today.
  - `Products.RatingsCount`: This product's review count.
  - `Products.Category`: This product's top-level category, value is a 2-element String array; the first value is the top-level category name, the second is the top-level category's nodeid. E.g. `["Clothing, Shoes & Jewelry","fashion"]`. When the top-level category is undisclosed, the returned value is empty.
  - `Products.BsrCategory`: This product's sub-category, value is a 2-D array `[["Category name", "NodeId", "Sub-category rank"], ...]`. E.g. `[["Baby","baby-products","1"],...]`. When the sub-category is undisclosed, the returned value is empty.
  - `Products.Rank`: This product's top-level category rank at the time of our collection. E.g. 1467.
  - `Products.Ratings`: This product's star rating. Example: 4.8.
  - `Products.VariationASINCount`: Variant count.
  - `Products.SellerCount`: How many sellers this product has.
  - `Products.HasVideo`: Whether this product has a main image video.
  - `Products.APlus`: Whether this product has an A+ page.
  - `Products.HasBrandStore`: Whether this product has a brand store.
  - `Products.Size`: This product's outer package dimensions, `["longest side", "second longest side", "shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
  - `Products.Weight`: This product's weight; when the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.
  - `Products.ExtraSavings`: Records the related promotion content of the product and the related ASINs in the content. E.g. `[{"Asin": "B0BZS461JG", "Text": "Save 5% on Waterdrop WD-G3-CF Filter when you purchase 1 or more Qualifying items offered by WaterdropDirect. Select \"Add both to Cart\" to automatically apply promo code WDG32CFF. Here's how (restrictions apply)"}, ...]`.
  - `Products.BrandPromotion`: This product's brand promotion.
  - `Products.DealType`: Product promotion tag; if there is a deal, we record the deal tag.

---

## 3. All Hot-selling Products in a Category (CategoryProducts)

- **Endpoint description**: Query more hot-selling products in a category; for long-tail categories, up to 1000+ products can be returned. The endpoint returns products updated in the last 15 days (15*24 hours) under the queried category.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NodeId | String | Yes | The NodeId to query |
  | Page | Integer | No | Paginated query, at most 100 products per page. Default 1, representing page 1 (all result pagination starts from 1, not 0) |
  | Range | Integer | No | Optional, the product count range to query sorted in descending order by monthly sales (last 30-day sales). When not specified, all products are returned. E.g. set to 1000, returns the top 1000 products sorted in descending order by monthly sales (last 30-day sales) |
- **Usage example**:
  ```bash
  # Query page 1
  sorftime api CategoryProducts '{"nodeId": "7073960011", "page": 1}' --domain 1

  # Query page 2
  sorftime api CategoryProducts '{"nodeId": "7073960011", "page": 2}' --domain 1
  ```
- **Response data**:
  - `Page`: Current page number.
  - `PageCount`: Total number of pages.
  - `Products`: Product list.
  - `Products.Title`: Product name.
  - `Products.Photo`: This product's main image, URL format.
  - `Products.ListingSalesVolumeOfDaily`: Listing daily sales (variants not distinguished). When value is -1, it means sales cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). Example: 1000.
  - `Products.ListingSalesOfDaily`: Listing daily sales amount. When value is -1, it means the sales amount cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). In local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.ListingSalesVolumeOfMonth`: Listing monthly sales (last 30-day sales; variants not distinguished). Recommended for product sales evaluation. When value is -1, it means sales cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). Example: 1000.
  - `Products.ListingSalesOfMonth`: Listing estimated monthly sales amount. When value is -1, it means the sales amount cannot be estimated; possible reason: the selected top-level category is missing, or the top-level category became non-standard (e.g. Our Brands, Amazon Renewed). In local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.ASIN`: This product's ASIN.
  - `Products.ParentAsin`: Parent ASIN. When the product has variants, this represents the product's parent ASIN; when the product has no variants, this field is null. When a listing has multiple variants, every variant's ParentASIN is the same, while ASIN is different.
  - `Products.Price`: ASIN's selling price (coupon not deducted), in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.ListPrice`: ASIN's list price (strikethrough), in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.Coupon`: At the time of our collection of this product, the coupon policy applied to the product's one-time purchase. When value > 0, it represents a specific discount amount, in local minor units (e.g. on the US site, in cents), e.g. 500 = $5 USD coupon. When value < 0, it represents a discount percentage, e.g. -10 = 10% off.
  - `Products.SalesPrice`: The actual selling price at the time of our collection of this product (after coupon), in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.Brand`: The current product's brand.
  - `Products.BuyboxSeller`: At the time of our collection of this product, the seller that got the Buybox.
  - `Products.BuyboxSellerId`: At the time of our collection of this product, the ID of the seller that got the Buybox.
  - `Products.BuyboxSellerAddress`: At the time of our collection of this product, the country/region of the Buybox seller. When the seller is Amazon itself, this field is null. 2-letter country code. E.g. China: CN, USA: US, UK: GB.
  - `Products.IsFBA`: At the time of our collection of this product, whether the Buybox seller's logistics method is FBA.
  - `Products.FbaFee`: If the product's logistics method is FBA, this product's FBA fee, in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.FbaDetetail`: If the product's logistics method is FBA, the FBA fee breakdown details, in local minor units. US site example: `["475","1-9:5","10-12:15"]` represents: shipping fee $4.75, 1-9 month storage fee $0.05, 10-12 month storage fee $0.15. The first value is the shipping fee, and the values after that are in the format `<month>: <storage fee>`; -1 means not charged.
  - `Products.PlatformFee`: Platform commission, in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.Profit`: Product gross profit, actual price - FBA fee - platform commission. If the product's logistics method is not FBA, the FBA fee is counted as 0, in local minor units (e.g. on the US site, in cents). Example: 1999 = 19.99 USD on the US site.
  - `Products.ProfitRate`: Profit margin, (gross profit / actual price) * 100. Example: 25.83 means the profit rate is 25.83%.
  - `Products.OnlineDate`: This product's listing date, format: yyyy-MM-dd.
  - `Products.OnlineDays`: Number of days from this product's listing date to today.
  - `Products.RatingsCount`: This product's review count.
  - `Products.Category`: This product's top-level category, value is a 2-element String array; the first value is the top-level category name, the second is the top-level category's nodeid. E.g. `["Clothing, Shoes & Jewelry","fashion"]`.
  - `Products.BsrCategory`: This product's sub-category, value is a 2-D array `[["Category name", "NodeId", "Sub-category rank"], ...]`. E.g. `[["Baby","baby-products","1"],...]`.
  - `Products.Rank`: This product's top-level category rank at the time of our collection. E.g. 1467.
  - `Products.Ratings`: This product's star rating. Example: 4.8.
  - `Products.VariationASINCount`: Variant count.
  - `Products.SellerCount`: How many sellers this product has.
  - `Products.HasVideo`: Whether this product has a main image video.
  - `Products.APlus`: Whether this product has an A+ page.
  - `Products.HasBrandStore`: Whether this product has a brand store.
  - `Products.Size`: This product's outer package dimensions, `["longest side", "second longest side", "shortest side"]`, unit: cm. E.g. `["11.10","7.91","2.56"]`.
  - `Products.Weight`: This product's weight; when the front-end shows pounds, it has been converted to grams (1 pound ≈ 453.6g), unit: g. E.g. 1500.

---

## 4. Query Market Historical Trend (CategoryTrend)

- **Endpoint description**: Query the historical trend of a category market for the last 2 years.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NodeId | String | Yes | The NodeId to query |
  | TrendIndex | Integer | Yes | The historical trend type to query<br>0: Sales trend<br>1: Brand count trend<br>2: Seller count trend<br>3: Average price trend<br>4: Average review count trend<br>5: Average star rating trend<br>6: 1-month new product share trend<br>7: 3-month new product share trend<br>8: 6-month new product share trend<br>9: Amazon self-operated share trend<br>10: FBM product count share trend<br>11: A+ product count share trend<br>12: Average per-product profit trend<br>13: Average hijacker count trend<br>14: Top 100 product occupancy rate trend<br>15: Average top-level category rank trend<br>16-18: 1/3/6-month new product average star rating trend<br>19-21: 1/3/6-month new product average review count trend<br>22-24: 1/3/6-month new product max review count trend<br>25-27: 1/3/6-month new product min review count trend<br>28-31: Top 3/5/10/20 listing monopoly index trend<br>32-35: Top 3/5/10/20 brand monopoly index trend<br>36-39: Top 3/5/10/20 seller monopoly index trend |
- **Usage example**:
  ```bash
  # Query sales trend
  sorftime api CategoryTrend '{"nodeId": "7073960011", "trendIndex": 0}' --domain 1

  # Query top 10 brand monopoly index trend
  sorftime api CategoryTrend '{"nodeId": "7073960011", "trendIndex": 34}' --domain 1
  ```
- **Response data**:
  - `Data`: At most returns the last 2 years of Top 100 category market trend. For monetary trends, the value is in local minor units (e.g. on the US site, 15.99 USD is returned as 1599). For percentage trends, the unit is percentage (e.g. 50% is returned as 50). Example: `[202010, 1000, 202011, 1010, 202012, 1050, ....]`. Each array: even indices are months, e.g. 202010; odd indices are the corresponding data.

---

## 5. Search Category by Name (CategorySearchFromName)

- **Endpoint description**: Use natural language to search Amazon-related category markets.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Name | String | Yes | The category name to search |
- **Usage example**:
  ```bash
  sorftime api CategorySearchFromName '{"name": "kitchen"}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Array (elements are objects).

---

## 6. AI Interpret Category Market (CategoryAssistant)

- **Endpoint description**: Sorftime Agent interprets the category market (currently only supports categories where the sum of monthly sales of the top 100 products is greater than 5000 AND the product count is greater than 50; otherwise it fails directly and returns the request). Generation takes about 5 minutes. Results can be obtained via the `AIResult` endpoint. Supports text and text+graphic versions (request cost: 75).
- **Requests consumed**: 25
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | NodeId | String | Yes | The nodeid of the sub-category to analyze |
  | Type | Integer | Yes | Report type. 0: text only (markdown); 1: both text and text+graphic (text in markdown, text+graphic in HTML) |
- **Usage example**:
  ```bash
  sorftime api CategoryAssistant '{"nodeId": "7073960011", "type": 1}' --domain 1
  ```
- **Response data**:
  - `Data`: The taskId of this run's task.

---

## 7. Same-category Product Feature Analysis (SimilarProductFeature)

- **Endpoint description**: Given a product / category name, extract and aggregate the features of the top-selling products in that Amazon category. Returns each feature's product-count ratio, monthly-sales ratio, and a short description. Use cases: product-selection differentiation analysis, Listing selling-point optimization, feature-gap mining.
- **Requests consumed**: 2
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it), 10(mx), 11(ae), 12(au), 13(br), 14(sa)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ProductName | String | Yes | Product / category name, supports Chinese and English |
- **Usage example**:
  ```bash
  sorftime api SimilarProductFeature '{"productName": "air fryer"}' --domain 1
  ```
- **Response data**: data is an Array where each element has:
  - `Feature`: Feature type. E.g. `Multi-function integration (5-7 functions)`.
  - `ProductCountRatio`: Share of products in the category that have this feature. E.g. `69.23%`.
  - `MonthlySalesRatio`: Share of monthly sales of products that have this feature. E.g. `52.67%`.
  - `FeatureDescription`: Description of this feature. E.g. `Supports multiple cooking modes such as air frying, baking, grilling, defrosting, reheating, etc., reducing the number of kitchen appliances needed.`

---

## Notes

1. **Category tree size**: `CategoryTree` returns a very large response (approx. 10MB+); it is recommended to set a long request timeout.
2. **Historical lookup**: `CategoryRequest` historical lookup supports up to 2 years of data, but does not support sites 5 (in) / 12 (au) / 14 (sa).
3. **Historical day span**: `CategoryRequest` historical lookup valid day span range is 3 - 40 days.
4. **Currency minor unit**: All monetary fields (`Price`, `ListPrice`, `Coupon`, etc.) are in local minor units (e.g. on the US site, 1999 = 19.99 USD); missing values return `-1`.
5. **Excluded categories**: We exclude categories that are not suitable for third-party sellers, e.g. apps, audio/video, books, music, food, number games, etc.
6. **AI report eligibility**: `CategoryAssistant` only supports categories where the sum of monthly sales of the top 100 products is greater than 5000 AND the product count is greater than 50; sites 5/11/12/13/14 are not supported.

---

## Best Practices

### 1. Complete Category Market Analysis Workflow

```bash
# Step 1: Get the category tree
sorftime api CategoryTree --domain 1

# Step 2: Fuzzy search to locate the category
sorftime api CategorySearchFromName '{"name": "bluetooth earbuds"}' --domain 1

# Step 3: Query the Best Sellers in this category
sorftime api CategoryRequest '{"nodeId": "7073960011"}' --domain 1

# Step 4: Query the full hot-selling products in this category
sorftime api CategoryProducts '{"nodeId": "7073960011", "page": 1}' --domain 1

# Step 5: Query the sales trend of this category
sorftime api CategoryTrend '{"nodeId": "7073960011", "trendIndex": 0}' --domain 1

# Step 6: Query the brand monopoly index of this category
sorftime api CategoryTrend '{"nodeId": "7073960011", "trendIndex": 34}' --domain 1

# Step 7: AI interpret the category market
sorftime api CategoryAssistant '{"nodeId": "7073960011", "type": 1}' --domain 1
sorftime api AIResult '{"taskId": "<taskId>"}' --domain 1
```

### 2. Historical Data Analysis

```bash
# Query Best Seller data for the last 10 days
sorftime api CategoryRequest '{"nodeId": "7073960011", "queryStart": "2024-01-01", "queryDate": "2024-01-10"}' --domain 1

# A 10-day span costs ceil(10/3) * 10 = 40 requests
```

### 3. Multi-site Comparison Analysis

```bash
sorftime api CategoryTrend '{"nodeId": "7073960011", "trendIndex": 0}' --domain 1   # US site
sorftime api CategoryTrend '{"nodeId": "7073960011", "trendIndex": 0}' --domain 2   # UK site
sorftime api CategoryTrend '{"nodeId": "7073960011", "trendIndex": 0}' --domain 3   # Germany site
sorftime api CategoryTrend '{"nodeId": "7073960011", "trendIndex": 0}' --domain 7   # Japan site
```
