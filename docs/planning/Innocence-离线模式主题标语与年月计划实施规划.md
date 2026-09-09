---
schema_version: 1
document_type: feature_implementation_plan
project_name: "Innocence"
status: implemented_automated_verification_complete_manual_resize_pending
updated_at: "2026-09-09"
owner: "Innocence Product + Client + Server"
authority: "用户 2026-09-03 新功能决策"
supersedes:
  - "离线仅指已登录桌面端短暂断网的旧范围"
  - "长计划按周展示与编辑的旧定义"
  - "超长计划逐周浏览、按天拆解且不建立月级契约的旧定义"
  - "首页 Hero 使用单一固定标语的旧方案"
  - "无框窗口只依赖顶层 WM_NCHITTEST 即视为完成的旧验收假设"
related_documents:
  - docs/01-product-scope.md
  - docs/02-contract-and-compatibility-rules.md
  - docs/03-execution-plan.md
  - docs/06-contract-inventory.md
  - docs/07-dataflow-and-module-map.md
  - docs/08-project-profile.md
  - docs/planning/Innocence-MVP第一版功能范围.md
  - docs/planning/Innocence-接口清单草案.md
  - docs/planning/Innocence-数据库表结构草案.md
  - docs/planning/Innocence-UI设计规划.md
  - docs/planning/Innocence-Windows自适应桌面体验.md
  - docs/planning/Innocence-Windows信息架构与组件体系.md
---

# Innocence 离线模式、主题标语、年月计划与窗口缩放实施规划

## 1. 本轮目标与边界

本规划一次性固化四项后续开发工作：

1. 增加无需登录即可进入的离线模式；离线产生的数据先安全保存在本机，登录后经用户确认绑定到账户并同步。
2. 将首页 Hero 的固定标语改为四主题独立的艺术字与每日轮换文案。
3. 将计划体系明确为“短计划按日、长计划按月、超长计划按年”，并保留日计划模板跨日期套用。
4. 重新设计 Windows 无框窗口的八方向边框缩放链路，补足真实拖动验证。

本规划的代码阶段已于 2026-09-09 执行，并于 2026-09-10 补齐离线设置分级开放与认证页拖窗纠正：Flutter、Windows runner、Java 与 SQL 均已落地并通过自动化回归。用户已确认普通 Canvas 边框拖动与离线模式可用；完整 100%/125%/150% DPI 矩阵和纠正后的认证页拖窗仍需实机复验，不据此扩大人工验收结论。下方“当前实现审查结论”保留为实施前基线，用于解释本轮改动来源。

### 1.1 实施结果摘要（2026-09-09）

- 未登录 local profile、SQLite 本地业务表、ownerScope 隔离与 sync_outbox 已实现。
- 登录后先执行 metadata-only import-preview，再显示目标账号与冲突策略；确认前不上传业务正文。
- import 按实体依赖顺序逐项事务与幂等处理，accepted/rejected/conflict 分开返回；仅 accepted 标记本机 synced，本地原始业务数据保留。
- 四主题各 7 条首页标语按本地日期稳定轮换，并接入主题化艺术字与跨午夜刷新。
- 短计划保存后保持编辑；长计划为完整月历并支持日模板套用；超长计划为 12 月年历并支持月区间拖动、编辑、删除和四主题季节图案。
- Flutter 边缘命中层与 Windows 原生 sizing loop 已实现，自动化测试和 Windows Release 编译已通过并启动；真实鼠标拖边矩阵仍待人工验收。
- 离线模式可以进入系统设置，只展示语言、本机资料、桌面体验、外观和本机操作；联网分区不向离线用户开放，桌面偏好写入本机 SQLite。
- 认证页顶部拖动层已移到滚动内容之上，品牌展示区也可拖动；登录表单、主题按钮和窗口按钮继续保留独立交互。

## 2. 已确认的产品决策

