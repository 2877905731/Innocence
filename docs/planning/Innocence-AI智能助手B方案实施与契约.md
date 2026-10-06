---
schema_version: 1
document_type: implementation_scope_and_contract
project_name: "Innocence"
module: "智能助手（第16个产品模块）"
status: byok_chat_discovery_implemented_fixture_verified_live_provider_and_device_pending
updated_at: "2026-10-04"
decision: "DEC-0050 / 0090；DEC-0051 / 0092用户修正为BYOK聊天助手；DEC-0052 / 0093简化模型接入"
user_selection: "采用b方案"
selected_option: B
implementation_status: "多轮聊天、地址与密钥获取真实模型列表、选择模型并验证协议后加密保存、两协议及14项软件工具已实现；高级设置保留手动模型与协议。真实供应商/完整登录HTTP/同步/实体设备未验，月历批量重排及原任务编辑尚未接聊天工具。"
release_baseline: "v1.2.2+7；未改变现行离线发行与P01/G01"
comparison_document: docs/planning/Innocence-AI智能助手与自动化系统方案评审.md
---

# Innocence AI 智能助手 B 方案实施与契约

> 2026-10-04接入简化（DEC-0052/0093）：第13节覆盖第12节的手动完整端点/模型/协议主流程；现只填地址与Key、获取模型、选择并验证连接，高级设置保留手动入口。168项Flutter/analyze与双端开发构建通过；真实供应商和原生设备继续待验。

> 2026-10-04交互方向修正（DEC-0051/0092）：用户要求类似Codex Chat的内置对话助手，自行填写API Key，通过对话规划并操控软件。第12节覆盖冲突的“服务端专用密钥/固定三候选主入口/离线资料禁止模型读取”设计；第1–11节保留B1原方案与历史证据，0090/0091不可变。主入口已改为聊天，原本地排程保留为次级工具。真实模型与全部模块动作没有因此验收通过；当前配置与验收见`../development/AI对话助手配置与验收.md`。

## 1. 正式选择与模块目标

2026-10-04 用户明确选择：“采用b方案”。据此采用「指令式计划执行助手」，作为新增第16个产品模块，原有15个模块的封板结论保留。B的产品方向与功能范围确认；模块实现、接口回放、模型质量和发布验收尚未完成。

核心体验：用户用一句话表达目标或修改意图，助手读取当前允许的安排，生成候选计划，检查业务规则，展示差异，并把选定安排保存到真实计划系统。实际保存结果、执行记录与撤销形成闭环。

本次选择仅为B。A保留为比较材料；C的定时/事件规则、后台持续执行、自动顺延和通知策略没有被一并采用。供应商、API密钥、收费、语音、外部日历与发布版本没有由本次选择自动确定。

## 2. 范围与实施顺序

| 批次 | 范围 | 完成标准 |
|---|---|---|
| B1 日计划闭环 | 文字指令、相关单日安排、保守/均衡/紧凑候选、冲突/容量校验、无冲突新增、预览应用、实际结果、幂等和撤销 | 真实模型与本地规则分别验证；数据写入、重启、错误与冲突路径完整 |
| B2 月历与存档 | 多日期安排、存档新建/复用、已授权未开始任务重排、覆盖差异和逐项结果 | 日期/闰月、模板、批量失败/重试、双端同步及覆盖授权验证 |
| B3 年度任务拆解 | 独立年度任务、月份跨度与子任务生成；分别选择年度与日期安排 | 年度独立进度、自然年边界、子任务与日期任务分别保存验证 |

B1完成不能标记整个B完成。B1先支持新增本人单日任务，批量移动/覆盖和年度动作按B2/B3推进。查询和建议可覆盖更长日期范围，B1执行边界始终为一个明确日期。

所有批次遵守：日计划30分钟网格；完成/进行中任务保留；年度进度不由AI推断；签到仍由用户手动完成；已有业务数据绑定当前账号或本机ownerScope。

## 3. 用户操作与执行授权

1. 入口：「智能助手」工具入口、首页“帮我安排今天”、计划页“用AI规划”。
2. 输入指令；若目标、日期或可用时间缺失，仅追问会影响实际安排的条件。可带假设给建议，但保存所需条件必须完整。
3. 显示读取范围与数据时间，生成三套候选安排；无法满足目标时显示容量缺口和可选调整。
4. 用户选择候选、编辑任务，再查看新增/保留/修改的准确差异。
5. 点击“应用”后执行；在业务保存确认后展示结果、返回计划页和撤销。

