---
schema_version: 1
document_type: windows_information_architecture_and_component_system
project_name: "Innocence"
status: approved
implementation_status: p01_shell_foundation_implemented
updated_at: "2026-08-10"
approved_at: "2026-08-10T09:22:16+08:00"
owner: "Innocence UI"
depends_on:
  - docs/planning/Innocence-MVP第一版功能范围.md
  - docs/planning/Innocence-接口清单草案.md
  - docs/planning/Innocence-Windows自适应桌面体验.md
---

# Innocence Windows 信息架构与组件体系

## 1. 文档职责

本文固化 P00.5 的四项交付：

1. MVP 页面清单与页面职责；
2. Windows 用户端、管理端与 Focus Orb 的导航地图；
3. Large / Medium / Small / Focus Orb 的跨尺寸内容优先级；
4. Flutter `DesktopPresentationTier`、组件密度与主题映射接口。

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
- 主题只改变视觉令牌，不改变导航、页面可见性、功能顺序或权限边界。

## 3. 顶层导航模型

### 3.1 用户端主工作区

| 顺序 | 导航 ID | 名称 | 职责 | Large / Medium | Small |
|---|---|---|---|---|
| 1 | `home` | 首页 | 当前专注、今日计划、签到与关键摘要 | 固定主导航 | 底部主导航 |
| 2 | `plans` | 计划 | 短计划、周计划、超长计划、模板与失败记录 | 固定主导航 | 底部主导航 |
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
| Focus Orb | 无业务导航；单击恢复最近非 Orb 页面 | 只显示专注进度、状态和最多一个未读点 |

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
   └─ 同类型设备会话替换确认

用户 Canvas
├─ 首页
│  ├─ 今日计划快捷编辑
│  ├─ 专注开始 / 当前专注
│  ├─ 签到结果
│  └─ 统计、陪伴、备忘录摘要下钻
├─ 计划
│  ├─ 今日短计划
│  ├─ 周计划
│  ├─ 超长计划
│  ├─ 日计划模板
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
| `entry.bootstrap` | 启动与会话恢复 | 初始化语言、会话、同步摘要和错误恢复 | `/sync/bootstrap`、当前会话 |
| `auth.login` | 登录中心 | 密码登录、验证码登录和注册三种模式 | `/auth/**` |
| `auth.passwordReset` | 找回 / 重置密码 | 发送验证码并设置新密码 | `/auth/password/**` |
| `auth.sessionConflict` | 设备会话替换确认 | 同类型设备超限时明确拒绝或替换 | `/auth/session/replace` |
| `auth.profileSetup` | 首次资料完善 | 注册后设置头像和昵称，可暂后处理 | `/account/profile`、头像上传 |

### 5.2 首页、计划、专注与签到

| 页面 ID | 页面 / 表面 | 核心职责 | 主要数据或接口族 |
|---|---|---|---|
| `home.overview` | 首页 | 聚合当前专注、今日计划、签到、趋势、队友和备忘录摘要 | `/home/overview` |
| `home.todayPlanEditor` | 今日计划快捷编辑 | 从首页快速调整当天时间块和任务 | `/study/plans/today`、`/study/plans/{id}` |
| `home.checkIn` | 今日签到表面 | 展示条件、手动签到和结果，不做独立顶层导航 | `/check-in/today`、`/check-in/submit` |
| `plans.today` | 今日短计划 | 半小时时间块、任务清单和完成状态 | `/study/plans/**` |
| `plans.week` | 周计划 | 一周安排、复制、模板套用和跨日编辑 | `/study/plans/calendar`、模板接口 |
| `plans.longTerm` | 超长计划 | 按天组织长期目标和多层级进度 | `/study/plans/**`，`planType=ultra` |
| `plans.templates` | 日计划模板 | 保存、浏览、套用和删除模板 | `/study/plans/templates/**` |
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
| `settings.syncDesktop` | 同步与桌面体验 | 同步状态、失败重试、开机自启、置顶和 Orb 行为 | `/sync/status`、`/settings/widget` |
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

- 首次加载、空数据、离线、同步中、同步失败；
- `401` 会话失效、`403` 权限拒绝、`404` 内容不存在、`409` 关系或设备冲突、`429` 操作过频；
- 删除好友、解散团队、封号、注销账号等高风险确认；
- 表单缺失字段、生成 / 上传失败、消息发送失败与安全拦截。

错误表面不得展示请求全文、邮箱、验证码、密码、Token 或其他用户数据。

## 6. 跨尺寸内容优先级