| 编号 | 决策 |
|---|---|
| D-01 | 认证页提供“离线使用”入口；用户无需注册或登录即可进入 Canvas。 |
| D-02 | 离线模式不是伪造登录会话，不使用 0、负数或固定 userId 冒充服务端用户。 |
| D-03 | 离线产生的可用功能数据全部写入本地持久化存储；SharedPreferences 只保存轻量偏好和当前本地身份指针。 |
| D-04 | 好友、团队、私信、服务端通知、账号安全和后台等联网功能保留入口说明，但不可执行；点击时必须解释原因并提供登录入口。 |
| D-05 | 登录后先识别本机离线数据及目标账号，再由用户确认合并；禁止在用户不知情时把本地资料上传到刚登录的账号。 |
| D-06 | 短计划是单日 48 个半小时单元，保存后仍可继续进入编辑，不产生“保存即锁定”。 |
| D-07 | 长计划升级为完整月历；一次展示当前月所有日期，横向滑动切换前后月，日计划模板可套用到任意一天或多天。 |
| D-08 | 超长计划升级为年历；展示 12 个月，并按月为最小单位拖动创建或调整计划区间。 |
| D-09 | 超长计划采用独立的年度计划区间语义，不再伪装成逐周日计划，也不复用旧“逐周向未来”的页面定义。 |
| D-10 | 首页 Hero 按“主题 + 本地日期 + 语言”稳定选择文案；同一天重启不跳句，跨本地午夜自动进入下一句。 |
| D-11 | 四主题拥有不同的艺术字构图；主题切换只改变文案与视觉令牌，不清空页面、草稿或业务状态。 |
| D-12 | Windows 拖边修复必须通过真实八方向拖动验证；只有光标变化或静态代码存在不得宣称修复完成。 |
| D-13 | 离线设置页只开放本机可生效的语言、本机资料、桌面体验、外观和本机操作；隐私、通知、设备会话、后台管理与账号注销不显示给离线用户。 |
| D-14 | Windows 认证页顶部安全条和无按钮品牌区都可拖动窗口；拖动层必须位于页面内容之上，但不得覆盖登录表单、主题切换和窗口按钮。 |

## 3. 当前实现审查结论

### 3.1 离线能力差距

- SessionStatus 当前只有 initializing、unauthenticated、authenticated，没有离线身份。
- 应用根节点在未登录时只能进入 AuthPage，首页要求已登录资料且大量回调直接依赖 AppSession。
- AuthLocalStorage 当前只保存访问令牌、服务端 userId、设备槽位和设备 ID，不具备本地业务数据库。
- 当前依赖只有 SharedPreferences 等轻量组件，计划、专注、备忘录和统计没有本地仓储。
- SessionController 在恢复会话失败时会清除会话并退回登录页，无法区分“令牌失效”和“网络暂不可达”。
- 各 feature API 直接调用 ApiClient；SocketException 只转为普通 ApiException，没有可重试离线队列、幂等键或冲突状态。

结论：离线模式必须从身份状态、仓储接口和同步队列开始建设，不能只在登录按钮旁增加一个跳转按钮。

### 3.2 计划能力差距

- 客户端当前核心模型为 TodayPlan、WeekPlanOverview、WeeklyPlanTemplate。
- 服务端当前真实能力为按日读取/保存、按周汇总和所谓 weekly template；模板本质上保存的是一整天的短计划。
- 当前长计划页面以一周为单位，超长计划仍基于周数据向未来移动，与本次月历、年历要求不一致。
- 现有接口没有月汇总、年汇总或月级年度计划区间契约。

结论：保留成熟的单日计划编辑器，把周概览降为兼容/辅助能力；新增月汇总和年度区间模型。

### 3.3 首页标语差距

- 截图箭头所指 Hero 当前固定使用“今天，从一件事开始。”。
- 组件虽然已按四主题改变表面和字号，但标题文案、字形层级和装饰仍共享同一结构。
- 当前没有按日期稳定轮换、跨午夜更新或主题独立文案池。

### 3.4 Windows 边框拖动根因

当前代码已经存在 WS_THICKFRAME、WM_NCHITTEST、WM_SETCURSOR 和 14px 命中带，但仍有以下结构问题：

1. SetChildContent 将 Flutter 子 HWND 铺满整个客户区，鼠标位于可见边缘时可能先命中 Flutter 子窗口，顶层窗口的边缘判定不能作为唯一保障。
2. FlutterWindow::MessageHandler 先把消息交给 Flutter 引擎，只有引擎未返回结果时才进入 Win32Window::MessageHandler；框架级命中消息存在被提前消费的风险。
3. Flutter 层没有八方向透明缩放手柄，也没有 startWindowResize(edge) 原生通道；顶层命中失效后没有备用路径。
4. UpdateWindowFrame 修改窗口样式后不在函数内部强制触发 SWP_FRAMECHANGED，依赖后续定位调用顺带刷新，调用链脆弱。
5. 命中宽度使用固定逻辑值，未结合系统 resize frame、当前 DPI、最大化状态和边角优先级统一计算。
6. 现有自动化只检查大中小尺寸按钮和页面滚动，没有对真实原生窗口执行任一方向的尺寸拖动。

结论：旧“增大 WM_NCHITTEST 命中区即可”的方案被本规划覆盖。后续采用 Flutter 可见内容层负责接收边缘指针、原生层负责启动 Windows sizing loop 的明确链路，同时保留顶层原生命中作为系统级补充。