“帮我规划”默认预览。明确的“直接新增到某日，不修改已有任务”允许在这次授权范围内执行无冲突新增，无须重复确认同一动作。授权与实际提案绑定，不能因模型声明“用户已同意”而跳过程序校验。

对直接执行，服务端使用用户原始指令和当前请求中的受限意图字段共同匹配：目标日期、允许动作add、现有任务保留、新增内容范围和数量/时段均可确定。模型只能建议，不能自行把建议模式升级为direct_add。条件不完整、提案超出授权或涉及覆盖时返回预览状态。用户点击应用可授权一个确定的提案版本与候选，不授权后续未知修改。

当前B1不实现删除原任务、修改完成状态、自动专注计时或代签。用户点击“开始专注”仍走原有专注动作和交互。

## 4. 内部模型与业务校验

### 4.1 内部对象

| 对象 | 最小字段与语义 |
|---|---|
| AssistantRequest | clientRequestId(UUID)、instruction、planDate、timeZone、generationMode、requestedExecutionMode；身份由可信会话/本机环境注入 |
| PlanSnapshot | planDate、dayRevision、planName、现有任务items、当前专注状态；由当前身份的业务查询取得 |
| AssistantProposal | proposalId(UUID)、proposalRevision(从1递增)、status、planDate、timeZone、sourceDayRevision、expiresAt、questions、assumptions、candidates |
| PlanCandidate | candidateId、intensity(conservative/balanced/compact)、items、diff、conflicts、capacity、explanation |
| ProposedTask | clientEntityId(UUID)、title、startSlot、endSlot；B1动作固定add，不能指定他人任务ID、completed或actualMinutes |
| Validation | validationId、proposalRevision、candidateId、sourceDayRevision、changesHash、expiresAt、canExecute、conflicts |
| ExecutionAuthorization | kind(preview_apply/direct_add)、绑定提案/候选/validationId、动作范围、目标日期、服务端核对的授权依据 |
| AssistantExecution | executionId、operationId、proposalId/revision、status、beforeRevision、afterRevision、actualChanges、undoEligibility、createdAt |

sourceDayRevision是服务端/本地仓储的权威修订号，不能信任模型或客户端自行生成。changesHash由程序对规范化差异生成，仅绑定授权，不能代替认证、版本和逐项业务校验。

### 4.2 B1硬性规则

- planDate必须明确为YYYY-MM-DD；首批执行限用户时区当天及之后30天内的单日，不写已过期日期。
- timeZone必须为有效时区标识；“今天/明天”按用户本次时区解析，日期与时区在预览和执行间固定。
- 0 ≤ startSlot < endSlot ≤ 48，单项最小30分钟；plannedMinutes由(endSlot-startSlot)×30计算，不由模型另行提供。
- 当天区间使用半开区间[startSlot,endSlot)，相邻任务可接续，重叠拒绝；与既有安排及其他新增任务全部比较。
- 标题非空且最多120个Unicode码点；一份候选最多48项；instruction非空且最多2000个Unicode码点，超限显式拒绝。
- 用户明确指定45分钟、跨午夜或范围超出B1时，先说明并提供可选拆分，不能舍入或静默扩大日期范围。
- 同时考虑已有有时段任务、用户指定不可用时间和当前专注；无时段任务展示为待分配工作量，不能假定它没有时间成本。
- 三种强度均遵守用户明确休息/睡眠约束。不可满足时status=no_solution，返回缺口；不能保证超出容量的目标。
- 新增任务completed=false、actualMinutes=0。模型不能提交学习成果或年度进度。

## 5. 在线模型与本机离线

在线账号使用服务端ModelProviderAdapter：供应商输出→严格结构校验→内部模型→规则排程。服务端仅发送本次指令和相关日期的必要任务/占用摘要；不自动附加聊天、全部备忘录或个人档案。用户可查看读取范围。

