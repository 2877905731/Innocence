---
schema_version: 1
document_type: windows_information_architecture_and_component_system
project_name: "Innocence"
status: approved
implementation_status: p01_shell_foundation_implemented
updated_at: "2026-09-08"
approved_at: "2026-08-10T09:22:16+08:00"
owner: "Innocence UI"
depends_on:
  - docs/planning/Innocence-MVP第一版功能范围.md
  - docs/planning/Innocence-接口清单草案.md
  - docs/planning/Innocence-Windows自适应桌面体验.md
  - docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md
---

# Innocence Windows 信息架构与组件体系

## 1. 文档职责

本文固化 P00.5 的四项交付：

1. MVP 页面清单与页面职责；
2. Windows 用户端、管理端与 Focus Orb 的导航地图；
3. Large / Medium / Small / Focus Orb 的跨尺寸内容优先级；
4. Flutter `DesktopPresentationTier`、组件密度与主题映射接口；
5. 2026-09-08 新增的离线访问、日/月/年计划和主题化年度图案信息架构。

本文只定义 UI 信息架构和前端呈现契约，不新增或改名业务接口。接口与字段继续以 `Innocence-接口清单草案.md` 为准，移动端布局与导航另行设计。

当前状态为 `approved`：用户已于 2026-08-10 确认继续，G00.5 的 `page_inventory_approved` 已满足。

## 2. 信息架构原则

- 首页负责聚合与进入状态，不承担所有模块的完整编辑。
- “计划 → 专注 → 签到 → 统计”是个人主链路，任何 Canvas 层级都必须保持可达。
- 好友、团队和队友进度统一归入“陪伴”；私信、团队群聊、通知统一归入“收件箱”，共享未读状态。
- 备忘录是高频工具，但不与个人主链路争夺 Small 底部导航位置。
- 设置、个人资料和后台管理是工具入口；后台仅在管理员权限成立时出现。
- 同一业务详情只拥有一个语义页面 ID。Large 可把详情放进右侧上下文栏，Medium 可放进抽屉，Small 可推入下一页，但不得复制业务状态。
- 页面路由、筛选、草稿、滚动和计时状态位于自适应 Shell 之上；调整窗口只改变呈现，不改变用户所在业务位置。
- 主题可以改变首页构图、组件形状、排版、留白、材质和装饰，但不改变导航语义、页面可见性、业务功能、内容优先级或权限边界。

## 3. 顶层导航模型

### 3.1 用户端主工作区

| 顺序 | 导航 ID | 名称 | 职责 | Large / Medium | Small |
|---|---|---|---|---|
| 1 | `home` | 首页 | 当前专注、今日计划、签到与关键摘要 | 固定主导航 | 底部主导航 |
| 2 | `plans` | 计划 | 短计划（日）、任务存档架与长计划（月）、独立年度任务板（年）及失败记录 | 固定主导航 | 底部主导航 |
| 3 | `focus` | 专注 | 学习时段、番茄、当前会话与历史 | 固定主导航 | 底部主导航 |
| 4 | `companions` | 陪伴 | 好友、团队、队友进度与关系申请 | 固定主导航 | 从首页或顶部菜单进入 |
| 5 | `inbox` | 收件箱 | 私信、团队群聊、通知与未读处理 | 固定主导航 | 底部主导航 |
| 6 | `stats` | 统计 | 趋势、完成率、签到、失败与队友摘要 | 固定主导航 | 从首页或顶部菜单进入 |

### 3.2 工具入口

| 导航 ID | 名称 | 入口规则 |
|---|---|---|
| `memos` | 备忘录 | Large / Medium 导航轨底部；Small 从首页摘要或顶部菜单进入 |
| `settings` | 设置 | Large / Medium 导航轨底部；Small 从头像菜单进入 |
| `admin` | 管理后台 | 仅管理员显示；进入独立 Admin Shell，不混入普通用户页面层级 |

### 3.3 各窗口形态的导航呈现