| 工作区 | `full`（Large） | `comfortable`（Medium） | `compact`（Small） | `glance`（Orb） |
|---|---|---|---|---|
| 首页 | 当前专注 + 今日计划 + 签到 + 趋势 + 陪伴 + 备忘录并列 | 当前专注与今日计划主导，其他为摘要 / 抽屉 | 当前专注、下一计划、今日完成度、一个主操作 | 专注进度、剩余时间、未读点 |
| 计划 | 时间轴 / 日历 + 编辑器 + 模板 / 失败上下文并列 | 列表或周视图 + 抽屉编辑 | 单列优先队列；复杂批量编辑提示扩大窗口 | 仅允许表达下一计划，不显示清单 |
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
SessionController / FeatureController（业务与同步状态）
└─ SemanticRouteState（当前页面、详情对象、筛选、草稿引用）
   └─ AdaptiveCanvasShell（Large / Medium / Small 编排）
      └─ AdaptiveFeatureComponent（full / comfortable / compact）

OrbWindow
└─ 订阅同一 Focus / Unread 状态，只保存 Orb 位置与窗口级偏好
```

跨层级切换不得重新创建业务 Controller。进入 Orb 时保存最近非 Orb 的语义页面、窗口尺寸、位置和滚动恢复键；恢复时回到原页面，而不是固定返回首页。

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
| `minimalism` | 纯白 / 黑灰层级、精确网格、排版主导、极少装饰 | 保留黑白层级、细线和明确节奏，不用密集边框补层级 | 高对比纯色表面 + 单色进度 + 状态点 |
| `midCenturyModern` | 暖米色、木质色、橙红、芥末黄、橄榄绿、有机几何与非对称网格 | 每屏最多保留一个低干扰几何装饰，优先保证正文和操作 | 深棕或暖米实色表面 + 橙红进度 + 橄榄绿状态 |
| `glassmorphism` | 深色渐变、分级背景模糊、半透明描边和柔和阴影；Large 降低材质强度 | 减少玻璃层叠数量，主操作保持高对比不透明底 | 单一高对比半透明 / 实色表面；不依赖壁纸模糊保证可读性 |

同一页面切换主题时只替换 `InnocenceThemeTokens`，不得重建路由、清空输入或切换 `DesktopPresentationTier`。

## 9. 关键交互与权限边界

- 非好友不可进入私信会话；非队友不可查看队友学习摘要；被拉黑关系的资料和互动入口必须在服务端拒绝后给出安全错误表面。
- 团队成员移除与解散仅对队长显示；后台入口仅对管理员显示，不能只靠前端隐藏代替服务端鉴权。
- 通知中的好友申请和团队邀请允许直接同意 / 拒绝，处理后同步更新陪伴页状态。
- 删除好友会删除历史私信；解散团队会删除团队交流数据；注销账号不可逆，均需明确二次确认。
- WebSocket 断开时，收件箱显示降级状态并回退 REST 拉取 + 系统通知，不伪装为实时在线。
- `/home/widget` 继续作为 Small / Orb 的轻量摘要来源，不约束客户端实现为旧固定挂件。

## 10. P00.5 验收矩阵

| 验收项 | 通过条件 |
|---|---|
| 页面覆盖 | MVP 账户、同步、好友、团队、交流、计划、专注、签到、统计、通知、备忘录、设置、首页、治理均有明确入口或状态表面 |
| 导航一致 | Large / Medium / Small 指向相同语义页面；Small 仅重组入口，不删业务 |
| 密度接口 | 三档 Canvas 和 Orb 有明确类型、默认映射与组件白名单 |
| 状态连续 | 页面、详情、筛选、草稿、滚动和计时的归属高于 Shell |
| 主题隔离 | 四主题不覆盖断点、导航、权限和功能可见性 |
| 契约兼容 | 未新增接口；`/home/overview` 与 `/home/widget` 职责保持不变 |
| 负向路径 | 会话失效、越权、权限拒绝、缺字段、同步 / 发送 / 上传失败均有安全表面 |
| 用户确认 | 已确认；文档状态为 `approved` |

## 11. 后续实施顺序

1. P01 首批已实现认证入口、语义导航、自适应主 Shell 与 Focus Orb；继续资料、隐私和设置页面；
2. P01-P04 每重建一个页面，同时实现 `full / comfortable / compact`，不得留到 P05 补响应式；
3. P05 在当前原生 `canvas / orb` 基础上完善边缘吸附、托盘、置顶和窗口状态持久化；
4. P06 按尺寸、DPI、多屏、四主题和权限负向路径完成矩阵验收。
