# Amazon Alexa Question Endpoints (4)


## Table of Contents

- [1. Real-time Collect Alexa Questions (AlexaQuestionsCollection)](#1-real-time-collect-alexa-questions-alexaquestionscollection)
- [2. Real-time Query Alexa Question Task Status (AlexaQuestionsCollectionStatusQuery)](#2-real-time-query-alexa-question-task-status-alexaquestionscollectionstatusquery)
- [3. Query Alexa Question Task Result (AlexaQuestionsCollectionResultQuery)](#3-query-alexa-question-task-result-alexaquestionscollectionresultquery)
- [4. Query Alexa Questions (AlexaQuestionsQuery)](#4-query-alexa-questions-alexaquestionsquery)
- [Notes](#notes)
- [Best Practices](#best-practices)
- [1. Full Alexa Question Research Workflow](#1-full-alexa-question-research-workflow)

**Endpoints in this file**: AlexaQuestionsCollection, AlexaQuestionsCollectionStatusQuery, AlexaQuestionsCollectionResultQuery, AlexaQuestionsQuery

**Amazon Domains**: 1=US, 2=UK, 3=DE, 4=FR, 5=IN, 6=CA, 7=JP, 8=ES, 9=IT

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency.

---

## 1. Real-time Collect Alexa Questions (AlexaQuestionsCollection)

- **Endpoint description**: Real-time collect the pre-set "Ask Alexa" questions and their AI answers for the given ASIN. This endpoint does not return the collected question content; use `AlexaQuestionsCollectionResultQuery` to query this run's results by task ID, or use `AlexaQuestionsQuery` to pull all questions collected in the last 15 days. Note: the passed-in ASIN is the current ASIN, and each call only collects that single ASIN, not other ASINs under the same listing. To collect multiple ASINs, call this endpoint once for each (each ASIN counts as 1 collection and deducts credits separately). Data consistency note: the "Ask Alexa" questions shown on Amazon's front-end are dynamically recommended content that may differ due to login account, browsing time, region, device, etc. Therefore the question count and specific content returned by this endpoint may not exactly match the Amazon front-end in real time.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Asin | String | Yes | The ASIN to query |
- **Usage example**:
  ```bash
  sorftime api AlexaQuestionsCollection '{"asin": "B0CVM8TXHP"}' --domain 1
  ```
- **Response data**:
  - `Data`: task ID (Integer type, e.g. `189669`). A task ID > 0 indicates the task was created successfully. While in progress, the response is `Code: 99` with `Data` still being the taskId.

---

## 2. Real-time Query Alexa Question Task Status (AlexaQuestionsCollectionStatusQuery)

- **Endpoint description**: Query the execution status of the real-time "Ask Alexa" pre-set question collection task.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Asin | String | Yes | The ASIN to collect Alexa pre-set questions for, e.g. B0CVM8TXHP |
  | Update | Integer | No | Time range (in hours) to check for executed collection tasks, valid values: 1 - 240. E.g. 48 means check real-time Alexa collection task status for `<ASIN>` within the last 48 hours |
- **Usage example**:
  ```bash
  sorftime api AlexaQuestionsCollectionStatusQuery '{"asin": "B0CVM8TXHP", "update": 48}' --domain 1
  ```
- **Response data**:
  - `Data`: Actually returns an Array (elements are objects).

---

## 3. Query Alexa Question Task Result (AlexaQuestionsCollectionResultQuery)

- **Endpoint description**: Query the "Ask Alexa" pre-set questions and AI answers collected in this real-time collection run by task ID.
- **Requests consumed**: 0
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | TaskId | Integer | Yes | Task ID, e.g. 12345 |
- **Usage example**:
  ```bash
  sorftime api AlexaQuestionsCollectionResultQuery '{"taskId": 12345}' --domain 1
  ```
- **Response data**:
  - `Asin`: Parent ASIN, i.e. the main ASIN of the listing this question belongs to, e.g. B0CRCJY6TT.
  - `VariationAsin`: Variant ASIN, the specific variant source of the question, e.g. B0CRCJY6YH.
  - `AlexaQuestions`: The "Ask Alexa" pre-set question, e.g. Does it really keep drinks cold 24 hours?.
  - `Answer`: The AI answer for this question, e.g. Yes, according to customer reviews, this bottle keeps drinks cold for up to 24 hours..
  - `ItemIndex`: The current item's index, e.g. 1.
  - `ItemTotal`: Total question count, e.g. 5000.

---

## 4. Query Alexa Questions (AlexaQuestionsQuery)

- **Endpoint description**: Query the "Ask Alexa" pre-set questions we have collected. For the latest content, use `AlexaQuestionsCollection` to perform a real-time collection and then query. This endpoint returns by default the "Ask Alexa" questions and AI answers for all variants of the given ASIN that have been updated within the last 15 days.
- **Requests consumed**: 5
- **Supported domains**: 1(us), 2(gb), 3(de), 4(fr), 5(in), 6(ca), 7(jp), 8(es), 9(it)
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Asin | String | Yes | The ASIN to query, e.g. B0CRCJY6TT |
  | PageIndex | Integer | No | Paginated query, at most 100 Alexa questions and their source variants per page. Defaults to 1, representing page 1 (all result pagination starts from 1, not 0) |
- **Usage example**:
  ```bash
  sorftime api AlexaQuestionsQuery '{"asin": "B0CRCJY6TT"}' --domain 1
  ```
- **Response data**:
  - `Asin`: Parent ASIN, i.e. the main ASIN of the listing this question belongs to, e.g. B0CRCJY6TT.
  - `VariationAsin`: Variant ASIN, the specific variant source of the question, e.g. B0CRCJY6YH.
  - `AlexaQuestions`: The "Ask Alexa" pre-set question, e.g. Does it really keep drinks cold 24 hours?.
  - `Answer`: The AI answer for this question, e.g. Yes, according to customer reviews, this bottle keeps drinks cold for up to 24 hours..
  - `ItemIndex`: The current item's index, e.g. 1.
  - `ItemTotal`: Total question count, e.g. 5000.

---

## Notes

1. **Site limitations**: Alexa-related endpoints do not support sites 10/11/12/13/14 (MX/AE/AU/BR/SA); only sites 1/2/3/4/5/6/7/8/9 are supported.
2. **Front-end consistency**: The "Ask Alexa" questions shown on Amazon's front-end are dynamically recommended content that may differ due to login account, browsing time, region, device, etc. The response from this endpoint may not exactly match the front-end display in real time.
3. **Variant scope**: Each `AlexaQuestionsCollection` call only collects the current ASIN. To collect multiple ASINs, call the endpoint separately for each.
4. **Time window**: The `Update` parameter supports 1 - 240 hours.

---

## Best Practices

### 1. Full Alexa Question Research Workflow

```bash
# Step 1: Start the real-time Alexa question collection
sorftime api AlexaQuestionsCollection '{"asin": "B0CRCJY6TT"}' --domain 1

# Step 2: Query the collection task status
sorftime api AlexaQuestionsCollectionStatusQuery '{"asin": "B0CRCJY6TT", "update": 48}' --domain 1

# Step 3: Query this run's collection result by task ID
sorftime api AlexaQuestionsCollectionResultQuery '{"taskId": "<taskId>"}' --domain 1

# Step 4: Pull all questions collected in the last 15 days (including all variants)
sorftime api AlexaQuestionsQuery '{"asin": "B0CRCJY6TT", "pageIndex": 1}' --domain 1
```
