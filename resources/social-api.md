# Social Media Endpoints (6)

**Endpoints in this file**: RedditPostSearch, RedditPostRequest, RedditCommentRequest, QuoraQuestionSearch, QuoraQuestionRequest, QuoraAnswerRequest

**Domains**: 801 = Reddit, 802 = Quora（2026-10-12 实测：803-810 均 404 未开放）

> **响应格式**：本族成功/错误均为 **camelCase**（与 1688/Temu/TikTok 同风格，见 `_common.md` §6.2）。
> **计费**（实测）：搜索类 5 credits/次，详情/列表类 1 credit/次。
> **MCP 双通道**：同一能力在 MCP 端点 `https://mcp.sorftime.com/social`（工具名 `reddit_*` / `quora_*`）也可用，适合 agent 直连；本文件面向 CLI 调用。

For common reference, see [`_common.md`](./_common.md): CLI call template, Domain table, error codes, response structure, rate limits & concurrency.

---

## Table of Contents

- [1. Reddit（domain=801）](#1-redditdomain801)
  - [1.1 Search Posts (RedditPostSearch)](#11-search-posts-redditpostsearch)
  - [1.2 Post Detail (RedditPostRequest)](#12-post-detail-redditpostrequest)
  - [1.3 Post Comments (RedditCommentRequest)](#13-post-comments-redditcommentrequest)
- [2. Quora（domain=802）](#2-quoradomain802)
  - [2.1 Search Questions (QuoraQuestionSearch)](#21-search-questions-quoraquestionsearch)
  - [2.2 Question Detail (QuoraQuestionRequest)](#22-question-detail-quoraquestionrequest)
  - [2.3 Question Answers (QuoraAnswerRequest)](#23-question-answers-quoraanswerrequest)
- [3. 舆情选品工作流](#3-舆情选品工作流)
- [Notes](#notes)

---

## 1. Reddit（domain=801）

### 1.1 Search Posts (RedditPostSearch)

- **Endpoint description**: Search Reddit posts by keyword (product / brand / problem descriptions; supports plain-language queries).
- **Requests consumed**: 5（实测）
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | SearchName | String | Yes | The keyword to search. E.g. yoga mat / Anker |
  | Page | Integer | No | Pagination (from 1) |

- **Usage example**（verified, returns real data）:
  ```bash
  sorftime api RedditPostSearch '{"SearchName": "yoga mat"}' --domain 801
  ```
- **Response data**: array of posts — verified fields `RedditId`（**t3_ 前缀，下游两件的串联键**）, `Subreddit`, `Author`, `PublishedTime`。

### 1.2 Post Detail (RedditPostRequest)

- **Endpoint description**: Fetch a post's full content and engagement.
- **Requests consumed**: 1（实测）
- **Request parameters**: `RedditId`（String, required — t3_ 前缀，from RedditPostSearch）
- **Usage example**:
  ```bash
  sorftime api RedditPostRequest '{"RedditId": "t3_1uzkbbn"}' --domain 801
  ```

### 1.3 Post Comments (RedditCommentRequest)

- **Endpoint description**: Fetch a post's comments, paginated.
- **Requests consumed**: 1（实测）
- **Request parameters**: `RedditId`（required, t3_ 前缀）+ `Page`（from 1）
- **Usage example**（verified）:
  ```bash
  sorftime api RedditCommentRequest '{"RedditId": "t3_1uzkbbn", "Page": 1}' --domain 801
  ```
- **Response data**: verified fields `ItemIndex`/`ItemTotal`, `CommentId`（t1_ 前缀）, `ParentCommentId`（空=顶层；非空=楼中楼，可重建评论树）。

---

## 2. Quora（domain=802）

### 2.1 Search Questions (QuoraQuestionSearch)

- **Endpoint description**: Search Quora questions by keyword.
- **Requests consumed**: 5（实测）
- **Request parameters**:

  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | SearchName | String | Yes | The keyword to search. E.g. anker |
  | Page | Integer | No | Pagination (from 1) |

- **Usage example**（verified, returns real data）:
  ```bash
  sorftime api QuoraQuestionSearch '{"SearchName": "anker"}' --domain 802
  ```
- **Response data**: array of questions — verified fields `QuoraId`（数字串，下游两件的串联键，无前缀）, `Title`。
- ⚠️ 实测观察：搜索结果相关性偏弱（部分返回高热度但主题不相关问题）——按热度非严格相关性排序的可能，筛选时自行过题干。

### 2.2 Question Detail (QuoraQuestionRequest)

- **Endpoint description**: Fetch a question's full content.
- **Requests consumed**: 1（实测）
- **Request parameters**: `QuoraId`（String, required — from QuoraQuestionSearch）
- **Usage example**（verified）:
  ```bash
  sorftime api QuoraQuestionRequest '{"QuoraId": "226959268"}' --domain 802
  ```

### 2.3 Question Answers (QuoraAnswerRequest)

- **Endpoint description**: Fetch a question's answers, paginated.
- **Requests consumed**: 1（实测）
- **Request parameters**: `QuoraId`（required）+ `Page`（from 1）
- **Usage example**（verified）:
  ```bash
  sorftime api QuoraAnswerRequest '{"QuoraId": "226959268", "Page": 1}' --domain 802
  ```
- **Response data**: verified fields `ItemIndex`/`ItemTotal`, `Author`, `AuthorCredential`（答主资历标识）。

---

## 3. 舆情选品工作流

```
Reddit 链路：RedditPostSearch（产品词/品牌词/痛点句式）
  → RedditPostRequest（正文+热度，确认讨论规模）
  → RedditCommentRequest（评论区痛点，ParentCommentId 可重建讨论树）
Quora 链路：QuoraQuestionSearch（产品词/品牌词，注意相关性过题干）
  → QuoraQuestionRequest（问题全文）
  → QuoraAnswerRequest（回答挖掘——问答平台的痛点表述比 Reddit 更长更具体）
```

产品词（如 "yoga mat"）看品类讨论与槽点；品牌词（如竞对品牌）看品牌舆情与未满足需求。

## Notes

- 搜索 5 credits、详情 1 credit：批量挖掘时先窄后宽（精准搜索词 → 少量详情），成本差 5 倍。
- 串联键区分：Reddit 用 `RedditId`（t3_ 前缀），Quora 用 `QuoraId`（纯数字）——两族不通用。
- 空参调用本族部分详情端点会返回 `Code: 0` + 空数据而非参数错误——不要依赖空参行为，始终带 ID。
