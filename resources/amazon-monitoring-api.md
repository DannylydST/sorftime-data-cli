# Amazon Monitoring — Common Rules & All Endpoints (14)

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency.
This document covers all Amazon monitoring endpoints — common rules plus 14 endpoint details in one file.

---

# Part A. Common Rules

## A1. Prerequisites

### Install sorftime-cli
```bash
npm install -g sorftime-cli
```

### Configure the account
```bash
# Add an account
sorftime add <profile-name> <your-account-sk>

# Switch to a default account
sorftime use <profile-name>
```

---

## A2. Domain Parameters and Site Support Matrix

| domain | Site code | Site name | Keyword monitoring | Best Seller list monitoring | Hijacker monitoring |
|---------|---------|---------|-----------|---------|---------|
| 1 | us | US site | ✓ | ✓ | ✓ |
| 2 | gb | UK site | ✓ | ✓ | ✓ |
| 3 | de | Germany site | ✓ | ✓ | ✓ |
| 4 | fr | France site | ✓ | ✓ | ✓ |
| 6 | ca | Canada site | ✓ | ✓ | ✓ |
| 7 | jp | Japan site | ✓ | ✓ | ✓ |
| 8 | es | Spain site | ✓ | ✗ | ✓ |
| 9 | it | Italy site | ✓ | ✗ | ✓ |
| 10 | mx | Mexico site | ✗ | ✗ | ✓ |
| 11 | ae | UAE site | ✗ | ✗ | ✓ |
| 12 | au | Australia site | ✗ | ✓ | ✓ |
| 13 | br | Brazil site | ✗ | ✗ | ✗ |
| 14 | sa | Saudi Arabia site | ✗ | ✗ | ✗ |

---

## A3. Credit Cost Rules

1. **Keyword monitoring**:
   - Monitor one keyword, 7 days/week, 24 hours/day, once per hour, first 3 pages each time
   - Weekly credit cost = 1×7×24×1×3 = **504**
   - JP site costs 2 credits per page; the same frequency costs **1008**
   - The monitoring task only deducts credits based on the keyword, regardless of how many ASINs are followed under that keyword

2. **Best Seller list monitoring**:
   - top100 costs **10** credits/day
   - top200 costs **20** credits/day
   - top300 costs **30** credits/day
   - top400 costs **40** credits/day

3. **Hijacker & stock monitoring**:
   - Each ASIN per monitoring run costs **2** credits (**4** credits on the JP site)
   - When stock checking is enabled, an additional **1** credit is consumed (**2** credits on the JP site)

4. **Credit reset**: At 00:00 on the 10th of each month, any unused credits from the previous period are cleared and new credits are issued.

---

## A4. Data Retention

- All monitoring results are retained for a maximum of **30 days**.

---

## A5. period Expression Syntax

Format: `<which days of the week>|<which time slots each day>|<monitoring frequency>`

- **Which days of the week**: 1-7 (comma-separated, 1=Monday, 7=Sunday)
- **Which time slots each day**: 1-6 (each slot is 4 hours, Beijing time)
  - 1: 1-4, 2: 5-8, 3: 9-12, 4: 13-16, 5: 17-20, 6: 21-0
- **Monitoring frequency**:
  - 1: once at any time within the slot
  - 11-14: 1st-4th time slot within the slot (may fail due to too many tasks)
  - 2: once per hour within the slot
  - 3: once every 2 hours within the slot (random even or odd)
  - 31: odd hours within the slot, total 2 runs (may fail due to too many tasks)
  - 32: even hours within the slot, total 2 runs (may fail due to too many tasks)

---

## A6. area Postal Codes

- **PC mode (mode=0)**:
  - US: 10041 (New York area), 60601 (Chicago), 94102 (San Francisco)
  - GB: N1P 3AA (London)
  - DE: 10115 (Berlin)
  - FR: 75001 (Paris)
  - CA: V5K 0A1 (Vancouver)
  - JP: 120-0015 (Tokyo)
  - ES: 28001 (Madrid)
  - IT: 66030 (Rome)

- **Mobile mode (mode=1)**:
  - US: 98101 (Seattle)
  - GB: B10 0AB (Birmingham)
  - DE: 20095 (Hamburg)
  - FR: 13001 (Marseille)
  - CA: V5K 0A1 (Victoria)
  - JP: 550-0004 (Osaka)
  - ES: 08001 (Barcelona)
  - IT: 16100 (Genoa)

---

## A7. Common Notes

