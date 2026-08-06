# Walmart Data Type Definitions

> Data field type definitions for all Walmart endpoints. Each endpoint document only describes the type of the `data` field; for individual fields, see this document.
> All endpoints share a common outer response structure: `requestLeft`, `requestConsumed`, `requestCount`, `code`, `message`, `data`.


## Table of Contents

- [CategoryTreeObject](#categorytreeobject)
- [ProductSummeryObject](#productsummeryobject)
- [ProductTrendObject](#producttrendobject)
- [ProductKeywordItemObject](#productkeyworditemobject)
- [KeywordSummeryObject](#keywordsummeryobject)
- [KeywordQueryPatternObject](#keywordquerypatternobject)
- [ProductListItemObject](#productlistitemobject)
- [ProductListObject](#productlistobject)

---

## CategoryTreeObject

A category tree node. The CategoryTree endpoint returns an array of this object.

| Field | Type | Description |
|------|------|------|
| id | Integer | Category ID |
| parentId | Integer | Parent category ID; 0 indicates the top level |
| nodeid | String | Category nodeid |
| name | String | Category name |
| cnName | String | Chinese name of the category |
| url | String | Category URL |

---

## ProductSummeryObject

A product summary object. Returned in the `data` field or as its array element of CategoryRequest, ProductRequest, KeywordSearchResults, ProductSearchFromName.

| Field | Type | Description |
|------|------|------|
| title | String | Product name |
| photo | String Array | Product main image URL array |
| listingSalesVolumeOfMonth | Integer | Estimated link-level monthly sales (variants not distinguished); recommended for product sales evaluation |
| listingSalesOfMonth | Integer | Estimated link-level monthly sales amount, in local minor units (e.g. cents on the US site) |
| productId | String | Product ID |
| parentProductId | String | Parent product ID |
| price | Integer | Product selling price, in local minor units (e.g. 1999 = $19.99) |
| brand | String | Product brand |
| seller | String | Seller at collection time |
| shipedby | String | Shipping method at collection time |
| wfsFee | Integer | If the logistics method is FBA, the product's FBA fee, in local minor units |
| attribute | String Array | Product attributes: `["Attribute1", "Value1", "Attribute2", "Value2", ...]` |
| firstReviewsDate | String | First review date (yyyy-MM-dd) |
| reviewsCount | Integer | Review count |
| ratings | Number | Rating star (e.g. 4.8) |
| nodePath | String Array | Category nodes the product belongs to, format: `["Category node name", "Category node", "Rank time", "Rank", ...]` |
| label | String Array | Product labels (e.g. pickup, savewith, bestsell, etc.) |
| popularPick | Integer | Popular Pick flag; 1 if present |
| clearance | Integer | Clearance flag; 1 if present |
| reducedPrice | Integer | Reduced Price flag; 1 if present |
| rollback | Integer | Rollback flag; 1 if present |
| flashDeal | Integer | Flash Deal flag; 1 if present |
| size | String Array | Outer package dimensions: `["longest side", "second longest side", "shortest side"]`, in cm |
| weight | Integer | Product weight, in g |
| variants | String Array | Variant information JSON array; each item includes VariantId, Url, Property, PriceUpdate, DetailUpdate |
| numberOfStar | String Array | Review count per star rating: `["star rating", "review count", "star rating", "review count", ...]` |

---

## ProductTrendObject

A product historical trend object. Returned in the `data` field of ProductTrendRequest.

| Field | Type | Description |
|------|------|------|
| productId | String | Product ID |
| listingSalesVolumeOfMonth | Integer | Estimated link-level monthly sales |
| listingSalesOfMonth | Integer | Estimated link-level monthly sales amount (local minor units) |
| listingSalesVolumeOfMonthTrend | String Array | Monthly sales historical trend array; even indices are dates, odd indices are sales |
| listingSalesOfMonthTrend | String Array | Monthly sales amount historical trend array (local minor units) |
| priceTrend | String Array | Price trend array (local minor units) |
| reviewsTrend | String Array | Review count trend array |
| starTrend | String Array | Star rating trend array (450 = 4.5 stars) |
| rankTrend | String[][] | Rank trend in each category; each row format: `["Category node name", "Category node", "Date", "Rank", "Date", "Rank", ...]` |

---

## ProductKeywordItemObject

A product reverse-lookup keyword object. Array element of the `data` field of ProductRequestKeyword.

| Field | Type | Description |
|------|------|------|
| ShowShare | Number | The traffic share contributed by this keyword in the product's reverse-lookup keywords |
| recentlyPosition | String | Recent exposure position, format `"1,2/18"` = page 1, position 2 of 18 |
| organicPosition | String | Recent organic exposure position |
| adPosition | String | Recent ad exposure position |
| keyword | [KeywordSummeryObject](#keywordsummeryobject) | Keyword details |

---

## KeywordSummeryObject

A keyword summary object. Returned in the `data` field or its array element of KeywordQuery, KeywordSearchResults, KeywordRequest, KeywordSearchFromName, KeywordExtends.

| Field | Type | Description |
|------|------|------|
| keyword | String | Keyword |
| keywordCNName | String | Chinese name of the keyword |
| images | String Array | Top 10 product images from a keyword search result, for quick keyword identification |
| update | String | Latest update time of this keyword |
| rank | Integer | Weekly search rank |
| searchVolume | Integer | Search volume in the last 30 days |
| productCount | Integer | Number of competitors; the number of competitors shown by Walmart on the keyword search page |
| searchFirstPageAvgPrice | Integer | Average price of products in organic positions on the first page (local minor units; e.g. 1999 = $19.99) |
| searchFirstPageAvgReviews | Number | Average review count of products in organic positions on the first page |
| searchFirstPageAvgStar | Number | Average star rating of products in organic positions on the first page (e.g. 4.5) |

---

## KeywordQueryPatternObject

A KeywordQuery pattern object. The `pattern` parameter of the KeywordQuery endpoint.

| Field | Type | Description |
|------|------|------|
| keyword | String | The keyword to query |
| rankCondition | String Array | Weekly rank filter condition: `[minimum value, maximum value]`, e.g. `["1", "5000"]` |
| searchVolumeCondition | String Array | 30-day search volume filter condition: `[minimum value, maximum value]`, e.g. `["10000"]` |

---

## ProductListItemObject

A product list item object. Element of the `products` array in ProductListObject.

| Field | Type | Description |
|------|------|------|
| title | String | Product name |
| photo | String | Product main image URL (JSON array format) |
| listingSalesVolumeOfMonth | Integer | Estimated link-level monthly sales (variants not distinguished) |
| listingSalesOfMonth | Integer | Estimated link-level monthly sales amount (local minor units) |
| productId | String | Product ID |
| parentProductId | String | Parent product ID |
| price | Integer | Product selling price (local minor units) |
| brand | String | Product brand |
| seller | String | Seller at collection time |
| reviewsCount | Integer | Review count |
| ratings | String | Rating star (e.g. 4.8) |
| nodePath | String Array | Category nodes the product belongs to |

---

## ProductListObject

A paginated product list object.

| Field | Type | Description |
|------|------|------|
| page | Integer | Current page number |
| pageCount | Integer | Total number of pages |
| products | String | Product list, JSON array format; elements are [ProductListItemObject](#productlistitemobject) |