供应商通过服务端配置注入，密钥走环境变量或安全配置；没有配置时返回明确AI_NOT_CONFIGURED，不返回假生成结果。在线模型供应商与真实凭据尚未提供，不因此阻止内部模型、规则、UI和业务执行代码的建设；真实模型验收在配置后补齐。

本机离线使用LocalPlanningAdapter，按明确日期、已选任务、模板、可用时段和优先级确定性排程。界面标为“离线排程”，不冒充开放式语言模型。若输入超出规则能力，要求结构化补充或提示范围限制。

未登录本机资料不上云。已登录但选择本机离线路径时，云端模型也不可代读该ownerScope。离线导入仍先预览并确认目标账号，AI上下文发送不能借用同步导入授权。

Android现行v1.2.2仍是无INTERNET权限的本机离线正式包。B的在线架构纳入开发设计；联网Android客户端另按网络权限、认证/会话、数据发送与实体设备验收推进，采用B不等于立刻改变现行发行包或发布联网版本。

## 6. B1线上接口契约

### 6.1 共用约定

- 基址：开发环境http://localhost:8080；生产基址沿用App配置，本次不指定新地址。
- 前缀：/api/app/v1/assistant；JSON请求/响应，Content-Type: application/json。
- 认证：Bearer当前账号；X-Device-Id/X-Device-Type承接会话。拒绝X-User-Id、模型userId或客户端ownerScope作为服务端身份。
- 公共响应沿用code/message/data/requestId/serverTime，code=0成功；时间字段ISO8601，过期时刻用UTC，日历日期按固定timeZone解释。
- 相关ID为UUID字符串；版本整数≥0。未选择候选时candidateId不传；禁止空字符串代替缺值。
- 集合字段始终为数组，空结果为[]；status=needs_input时candidates=[]、questions非空；no_solution时解释容量缺口；非ready提案不可执行。
- B1不新增历史列表分页接口。单次状态查询不会返回其他用户记录；日志只记录ID、数量、结果和耗时，不存完整请求/凭据/邮件地址。
- 默认模型调用超时15秒、服务端生成预算20秒、客户端请求25秒，均可配置。生成前以clientRequestId登记请求，超时后按该ID查询结果，不能盲目新增一次计费调用。
- 提案与验证默认30分钟有效；执行前重新校验，不能把未过期视为数据没有变化。

### 6.2 接口表

| ID | 方法与路径 | 请求 | 成功data与副作用 |
|---|---|---|---|
| UAI-01 | POST /proposals | clientRequestId、instruction、planDate、timeZone、generationMode=model、requestedExecutionMode=suggest或direct_add；未知枚举拒绝 | requestStatus(pending/complete/failed)、proposal可空、failure可空；complete时proposal含4.1字段，ready/needs_input/no_solution；不写业务计划 |
| UAI-02 | GET /requests/{clientRequestId} | 无body/query，当前账号内查询 | 与UAI-01相同状态对象；供生成请求结果不明时查询 |
| UAI-03 | POST /proposals/{proposalId}/validate | proposalRevision、candidateId、editedItems(可省略，省略表示未改；不能传null) | editedItems存在时新建提案修订，返回proposalRevision及Validation；[]表示无新增，不是清空原计划；canExecute=false时冲突列表非空 |
| UAI-04 | POST /proposals/{proposalId}/execute | operationId、proposalRevision、candidateId、validationId、authorizationKind=preview_apply或direct_add | AssistantExecution；prepared/committed/rejected；只有committed表示业务写入；不调用模型 |
| UAI-05 | GET /executions/{executionId} | 无body/query | 当前账号的执行记录及可撤销条件；不重新执行 |
| UAI-06 | POST /executions/{executionId}/undo | operationId、expectedAfterRevision | 撤销执行记录undoExecutionId、status、newDayRevision、实际补偿变更；仅对应原执行，不能恢复覆盖后续修改 |

UAI-04的operationId同时作为可查询的executionId，UUID全程固定；因此调用超时也能使用UAI-05查结果。UAI-06的operationId同样作为撤销执行ID，重复撤销返回原结果。

UAI-01只创建提案，requestedExecutionMode=direct_add也不能在生成接口中暗中写入。客户端生成后调用validate，再调用execute完成显式直接新增链路；该链路可以不再弹第二次确认，但每一步均核对原始授权、当前身份与状态。

