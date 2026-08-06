# Temu Data Type Definitions

> Data field type definitions for all Temu endpoints. Each endpoint document only describes the type of the `data` field; for individual fields, see this document.
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
| URL | String | Category URL (temu.com) |

---

## CategoryObject

A category market object. Returned in the `data` field of CategoryRequest.

| Field | Type | Description |
|------|------|------|
| IsSubCategory | Boolean | Whether the category is a sub-category |
| Products | Array of [ProductSummeryObject](#productsummeryobject) | Best Seller list products in the category |

---

## CategoryListObject

A category search result object. Element of the `data` field array of CategorySearch.

| Field | Type | Description |
|------|------|------|
| Name | String | Category name |
| NodeId | String | Category NodeId |
| MonthlySaleCount | Integer | Monthly sales of the top 100 products in the category |
| MonthlySaleCountShareRatio | Number | Top 100 share of Top 600 monthly sales (%) |
| MonthlySaleCountMOM | Number | Top 100 products' month-over-month change in monthly sales (%) |
| MonthlySaleAmount | Number | Top 100 products' monthly sales amount |
| AvgPrice | Number | Top 100 products' average selling price |
| AvgReviewCount | Integer | Top 100 products' average review count |
| AvgStar | Number | Top 100 products' average star rating |
| SellerCount | Integer | Seller count for the top 100 products |
| BrandCount | Integer | Brand count for the top 100 products |
| Top10ProductSaleCountShareRatio | Number | Top 10 share of Top 100 sales volume (%) |
| Top10SellerSaleCountShareRatio | Number | Top 10 sellers' sales volume share (%) |
| SemiManagedShopCount | Integer | Semi-managed shop count |
| SemiManagedShopSaleCount | Integer | Semi-managed shops' monthly sales |
| SemiManagedShopCumulativeSaleCount | Integer | Semi-managed shops' cumulative sales |
| StarSellerCount | Integer | Star seller count |
| StarSellerMonthlySaleCount | Integer | Star sellers' monthly sales |
| NewProductCount | Integer | Count of new products listed within 30 days |
| NewProductSaleCount | Integer | New products' monthly sales |
| NewProductSaleCountShareRatio | Number | New products' share of Top 600 monthly sales (%) |

---

## ProductSummeryObject

A product summary object. Returned in the `data` field or as array element of ProductRequest, ProductSearchFromName, ProductSearch. Also returned as the `Products` array element of CategoryRequest.

| Field | Type | Description |
|------|------|------|
| ProductId | String | Product ID |