| 形态 | 导航呈现 | 详情呈现 |
|---|---|---|
| Large Canvas | 左侧固定导航轨：6 个主工作区；底部放备忘录、设置和管理员入口 | 主区 + 右上下文栏，可形成列表 / 内容 / 详情三段式 |
| Medium Canvas | 64px 紧凑导航轨；空间不足时转顶部模块栏 | 主区 + 右抽屉或覆盖式编辑器，一次只突出一个主要任务 |
| Small Canvas | 底部 4 项：首页、计划、专注、收件箱；头像菜单承接其他入口 | 单列“列表 → 详情 → 返回”，复杂操作可提示扩大窗口 |
| Focus Orb | 无业务导航；单击恢复最近非 Orb 页面 | `72×72` 圆形，只显示专注进度环、剩余分钟/待机图标和最多一个未读点，颜色跟随当前主题 |

## 4. 导航地图

```text
启动
├─ 首次语言选择
├─ 启动与会话恢复
└─ 认证
   ├─ 密码登录
   ├─ 验证码登录
   ├─ 注册
   ├─ 找回 / 重置密码
   ├─ 同类型设备会话替换确认
   └─ 离线使用说明 → 本机离线资料 Canvas

用户 Canvas
├─ 首页
│  ├─ 今日计划快捷编辑
│  ├─ 专注开始 / 当前专注
│  ├─ 签到结果
│  └─ 统计、陪伴、备忘录摘要下钻
├─ 计划
│  ├─ 今日短计划
│  ├─ 长计划：完整月历
│  ├─ 超长计划：12 个月筛选与独立年度任务卡
│  ├─ 日计划模板
│  ├─ 周概览兼容辅助
│  └─ 计划失败记录
├─ 专注
│  ├─ 开始配置
│  ├─ 当前学习时段 / 番茄
│  ├─ 常用番茄配置
│  └─ 学习历史
├─ 陪伴
│  ├─ 好友列表、搜索、申请、资料、分组与黑名单
│  └─ 团队总览、创建 / 加入、成员、队友进度与邀请
├─ 收件箱
│  ├─ 私信会话与消息
│  ├─ 团队群聊
│  ├─ 通知中心
│  └─ 消息举报
├─ 统计
│  ├─ 总览与 7 / 30 天趋势
│  ├─ 计划 / 签到完成率
│  ├─ 失败摘要
│  └─ 队友摘要与提醒
├─ 备忘录
│  ├─ 卡片列表
│  └─ 文本 / 清单编辑
└─ 设置
   ├─ 账户资料
   ├─ 隐私与黑名单
   ├─ 通知
   ├─ 同步与桌面体验
   ├─ 本机数据、登录并同步、导出与清除
   ├─ 外观与四主题
   ├─ 关于、缓存与退出
   └─ 注销账号

管理员 Admin Shell
├─ 总览
├─ 用户管理与处罚记录
├─ 团队管理
├─ 公告与定向通知
├─ 举报、处理与复核
├─ 敏感词
└─ 审计记录

Focus Orb
├─ 单击：恢复最近 Canvas 页面
├─ 双击：开始 / 暂停专注
└─ 右键：恢复、开始 / 暂停、置顶、托盘、退出
```

团队群聊可以从“团队详情”进入，也可以从“收件箱”进入，但两处必须指向同一语义页面和同一会话状态。

## 5. 页面清单

### 5.1 启动与认证

| 页面 ID | 页面 / 表面 | 核心职责 | 主要数据或接口族 |
|---|---|---|---|
| `entry.language` | 首次语言选择 | 首次选择界面语言；完成后不重复打断 | 本地设置 |
| `entry.bootstrap` | 启动与会话恢复 | 初始化语言、AccessMode、连接状态、本机资料/账户缓存和错误恢复；未认证时不得请求受保护摘要 | 本地业务库；已登录后 `/sync/bootstrap` |
| `auth.login` | 登录中心 | 密码登录、验证码登录、注册与“离线使用”入口 | `/auth/**`；离线入口只访问本地仓储 |
| `auth.offlineIntro` | 离线使用说明 | 首次说明本机存储、联网功能限制和登录后可确认同步 | 本地设置、`local_profile` |
| `auth.offlineImport` | 本机数据导入确认 | 登录后展示目标账号、数量、日期范围和冲突，用户确认后才上传 | `/sync/import-preview`、`/sync/import` |
| `auth.passwordReset` | 找回 / 重置密码 | 发送验证码并设置新密码 | `/auth/password/**` |
| `auth.sessionConflict` | 设备会话替换确认 | 同类型设备超限时明确拒绝或替换 | `/auth/session/replace` |
| `auth.profileSetup` | 首次资料完善 | 注册后设置头像和昵称，可暂后处理 | `/account/profile`、头像上传 |