## 4. 离线模式详细方案

### 4.1 两种离线场景

| 场景 | 身份 | 数据范围 | 恢复联网后的行为 |
|---|---|---|---|
| 未登录离线模式 | 本机离线资料 local profile | 只读写该本地资料的数据，不读取任何历史账号缓存 | 登录后显示导入预览，经确认后合并到账户 |
| 已登录后断网 | 已绑定账户的本地镜像 account scope | 可读取该账户已缓存数据，并把本地修改写入待同步队列 | 网络恢复后自动重试，遇到业务冲突再要求用户决策 |

两个数据域必须由 ownerScope 隔离。未登录离线资料不得看到之前登录账号的缓存，账号 A 的缓存也不得在账号 B 登录后自动显示或上传。

### 4.2 应用状态模型

建议将“是否登录”和“是否联网”拆开，避免把网络状态塞进单一 SessionStatus：

- AccessMode：unauthenticated、offlineProfile、authenticated。
- ConnectivityState：unknown、online、offline。
- SyncState：idle、pending、syncing、conflict、failed。

页面可用性由 AccessMode 决定；顶部状态与重试行为由 ConnectivityState 和 SyncState 决定。网络断开不得自动清除有效登录令牌；只有服务端明确返回 401/会话撤销才进入会话失效流程。

### 4.3 本地数据模型

业务数据使用 SQLite 类本地数据库；具体 Dart 包在实施前按官方元数据核对后锁定版本。本规划不预先写死包版本。

本地表至少包括：

| 本地表 | 用途 |
|---|---|
| local_profile | 本机离线身份；保存随机 UUID、创建时间、可选本地昵称，不保存伪造服务端 userId。 |
| local_daily_plan / local_daily_plan_item | 任意日期的短计划与 48 段时间块。 |
| local_day_template / local_day_template_item | 从短计划保存的日模板。 |
| local_annual_segment | 年度计划区间；保存年份、起止月份、标题、颜色键和排序。 |
| local_focus_session / local_focus_event | 本地专注状态和不可重复上传的完成事件。 |
| local_memo / local_memo_item | 本地文本和清单备忘录。 |
| local_checkin_intent | 离线签到意图；只记录“待服务端校验”，不直接记为成功。 |
| sync_outbox | 待上传操作队列、幂等 operationId、重试次数和错误分类。 |
| sync_binding | 本地资料与服务端账号的绑定结果及最后同步游标。 |
| local_widget_setting | 当前离线资料的 Canvas/Focus Orb 本机偏好；不加入云端业务 outbox。 |

所有可同步实体统一携带：

- clientEntityId：客户端生成的 UUID，跨重试不变；
- ownerScope：local:profileUuid 或 account:userId；
- serverId：首次上传成功前为空；
- revision 与 updatedAtUtc：冲突比较和审计；
- syncState：localOnly、pending、syncing、synced、conflict、failedPermanent；
- deletedAtUtc：软删除墓碑，服务端确认后再清理。

访问令牌、密码、验证码、完整请求正文和邮箱不得写入 sync_outbox 或错误日志。

### 4.4 离线功能可用矩阵

| 模块 | 未登录离线 | 已登录断网 | 说明 |
|---|---|---|---|
| 首页 | 可用 | 可用 | 聚合本地计划、专注、备忘录和本地统计；联网摘要显示降级。 |
| 短/月/年计划 | 可用 | 可用 | 所有编辑先写本地事务，再入队同步。 |
| 专注计时 | 可用 | 可用 | 使用绝对开始/结束时间恢复，应用关闭或断网不丢计时。 |
| 备忘录 | 可用 | 可用 | 本地增删改；删除同步使用墓碑。 |
| 本地统计 | 可用 | 可用 | 从本地事件派生；服务端统计需联网后重新核对。 |
| 签到 | 待验证状态 | 待验证状态 | 可记录签到意图，但连续天数和成功结果必须由服务端验证。 |
| 外观、语言、窗口设置 | 可用 | 可用 | 本机偏好不依赖账号；可选择是否以后同步。 |
| 好友、团队、私信 | 不可用 | 只显示已缓存摘要或不可用 | 入口明确显示云端标记；禁止伪造发送成功。 |
| 通知、邀请、提醒 | 不可执行 | 缓存只读 | 处理动作必须联网。 |
| 账号资料、黑名单、设备会话 | 不可用 | 缓存只读 | 修改必须重新联网并通过鉴权。 |
| 管理后台 | 不可用 | 不可用 | 必须在线鉴权。 |

### 4.5 用户入口与提醒