UAI-03 editedItems采用ProposedTask白名单结构，不允许客户端添加owner、completed、actualMinutes、任意路由或指令。重新编辑使旧validation失效。UAI-04只能执行当前提案版本且匹配的有效validation，不能接受一份任意模型JSON直接保存。

### 6.3 错误约定

保留已有公共错误码，不静默修改旧接口；助手新增分类作为data.reason，data.fieldErrors为可空数组。GlobalExceptionHandler当前没有此助手结构，实施时在助手路径兼容扩展，并补回放样本。

| HTTP / code | reason示例 | 行为 |
|---|---|---|
| 400 / 1001 | MISSING_FIELD、INVALID_SLOT、INVALID_ENUM、UNSUPPORTED_SCOPE | 不写业务；明确字段，不能自动补默认日期 |
| 401 / 2000 | AUTHENTICATION_REQUIRED | 不读写用户资料，不回退成离线另一身份 |
| 403 / 2001 | AUTHORIZATION_SCOPE_MISMATCH | 不执行；例如direct_add试图覆盖原任务 |
| 404 / 4004 | RESOURCE_NOT_FOUND | 资源不存在和属于其他账号统一404，避免跨用户存在性泄露 |
| 409 / 4101（新增） | STALE_PROPOSAL、STALE_DAY、IDEMPOTENCY_CONFLICT、UNDO_CONFLICT | 不覆盖；回到当前账号的新差异；同键不同内容拒绝 |
| 429 / 1002 | QUOTA_EXCEEDED、RATE_LIMITED | 返回Retry-After；不自动高频重试 |
| 503 / 9101（新增） | AI_NOT_CONFIGURED、MODEL_UNAVAILABLE、INVALID_MODEL_OUTPUT | 保留用户输入，不写业务，不泄露供应商正文或密钥 |
| 504 / 9102（新增） | GENERATION_TIMEOUT | 用UAI-02查结果，不能另生成新请求规避幂等 |
| 500 / 9000 | PERSISTENCE_FAILED | 回滚单日事务；结果不明时查执行，不误报已保存 |

状态查询不使用404代表保存失败；初始请求未落库与已拒绝分别返回不存在或记录中的rejected。网络失败本身不能判定服务器没执行。

## 7. 修订号、幂等、事务与撤销

### 7.1 现状与必须实施的兼容改造

已核对：TodayPlanResponse/Flutter TodayPlan尚无dayRevision；SaveTodayPlanRequest也没有baseRevision。StudyPlanService.saveTodayPlan会替换日计划条目，不能把当前接口当成已有稳定条目ID或并发撤销保证。

新增单日修订记录，以(userId,planDate)唯一键维护单调递增revision，空日期从0开始。所有日计划写路径（原UI保存、状态修改、模板套用、AI执行、导入及删除）必须在同一单日锁/事务中推进revision；删除日期也保留修订记录，防止旧提案误判为空白新数据。

助手获取快照、校验与执行共用该修订记录。旧客户端可继续原接口；新响应可增加dayRevision，但不得更改已有字段语义。所有旧写入口参与修订推进后，助手版本检查才算有效；只改助手接口不能通过并发门禁。

B1采用稳定实体保存适配器，对原任务保留ID、完成状态和实际时长，新增任务分配真实ID；不能用删除整日再插入的方式实现“仅新增”。这项适配器设计与旧SaveTodayPlan API的替换语义分别处理，兼容变化需记录。

### 7.2 执行约束

- 生成在数据库事务外，读取快照后记录sourceDayRevision；执行不再次调用模型。
- 幂等键为(owner,operationId)，同键同规范化请求返回原记录；同键不同请求409。
- prepared登记操作后，执行时锁定目标日期，重新校验账号、提案版本、授权、当前revision和专注状态。
- 业务变化、revision递增及committed结果在同一事务提交。发生异常回滚，失败状态另行可靠记录；进程在prepared后退出可按原ID恢复，不能凭TTL放行第二次写入。
- B1一个日期全有全无，空变更不创建计划也不增加revision；无变化结果明确返回actualChanges=[]。
- 在线请求由服务端执行并返回权威结果，客户端只刷新现有计划状态；不能再顺手调用原保存接口重复写入。

### 7.3 撤销约束