### 5.2 首页、计划、专注与签到

| 页面 ID | 页面 / 表面 | 核心职责 | 主要数据或接口族 |
|---|---|---|---|
| `home.overview` | 首页 | 聚合当前专注、今日计划、签到、趋势、队友和备忘录摘要；Hero 按主题与本地日期稳定轮换 | 在线 `/home/overview`；离线由本地仓储聚合 |
| `home.todayPlanEditor` | 今日计划快捷编辑 | 用固定可见的48段多色昼夜时间轴调整当天时间块；空白段新建、已有段拖动首尾，计划条联动后即可保存 | `/study/plans/today`、`/study/plans/{id}` |
| `home.checkIn` | 今日签到表面 | 展示条件、手动签到和结果，不做独立顶层导航 | `/check-in/today`、`/check-in/submit` |
| `plans.today` | 今日短计划 | 48段多色半小时时间轴、等量计划条、无重叠边界拖动、任务清单、直接保存、完成状态和“保存当前安排为任务存档” | `/study/plans/**` |
| `plans.month` | 长计划 / 月历 | 展示当前月全部日期与显式任务存档架；直接新建、编辑、删除存档并批量套用；横向滑动前后月和打开日期编辑 | `/study/plans/month?month`、`/study/plans/today?date`、任务存档批量套用 |
| `plans.year` | 超长计划 / 年度任务 | 吸顶的 12 个月按钮筛选独立年度任务；每卡以编辑月份为脉冲空框、0–100% 任务进度为框内填充，配对增减/直接完成、多子任务及右侧确认/编辑/删除 | `/study/plans/year?year`、`/study/plans/annual-segments/**` |
| `plans.templates` | 任务存档 | 从已保存短计划归档或从月历直接新建；浏览、编辑、删除和批量套用 | `/study/plans/day-templates/**` |
| `plans.weekCompatibility` | 周概览兼容辅助 | 承接已有周数据与迁移，不作为长计划主入口或新模型 | 旧 `/study/plans/week?anchorDate`、`/study/plans/weekly-templates` |
| `plans.failures` | 计划失败记录 | 低压力展示并支持手动删除 | `/study/plans/fail-records/**` |
| `focus.session` | 当前专注 | 设置结束时间、番茄配置、开始 / 暂停 / 结束与当前阶段 | `/focus/session/**` |
| `focus.presets` | 番茄配置 | 管理常用学习 / 休息组合 | `/focus/pomodoro/configs` |
| `focus.history` | 学习历史 | 按日期查看学习时段记录 | `/focus/session/history` |

### 5.3 陪伴与收件箱

| 页面 ID | 页面 / 表面 | 核心职责 | 主要数据或接口族 |
|---|---|---|---|
| `companions.friends` | 好友中心 | 好友列表、搜索、分组和关系操作 | `/friends/**`、`/users/search` |
| `companions.requests` | 关系申请 | 收到 / 发出的好友申请和团队邀请 | `/friends/requests/**`、`/teams/invitations/**` |
| `companions.profile` | 用户资料 | 权限裁剪后的资料、学习摘要和关系操作 | `/users/{id}/profile`、`study-summary` |
| `companions.team` | 团队工作区 | 团队总览、创建 / 加入、邀请码和成员管理 | `/teams/**` |
| `companions.teammateProgress` | 队友进度 | 今日计划完成度、学习时长和提醒 | `/teams/current/overview`、提醒接口 |
| `inbox.sessions` | 会话列表 | 私信、团队群聊和通知入口，统一未读状态 | `/chat/**`、`/unread/summary` |
| `inbox.privateChat` | 私信会话 | 好友间纯文字消息 | `/chat/private/**`、WebSocket |
| `inbox.teamChat` | 团队群聊 | 团队文字交流；与团队工作区共享会话状态 | `/chat/team/**`、WebSocket |
| `inbox.notifications` | 通知中心 | 30 天通知、已读和邀请直接处理 | `/notifications/**`、公告接口 |
| `inbox.reportMessage` | 举报消息表面 | 填写举报原因并提交；成功后返回原会话 | `/chat/messages/{id}/report` |

### 5.4 结果、工具与设置

