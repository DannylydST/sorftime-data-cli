# Amazon AI Analysis Result Query Endpoints (2)

**Endpoints in this file**: AIResultQuery, AIResult

**Amazon Domains**: 1=US, 2=UK, 3=DE, 4=FR, 6=CA, 7=JP, 8=ES, 9=IT, 10=MX

> Note: The endpoints that CREATE AI tasks are:
> - Product AI interpretation: `ProductAssistant` (see [amazon-product-api.md](./amazon-product-api.md))
> - Category AI interpretation: `CategoryAssistant` (see [amazon-category-api.md](./amazon-category-api.md))

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency.

---

## 1. Query AI Task Progress (AIResultQuery)

- **Endpoint description**: Query historical AI tasks that have been executed.
- **Requests consumed**: 1
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Method | Integer | Yes | 0: AI product interpretation<br>1: AI sub-category interpretation |
  | Params | String | No | Optional. If querying a product, pass the ASIN; if querying a category, pass the nodeId |
  | QueryStart | String | No | Query start time. The interval between QueryStart and QueryEnd must not exceed 7 days. Format: `yyyy-MM-dd` |
  | QueryEnd | String | No | Query end time. The interval between QueryStart and QueryEnd must not exceed 7 days. Format: `yyyy-MM-dd` |
- **Usage example**:
  ```bash
  sorftime api AIResultQuery '{"method": 0, "params": "B0CVM8TXHP", "queryStart": "2026-07-12", "queryEnd": "2026-07-19"}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Array.

---

## 2. Query AI Interpretation Analysis Result (AIResult)

- **Endpoint description**: Query the result of an AI-analyzed category or product.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 6(ca), 7(jp), 8(es), 9(it), 10(mx)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | TaskId | String | Yes | The taskId returned when the analysis task was created, or obtained via the `AIResultQuery` endpoint |
- **Usage example**:
  ```bash
  sorftime api AIResult '{"taskId": "abc123"}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Object.

---

## Notes

1. **Eligibility**: `ProductAssistant` only supports products with monthly sales greater than 500; `CategoryAssistant` only supports categories where the sum of monthly sales of the top 100 products is greater than 5000 AND the product count is greater than 50.
2. **Site limitations**: AI series endpoints only support domains 1/2/3/4/6/7/8/9/10 (9 sites in total). Domains 5/11/12/13/14 are not supported.
3. **Expected time**: AI reports take approximately 5 minutes to generate.
4. **Report types**: When creating a task via `ProductAssistant` / `CategoryAssistant`, `Type=0` returns only the text version (markdown); `Type=1` returns both the text version and a graphic version (75 requests consumed).
5. **Query interval**: The interval between `QueryStart` and `QueryEnd` for `AIResultQuery` must not exceed 7 days.

---

## Best Practices

### 1. AI Product Interpretation + Get Result

```bash
# Step 1: Create the AI product interpretation task
sorftime api ProductAssistant '{"asin": "B0CVM8TXHP", "type": 1}' --domain 1

# Step 2: Get the task result directly (or use AIResultQuery to list after a delay)
sorftime api AIResult '{"taskId": "<taskId>"}' --domain 1

# Step 3: List historical tasks from the last 7 days
sorftime api AIResultQuery '{"method": 0, "params": "B0CVM8TXHP", "queryStart": "2026-07-12", "queryEnd": "2026-07-19"}' --domain 1
```

### 2. AI Category Market Interpretation

```bash
# Step 1: Create the AI category interpretation task
sorftime api CategoryAssistant '{"nodeId": "7073960011", "type": 1}' --domain 1

# Step 2: Fetch the result
sorftime api AIResult '{"taskId": "<taskId>"}' --domain 1
```