1. **Credit management**: Monitoring endpoints all consume credits, reset at 00:00 on the 10th of each month.
2. **Data retention**: All monitoring results are retained for a maximum of 30 days.
3. **Task registration failure**: When certain frequencies are set (11-14, 31-32), registration may fail due to too many tasks in the slot, returning taskId = **-999**.
4. **Best Seller list monitoring prerequisite**: The registered category must be a followed category first.
5. **Hijacker monitoring limit**: At most the top 30 sellers are monitored.

---

## A8. Common Errors

| Error code | Description | Solution |
|--------|------|----------|
| 0 | Success | - |
| 4 | Insufficient credit balance | Top up credits or wait for next month's reset |
| -999 | Task registration/modification failed | Too many tasks in the time slot; try another time slot or frequency |
| 401 | Authentication failed | Check whether the Account-SK is valid |
| 403 | Insufficient permissions | Check plan permissions or request count |

---

# Part B. Endpoint Index

| Monitoring type | Endpoint count | Endpoint list |
|---------|---------|---------|
| Keyword monitoring | 5 | KeywordBatchSubscription, KeywordTasks, KeywordBatchTaskUpdate, KeywordBatchScheduleList, KeywordBatchScheduleDetail |
| Best Seller list monitoring | 4 | BestSellerListSubscription, BestSellerListTask, BestSellerListDelete, BestSellerListDataCollect |
| Hijacker & stock monitoring | 5 | ProductSellerSubscription, ProductSellerTasks, ProductSellerTaskUpdate, ProductSellerTaskScheduleList, ProductSellerTaskScheduleDetail |

---

# Part C. Endpoints

## C1. Keyword Monitoring (5 endpoints)

### 1. Register Keyword Monitoring (KeywordBatchSubscription)

- **Endpoint description**: Periodically monitor an ASIN's search rank for the given keyword, supporting both mobile and PC browsers.
- **Credit cost**: 0 requests, but consumes credits instead.
- **Note**: Not limited by followed category; can monitor any keyword.
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | keyword | String Array | Yes | Keyword list to monitor, e.g. `["kw1","kw2"]` |
  | mode | Integer | Yes | Monitoring mode: 0=PC browser, 1=mobile browser |
  | area | String | Conditional | Monitoring area postal code (see description below) |
  | page | Integer | Yes | First N pages to monitor: 1, 3, 5, 7 (mobile mode is always 1, returns ~120+ products) |
  | period | String | Yes | Monitoring frequency expression: `<which days of the week>|<which time slots each day>|<monitoring frequency>` |
- **area description**:
  - **PC mode (mode=0)**:
    - US: 10041 (New York area), 60601 (Chicago), 94102 (San Francisco)
    - GB: N1P 3AA (London)
    - DE: 10115 (Berlin)
    - FR: 75001 (Paris)
    - CA: V5K 0A1 (Vancouver)
    - JP: 120-0015 (Tokyo)
    - ES: 28001 (Madrid)
    - IT: 66030 (Rome)
  - **Mobile mode (mode=1)**:
    - US: 98101 (Seattle)
    - GB: B10 0AB (Birmingham)
    - DE: 20095 (Hamburg)
    - FR: 13001 (Marseille)
    - CA: V5K 0A1 (Victoria)
    - JP: 550-0004 (Osaka)
    - ES: 08001 (Barcelona)
    - IT: 16100 (Genoa)
- **period frequency expression**: `<which days of the week>|<which time slots each day>|<monitoring frequency>`
  - `<which days of the week>`: 1-7 (comma-separated, 1=Monday, 7=Sunday)
  - `<which time slots each day>`: 1-6 (each slot is 4 hours, Beijing time)
    - 1: 1-4, 2: 5-8, 3: 9-12, 4: 13-16, 5: 17-20, 6: 21-0
  - `<monitoring frequency>`:
    - 1: once at any time within the slot
    - 11-14: 1st-4th time within the slot (may fail due to too many tasks)
    - 2: once per hour within the slot
    - 3: once every 2 hours within the slot (random even or odd)
    - 31: odd hours within the slot, total 2 runs (may fail due to too many tasks)
    - 32: even hours within the slot, total 2 runs (may fail due to too many tasks)
