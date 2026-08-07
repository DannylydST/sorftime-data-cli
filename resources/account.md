# Account Management Endpoints (3)

**Endpoints in this file**: CoinQuery, CoinStream, RequestStreamMonth

> These 3 endpoints are common to all platforms and can be called against any Amazon / Shopee / Walmart site. They are account-level endpoints (not site-specific).

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency.

---

## 1. Query Credits Balance (CoinQuery)

- **Endpoint description**: Query the current account credit balance. Credits are issued at 00:00 on the 10th of each month and are not differentiated by site or platform.
- **Requests consumed**: 1
- **Supported domains**: any (1, 21, 201-208, 601, 701, 705, 301-312)
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api CoinQuery '{}' --domain 1
  ```
- **Response data**: data is [CoinQueryObject](./amazon-data-types.md#coinqueryobject), containing a `coin` (Integer) field representing the current credit balance.

---

## 2. Query Credit Stream (CoinStream)

- **Endpoint description**: Query the credit consumption stream.
- **Requests consumed**: 1
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Platform | Integer | No | Platform filter: 0=Amazon (default), 1=Shopee, 2=Walmart |
  | QueryDate | String Array | No | Query time range: `[startDate, endDate]`, format `yyyy-MM-dd`. Default is the most recent 6 months; maximum range is the most recent 12 months |
  | PageIndex | Integer | No | Page number for paginated query, default 1 |
  | PageSize | Integer | No | Items per page, default 20, max 200 |
- **Usage example**:
  ```bash
  # Query all credit stream records
  sorftime api CoinStream '{}' --domain 1

  # Query a specific time range
  sorftime api CoinStream '{"QueryDate": ["2025-01-01", "2025-01-31"]}' --domain 1

  # Query page 2
  sorftime api CoinStream '{"PageIndex": 2, "PageSize": 20}' --domain 1
  ```
- **Response data**: data is a nested object with the following structure:
  ```json
  {
    "CoinStream": [taskType, consumptionTime, coinsSpent, coinsRemaining, ...]
  }
  ```
  The array is grouped in 4 elements per record:
  - Element 1 is the task type: `1`=keyword monitoring, `3`=hijacker & stock monitoring, `9`=ASIN real-time collection, `10`=review real-time collection, `12`=Best Seller list monitoring, `15`=ASIN subscription update, `27`=image-search similar products.
  - Element 2 is the date, format `yyyyMMddHHmm`, e.g. `202607221524`.
  - Element 3 is the credits spent.
  - Element 4 is the credits remaining.

  > Note: unlike Shopee / Walmart / Temu / TikTok's `CoinStream` (flat array `Data: [...]`), Amazon's `CoinStream` is a nested object `Data: { CoinStream: [...] }`.

---

## 3. Query Request Stream (RequestStreamMonth)

- **Endpoint description**: Query the request purchase and consumption stream. Request queries are not differentiated by site; queries against any site return the total request balance.
- **Requests consumed**: 0
- **Request parameters**: none
- **Usage example**:
  ```bash
  sorftime api RequestStreamMonth '{}' --domain 1
  ```
- **Response data**: data contains `Purchase` (Array, currently empty) and `Consume` (2-D array, each row formatted as `[month, requestsSpent]`, e.g. `["202605", 510]`).