| 页面 ID | 页面 / 表面 | 核心职责 | 主要数据或接口族 |
|---|---|---|---|
| `stats.overview` | 统计中心 | 关键指标、7 / 30 天趋势和双完成率 | `/stats/**` |
| `stats.failures` | 失败摘要 | 汇总计划和签到失败，不混用两者数据模型 | `/stats/failures`、两类失败记录 |
| `stats.teammates` | 队友摘要 | 轻量查看队友数据并提醒，不做排名 | `/stats/team/**` |
| `memos.list` | 备忘录 | 文本 / 清单卡片列表和快速新建 | `/memos` |
| `memos.editor` | 备忘录编辑 | 创建、编辑和直接删除；删除需确认 | `/memos/{id}` |
| `settings.account` | 账户资料 | 头像、昵称、用户号和基础资料 | `/account/profile` |
| `settings.privacy` | 隐私与黑名单 | 好友资料、队友学习权限和黑名单 | `/account/privacy`、`/account/blacklist` |
| `settings.notifications` | 通知设置 | 按渠道和类型控制通知 | `/settings/notifications` |
| `settings.syncDesktop` | 同步与桌面体验 | 同步状态、失败重试、本机数据查看/导出/清除、登录并同步、开机自启、置顶和 Orb 行为 | 本地仓储、`/sync/status`、`/sync/import*`、`/settings/widget` |
| `settings.appearance` | 外观 | 浅 / 深模式和四主题切换 | `/settings/appearance` |
| `settings.about` | 关于与缓存 | 版本、帮助、清理缓存和退出登录 | `/settings/cache/clear`、`/auth/logout` |
| `settings.cancelAccount` | 注销账号 | 验证、风险确认和不可逆注销 | `/account/cancel` |

### 5.5 管理后台

| 页面 ID | 页面 / 表面 | 核心职责 | 主要数据或接口族 |
|---|---|---|---|
| `admin.login` | 管理员登录 | 管理员独立鉴权 | `/api/admin/v1/auth/login` |
| `admin.dashboard` | 管理总览 | 用户、团队、待处理举报和通知摘要 | `/dashboard/**` |
| `admin.users` | 用户管理 | 查询、查看、禁言、封号和解除处罚 | `/users/**` |
| `admin.teams` | 团队管理 | 查询、移除成员和强制解散 | `/teams/**` |
| `admin.announcements` | 公告与定向通知 | 公告 CRUD、用户 / 团队定向通知 | `/announcements/**`、`/notifications/**` |
| `admin.reports` | 举报治理 | 列表、详情、处理、复核与违规内容删除 | `/reports/**`、`/content/team-chat/**` |
| `admin.sensitiveWords` | 敏感词 | 词条与替换 / 禁发策略管理 | `/sensitive-words/**` |
| `admin.audit` | 审计记录 | 展示处罚、举报和高风险操作轨迹 | 复用管理接口返回的审计记录；缺失时进入契约决策 |

### 5.6 共用状态表面

以下内容是共用状态，不建立独立主导航页面：

- 首次加载、空数据、未登录离线、已登录断网、待同步、同步中、冲突、同步失败；
- 未登录离线状态固定显示“离线模式 · 仅本机”，不得复用“状态已连接”；联网依赖入口点击后解释限制并提供登录入口；
- `401` 会话失效、`403` 权限拒绝、`404` 内容不存在、`409` 关系或设备冲突、`429` 操作过频；
- 删除好友、解散团队、封号、注销账号等高风险确认；
- 表单缺失字段、生成 / 上传失败、消息发送失败与安全拦截。

错误表面不得展示请求全文、邮箱、验证码、密码、Token 或其他用户数据。

## 6. 跨尺寸内容优先级