- **Usage example**:
  ```bash
  # Monday to Friday, 5-8 and 9-12 each day, once per slot, monitor first 3 pages, PC mode (New York)
  sorftime api KeywordBatchSubscription '{"keyword": ["power bank"], "mode": 0, "area": "10041", "page": 3, "period": "1,2,3,4,5|2,3|1"}' --domain 1

  # Every day around the clock, once per hour, mobile mode (Seattle)
  sorftime api KeywordBatchSubscription '{"keyword": ["power bank"], "mode": 1, "page": 1, "period": "1,2,3,4,5,6,7|1,2,3,4,5,6|2"}' --domain 1

  # 0-4 every day, once every 2 hours, PC mode (London), monitor first page
  sorftime api KeywordBatchSubscription '{"keyword": ["power bank"], "mode": 0, "area": "N1P 3AA", "page": 1, "period": "1,2,3,4,5,6,7|1|3"}' --domain 2
  ```
- **Returns**: `["keyword:taskId", ...]`; `taskId=-999` indicates registration failure (too many tasks in the time slot)

---

### 2. Query Keyword Tasks (KeywordTasks)

- **Endpoint description**: View all valid (non-deleted) keyword monitoring tasks.
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | pageIndex | Integer | No | Page number, default 1 |
  | pageSize | Integer | No | Items per page, min 20, default 20, max 200 |
  | taskid | String | No | If querying by task ID, multiple task IDs are separated by commas |
  | keyword | String | No | Fuzzy match on keyword |
- **Usage example**:
  ```bash
  # Query all tasks
  sorftime api KeywordTasks '{"pageIndex": 1, "pageSize": 20}' --domain 1

  # Query by task ID
  sorftime api KeywordTasks '{"taskid": "12345,12346"}' --domain 1

  # Fuzzy match on keyword
  sorftime api KeywordTasks '{"keyword": "power"}' --domain 1
  ```