认证页主操作下新增“离线使用”：

1. 第一次进入前展示一次说明：数据仅保存在本机、社交与云端功能不可用、登录后可选择同步。
2. 用户确认后创建本机离线资料并进入当前主题的 Canvas。
3. 顶部同步状态显示“离线模式 · 仅本机”，不能显示“状态已连接”。
4. 联网模块入口保持可发现，但带云端/锁定语义；点击后弹出主题化说明，提供“登录并同步”与“暂时离线使用”。
5. 同一会话内重复点击可使用轻提示，避免连续弹窗打扰。
6. 设置页在离线模式只展示语言、本机资料、桌面体验、外观和本机操作；联网分区直接从导航移除，并用页面提示说明登录后才能使用。
7. 离线桌面偏好写入 local_widget_setting 并立即应用到 Windows 壳；离开离线模式或重启后仍可恢复。

### 4.6 登录后的导入与同步

登录成功后按以下顺序处理：

1. 完成服务端认证并取得真实当前用户上下文。
2. 读取当前 local profile 的数据清单，不直接上传。
3. 拉取目标账号同步摘要，生成导入预览：实体数量、日期范围、冲突数量和预计上传内容。
4. 用户确认“合并到当前账号”；同时明确展示目标账号昵称/用户号，避免登录错账号。
5. 在本地事务中把待导入实体标记为 pending，但保留 local profile 原始数据，直到服务端逐条确认。
6. 按依赖顺序上传：日模板 → 日计划 → 年度区间 → 专注完成事件 → 备忘录 → 签到意图。
7. 服务端以 operationId/clientEntityId 幂等去重，返回 serverId、serverRevision 和 accepted/rejected/conflict 状态。
8. 客户端只对 accepted 项标记 synced；失败项保留并按指数退避重试。
9. 全部完成后把 local profile 标为已绑定归档；除非用户主动确认，不立即物理删除本地副本。

冲突规则：

- 同日期日计划：云端为空则直接导入；云端已有计划时提供“保留云端”“用离线计划覆盖”“把离线计划另存为模板”。
- 备忘录：clientEntityId 不同则并存；同一实体才按 revision/updatedAtUtc 处理最后修改覆盖。
- 专注记录：视为不可变事件，以 event UUID 去重后追加，不按时间覆盖。
- 年度计划区间：不同 clientEntityId 并存；同一实体按 revision 处理。
- 签到意图：先上传依赖的计划与专注记录，再由服务端重新校验；离线期间不得展示为成功签到。
- 永久失败（字段非法、权限拒绝、租户不匹配）停止自动重试并显示可操作原因；临时网络失败继续保留队列。

### 4.7 离线负向路径

- 未登录离线模式不得向任一需要 Bearer token 的接口发请求。
- 登录账号与已绑定账号不一致时不得自动合并，必须重新确认。
- 网络中途断开、应用崩溃或重复点击同步时不得重复创建服务端数据。
- 401 只影响账户同步，不得删除尚未绑定的本地资料。
- tenant mismatch、permission denied、missing field、generation/upload failure 都必须保留原始本地数据并给出安全提示。
- 日志只记录 operationId、实体类型、错误码和时间，不记录正文、个人身份、邮箱、令牌或计划内容。

## 5. 四主题首页标语与艺术字

### 5.1 轮换规则

- 文案单元包含 themeId、dayIndex、titleZh、titleEn、subtitleZh、subtitleEn。
- 每个主题首批 7 条；索引使用本地日期的稳定日序号对 7 取模，不使用每次构建随机数。
- 同一天切换主题时显示该主题同序号文案；切换语言时使用同一文案单元的对应语言。
- 应用跨午夜仍在运行时，于下一个本地 00:00 更新；系统日期回拨时重新计算但不写业务数据。
- 正在专注时，状态标题“此刻，保持专注”优先，不被每日标语覆盖；专注结束后恢复当日主题标语。
- Small Canvas 允许缩短副标题，但不可缩放整组艺术字造成溢出。

### 5.2 首批每日标语池

#### 侘寂禅意

侘寂中文界面也允许主标题使用英文艺术字，副标题仍按界面语言提供可读说明。

| 日序 | 主标题 |
|---|---|
| 1 | Begin with quiet. |
| 2 | One thing. Fully here. |
| 3 | Leave room for the day. |
| 4 | Slow is still forward. |
| 5 | Make space for what matters. |
| 6 | Let the noise fall away. |
| 7 | A gentle start is enough. |

固定副标题语气：中文“给重要的事，留一块安静的位置。”；英文“Leave quiet room for what matters.”

#### 极简主义

