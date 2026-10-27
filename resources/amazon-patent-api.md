# Amazon Patent Endpoints (3)

> 2026-10-27 全链路实测（domain 1 / 2 / 7 均可——专利数据全局，与站点无关）
> 数据源：智慧芽（zhihuiya）图链。计费走积分（MCP 同工具标注：关键词搜 60 / 图搜 450 / 详情 150 积分每次；CLI 侧 `RequestConsumed=0`）

**Endpoints in this file**: PatentSearchFromKeyword, PatentSearchFromImage, PatentRequest

---

## 1. PatentSearchFromKeyword（关键词/公司/人名/公告号查专利）

- **Endpoint description**: 按关键词、公司名、人名、专利公告号/申请号检索专利；单页最多 30 条。用于竞品专利组合分析与侵权线索发现。
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Keyword | String | Yes | 检索内容（专利关键词 / 公司名 / 人名 / 公告号 / 申请号） |
  | PatentType | Integer[] | No | 专利类型：1=发明申请 2=发明授权 3=实用新型 4=外观设计 |
  | LegalStatus | Integer[] | No | 法律状态：1=失效 2=有效 3=审查中 4=PCT 失效 5=PCT 审查中 6=状态不明 |
  | Country | String[] | No | 受理局：`WO`(WIPO) `EP`(EPO) `CN` `EM`(EUIPO) `JP` `KR` `US` 等 |
  | Applicant | String | No | 申请人（公司/个人） |
  | PublicationNo | String | No | 公告号（如 `CN308683395S`） |
  | ApplicationNo | String | No | 申请号 |
  | ClassType | Integer | No | 分类体系：1=LOC（外观） 2=IPC（国际专利分类） |
  | ClassNo | **String** | No | 分类号，配 ClassType 使用。⚠️ **必须传字符串**（如 `"07-01"`）；传数组会静默返回空 |
  | PageIndex | Integer | No | 页码，默认 1 |
  | PageSize | Integer | No | 每页条数，**最大 30** |
- **Usage example**（实测有真数据）:
  ```bash
  sorftime api PatentSearchFromKeyword '{"keyword": "cup", "applicant": "武义泰祺硕杯业有限公司", "pageSize": 10}' --domain 1
  ```
- **Response data**: 数组，每条：`Photo`（专利图，**可能为 null**）/ `Title`（专利名）/ `PublicationNo`（公告号，下游 PatentRequest 的键）/ `Applicant` / `ApplicationDate` / `PublicationDate`

---

## 2. PatentSearchFromImage（图搜外观专利）

- **Endpoint description**: 以产品图检索外观设计专利，最多返回 100 条（按相似度）。上架前外观侵权排查的主力工具。
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | Image | String | Yes | 产品图：公开 URL 或 Base64（支持 `http(s)://`、`data:image/...;base64,`、裸 Base64）。建议产品占比 >80%、背景干净；jpg/png，<4M |
  | QueryMode | Integer | **实际必传** | 1=智能联想（推荐，适合杂乱背景/实物图，提取特征做综合检索）；2=以图搜图（按图案/形状/颜色匹配）。⚠️ **不传返回 `Data: null`（不是无结果）** |
  | Country | String[] | No | 受理局多选 |
  | LegalStatus | Integer[] | No | 法律状态（枚举同 §1） |
  | LocClassNo | String[] | No | LOC 外观分类，如 `["07-01","10-01"]` |
  | ProductKeyword | String | No | 产品词（逗号分隔），如 `cup,bottle` |
  | Applicant | String | No | 申请人过滤 |
- **Usage example**（实测有真数据，返回 100 条）:
  ```bash
  sorftime api PatentSearchFromImage '{"image": "https://m.media-amazon.com/images/I/71GZCWlJ6NL._AC_UY218_.jpg", "queryMode": 2, "country": ["CN"]}' --domain 1
  ```
- **Response data**: 数组，每条：`Photo` / `Title` / `PublicationNo` / `Applicant` / `ApplicationDate` / `PublicationDate` / **`Similarity`**（相似度）

---

## 3. PatentRequest（专利详情）

- **Endpoint description**: 按公告号取专利全量详情。同一公告号同账号**首次查询计费、后续免费**。
- **Request parameters**:
  | Parameter | Type | Required | Description |
  |------|------|------|------|
  | PublicationNo | String | Yes | 专利公告号（如 `CN308683395S`），从 §1/§2 的结果取 |
- **Usage example**（实测有真数据）:
  ```bash
  sorftime api PatentRequest '{"publicationNo": "CN308683395S"}' --domain 1
  ```
- **Response data**:
  - `Title` / `PublicationNo` / `PatentType`（4=外观设计）/ `Country`（如「中国(China)」）
  - `Inventor` / `Applicant`
  - `LocClassNo` / `IpcClassNo` / `CpcClassNo` / `GbcClassNo`（分类号数组）
  - `LegalStatus`（枚举同 §1）/ `ApplicationDate` / `PublicationDate` / `EstimatedExpiryDate`
  - `Photos`（专利图数组）

---

## 侵权排查工作流

```bash
# 1) 有产品图：图搜外观专利（相似度降序，最多 100 条）
sorftime api PatentSearchFromImage '{"image": "<产品图URL>", "queryMode": 2}' --domain 1
# 2) 有产品词/竞品公司：关键词 + 申请人组合
sorftime api PatentSearchFromKeyword '{"keyword": "yoga mat", "applicant": "<竞品公司>", "patentType": [4]}' --domain 1
# 3) 命中可疑公告号：查详情（法律状态/分类/到期日）
sorftime api PatentRequest '{"publicationNo": "<公告号>"}' --domain 1
```

> 判读：`LegalStatus=2`（有效）才需重点关注；`1` 失效；`3` 审查中；`4/5` PCT 阶段；`6` 状态不明（如实提示用户自行核实）。专利判读属法律风险提示，不做侵权法律结论。

## Notes

1. 专利数据全局，与 Amazon 站点无关：domain 1/2/7 实测均可（传任一站）。
2. `Photo` 可能为 null（部分专利无图）。
3. `ClassNo` 必须字符串；数组形式会静默返回空。
4. `PatentSearchFromImage` 不传 `QueryMode` 返回 `Data: null`——不是「无同款」。