| 工作区 | `full`（Large） | `comfortable`（Medium） | `compact`（Small） | `glance`（Orb） |
|---|---|---|---|---|
| 首页 | 当前专注 + 今日计划 + 签到 + 趋势 + 陪伴 + 备忘录并列 | 当前专注与今日计划主导，其他为摘要 / 抽屉 | 当前专注、下一计划、今日完成度、一个主操作 | 专注进度、剩余时间、未读点 |
| 计划 | 日计划时间轴、带存档架的完整月历或独立年度任务板 | 日计划完整可编辑；月历保留存档直接套用；年度任务可筛选月份与编辑子任务 | 日计划保留48段和保存；月/年单列可滚动，保留新建、完成确认和编辑/删除入口 | 仅允许表达下一计划，不显示清单 |
| 专注 | 当前会话、阶段、配置、关联计划与历史上下文 | 当前会话 + 核心控制 + 可展开配置 | 计时、任务名、开始 / 暂停 / 结束 | 进度环、状态色、时间简写 |
| 陪伴 | 好友 / 团队列表 + 内容 + 资料三段式 | 列表 + 内容，资料进抽屉 | 列表与详情互相切换 | 不展示成员内容 |
| 收件箱 | 会话列表 + 消息 + 详情三段式 | 会话列表 + 消息，详情进抽屉 | 会话 / 通知列表与内容互相切换 | 最多一个未读点，不显示正文 |
| 统计 | 指标、趋势、失败和队友摘要工作台 | 指标 + 单图 + 摘要切换 | 关键数字 + 一张趋势图；复杂比较提示扩大 | 不展示统计页，仅复用当前专注进度 |
| 备忘录 | 卡片网格 + 编辑器并列 | 列表 / 网格 + 抽屉编辑 | 单列卡片与独立编辑页 | 不展示 |
| 设置 | 分组导航 + 表单并列 | 单栏表单 + 分组导航 | 设置列表 → 子页 | 仅右键菜单中的窗口级选项 |
| 管理后台 | 完整表格、筛选和详情上下文 | 单栏列表 + 详情抽屉 | 只读摘要与“扩大窗口继续”；高风险操作禁用 | 不展示 |

优先级降级顺序固定为：保留当前业务状态和主操作 → 收起上下文 → 减少摘要 → 将复杂编辑下钻 → 提示扩大窗口。禁止通过缩小字号、压缩点击区域或隐藏关键权限提示来换取空间。

## 7. Flutter 呈现接口

### 7.1 规范类型

```dart
enum DesktopWindowSurface {
  auth,
  canvas,
  orb,
}

enum DesktopPresentationTier {
  large,
  medium,
  small,
}

enum AppAccessMode {
  unauthenticated,
  offlineProfile,
  authenticated,
}

enum AppSyncState {
  idle,
  pending,
  syncing,
  conflict,
  failed,
}

enum ComponentPresentationDensity {
  full,
  comfortable,
  compact,
  glance,
}

enum NavigationPresentation {
  rail,
  compactRail,
  bottomBar,
  none,
}

@immutable
class DesktopPresentationSpec {
  const DesktopPresentationSpec({
    required this.surface,
    required this.tier,
    required this.defaultDensity,
    required this.navigation,
    required this.showContextPane,
    required this.reduceMotion,
  });

  final DesktopWindowSurface surface;
  final DesktopPresentationTier? tier;
  final ComponentPresentationDensity defaultDensity;
  final NavigationPresentation navigation;
  final bool showContextPane;
  final bool reduceMotion;
}
```

`Focus Orb` 是独立 `surface`，不是第四个 `DesktopPresentationTier`。这样 Canvas 的页面路由不会因为进入 Orb 而被解释成切换页面。

### 7.2 默认映射

| Surface / Tier | 默认组件密度 | 导航 | 上下文区 |
|---|---|---|---|
| `canvas + large` | `full` | `rail` | 固定右栏可用 |
| `canvas + medium` | `comfortable` | `compactRail`，空间不足可转顶部栏 | 抽屉 / 覆盖层 |
| `canvas + small` | `compact` | `bottomBar` | 独立下钻页 |
| `orb` | `glance` | `none` | 无 |

页面可以为局部组件显式传入更紧凑密度，例如 Large 右上下文栏中的计划摘要可使用 `comfortable`，但不得由叶子组件自行读取窗口宽度并改变业务语义。

### 7.3 层级解析与回滞

`DesktopPresentationPolicy.resolveTier` 只接受客户区逻辑尺寸和前一层级：

- 无前一层级时：`1180 × 720` 及以上为 Large，`760 × 620` 及以上为 Medium，其余合法尺寸为 Small；
- Medium 升 Large：宽高同时达到 `1180 × 720`；Large 降 Medium：宽或高低于 `1148 × 688`；
- Small 升 Medium：宽高同时达到 `760 × 620`；Medium 降 Small：宽或高低于 `728 × 588`；
- 客户区不得小于 `380 × 520`；宽而矮时按高度降级；
- 一次拖拽可跨越多个层级，但每次布局帧只发布最终稳定层级；
- 系统“减少动画”开启时取消跨层级补间，不取消状态保持。