| 日序 | 中文主标题 | 英文界面 |
|---|---|---|
| 1 | 今天，只做重要的。 | Today, only what matters. |
| 2 | 少一点。完成多一点。 | Less noise. More done. |
| 3 | 清晰，然后开始。 | Get clear. Then begin. |
| 4 | 一件事，一个结果。 | One thing. One result. |
| 5 | 留白，也是安排。 | Space is part of the plan. |
| 6 | 把复杂留在门外。 | Leave complexity outside. |
| 7 | 现在，进入正题。 | Now, get to the point. |

固定副标题语气：中文“移除噪音，只保留下一步。”；英文“Remove noise. Keep the next action.”

#### 中世纪现代主义

| 日序 | 中文主标题 | 英文界面 |
|---|---|---|
| 1 | 把今天，设计得有趣一点。 | Design a brighter day. |
| 2 | 好状态，从一个大胆开场开始。 | A good day starts boldly. |
| 3 | 让计划有形，让进度有色。 | Give plans shape and progress color. |
| 4 | 今天也值得一场漂亮推进。 | Today deserves a beautiful move forward. |
| 5 | 给目标一条明快的轨道。 | Put your goal on a bright track. |
| 6 | 把灵感排进时间表。 | Put inspiration on the schedule. |
| 7 | 向前一点，就是好日子。 | One step forward makes a good day. |

固定副标题语气：中文“让计划、专注和进度组成今天的好设计。”；英文“Let plans, focus and progress shape the day.”

#### 玻璃态

| 日序 | 中文主标题 | 英文界面 |
|---|---|---|
| 1 | 进入今日轨道。 | Enter today’s orbit. |
| 2 | 让此刻聚焦，让进度发光。 | Focus the moment. Light the progress. |
| 3 | 点亮下一步。 | Light up the next step. |
| 4 | 把今天调到清晰频道。 | Tune today into focus. |
| 5 | 目标已上线，行动开始同步。 | Goal online. Action in sync. |
| 6 | 在光的层次里，看见推进。 | See progress through layers of light. |
| 7 | 连接当下，抵达下一刻。 | Connect now. Reach what comes next. |

固定副标题语气：中文“计划、专注与记录，在同一条光轨上推进。”；英文“Plans, focus and records move on one luminous track.”

### 5.3 艺术字与装饰规则

| 主题 | 标题排版 | 艺术装置 | 禁止项 |
|---|---|---|---|
| 侘寂 | 英文衬线/斜体，大字与小字错位，允许轻微缺口、墨印和不完全基线 | 纸纤维、淡刷痕、残缺圆印；动画只做低速淡入 | 霓虹、发光描边、强渐变、大圆角 |
| 极简 | 超大无衬线，细字重与粗体关键词对比，严格网格与极少行数 | 一条细线、页码式日序或小型黑色方点 | 纹理、复杂插画、阴影和装饰堆叠 |
| 中世纪现代 | 几何无衬线、错层色块、全大写小标签与乐观倾斜构图 | 星爆、圆盘、回旋镖或木质色条；每屏一个主锚点 | 玻璃模糊、赛博霓虹、过度写实图案 |
| 玻璃态 | 大号紧凑字重、半透明重影或细描边层，保持高对比 | 蓝紫光轨、轨道圆、低速粒子和柔光；减少动画时静止 | 绿色通用强调、低对比透明字、无休止高频闪烁 |

艺术字必须由主题令牌或可访问字体回退实现；装饰性图层不参与语义读取，屏幕阅读器只读一次完整标题。

## 6. 计划体系详细方案

### 6.1 统一语义

| 层级 | 时间单位 | 主视图 | 核心数据 |
|---|---|---|---|
| 短计划 | 半小时 / 日 | 单日 48 段时间轴 | DailyPlan + DailyPlanItem |
| 长计划 | 日 / 月 | 一个月完整日历 | MonthPlanOverview，日期单元仍引用 DailyPlan |
| 超长计划 | 月 / 年 | 12 个月年历与月区间轨道 | AnnualPlanSegment |

周概览保留为辅助摘要和旧接口兼容，不再定义为“长计划”的主页面。日计划模板统一称为 DayPlanTemplate；现有 weekly template 命名在代码迁移期通过 adapter 兼容，避免同时存在两套模板数据。

### 6.2 短计划：保存后继续编辑

