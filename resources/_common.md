# Sorftime CLI Common Reference (_common.md)

> For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency. Each endpoint document **only retains the endpoint's own parameters / fields / examples**; common parts are referenced from this file.


## Table of Contents

- [1. CLI Call Template](#1-cli-call-template)
- [2. Amazon Domain Table (14 sites)](#2-amazon-domain-table-14-sites)
- [3. Shopee Domain Table (8 sites)](#3-shopee-domain-table-8-sites)
- [4. 1688 Domain Table (1 site)](#4-1688-domain-table-1-site)
- [5. Walmart Domain Table (1 site)](#5-walmart-domain-table-1-site)
- [5b. Temu Domain Table (2 sites)](#5b-temu-domain-table-2-sites)
- [5c. TikTok Domain Table (8 sites)](#5c-tiktok-domain-table-8-sites)
- [6. Common Response Structure](#6-common-response-structure)
- [6.1 Amazon / Shopee / Walmart — PascalCase](#61-amazon--shopee--walmart--pascalcase)
- [6.2 1688 / Temu / TikTok — PascalCase on success, camelCase on error](#62-1688--temu--tiktok--pascalcase-on-success-camelcase-on-error)
- [6.3 Common Field Description](#63-common-field-description)
- [7. Error Code Table](#7-error-code-table)
- [Amazon business error codes](#amazon-business-error-codes)
- [Shopee business error codes](#shopee-business-error-codes)
- [1688 business error codes](#1688-business-error-codes)
- [Walmart business error codes](#walmart-business-error-codes)
- [Temu business error codes](#temu-business-error-codes)
- [TikTok business error codes](#tiktok-business-error-codes)
- [8. Rate Limit and Concurrency Constraints (Common)](#8-rate-limit-and-concurrency-constraints-common)
- [9. How Each Endpoint Document References This File](#9-how-each-endpoint-document-references-this-file)

---

## 1. CLI Call Template

```bash
sorftime api <Endpoint> '<json-params>' --domain <N> --profile <name>
```

| Option | Description |
|------|------|
| `<Endpoint>` | Endpoint name, **case-sensitive**, use the PascalCase form as documented in each file in this directory (e.g. `ProductRequest`, `KeywordBatchSubscription`). Lowercase forms in the CLI README are only examples; actual requests must use PascalCase. |
| `<json-params>` | JSON string wrapped in single quotes. For endpoints with multiple parameters, non-required fields can be omitted; pass them as required per the endpoint document. |
| `--domain` | Site code (see the table below). Amazon 1-14, Shopee 201-208, Walmart 21, Temu 701/705, 1688 601, TikTok 301-312. **Omitting or passing an incorrect value directly returns 401/404**. |
| `--profile` | Profile name, corresponding to the auth config (containing the token and default domain) created by `sorftime add`. Optional; when omitted, uses the profile currently selected by `sorftime use`. |


**Profile management cheat sheet**:
```bash
sorftime add <profile-name> <api-key>          # Add profile-name
sorftime list                                  # List all profile-name
sorftime use <profile-name>                    # Switch default profile-name
sorftime whoami                                # View current profile-name
sorftime rm <profile-name>                     # Delete profile-name
```

---

## 2. Amazon Domain Table (14 sites)

| domain | Site | Country |
|--------|------|------|
| 1 | US | United States |
| 2 | UK | United Kingdom |
| 3 | DE | Germany |
| 4 | FR | France |
| 5 | IN | India |
| 6 | CA | Canada |
| 7 | JP | Japan |
| 8 | ES | Spain |
| 9 | IT | Italy |
| 10 | MX | Mexico |
| 11 | AE | United Arab Emirates |
| 12 | AU | Australia |
| 13 | BR | Brazil |
| 14 | SA | Saudi Arabia |

---

## 3. Shopee Domain Table (8 sites)

| domain | Site | Country/Region |
|--------|------|-----------|
| 201 | VN | Vietnam |
| 202 | ID | Indonesia |
| 203 | SG | Singapore |
| 204 | TH | Thailand |
| 205 | MY | Malaysia |
| 206 | TW | Taiwan, China |
| 207 | PH | Philippines |
| 208 | BR | Brazil |

---

## 4. 1688 Domain Table (1 site)

| domain | Site | Country |
|--------|------|------|
| 601 | 1688 | China (1688 sourcing platform) |

---

## 5. Walmart Domain Table (1 site)

| domain | Site | Country |
|--------|------|------|
| 21 | US | United States (Walmart currently opens only the US site) |

---

## 5b. Temu Domain Table (2 sites)

| domain | Site | Country |
|--------|------|------|
| 701 | US | United States |
| 705 | EU | Europe |

> **Note**: Temu does not provide a keyword module or any keyword-related endpoints.

---

## 5c. TikTok Domain Table (8 sites)

| domain | Site | Country |
|--------|------|------|
| 301 | US | United States |
| 303 | MY | Malaysia |
| 304 | PH | Philippines |
| 305 | VN | Vietnam |
| 306 | TH | Thailand |
| 307 | ID | Indonesia |
| 309 | GB | United Kingdom |
| 312 | JP | Japan |

> **Note**: AuthorRequest, VideoRequest, VideoTagSearch are limited to domain=301 (US site) only.

---

## 6. Common Response Structure

All endpoints return JSON uniformly. **Actual field naming varies by platform as follows**

### 6.1 Amazon / Shopee / Walmart — PascalCase

```json
{
  "RequestLeft": 1052670,
  "RequestConsumed": 5,
  "Code": 0,
  "Message": null,
  "Data": { ... }
}
```

- The Walmart response **additionally** includes a `RequestCount: 0` field (other platforms do not have this field).

### 6.2 1688 / Temu / TikTok — PascalCase on success, camelCase on error

Success response (e.g. `code=0`):
```json
{
  "RequestLeft": 1052670,
  "RequestConsumed": 5,
  "Code": 0,
  "Message": null,
  "Data": { ... }
}
```

Error / no-data response (e.g. `code=11`):
```json
{
  "code": 11,
  "message": "No data available"
}
```

- **Important**: When parsing, support both PascalCase (success) and camelCase (error) naming; case-insensitive access is recommended.

### 6.3 Common Field Description

| Field | Description |
|------|------|
| `RequestLeft` / `requestleft` | Remaining request count |
| `RequestConsumed` / `requestconsumed` | Requests consumed by this request |
| `RequestCount` (Walmart only) | Fixed at 0; meaning to be confirmed |
| `Code` / `code` | Business status code, **the only basis for judging success** (see error code table). `0` indicates success; non-zero means a business error. |
| `Message` / `message` | Status description; contains the specific reason on error. |
| `Data` / `data` | Business data; structure varies per endpoint. |

---

## 7. Error Code Table

### Amazon business error codes

| code | Meaning | Troubleshooting |
|------|------|---------|
| `0` | Execution succeeded | — |
| `4` | Insufficient credit balance | Top up credits or wait for next month's reset |
| `10` | Request parameters error | Check endpoint parameter format, type, and required fields |
| `11` | No data available | No data is returned under this condition; try adjusting parameters |
| `12` | Data already exists | Submitting duplicate data; no need to repeat |
| `13` | First-page review data does not exist | Use the ProductRealtimeReviews endpoint to collect reviews first |
| `14` | ASIN count exceeded | A single request supports up to 100 ASINs |
| `15` | ASIN query count exceeded | A single request supports up to 10 ASINs |
| `16` | Endpoint not supported | This site does not support this endpoint |
| `17` | ASIN collection count exceeded | A single request supports up to 30 ASINs for detail collection |
| `18` | Task detail query exceeded | A single request supports up to 20 task detail queries |
| `19` | Only sub-categories supported | Non-sub-categories are not supported for this query |
| `20` | Real-time data is being calculated | Please retry later |
| `21` | Some ASINs are being calculated | Some ASINs are still being calculated; please retry later |
| `22` | ASIN monitoring count exceeded | Stock monitoring only supports a single ASIN |
| `23` | Data beyond two years not supported | Data older than the last two years is currently not supported |
| `24` | Monthly query not supported | Monthly historical data queries are currently not supported |
| `106` | Data already exists (subscription) | Returns when re-subscribing to the same resource (verified: `ProductSellerSubscription` returns this when re-subscribing an already-subscribed ASIN) |
| `-1` | Execution failed | General error; see the message field for details |
| `97` | ASIN does not exist | Check whether the ASIN is correct |
| `98` | Collection failed | Retry later, or contact Sorftime support |
| `99` | Collecting | Real-time fetching in progress (about 5 minutes); please retry later |
| `400` | Unverified IP | Current IP is not in the whitelist |
| `401` | Endpoint not open | Check whether the endpoint name is correct, and whether the plan includes this endpoint |
| `402` | No permission to view this data | Check account permissions |
| `500` | Monthly request count limit reached | Wait for next month's reset or upgrade plan |
| `501` | Per-minute request limit reached | Lower the request frequency; retry in 1 minute |
| `502` | Daily request limit reached | Wait for next day's reset or upgrade plan |
| `503` | Task registration failed | Task volume at this time exceeded; try another time slot |
| `694` | Insufficient request remaining | Log in to your Sorftime account (open-intl.sorftime.com) to check or top up request credits |

---

### Shopee business error codes

| code | Meaning | Troubleshooting |
|------|------|---------|
| `0` | Execution succeeded | — |
| `4` | Insufficient credit balance | Top up credits or wait for next month's reset |
| `10` | Request parameters error | Check endpoint parameter format, type, and required fields |
| `11` | No data available | No data is returned under this condition; try adjusting parameters |
| `12` | Data already exists | Submitting duplicate data; no need to repeat |
| `13` | First-page review data does not exist | Use the ProductRealtimeReviews endpoint to collect reviews first |
| `14` | ASIN count exceeded | A single request supports up to 100 ASINs processed simultaneously |
| `15` | ASIN query count exceeded | A single request supports up to 10 ASINs queried simultaneously |
| `16` | Endpoint not supported | This endpoint is not supported on this site |
| `17` | ASIN collection count exceeded | A single request supports up to 30 ASINs for detail collection |
| `18` | Task detail query exceeded | A single request supports up to 20 task detail queries |
| `19` | Only sub-categories supported | Non-sub-category queries are currently not supported |
| `20` | Real-time data is being calculated | Please retry later |
| `21` | Some products are being calculated | Some products are being calculated; please retry later |
| `22` | Only single-product monitoring supported | Only single-product monitoring is supported |
| `23` | Data beyond two years not supported | Data older than the last two years is currently not supported |
| `-1` | Execution failed | General error; see the message field for details |
| `97` | Product does not exist | Check whether the ProductID is correct |
| `98` | Collection failed | Retry later, or contact Sorftime support |
| `99` | Collecting | Real-time fetching in progress; please retry later |
| `400` | Unverified IP | Current IP is not in the whitelist |
| `401` | Endpoint not open | Check whether the endpoint name is correct, and whether the plan includes this endpoint |
| `402` | No permission to view this data | Check account permissions |
| `500` | Monthly request count limit reached | Wait for next month's reset or upgrade plan |
| `501` | Per-minute request limit reached | Lower the request frequency; retry in 1 minute |
| `502` | Daily request limit reached | Wait for next day's reset or upgrade plan |
| `503` | Task registration failed | Task volume at this time exceeded; try another time slot |
| `694` | Insufficient request remaining | Log in to your Sorftime account (open-intl.sorftime.com) to check or top up request credits |
---

### 1688 business error codes

| code | Meaning | Troubleshooting |
|------|------|---------|
| `0` | Execution succeeded | — |
| `4` | Insufficient credit balance | Top up credits or wait for next month's reset |
| `10` | Request parameters error | Check endpoint parameter format, type, and required fields |
| `11` | No data available | No data is returned under this condition; try adjusting parameters |
| `-1` | Execution failed | General error; see the message field for details |
| `400` | Unverified IP | Current IP is not in the whitelist |
| `401` | Endpoint not open | Check whether the endpoint name is correct, and whether the plan includes this endpoint |
| `402` | No permission to view this data | Check account permissions |
| `500` | Monthly request count limit reached | Wait for next month's reset or upgrade plan |
| `501` | Per-minute request limit reached | Lower the request frequency; retry in 1 minute |
| `502` | Daily request limit reached | Wait for next day's reset or upgrade plan |
| `694` | Insufficient request remaining | Log in to your Sorftime account (open-intl.sorftime.com) to check or top up request credits |

---

### Walmart business error codes

| code | Meaning | Troubleshooting |
|------|------|---------|
| `0` | Execution succeeded | — |
| `4` | Insufficient credit balance | Top up credits or wait for next month's reset |
| `10` | Request parameters error | Check endpoint parameter format, type, and required fields |
| `11` | No data available | No data is returned under this condition; try adjusting parameters |
| `12` | Data already exists | Submitting duplicate data; no need to repeat |
| `13` | First-page review data does not exist | Use the ProductRealtimeReviews endpoint to collect reviews first |
| `14` | ASIN subscription exceeded | A single request supports up to 100 ASINs subscribed simultaneously |
| `15` | Request content not within signed validity period | Check whether the request is within the plan validity period |
| `20` | Real-time data is being calculated | Please retry later |
| `-1` | Execution failed | General error; see the message field for details |
| `97` | ASIN does not exist | Check whether the ASIN is correct |
| `98` | Collection failed | Retry later, or contact Sorftime support |
| `99` | Collecting | Real-time fetching in progress; please retry later |
| `400` | Unverified IP | Current IP is not in the whitelist |
| `401` | Endpoint not open | Check whether the endpoint name is correct, and whether the plan includes this endpoint |
| `402` | No permission to view this data | Check account permissions |
| `500` | Monthly request count limit reached | Wait for next month's reset or upgrade plan |
| `501` | Per-minute request limit reached | Lower the request frequency; retry in 1 minute |
| `502` | Daily request limit reached | Wait for next day's reset or upgrade plan |
| `694` | Insufficient request remaining | Log in to your Sorftime account (open-intl.sorftime.com) to check or top up request credits |
---

### Temu business error codes

| code | Meaning | Troubleshooting |
|------|------|---------|
| `0` | Execution succeeded | — |
| `4` | Insufficient credit balance | Top up credits or wait for next month's reset |
| `10` | Request parameters error | Check endpoint parameter format, type, and required fields |
| `11` | No data available | No data is returned under this condition; try adjusting parameters |
| `-1` | Execution failed | General error; see the message field for details |
| `97` | Product does not exist | Check whether the product ID is correct |
| `98` | Collection failed | Retry later, or contact Sorftime support |
| `99` | Collecting | Real-time fetching in progress; please retry later |
| `400` | Unverified IP | Current IP is not in the whitelist |
| `401` | Endpoint not open | Check whether the endpoint name is correct, and whether the plan includes this endpoint |
| `402` | No permission to view this data | Check account permissions |
| `500` | Monthly request count limit reached | Wait for next month's reset or upgrade plan |
| `501` | Per-minute request limit reached | Lower the request frequency; retry in 1 minute |
| `502` | Daily request limit reached | Wait for next day's reset or upgrade plan |
| `694` | Insufficient request remaining | Log in to your Sorftime account (open-intl.sorftime.com) to check or top up request credits |

---

### TikTok business error codes

| code | Meaning | Troubleshooting |
|------|------|---------|
| `0` | Execution succeeded | — |
| `9` | Resource access restricted | Check account permissions and IP whitelist |
| `10` | Request parameters error | Check endpoint parameter format, type, and required fields |
| `11 - 399` | Business-defined content | See the Message field for details |
| `400` | Unverified IP | Current IP is not in the whitelist |
| `401` | Endpoint not open | Check whether the endpoint name is correct, and whether the plan includes this endpoint (or the domain is not supported) |
| `500` | Monthly request count limit reached | Wait for next month's reset or upgrade plan |
| `501` | Per-minute request limit reached | Lower the request frequency; retry in 1 minute |

---

## 8. Rate Limit and Concurrency Constraints (Common)

| Dimension | Limit | Note |
|------|------|------|
| Single profile QPM | ≤ 200 | Exceeding 200 QPM will trigger a rate limit warning |

---

## 9. How Each Endpoint Document References This File

Each `resources/*.md` file's header should consistently include:

```markdown
> For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency. This document covers only parameters and fields unique to this category of endpoints.
```

---