### 7.4 组件接口规则

核心自适应组件统一采用以下输入边界：

```dart
class AdaptiveFeatureCard<T> extends StatelessWidget {
  const AdaptiveFeatureCard({
    super.key,
    required this.model,
    required this.density,
    required this.onPrimaryAction,
    this.onOpenDetails,
  });

  final T model;
  final ComponentPresentationDensity density;
  final VoidCallback onPrimaryAction;
  final VoidCallback? onOpenDetails;
}
```

- `model` 与回调在四种密度之间共享，不创建 `LargeXxxModel`、`SmallXxxModel`。
- 页面 / Shell 决定 `density`；业务叶子组件不得直接根据 `MediaQuery` 分叉接口调用。
- `full / comfortable / compact` 必须保留同一主操作；`glance` 只用于明确列入 Orb 白名单的状态组件。
- 核心白名单组件为：`FocusStatus`、`TodayPlanSummary`、`UnreadStatus`。只有 `FocusStatus` 和 `UnreadStatus` 可直接渲染 `glance`。
- 编辑器、聊天正文、用户资料、管理操作和危险操作没有 `glance` 版本。
- 稳定 `ValueKey` 至少包含语义页面 ID 与业务对象 ID，保证重排后草稿、滚动和选择状态可恢复。

### 7.5 页面状态归属

```text
AccessController（unauthenticated / offlineProfile / authenticated）
└─ LocalRepository + SyncOutbox（按 ownerScope 隔离）
   └─ SessionController / FeatureController（业务、连接与同步状态）
      └─ SemanticRouteState（当前页面、详情对象、筛选、草稿引用）
         └─ AdaptiveCanvasShell（Large / Medium / Small 编排）
            └─ AdaptiveFeatureComponent（full / comfortable / compact）

OrbWindow
└─ 订阅同一 Focus / Unread 状态，只保存 Orb 位置与窗口级偏好
```

跨层级切换不得重新创建业务 Controller。进入 Orb 时保存最近非 Orb 的语义页面、窗口尺寸、位置和滚动恢复键；恢复时回到原页面，而不是固定返回首页。切换主题、联网状态变化或登录导入也不得无条件销毁本机草稿；ownerScope 变更必须经过导入/切换流程。

## 8. 主题映射契约

### 8.1 结构令牌与视觉令牌分离

以下结构令牌由自适应系统统一管理，不允许主题覆盖：

- Large / Medium / Small 断点和 `32px` 回滞；
- 导航位置、页面可见性、内容优先级和最小点击区域；
- 网格列数、上下文栏职责、Small 底部 4 项顺序；
- 权限、错误、空状态和危险操作确认。

主题通过 `ThemeExtension<InnocenceThemeTokens>` 提供：

- `colors`：背景、表面、文字、强调、成功、警告、危险和状态色；
- `surface`：不透明度、模糊、边框、阴影和材质；
- `shape`：圆角、直角、线宽与局部装饰形状；
- `typography`：字体家族、字重、字距和艺术标题策略；
- `motion`：进入、切换、反馈时长与曲线；
- `ornament`：纹理、几何、光效和装饰密度；
- `orb`：主表面色、进度色、状态色与壁纸对比保护。

### 8.2 四主题跨形态映射

| 主题 ID | Canvas 主表达 | Small 降噪 | Orb 表达 |
|---|---|---|---|
| `wabiSabi` | 暖灰米色、自然留白、直角无框纯色色块、大胆艺术字；禁用渐变、玻璃态、强阴影和大圆角 | 减少艺术标题尺寸与装饰，只保留暖灰米色层级和直角关系 | 实色暖灰表面 + 克制强调色进度 + 清晰状态点 |
| `minimalism`（兼容键） | 灰白编辑网格、薰衣草紫与珊瑚柔彩叠层、圆角看板、细线图表和轻阴影 | 单列重排，只保留一处主色形块；卡片与文字层级不丢失 | 灰白真圆表面 + 薰衣草紫进度 + 业务状态点 |
| `midCenturyModern` | 暖米色、木质色、橙红、芥末黄、橄榄绿、有机几何与非对称网格 | 每屏最多保留一个低干扰几何装饰，优先保证正文和操作 | 深棕或暖米实色表面 + 橙红进度 + 橄榄绿状态 |
| `glassmorphism` | 蓝紫粉空间渐变、动态光团/微粒、分级玻璃、半透明描边、柔和阴影与悬停发光；Large 完整展示美学 | 减少粒子和嵌套层数，主操作保持高对比 | 单一高对比半透明 / 实色表面；不依赖壁纸模糊保证可读性 |