撤销检查当前dayRevision等于原执行afterRevision，且受影响任务没有进入专注。B1只删除本次新增且尚未变更的任务，并恢复本次修改的必要摘要；不能清空整日或删除原任务。

撤销也是新事务/新operationId，会生成更大的revision；不能把revision调回旧值或删除历史。后续改动、完成或专注状态变化均阻止盲目撤销；返回UNDO_CONFLICT并显示具体影响，不抹掉用户的新操作。

### 7.4 本机离线

本机单日修订、提案、执行和偏好全部按ownerScope隔离；业务写入、执行记录、修订和outbox在同一SQLite事务中完成。当前同步仅发送原业务类型变更，不自动上传聊天/助手历史。离线执行的成功是“保存在本机”，不能标记为云端已同步。

身份切换/退出后保留归属明确的历史，取消未执行提案上下文；旧ownerScope的validation不能在新身份下应用。本地修订与云端修订不是同一个计数器，不能互相比较或冒充；导入/同步后重新取服务器快照生成在线提案。

## 8. 数据模型与保留规则

以下为逻辑模型。2026-10-04 B1采用assistant_document复合主键(user_id,kind,document_id)承载request/proposal/validation/execution四类强类型文档；daily_plan_revision单独存储。SQLite v6采用local_assistant_document和local_day_revision；无偏好配置实现。schema.sql以CREATE IF NOT EXISTS初始化新表，SQLite v5→v6迁移不改旧任务内容。

| 模型 | 关键约束 |
|---|---|
| assistant_request | owner、clientRequestId唯一；状态、输入hash、提案ID、失效/失败；输入正文与必要上下文仅作业务存储，不进日志 |
| assistant_proposal | owner、proposalId、revision；候选/问题/假设、源日修订、有效期；用户编辑生成新修订 |
| assistant_validation | owner、validationId、提案修订/候选、源修订、changesHash、到期；旧修订不可复用 |
| assistant_execution | owner、operationId唯一；提案修订、before/after、实际变更、撤销关系、状态；源变更快照用于冲突检查 |
| daily_plan_revision | owner与日期唯一；所有写入口共用锁和单调修订；空计划/删除后记录仍保留 |
| 本地同类对象 | ownerScope分区，ID不能作为身份；与本地业务/outbox同事务 |

默认建议：未应用提案及原指令正文保留7天，用户可提前清除；执行详情与撤销依据保留30天，过期后仅保留最低限度的幂等结果和变更摘要，不保留任务正文。执行重试有效期为30天，超期operationId显式拒绝，不能把已清理记录当成从未执行。业务任务按原保留规则，不随聊天清除而删除。

注销账号按既有删除流程清除助手业务内容；最低审计/幂等保留期限在实现迁移前与项目账号治理规则核对。首版不推断永久偏好；用户明确保存的偏好单独存储并提供修改/清除入口。

## 9. 双端UI范围

共用三个页面职责：对话、计划提案、执行记录。B不显示自动化规则页或创建持续任务入口。

Windows入口位于工具区，首页与计划页有快捷入口；Large并排显示对话/提案/差异，Medium用详情抽屉，Small独立提案页。业务状态置于自适应Shell之上，缩放保留输入、候选、滚动和执行状态。Focus Orb承接原有专注显示与恢复行为。

Android从三点侧栏工具项进入助手；保持五个主入口。提案采用全屏详情，键盘上方输入操作可见，返回保留未应用草稿；支持两主题、中英文、大字体、屏幕阅读器与减少动画。

执行中不可重复应用；网络失败显示“结果待确认”，进入状态查询。生成失败保留指令与选择；保存失败保留提案。空安排显示可开始规划，缺数据明确标注，离线模式显式显示规则能力。

## 10. 开发入口与验收顺序

1. 内部模型/规则校验与供应商适配器；服务端请求/提案/验证/执行模型及本机对等模型。
2. 单日修订迁移与全部写路径接入，稳定实体新增适配器；先解决双端旧写入口导致的过期覆盖。
3. 在线与离线执行、幂等、实际结果、状态查询和撤销；契约回放与实际存储值核对。
4. Flutter assistant feature、三种画布与Android页面；接入现有会话/ownerScope/计划刷新。
5. 配置真实供应商并验证生成质量、费用控制与失败；完成双端运行、冷启动和同步子集证据后再确定发布版本。