- **Response data**: data is an Array of [KeywordTaskObject](./amazon-data-types.md#keywordtaskobject).

---

### 3. Modify Keyword Monitoring Task (KeywordBatchTaskUpdate)

- **Endpoint description**: Modify a keyword monitoring task (pause, start, delete, change settings).
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | taskId | Integer | Yes | Keyword monitoring task ID |
  | update | Integer | Yes | 0=change settings, 1=pause, 2=start, 9=delete |
  | mode | Integer | Conditional | Valid when `update=0`: 0=PC, 1=mobile |
  | area | String | Conditional | Valid when `update=0`; area postal code |
  | page | Integer | Conditional | Valid when `update=0`: 1, 3, 5, 7 |
  | period | String | Conditional | Valid when `update=0`; frequency expression |
- **Usage example**:
  ```bash
  # Pause task
  sorftime api KeywordBatchTaskUpdate '{"taskId": 12345, "update": 1}' --domain 1

  # Start task
  sorftime api KeywordBatchTaskUpdate '{"taskId": 12345, "update": 2}' --domain 1

  # Delete task
  sorftime api KeywordBatchTaskUpdate '{"taskId": 12345, "update": 9}' --domain 1

  # Change task settings
  sorftime api KeywordBatchTaskUpdate '{"taskId": 12345, "update": 0, "mode": 0, "area": "10041", "page": 3, "period": "1,2,3,4,5|2,3|1"}' --domain 1
  ```
- **Returns**: taskId (String type, e.g. `"34567"`); > 0 indicates success, -999 indicates modification failure (too many tasks in the time slot)

---

### 4. Query Keyword Monitoring Task Execution Batches (KeywordBatchScheduleList)

- **Endpoint description**: Query all execution task batches of keyword monitoring.
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | TaskId | Integer | Yes | Keyword monitoring task ID |
  | queryDate | String | No | Format yyyy-MM-dd. Default: query all. If specified, query from this date to the most recent |
- **Usage example**:
  ```bash
  # Query all batches
  sorftime api KeywordBatchScheduleList '{"TaskId": 12345}' --domain 1

  # Query batches after a specific date
  sorftime api KeywordBatchScheduleList '{"TaskId": 12345, "queryDate": "2024-01-15"}' --domain 1
  ```
- **Response data**: data is a String Array of [KeywordBatchScheduleObject](./amazon-data-types.md#keywordbatchscheduleobject), format `<execution time yyyyMMddHHmm>:<batchId>:<status>:<finish time>`.

---

### 5. Extract Keyword Monitoring Product List Detail Data (KeywordBatchScheduleDetail)

- **Endpoint description**: Extract the ASIN list data of all products in a single keyword monitoring search result.
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ScheduelId | String | Yes | Batch task ID, supports multiple task IDs (comma-separated), max 20 |
- **Usage example**:
  ```bash
  # Query a single batch
  sorftime api KeywordBatchScheduleDetail '{"ScheduelId": "batch123"}' --domain 1

  # Query multiple batches (up to 20)
  sorftime api KeywordBatchScheduleDetail '{"ScheduelId": "batch123,batch124,batch125"}' --domain 1
  ```
- **Response data**: data is a CSV-format String Array of [KeywordBatchScheduleDetailObject](./amazon-data-types.md#keywordbatchscheduledetailobject), where each row contains 20 fields including asin, main image link, product title, exposure type, flag, exposure rank, etc.

---

## C2. Best Seller List Monitoring (4 endpoints)

### 1. Register Best Seller List Monitoring Task (BestSellerListSubscription)

- **Endpoint description**: Register a Best Seller list monitoring task; the target category must be a followed category first.
- **Credit cost**: 0 requests, but consumes credits instead.
- **Note**:
  - Monitoring frequency: 1 or 12 times per day.
  - top100: 10 credits/day; top200: 20 credits/day; top300: 30 credits/day; top400: 40 credits/day.
  - Some categories do not have enough data in the corresponding list; credits are deducted according to the task settings, not the actual count.
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | nodeid | String | Yes | The nodeid to monitor |
  | Range | Integer | Yes | The maximum range of list data to monitor: 1=top100 |
  | Period | Integer | Yes | Monitoring frequency (see description below) |
  | BestSellerListType | Integer | Yes | List type (see description below) |
- **Period (monitoring frequency)**:
  - 100: Once per day, at 00:00 (Beijing time)
  - 106: Once per day, at 06:00 (Beijing time)
  - 112: Once per day, at 12:00 (Beijing time)
  - 118: Once per day, at 18:00 (Beijing time)
  - 200: 12 times per day, runs on even hours (0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22)
  - 201: 12 times per day, runs on odd hours (1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23)
- **BestSellerListType (list type)**:
  - 1: New Releases
  - 3: Most Wished For
  - 4: Gift Ideas
  - 5: Best Sellers
- **Usage example**:
  ```bash
  # Monitor Best Sellers list, top100, daily at 00:00
  sorftime api BestSellerListSubscription '{"nodeid": "7073960011", "Range": 1, "Period": 100, "BestSellerListType": 5}' --domain 1

  # Monitor New Releases list, top100, 12 times per day (even hours)
  sorftime api BestSellerListSubscription '{"nodeid": "7073960011", "Range": 1, "Period": 200, "BestSellerListType": 1}' --domain 1

  # Monitor Most Wished For list, top100, daily at 06:00
  sorftime api BestSellerListSubscription '{"nodeid": "7073960011", "Range": 1, "Period": 106, "BestSellerListType": 3}' --domain 1
  ```
- **Returns**: taskId (Integer)

---

### 2. Query Best Seller List Monitoring Tasks (BestSellerListTask)

- **Endpoint description**: View all Best Seller list monitoring tasks.
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | pageIndex | Integer | No | Page number, default 1 |
  | pageSize | Integer | No | Items per page, min 20, default 20, max 200 |
- **Usage example**:
  ```bash
  sorftime api BestSellerListTask '{"pageIndex": 1, "pageSize": 20}' --domain 1
  ```
- **Returns format**: 2-D array
  ```json
  [["<nodeid>", "<BestSellerListType>", "<taskId>", "<Period>", "<status>", "<monitoring start date>", "<monitoring end time>"]]
  ```
  - `status`: 1=normal, 2=stopped, 9=list does not exist
  - The monitoring end time is only populated when the task has been deleted; otherwise the field is empty.

---

### 3. Delete Best Seller List Monitoring Task (BestSellerListDelete)

- **Endpoint description**: Delete a registered Best Seller list monitoring task.
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | nodeid | String | Yes | The nodeid whose monitoring should be deleted |
  | BestSellerListType | Integer | Yes | List type: 1, 3, 4, 5 |
- **Usage example**:
  ```bash
  sorftime api BestSellerListDelete '{"nodeid": "7073960011", "BestSellerListType": 5}' --domain 1
  ```
- **Returns**: Returns the original taskId on success, otherwise returns -1.

---

### 4. Collect Best Seller List Monitoring Data (BestSellerListDataCollect)

- **Endpoint description**: Query the data of a monitored list.
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | nodeid | String | Yes | The nodeid to query |
  | BestSellerListType | Integer | Yes | List type: 1, 3, 4, 5 |
  | queryDate | String | **Yes** (omitting returns `Code: 10 Invalid request parameter`) | The date/hour to collect; format `yyyy-MM-dd HH`. Earliest supported: from the monitoring start date (max 2 years). |
- **Note**:
  - When the hour component is not specified, the first batch of data for the day is returned by default.
  - When the task runs once per day, returns the first batch within 6 hours of the specified hour.
  - When the task runs 12 times per day, returns the first batch within 2 hours of the specified hour.
- **Usage example**:
  ```bash
  # Query the first batch of data for the current day
  sorftime api BestSellerListDataCollect '{"nodeid": "7073960011", "BestSellerListType": 5}' --domain 1

  # Query data for a specific date
  sorftime api BestSellerListDataCollect '{"nodeid": "7073960011", "BestSellerListType": 5, "queryDate": "2024-01-15 00"}' --domain 1

  # Query data for a specific hour
  sorftime api BestSellerListDataCollect '{"nodeid": "7073960011", "BestSellerListType": 5, "queryDate": "2024-01-15 06"}' --domain 1
  ```
- **Response data**: data is an Array of [BestSellerListItemObject](./amazon-data-types.md#bestsellerlistitemobject).

---

## C3. Hijacker & Stock Monitoring (5 endpoints)

### 1. Register Hijacker & Stock Monitoring (ProductSellerSubscription)

- **Endpoint description**: Periodically monitor hijacker sellers (up to the top 30 sellers) of an ASIN.
- **Credit cost**: 0 requests, but consumes credits instead.
- **Note**:
  - Each ASIN monitoring run consumes 2 credits (4 credits on the JP site).
  - When stock checking is enabled, an additional 1 credit is consumed (2 credits on the JP site).
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | asin | String | Yes | The ASIN to monitor |
  | checkstock | Integer | No | 0=do not check stock (default), 1=check stock |
  | period | String | Yes | Monitoring frequency expression: `<which days of the week>|<which hours of each day>|<monitoring frequency>` |
- **period frequency expression**: Same as keyword monitoring.
- **Usage example**:
  ```bash
  # No stock check, Monday to Friday, 5-8 and 9-12 each day, once per slot
  sorftime api ProductSellerSubscription '{"asin": "B0CVM8TXHP", "checkstock": 0, "period": "1,2,3,4,5|2,3|1"}' --domain 1

  # Stock check, every day around the clock, once per hour
  sorftime api ProductSellerSubscription '{"asin": "B0CVM8TXHP", "checkstock": 1, "period": "1,2,3,4,5,6,7|1,2,3,4,5,6|2"}' --domain 1

  # No stock check, 0-4 every day, once every 2 hours
  sorftime api ProductSellerSubscription '{"asin": "B0CVM8TXHP", "checkstock": 0, "period": "1,2,3,4,5,6,7|1|3"}' --domain 1
  ```
- **Returns**: `["asin:taskId", ...]`

---

### 2. Query Hijacker & Stock Monitoring Tasks (ProductSellerTasks)

- **Endpoint description**: View all valid (non-deleted) hijacker monitoring tasks.
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | pageIndex | Integer | No | Page number, default 1 |
  | pageSize | Integer | No | Items per page, min 20, default 20, max 200 |
- **Usage example**:
  ```bash
  sorftime api ProductSellerTasks '{"pageIndex": 1, "pageSize": 20}' --domain 1
  ```
- **Response data**: data is an Array of [ProductSellerTaskObject](./amazon-data-types.md#productsellertaskobject).

---

### 3. Modify Hijacker & Stock Monitoring Task (ProductSellerTaskUpdate)

- **Endpoint description**: Modify a hijacker monitoring task (pause, start, delete, change settings).
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | taskId | Integer | Yes | Task ID |
  | update | Integer | Yes | 0=change settings, 1=pause, 2=start, 9=delete |
  | period | String | Conditional | Valid when `update=0`; frequency expression |
- **Usage example**:
  ```bash
  # Pause task
  sorftime api ProductSellerTaskUpdate '{"taskId": 12345, "update": 1}' --domain 1

  # Start task
  sorftime api ProductSellerTaskUpdate '{"taskId": 12345, "update": 2}' --domain 1

  # Delete task
  sorftime api ProductSellerTaskUpdate '{"taskId": 12345, "update": 9}' --domain 1

  # Change task settings
  sorftime api ProductSellerTaskUpdate '{"taskId": 12345, "update": 0, "period": "1,2,3,4,5|2,3|1"}' --domain 1
  ```
- **Response data**: data is a String, representing the returned taskId. > 0 indicates success; -999 indicates failure (too many tasks in the time slot).

---

### 4. Query Hijacker & Stock Monitoring Task Execution Batches (ProductSellerTaskScheduleList)

- **Endpoint description**: Query all execution task batches of hijacker monitoring.
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | TaskId | Integer | Yes | Task ID |
- **Usage example**:
  ```bash
  sorftime api ProductSellerTaskScheduleList '{"TaskId": 12345}' --domain 1
  ```
- **Response data**: data is a string array with the format `<execution time yyyyMMddHHmm>:<batchId>`.

---

### 5. Extract Hijacker & Stock Monitoring Execution Result Detail Data (ProductSellerTaskScheduleDetail)

- **Endpoint description**: Extract the result data of a single hijacker monitoring run.
- **Requests consumed**: 0
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | ScheduelId | String | Yes | Batch task ID |
- **Usage example**:
  ```bash
  sorftime api ProductSellerTaskScheduleDetail '{"ScheduelId": "batch123"}' --domain 1
  ```
- **Response data**: data is a CSV-format string array of [ProductSellerScheduleDetailObject](./amazon-data-types.md#productsellerscheduledetailobject), where each row format is: `<collection time>,<asin>,<seller name>,<seller ID>,<is buybox>,<shipping method>,<type>,<price>,<stock>,<is limited purchase>`.

---

# Part D. Best Practices

### 1. Keyword rank monitoring
```bash
# Register a monitoring task: once per hour during work hours on weekdays
sorftime api KeywordBatchSubscription '{"keyword": ["power bank"], "mode": 0, "area": "10041", "page": 3, "period": "1,2,3,4,5|1,2,3,4,5,6|2"}' --domain 1

# Query the task list
sorftime api KeywordTasks '{"keyword": "power"}' --domain 1

# Query execution batches
sorftime api KeywordBatchScheduleList '{"TaskId": 12345}' --domain 1

# Extract a single monitoring run's detail data
sorftime api KeywordBatchScheduleDetail '{"ScheduelId": "batch123"}' --domain 1
```

### 2. Best Seller list monitoring
```bash
# Register a Best Sellers list monitoring task, daily at 00:00
sorftime api BestSellerListSubscription '{"nodeid": "7073960011", "Range": 1, "Period": 100, "BestSellerListType": 5}' --domain 1

# Query the list monitoring task
sorftime api BestSellerListTask '{"pageIndex": 1, "pageSize": 20}' --domain 1

# Query list data
sorftime api BestSellerListDataCollect '{"nodeid": "7073960011", "BestSellerListType": 5, "queryDate": "2024-01-15 00"}' --domain 1

# Delete a list monitoring task
sorftime api BestSellerListDelete '{"nodeid": "7073960011", "BestSellerListType": 5}' --domain 1
```

### 3. Hijacker monitoring
```bash
# Register hijacker monitoring, once per hour, no stock check
sorftime api ProductSellerSubscription '{"asin": "B0CVM8TXHP", "checkstock": 0, "period": "1,2,3,4,5,6,7|1,2,3,4,5,6|2"}' --domain 1

# Query hijacker monitoring tasks
sorftime api ProductSellerTasks '{"pageIndex": 1, "pageSize": 20}' --domain 1

# Pause task
sorftime api ProductSellerTaskUpdate '{"taskId": 12345, "update": 1}' --domain 1

# Resume task
sorftime api ProductSellerTaskUpdate '{"taskId": 12345, "update": 2}' --domain 1

# Query execution batches
sorftime api ProductSellerTaskScheduleList '{"TaskId": 12345}' --domain 1

# Extract monitoring results
sorftime api ProductSellerTaskScheduleDetail '{"ScheduelId": "batch123"}' --domain 1
```

### 4. Combined monitoring strategy
```bash
# Scenario: monitor a core product's keyword rank, list position, and hijacker status

# 1. Keyword rank monitoring (hourly during work hours)
sorftime api KeywordBatchSubscription '{"keyword": ["power bank"], "mode": 0, "area": "10041", "page": 3, "period": "1,2,3,4,5|1,2,3,4,5,6|2"}' --domain 1

# 2. Best Seller list monitoring (daily at 00:00)
sorftime api BestSellerListSubscription '{"nodeid": "7073960011", "Range": 1, "Period": 100, "BestSellerListType": 5}' --domain 1

# 3. Hijacker monitoring (hourly, with stock check)
sorftime api ProductSellerSubscription '{"asin": "B0CVM8TXHP", "checkstock": 1, "period": "1,2,3,4,5,6,7|1,2,3,4,5,6|2"}' --domain 1
```