同一页面切换主题时只替换 `InnocenceThemeTokens`，不得重建路由、清空输入或切换 `DesktopPresentationTier`。

年度任务板用文字/数字月份按钮与彩色跨度条承载时间语义；春夏秋冬图案可以在辅助位置作为 `ornament`，但不再生成旧式季节月卡，也不得替代月份文字、选择状态或完成确认。

## 9. 关键交互与权限边界

- 非好友不可进入私信会话；非队友不可查看队友学习摘要；被拉黑关系的资料和互动入口必须在服务端拒绝后给出安全错误表面。
- 未登录离线资料中，好友、团队、私信、云端通知处理、账号资料、安全设置和管理后台保留可发现说明但不可执行；不得构造临时账号或显示假成功。
- 从离线资料登录后，只有导入确认表面可以改变 ownerScope；切换到其他账号、权限拒绝或同步失败不得删除本机原始数据。
- 未登录离线资料不可执行好友、团队、私信、云端通知处理、账号安全或后台操作；入口可以保留可发现性，但必须说明需要登录且不得显示伪成功状态。
- 登录后发现本机离线资料时先展示导入预览和目标账号；确认前不上传，账号不一致时停止自动合并。
- 团队成员移除与解散仅对队长显示；后台入口仅对管理员显示，不能只靠前端隐藏代替服务端鉴权。
- 通知中的好友申请和团队邀请允许直接同意 / 拒绝，处理后同步更新陪伴页状态。
- 删除好友会删除历史私信；解散团队会删除团队交流数据；注销账号不可逆，均需明确二次确认。
- WebSocket 断开时，收件箱显示降级状态并回退 REST 拉取 + 系统通知，不伪装为实时在线。
- `/home/widget` 继续作为 Small / Orb 的轻量摘要来源，不约束客户端实现为旧固定挂件。

## 10. P00.5 验收矩阵

| 验收项 | 通过条件 |
|---|---|
| 页面覆盖 | MVP 账户、同步、好友、团队、交流、计划、专注、签到、统计、通知、备忘录、设置、首页、治理均有明确入口或状态表面 |
| 离线访问 | 未登录可进入隔离的本机 Canvas；可用功能持久化，联网功能明确受限；登录后先预览并确认目标账号再导入 |
| 计划层级 | 短计划保存后可编辑并归档；长计划为带显式存档架的完整月历；超长计划为独立年度任务板，含月份筛选、动态跨度条与多子任务 |
| 导航一致 | Large / Medium / Small 指向相同语义页面；Small 仅重组入口，不删业务 |
| 密度接口 | 三档 Canvas 和 Orb 有明确类型、默认映射与组件白名单 |
| 状态连续 | 页面、详情、筛选、草稿、滚动和计时的归属高于 Shell |
| 主题隔离 | 四主题不覆盖断点、导航、权限和功能可见性 |
| 契约兼容 | 未新增接口；`/home/overview` 与 `/home/widget` 职责保持不变 |
| 负向路径 | 会话失效、越权、权限拒绝、缺字段、同步 / 发送 / 上传失败均有安全表面 |
| 离线边界 | 未登录可进入本机 Canvas 并重启恢复；联网依赖操作被真实阻止；目标账号未确认前没有业务正文上传 |
| 计划层级 | 短计划保存后可编辑并归档；长计划可滑动、可管理和批量套用任务存档；超长计划独立于长计划，可管理年度任务及子任务；旧周视图仅兼容 |
| 用户确认 | 已确认；文档状态为 `approved` |

## 11. 后续实施顺序

1. P01 首批已实现认证入口、语义导航、自适应主 Shell 与 Focus Orb；继续资料、隐私和设置页面；
2. P01-P04 每重建一个页面，同时实现 `full / comfortable / compact`，不得留到 P05 补响应式；
3. P05 在当前原生 `canvas / orb` 基础上完善边缘吸附、托盘、置顶和安全状态持久化；Canvas 首次按工作区比例居中进入 Large，之后恢复用户最后一次有效尺寸与位置；
4. P06 按尺寸、DPI、多屏、四主题和权限负向路径完成矩阵验收。