必须覆盖：authentication_failure、tenant_mismatch、permission_denied、missing_field、generation_failure；另有冲突/容量不足、半小时与24:00、同键重试/异载荷、旧UI写后AI拒绝、超时结果不明、撤销冲突、切身份、本地事务回滚与outbox重放。

用合成任务和隔离账号，不向用户真实账号写验收任务。不把mock输出、宿主UI或纯代码审查标为真实模型、HTTP或实体手机证据。P01/G01、Android A0–A5与原有待验事项继续按各自门禁推进。

## 11. 本次落档结果

2026-10-04用户要求“开始实施方案”后，B1首批实现已落地：Spring六项端点、严格DTO与供应商适配器、当前账号/本机资料边界、三候选、编辑/校验、稳定新增、修订锁、prepared/committed/rejected、按原操作ID恢复查询、撤销与SQLite业务outbox，以及Windows工具区/首页/计划快捷入口和Android三点侧栏/手机详情。真实模型与设备验收未完成，不能将整个B模块或B1验收标为通过；后续B2月历与存档、B3年度拆解仍待开发。

首批实现细节与可复现命令见[AI助手本机开发与验收](../development/AI助手本机开发与验收.md)。本机离线支持“任务名 60分钟；另一任务 90分钟”及英文min；自然语言开放意图由已配置的云端模型处理。中文固定语法“直接新增 YYYY-MM-DD HH:MM-HH:MM 标题，保留已有任务”会在候选严格匹配后自动校验与保存；模型超出授权时保留预览。明确45分钟或非网格时刻会先澄清，不舍入。

供应商默认关闭；仅服务器环境变量配置地址/模型/密钥，客户端不持有模型密钥。生成上限为每账号4次/分钟和30次/24小时，已登记的相同请求不重复计次；供应商429另外保留。相同操作内容重复提交返回原结果，30天后的operationId返回410而非重新执行。执行未提交时登记prepared；异常回滚后单独记rejected，查询与同键恢复不创建第二次新增。

专注模型目前只保存taskName而无日任务ID，因此首批采用保守撤销保护：开始任何专注会使该身份下旧助手执行的撤销资格失效，并推进专注当日修订；结束专注不会恢复旧撤销授权。跨时区也不能借此删除已进入专注的任务。后续可在专注绑定稳定任务ID后收窄保护范围。

未应用文档7天清理；执行30天后移除正文，保留操作标识/最低幂等摘要并拒绝重新执行。SQLite恢复文档存储草稿和待确认ID，不存token或模型凭据；切换身份取消未执行直接意图，结果不明的已授权操作仍按原ID查询。助手历史不进入同步outbox，只有原daily_plan业务变更入队。注销账号删除对应助手内容。当前无独立偏好页或完整执行历史列表，后续纳入B2。

## 12. 用户修正：自带密钥的全局聊天助手

主入口改为多轮聊天。连接设置包含完整端点、模型名、协议（Chat Completions或Responses）、隐藏API Key、保存及测试连接。客户端直接连接用户指定服务；完整连接配置（含密钥）按当前账号/本机资料隔离，用Windows用户级DPAPI或Android Keystore加密后保存在本机，不进入Innocence服务器、Git、日志、聊天或同步。加密不可用时拒绝保存，没有明文兜底。无配置返回明确提示，不生成假回复。

“聊天”模式只发送对话；“操控软件”模式允许模型按需调用公开工具，界面明确说明对话及工具读取数据发往所选服务。软件数据是资料，不能授予权限。工具无userId/ownerScope字段，执行绑定可信身份；换身份/停止后不得开始新动作。模型请求写操作时先展示具体参数和影响；用户确认绑定该调用、身份和资料版本，再执行并反馈实际结果。被取消/不支持/冲突/失败的工具返回明确结果，模型不能自行授权。账号凭据、隐私/权限修改、签到、管理员处罚不向模型开放。

工具注册表覆盖页面导航、日/月/年度安排与存档、备忘录、专注、统计、通知与陪伴摘要、主题和语言。读操作仅返回相关字段；社交正文与其他敏感字段不自动打包上下文。写入经既有业务API/本机事务，不允许任意HTTP、SQL、文件、终端或模型生成代码执行。日计划新增继续用稳定ID、修订与幂等执行链。