1. 进入任意日期时读取该日已保存计划；无数据时显示空白 48 段时间轴。
2. 空白段拖动/点击创建计划；选择已有计划后拖动首尾修改，保持现有防重叠规则。
3. “保存当天计划”提交整日快照，并明确显示“已保存于 HH:mm”。
4. 保存成功后仍停留在编辑器，所有计划继续可选、改名、改时段、增删和调整完成状态。
5. 再次修改后显示“有未保存更改”；关闭、换日期、切月、切主题或切窗口层级不得静默丢失草稿。
6. 离线时保存到本地并显示“已保存到本机 · 待同步”；已登录联网时也先本地提交，再后台同步。
7. “保存为模板”复制当前日计划结构，不绑定当天日期和完成状态。

### 6.3 长计划：完整月历

布局与交互：

- 当前月显示 1 日到最后一日，按周一至周日排列；月外补位日期降低对比度且不计入“本月天数”。
- 横向左滑进入下一月，右滑进入上一月；同时保留键盘可达的上一月、回到本月、下一月按钮。
- Large 使用 7 列完整月历并可显示任务数、计划时长、完成度和模板标记。
- Medium 保留 7 列但减少单元格摘要；详情进入右侧抽屉或下方编辑器。
- Small 使用可读的紧凑月历，点击日期进入单日编辑；不得把 31 天压成不可点击的小点阵。
- 月份切换采用三页窗口缓存，只预取前月、当前月和后月；切换后释放远月详情，保留摘要缓存。

日期操作：

- 单击日期打开该日短计划；保存后回到月历立即回显摘要。
- 可以选择“套用日模板”，目标为当前日期或多选日期。
- 目标日已有计划时第一版必须选择覆盖、跳过或取消；不做不透明的自动字段合并。
- 支持从某日复制到一个或多个日期，复用模板/批量应用服务，不逐日发出无幂等保护的请求。
- 月历只聚合日计划，不复制日计划正文模型。

### 6.4 超长计划：12 月年历与月区间拖动

年历结构：

- 顶部固定年份、上一年、回到今年、下一年；主体直接展示 12 个月。
- Large 为 4×3 月卡，Medium 为 3×4 或 2×6，Small 为 1×12/2×6 可滚动布局。
- 每个月卡展示月级目标摘要、区间颜色和进入该月长计划的入口。
- 年历上方或选中详情中提供 12 段月轨道，交互沿用短计划的区间选择语言：在空白轨道拖动创建，选中已有区间后拖动首月/末月调整。
- 年度目标允许并行，因此不同计划可以覆盖同一月份；重叠目标分轨显示，不套用短计划“时间不可重叠”的业务限制。
- 起止月份均包含在区间内，最短 1 个月，不允许跨自然年；跨年目标拆为两个关联区间，避免单个年历状态复杂化。
- 点击月份进入对应长计划月历；月级目标与日计划相互引用但不自动展开成 30/31 条日任务。

AnnualPlanSegment 至少包含：

- id / clientEntityId；
- year；
- title；
- startMonth / endMonth（1 至 12）；
- colorKey；
- sortOrder；
- optional note；
- revision / updateTime。

### 6.5 四主题季节图案

年历/月轨道不得直接复用短计划时间轴的太阳/月亮图案，而改用春夏秋冬图案；短计划自身的昼夜时间轴仍保留太阳/月亮。季节图案不使用平台 emoji，统一用 CustomPainter 或项目内 SVG/矢量资源，保证不同机器一致。

| 主题 | 春 | 夏 | 秋 | 冬 |
|---|---|---|---|---|
| 侘寂 | 淡墨新芽与不完整圆印 | 亚麻纹竹叶/水纹 | 枯叶、陶土刷痕 | 裸枝、留白雪点 |
| 极简 | 单线嫩芽 | 实心圆与短射线 | 两片几何叶 | 四向细线雪晶 |
| 中世纪现代 | 橄榄绿有机叶片 | 芥末黄星爆太阳 | 橙红回旋叶与木质条 | 灰蓝原子式雪花 |
| 玻璃态 | 折射花瓣与青紫光点 | 蓝紫光环太阳 | 粉紫晶体叶片 | 冰蓝轨道与玻璃雪晶 |

规则：

- 图案只表达季节和主题，不承载唯一业务含义。
- 当前月份仍需文字、数字和可访问标签，不能只靠图案或颜色。
- 每个主题四季图案共用相同占位边界，切换主题不引起月卡跳动。
- 减少动画开启时停止漂浮、旋转和粒子，仅保留静态图案。

### 6.6 计划接口方向

在客户端实现前先固化以下契约：