新增线上契约UAI-07：POST /api/app/v1/assistant/client-proposals，Bearer当前账号，严格JSON {clientRequestId(UUID),planDate(YYYY-MM-DD),timeZone(IANA),sourceDayRevision(integer),items:[{clientEntityId(UUID),title,startSlot,endSlot}]}。服务端核对当前身份、日期/网格/冲突/修订，保存一份候选提案（不调用模型、不写计划）；相同请求ID同载荷返回原提案，异载荷409。字段与身份负向保持原共用规则。随后走validate/execute（preview_apply）/query/undo，不信任客户端执行成功声明。

首版聊天采用完整响应后展示，支持停止、多轮上下文、工具步骤与确认卡片；本机保存可见对话（当前身份分区），未完成写操作不在恢复后自动重试。模型工具协议按官方function calling文档适配，供应商支持范围需由用户实际配置验证。Android正式无INTERNET包仍不能联网；开发联网构建与已发布离线版本明确区分，不自动发布。

P01/G01、Android A0–A5与v1.2.2+7正式发行基线保留。此次为本机开发实现及构建，未发布新版本、未推送远端；模型质量、真实登录HTTP/跨端同步、Windows完整视觉矩阵和实体手机仍须独立验收。

## 13. 简化接入：地址与密钥发现模型（DEC-0052）

用户要求类似zcode，只提供API Key和链接即可自动检测可用模型。主设置改为服务地址、隐藏API Key、“获取模型”、模型选择和“保存并连接”；协议默认自动识别，手动模型及协议放入高级设置。地址可为服务根地址、带/v1或自定义前缀的API地址，也兼容旧完整/chat/completions、/responses、/models路径。明确展示实际识别结果，不自动改写用户指定的模型名称。

外部契约采用独立适配器：同一用户指定origin下GET {apiBase}/models，必要时仅对未声明版本的地址尝试{apiBase}/v1/models；Authorization: Bearer {用户密钥}，不重定向。仅HTTPS或loopback HTTP，拒绝URL凭据/query/fragment及含换行密钥。成功JSON要求data数组和非空字符串id，保留服务顺序/去重，可选name用于展示；不据列表宣布模型可调用或有工具权限。空列表/无有效id立即报告，绝不伪造模型。401/403/402/429和网络错误停止，不尝试其他供应商或域名；404/405或JSON列表外层不兼容才允许有限同origin路径回退。

选择模型后“保存并连接”只发送简短无软件工具/业务数据的验证请求，根据明确旧路径、同服务已保存协议及常见供应商优先级尝试Chat Completions或Responses；不从DeepSeek的anthropic_messages能力字段推断这两个协议。仅在协议/路径不兼容时有限回退，凭据/余额/限额/网络错误不回退。验证成功后保存最终端点/原始模型标识/协议与密钥至原生加密仓储；失败保留旧有效配置，输入留在当前对话框。模型列表仅当前设置会话使用，地址/密钥修改或身份变化立即失效；换身份/关闭设置/停止会取消请求，旧身份结果不得写入新身份。

没有/models接口的兼容服务可展开高级设置手动填写模型；模型名不自动猜测、不用固定过期目录替代。DeepSeek Chat Completions返回的reasoning_content在当前请求上下文内按官方要求回传，不显示、记录或保存到可见历史；恢复会话时若历史缺少该字段，则仅对DeepSeek官方Chat端点明确采用非思考模式完成工具交互，避免缺字段400。Responses仍回传完整output项。

配置旧数据无需迁移；仍以最终endpoint/model/protocol的原结构加密保存，重新进入可从endpoint还原服务地址。模型发现不调用Innocence后端，不新增业务接口、不改变owner/工具/执行规则，正式Android离线包仍禁止联网。官方来源：[DeepSeek模型列表](https://api-docs.deepseek.com/api/list-models/)、[DeepSeek思考模式](https://api-docs.deepseek.com/guides/thinking_mode/)、[OpenAI API认证与模型列表](https://developers.openai.com/api/reference/overview)。真实供应商列表和连接需用户在软件中配置后核验，本轮不读取或复制真实密钥。