| 接口 | 用途 |
|---|---|
| GET /api/app/v1/plans/month?month=YYYY-MM | 一次返回该月每天的摘要，不要求客户端拼接 4 至 6 次周请求。 |
| GET /api/app/v1/plans/year?year=YYYY | 返回 12 个月摘要和年度区间。 |
| POST /api/app/v1/plans/day-templates | 保存日计划模板。 |
| GET /api/app/v1/plans/day-templates | 获取日模板。 |
| POST /api/app/v1/plans/day-templates/{id}/apply-batch | 把模板幂等套用到一个或多个日期，显式提交 overwrite/skip 策略；取消发生在客户端提交前。 |
| POST /api/app/v1/plans/annual-segments | 创建年度月区间。 |
| PUT /api/app/v1/plans/annual-segments/{id} | 修改标题、起止月份、颜色或说明。 |
| DELETE /api/app/v1/plans/annual-segments/{id} | 删除年度区间。 |

现有 /week 与 /weekly-templates 路由在兼容期保留，但新页面不得把它们继续暴露为长计划的产品语义。所有写接口由服务端从 Bearer token 解析 userId，离线导入也不接受客户端 userId。

## 7. Windows 八方向缩放修复计划

### 7.1 最终事件链

1. Flutter Canvas/Auth 最外层 Stack 放置 DesktopResizeFrame。
2. DesktopResizeFrame 创建上、下、左、右和四角八个透明命中区；命中区仅覆盖边缘，不绘制可见黑框。
3. MouseRegion 显示对应的横向、纵向或对角光标。
4. 用户按下并开始拖动时调用 startWindowResize(edge)。
5. 原生层校验当前不是 Orb、不是最大化且具有 WS_THICKFRAME，然后 ReleaseCapture 并发送 WM_NCLBUTTONDOWN + 对应 HT 值，进入 Windows 原生 sizing loop。
6. WM_SIZE 调整 Flutter 子窗口并发布最终客户区；现有 DesktopPresentationTier 只响应尺寸，不参与原生拖动。
7. WM_EXITSIZEMOVE 后统一保存最终窗口边界，避免拖动过程高频写注册表。

### 7.2 原生层加固

- Win32Window 新增 BeginWindowResize(edge) 和统一 Edge → HT 常量映射。
- FlutterWindow 注册 startWindowResize 方法通道并对非法 edge 返回参数错误。
- WM_NCCALCSIZE、WM_NCHITTEST、WM_SETCURSOR、WM_GETMINMAXINFO 等框架消息先由窗口壳处理，避免被 Flutter 引擎提前消费。
- UpdateWindowFrame 每次修改 GWL_STYLE/GWL_EXSTYLE 后立即调用一次仅刷新 frame 的 SetWindowPos + SWP_FRAMECHANGED。
- 原生备用命中宽度基于 GetSystemMetricsForDpi 的 frame + padded border，并设置合理最小值；最大化和 Orb 返回 HTCLIENT。
- Flutter 子窗口继续铺满视觉画面；实际边缘手势由 DesktopResizeFrame 接收，不再依赖父 HWND 恰好收到鼠标消息。

### 7.3 命中区规则

- 边命中区建议 8 至 12 逻辑像素；角命中区建议 16 至 20 逻辑像素，最终以实机舒适度验收。
- 角优先于边，边优先于页面内容。
- 命中区不得遮挡顶部窗口按钮、滚动条或主要内容；必要时为窗口控制区预留排除矩形。
- Auth、Large、Medium、Small 都启用；Focus Orb、最大化和全屏状态禁用。
- 四主题只影响光标附近可选的轻量反馈，不改变命中范围。

### 7.4 缩放验收矩阵

自动化：

- Flutter widget test 验证八个 edge 映射、MouseCursor、Orb/最大化禁用和不遮挡窗口按钮。
- MethodChannel test 验证每个 edge 只发一次 startWindowResize，非法值不启动。
- Windows Release smoke script 获取真实窗口 RECT，分别拖动八方向后确认预期边发生变化、对边保持在容差内。

实机：

- 100%、125%、150% DPI；
- Auth、Large、Medium、Small；
- 左、右、上、下、左上、右上、左下、右下；
- 普通、最大化后恢复、多屏跨 DPI；
- 四主题、滚动页面、弹窗关闭后、尺寸预设后、Orb 恢复后；
- 检查方向光标、连续尺寸变化、最小尺寸、无黑边、无闪烁、路由/草稿/滚动/专注状态不丢失。

只有八方向 Release 实测全部通过，且记录命令、窗口前后 RECT 与失败路径，才能将“边框拖动已修复”写入完成检查点。

## 8. 分阶段实施顺序

### 阶段 A：契约与迁移准备

- 固化离线身份、同步导入、月汇总、年度区间和模板批量套用 DTO。
- 给服务端实体与本地实体补 clientEntityId、revision、updateTime 和幂等规则。
- 明确旧 weekly template 到 DayPlanTemplate 的兼容映射。
- 输出数据库迁移脚本和回滚说明，但不删除旧表/旧路由。

### 阶段 B：优先修复 Windows 拖边

- 实现 DesktopResizeFrame、startWindowResize 和原生 sizing loop。
- 先完成八方向自动化和 Release 实机矩阵，再继续叠加大型新页面，避免后续验收继续受窗口基础能力阻塞。

### 阶段 C：本地优先仓储

- 建立本地数据库、ownerScope、repository 接口和 sync_outbox。
- 将短计划、专注、备忘录、日模板、年度区间先迁移为“本地提交成功即 UI 成功”。
- 提供从当前内存/API-only 状态到本地镜像的单次迁移。

### 阶段 D：离线入口与功能裁剪

- 增加 offlineProfile 状态、认证页入口、离线顶部状态和联网功能拦截器。
- 完成首页、计划、专注、备忘录、本地统计、设置在无 AppSession 时运行。
- 完成离线签到意图的“待验证”表现。

### 阶段 E：登录导入与持续同步

- 实现导入预览、目标账户确认、冲突决策、分批幂等上传和断点续传。
- 覆盖登录错账号、部分成功、应用重启、401、权限拒绝和永久失败。

### 阶段 F：主题标语

- 建立 4×7 文案池和稳定日序算法。
- 为四主题实现独立 HeroTypography/Ornament 配置。
- 验证中文、英文、跨午夜、活动专注优先、Small 溢出和减少动画。

### 阶段 G：月历长计划与年历超长计划

- 先实现 MonthPlanOverview 与月汇总服务，再接月历 UI 和模板批量套用。
- 再实现 AnnualPlanSegment、年汇总和 12 月拖动轨道。
- 最后接入四主题季节图案、离线仓储和同步。

## 9. 预计代码影响范围

以下为本轮已经产生实际改动的主要代码范围：

- Flutter app：app.dart、session_controller.dart，新增 access/sync controllers。
- Flutter core：network、local database、repository、sync、DesktopResizeFrame、desktop_widget_bridge。
- Flutter features：auth、home、plans、focus、memos、stats、settings、friends/team/inbox 的能力门控。
- Windows runner：flutter_window.cpp、win32_window.cpp、win32_window.h。
- Server：auth/sync/plan 模块、DTO、service、mapper 和 schema migration。
- Tests：离线仓储/导入、月年计划、Hero 轮换、原生窗口缩放 smoke。

## 10. 完成定义

### 离线模式

- 无账号、无网络时可进入并完成计划、专注、备忘录和本地统计操作，重启后数据仍在。
- 联网功能每次都真实不可用且有明确原因，不出现假成功。
- 登录后可预览、确认、暂停和重试导入；目标账号、冲突与失败项可解释。
- 所有服务端读写继续绑定当前 token 用户，跨本地资料/跨账号数据不可见。

### 主题标语

- 四主题各 7 条，按日稳定轮换；同日重启不变化，跨午夜更新。
- 四主题艺术字构图明显不同，并在 Large/Medium/Small 中无溢出。
- 中文/英文、屏幕阅读器和减少动画通过。

### 计划

- 短计划保存后可以继续编辑，草稿和同步状态清晰。
- 长计划显示完整月份，滑动切月，模板可套用到一天或多天。
- 超长计划直接显示 12 个月，可按月拖动创建和调整年度区间。
- 四主题四季图案均可识别且不承担唯一语义。

### Windows 缩放

- 八方向在 Auth/Large/Medium/Small 与 100%/125%/150% DPI 下真实可拖动。
- 光标方向、最小尺寸、窗口记忆和断点重排正确。
- 无黑框、内容遮挡、状态丢失或“只有光标变化但窗口不动”的假通过。

## 11. 覆盖关系

本规划自 2026-09-08 起为上述四项需求的当前权威详稿：

- “桌面端临时离线后补传”继续保留，但只作为已登录断网场景；新增的未登录 offlineProfile 是同等正式入口。
- “长计划按周”改为“长计划按月”；周概览只保留兼容和辅助摘要。
- “超长计划按天/逐周”改为“超长计划按年、以月为区间单位”；旧“不新增超长计划独立契约”被明确覆盖。
- “首页固定一句标语”改为“四主题各 7 条按日轮换”。
- “顶层 WM_NCHITTEST + 14px 命中带即完成”改为“Flutter 八向边缘手势 + 原生 sizing loop + 顶层备用命中 + Release 实测”。

历史检查点和旧文档保留审计价值；若出现冲突，以本规划及 0040 决策检查点为准。
