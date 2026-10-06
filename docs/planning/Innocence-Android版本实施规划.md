---
schema_version: 1
document_type: platform_implementation_plan
project_name: "Innocence"
platform: Android
status: in_progress
created_at: "2026-09-26"
authority: "现行 MVP、接口与数据流；用户确认 Android 首版采用 Material Design 3、四主题适配后置、三点按钮侧边栏与未登录本机离线入口"
related_gate: "G01-G06；Android 另以 A0-A5 跟踪，不改变现行阶段状态"
---

## 2026-10-07 v1.2.3 小版本发行准备

v1.2.3+8 整合新的简约白和专注布局，正式 APK 仍使用原发行证书且无 INTERNET。188 项客户端用例通过（4 项平台条件跳过）、19 项离线专项与正式包权限/版本/摘要核对通过；API36覆盖升级与公开发行结果由本轮最新检查点记录。Windows BYOK 功能随桌面包提供；Android 离线包的模型联网调用继续关闭。实体设备、OEM/Vulkan、完整交互和同步门禁保留。

# Innocence Android 版本实施规划

## 2026-10-05 专注卡布局与实际启动（0097）

按用户首页截图修正专注卡：数字计时和表盘并列、状态与任务信息聚合、底部通栏入口，窄屏/大字体上下居中，小时数数字完整单行；详情页开始/暂停/继续/结束复用原回调及忙状态禁用。四主题材质保留，MD3、FocusSession/ticker和本机资料逻辑不改。

24项相关回归通过（新增13布局/动作用例、原首页5与表盘/尺寸6），analyze无问题37.1秒、Debug构建19秒。模拟器曾被关闭，重开后其自动窗口尺寸落屏外；备份AVD窗口ini，只改显示位置与比例0.32，再通过sky标题栏居中，不wipe userdata。install -r Success，最终冷启动Status ok/COLD/3381ms，00:10:02进程3451/MainActivity前台，三种错误筛选均0；原复古主题、本机资料、首页专注卡与进入详情实际核对，未开启实际专注或写任务。

命令、摘要、截图和窗口恢复边界见 `../development/Android专注卡布局修正与验收.md`。本轮仅更新当前Debug开发安装，正式v1.2.2+7离线资产保持；实体设备/键盘/全状态真实交互、供应商与HTTP/同步继续待验。

## 2026-10-04 Android启动与桌面居中（0096）

用户要求启动Android并把桌面界面居中。在现有 `Innocence_API36_Pixel7` / Android16 API36模拟器覆盖安装0095同一Debug APK，`install -r` Success，不wipe本机资料；冷启动Status ok/COLD/3368ms。23:47:14进程4472与MainActivity保持前台，致命/Flutter未处理异常/布局溢出筛选均0；原生简约白首页字标和面板背景区分可见。模拟器主窗口及工具栏整体居中、保持运行，用户自行切换主题与继续浏览；助手没有代写业务数据或将用户浏览记录为完整导航验收。

复现命令和窗口位置见 `../development/简约白最早基准重建与验收.md` 末节，证据在 `client/flutter_app/build/qa/android-minimal-runtime/`。这是Debug开发包实际启动子集，覆盖下文“本轮未安装”的时间性描述；正式v1.2.2离线资产未改，实体设备/OEM/Vulkan、完整交互和真实模型/HTTP/同步仍待验。

## 2026-10-04 简约白重建（DEC-0054）

与Windows共同采用最早 `minimalism.html` 的黑白灰与排版，手机欢迎区删除橙色阶梯，按窄屏/大字体自然上下排列。中性浅灰画布与纯白工作面板用1px细边线明确分开；取消暖光、阴影及局部磨砂。按钮/输入保留4px小圆角、MD3导航/触控/键盘/返回/无障碍；表盘仍复用原计时状态，标语正文保留。DEC-0054覆盖下节柑橘/暖灰/柔影视觉，活动共用组件与主题令牌同步重建；宿主布局与开发APK构建不替代实体设备验收。

## 2026-10-04 简约白表盘与标语标签（DEC-0053/0094，视觉已覆盖）

手机首页和专注页新增共用FocusTimerDial，读取现有FocusSession已用时间/计划时长及暂停状态，不创建独立计时。简约白欢迎卡半遮挡圆球换成完整黑橙阶梯图形，实色白面板、清晰边线和柔影与暖灰背景分开；玻璃主题仍用自己的材质。首页中英文“每日标语 / Daily inspiration”标签删除，原创正文/日期主题池继续使用，专注时也保留正文。

该呈现规则覆盖下文历史“局部磨砂圆盘/显式标语标签”的冲突部分，沿用三点侧栏和Material 3交互。共享Flutter布局与开发编译不能替代实体手机验收；不更新已发布v1.2.2+7无INTERNET正式包。本轮配置/构建与运行证据见0094及`../development/简约白表盘与首页视觉验收.md`。

## 2026-10-04 智能助手B增量范围（DEC-0050/0090）

用户采用B后，DEC-0051/0092修正为BYOK多轮聊天，DEC-0052/0093进一步简化为地址+Key获取模型/选择/自动协议验证后保存。Android从三点侧栏工具项和计划快捷入口进入，14项工具接共用业务层，变更先确认；原排程为次级工具，五主入口、两主题与MD3基础保持。完整范围与契约见`Innocence-AI智能助手B方案实施与契约.md`第12–13节。

现行正式v1.2.2仍为无INTERNET权限的本机离线包。本轮只编译INNOCENCE_OFFLINE_ONLY=false的Debug联网开发包，未安装或发布；已实现Android Keystore AES-GCM通道，但设备加密往返/真实模型/完整HTTP/实体手机未验。正式联网发行仍需另行处理权限、签名与验收，不把开发构建替代既有正式离线包。采用B不包含C后台调度，也不表示Android A0–A5通过。

## 2026-10-04 v1.2.2 正式离线升级发行（0088）

基于 0087 的独立手机页实现，以 `1.2.2+7` 发布双端更新。Android APK 使用原 applicationId 和发行证书，仍无 `INTERNET` 权限；Windows 安装器与便携包沿用当前发布链。变更摘要和三项资产 SHA256 见 `docs/releases/v1.2.2.md`。

`flutter analyze --no-pub` 无问题，108 项全量和 4 项离线专项通过。Android API 36 隔离模拟器飞行模式下安装正式 1.2.1、创建合成本机资料及 07:00–08:00 计划，覆盖安装 1.2.2 后冷启动 `Status: ok / LaunchState: COLD / TotalTime: 1298ms`；原本机资料与计划仍可见，新月历显示该计划，年度页可进入，应用日志错误模式筛选为 0。Windows 包及 Android APK 均通过版本／结构／签名／权限校验，摘要逐项重算一致。

月计划和年度任务现已进入 Android 正式更新包。实体手机/OEM/Vulkan、其他业务详情页、Windows 多尺寸／多 DPI 与真实联网同步仍待验收；本次不通过 Android A0–A5 或 P01/G01。模拟器使用的均为 `QA_` 合成数据。

## 2026-10-03 月计划与年度任务独立手机页实施（0087）

用户询问安卓月计划和年度任务是否未完成，并要求“继续”。本轮补齐手机独立布局，在计划入口提供今日/月计划/年度分页，保留Material 3导航、触控与表单语义，承接简约白色和液态玻璃两主题。月页提供真实天数/闰月月历、前后月/本月、单日详情与编辑、多日期选择、任务存档新建/编辑/删除、从今日安排归档及显式取消/跳过已有/覆盖套用确认；切月清空旧选择，失败保留草稿或选择并给出提示。

年度页独立于月历数据，提供前后年/今年、1–12月横向刻度和月份筛选，纵向滚动时刻度吸顶。刻度与每张任务卡的48dp月份网格共用几何并同步横向偏移；唯一充能组件的外框表示起止月、内部填充表示0–100%进度。七种可见色样、成对±10/5/1、直接完成与减量重开、任务编辑/删除及多子任务独立完成/编辑/删除均复用当前SessionController及SQLite/outbox。共用日计划保存和年度保存返回成功布尔值；失败不能呈现保存完成。

`flutter analyze --no-pub`无问题；`flutter test --no-pub --reporter expanded`108项通过，最终日期触控尺寸调整后计划专项9项再次通过。宿主用例覆盖320dp/1.5倍字体/280dp键盘、中英文两主题、闰月与批量策略、边界与独立子任务、月份几何/吸顶横滑、无会话及写入失败；真实SQLite验证重开、outbox删除和其他ownerScope空读。401/403/400由注入异常覆盖，不能作为真实HTTP验收。

最终本机离线Debug APK35.2秒构建成功。新隔离API36 userdata、飞行模式和合成任务下，实际创建存档并套用2026-10-04/05，年度任务1–12月/鎏金黄由0增至15再减至14、勾选独立子任务；简约白/液态玻璃与真实Gboard固定保存可见。冷启动`Status: ok / LaunchState: COLD / TotalTime: 2395ms`，两日计划、14%与子任务保留；SQLite完整性/业务值/同一本机ownerScope核对一致，月份横滑至12及纵向吸顶可见，当前PID日志错误筛选0。详细命令、截图和摘要见0087。

本轮完成源码与本机离线验证子集，正式版本仍为v1.2.1+6；未发布新版本或修改远端。实体手机/OEM/Vulkan、系统返回完整矩阵、长期性能、联网同步和跨账号HTTP负向回放仍待验收，不据此通过A0–A5或P01/G01。下文历史记录中月/年“尚未完成”的描述按其记录时间保留，当前状态以本节为准。

## 2026-10-02 v1.2.1 修正发行（2026-10-03 发布核对收尾）

用户要求“更新一个新的小版本”，本轮正式发行 `1.2.1+6`，整合0084玻璃纹理方向、圆盘手柄误滚动、每日标语和0085自适应图标填充纠正。Android继续提供本机离线版，applicationId与发行密钥保持原值；无`INTERNET`权限，缺少签名材料时在构建前明确失败。

99项全量回归、8项离线专项及analyze通过。API36隔离模拟器在飞行模式下从正式v1.2.0覆盖升级，冷启动保留本机资料与`05:30–09:00`计划；标语、玻璃首页与圆形图标核对。公开Release401851379为latest，Android/Windows双端共四项资产摘要与下载核对通过；命令和结果见0086。

实体手机、OEM图标蒙版、Vulkan、软键盘/大字体和长时间性能仍须独立验收。本轮未改变联网接入范围或宣布Android A0–A5全面通过。

## 2026-10-02 触控与玻璃显示纠正

- Android 短计划圆盘首尾手柄采用36dp触控半径；手柄按下立即接管拖动，防止纵向微调变成表单滚动。非手柄区域保留纵向滚动，仍按半小时及当天00:00–24:00契约保存。
- 玻璃光场离屏纹理在 Flutter 3.44.4 的 Impeller GLES 采样时补偿纵坐标反转；Flutter3.47+用迁移宏避开旧补偿，其他后端保持原方向。
- 首页每日标语与 Windows 共用按本地日期、主题和语言稳定选择的原创文案池；专注期间继续显示，午夜及从后台恢复时刷新。用户已取消本轮艾薇儿/Sum41歌词收录。
- 0084记录命令/像素探针/触控回归与构建证据。实体手机、Vulkan设备和完整大字体/性能矩阵继续独立验收。

## 2026-10-01 v1.2.0 本机离线发行范围

用户要求把目前成果作一次小版本发布，包括 Android；对于服务端地址明确答复：“先发布可用的本机离线版，联网功能后续接入”。本次 v1.2.0+5 发行 Android 本机离线 APK，与 Windows 安装器／便携包共享版本号。首次选择语言后使用明确的离线入口；显式进入后恢复同一本机资料。登录、好友、团队、聊天、云同步与推送不在本次 Android 发行范围，后续接入可用 HTTPS 服务端时另行验证。

应用名／图标改为 Innocence，applicationId 沿用 `com.innocence.app.innocence_flutter`；独立发行密钥保存在仓库外，Gradle 不再使用 Debug 签名兜底。`INNOCENCE_OFFLINE_ONLY=true` 禁用请求及在线会话恢复，并从最终 Manifest 移除 `INTERNET`。打包脚本校验签名、版本、非调试状态和权限，生成双端 SHA256 清单。正式包不能直接覆盖此前 Debug 签名开发包；后续正式版必须保留同一密钥。

发行准备通过 analyze、93 项 Flutter 全量用例和 8 项离线编译／恢复专项；实际 Release 构建、安装与发布结果以 0083 检查点为准。此范围决定不把 Android A0–A5 自动改为通过：实体手机、月／年计划详情、长时间前后台恢复与性能、真实联网认证及跨设备同步仍需后续证据。

## 2026-09-29 两主题立即接入（覆盖下文“移动适配后置”）

用户最新指令要求开始覆盖程序 UI，并让液态玻璃、简约白色都能用于 Android。Android 现立即接入两主题共用的 Flutter 色彩、表面和页面背景：简约白色使用暖白／炭黑／柑橘与局部磨砂；液态玻璃使用动态午夜蓝空间光和中性半透明模糊面板。设置中的主题选择继续本机持久化。`Scaffold`、三点 `NavigationDrawer`、`FilledButton` 等 Material 3 交互、系统返回、离线身份隔离及业务回调保持适用。下文 2026-09-26 的“仅 MD3、四主题移动适配后置”是历史决定；两主题适配顺序以本节和 UI 设计规划的 2026-09-29 覆盖决定为准。其余业务详情页、真机可读性、动画性能和实体设备仍须单独验证，不能因主题令牌接入判定 Android 全面完成。

## 2026-10-01 短计划圆盘时钟选段

Android 短计划及共用日任务存档编辑器按用户最新指令采用 24 小时圆盘选时，覆盖下文 48 个时间单元滚动编辑的旧呈现要求。盘顶显示 `00/24`，凌晨位于上方；点击起止边界建立时段，已有任务可通过圆点拖动或半小时加减按钮调整，保留邻接防重叠和最短半小时规则。输入备选入口保留 Material 时间选择器和字段校验。任务内容可纵向滚动，关闭与保存固定在底部；窄屏、大字体和键盘由独立手机布局处理。仍使用 `startSlot=0..47 / endSlot=1..48` 的当天持久化契约：结束选择的盘顶代表 `24:00`，不自行推定跨日计划。用户句末“在凌晨时间”的进一步范围尚未收到补充。详见 UI 设计规划 2.35。

## 视觉范围决策（2026-09-26）

> 主题可以先不着急做，但是要ui依照md3来自做

Android 首版以 Material Design 3（MD3）完成全部用户界面；侘寂、柔彩、中世纪现代、玻璃态的 Android 适配延后，不作为 A0–A5 的交付或验收条件。Windows 已有四主题及其提示词存档继续有效。Android 可以先提供 MD3 的系统／浅色／深色外观，但不把它当作四个产品主题已实现。用户后续确认左上角“···”按钮侧边栏和未登录本机离线入口均属于 Android 首发范围。

## 1. 目标与依据

Android 是手机主应用。第一版要在手机上完整完成「计划 → 专注 → 记录 → 签到 → 统计」，支持好友与小团队的轻量陪伴，并与 Windows 使用同一账号同步核心数据。服务端仍是唯一在线业务权威；同一账号遵守「1 台手机 + 1 台电脑」会话策略。

本稿承接 `Innocence-MVP第一版功能范围.md`、`Innocence-项目计划书.md`、`Innocence-UI设计规划.md`、`docs/02-contract-and-compatibility-rules.md`、`docs/06-contract-inventory.md` 和 `docs/07-dataflow-and-module-map.md`。2026-08-07 的移动端单独设计决策继续有效；新决策把 Android 首版的视觉基线确定为 MD3。手机端不把 Windows Canvas、Focus Orb、悬浮窗控件或桌面页面缩窄后直接使用。

本稿是实施建议，不代表 Android 功能、接口回放、真机视觉或发行验收已完成。Windows v1.1.1 的多尺寸／多 DPI 目视验收、真实同步回放及签名事项仍按原 G01/G05/G06 待办跟踪。

## 2. 当前可复用基线与差距

| 范围 | 仓库现状 | Android 工作 |
|---|---|---|
| 工程 | `client/flutter_app/android/` 已有 Flutter Android 工程；`AppConfig` 提供 Android 设备类型与模拟器本地 API 地址 | 验证 Android 工具链、模拟器与真机启动；生产 API 地址须由环境配置，正式包只连接 HTTPS |
| 数据与业务 | `SessionController`、API 模型、SQLite `OfflineStore` 和同步队列已在同一 Flutter 工程；服务端把 `android` 归入 mobile 会话槽 | 审计平台分支、令牌存储、断网恢复和跨设备写入；共享业务逻辑，移动端单独呈现 |
| 页面 | `HomePage` 有非 Windows 分支，认证页和二级页含大量桌面优先布局与窗口语义 | 建立手机路由、导航和触控页面；逐页替换桌面呈现，不把现有非 Windows 分支当成已验收手机版 |
| MD3 界面 | Flutter 主题数据已设置 `useMaterial3: true`，但应用仍从四主题控制器生成全局主题；非 Windows 页面并未因此完成 MD3 手机体验 | Android 建立独立的 MD3 `ColorScheme`、`TextTheme`、组件主题和移动页面；Windows 四主题路径保持现状 |
| 发行 | v1.2.0+5 已正式发布 Innocence 品牌/独立签名的本机离线 APK，应用 ID 延续；最终无 INTERNET，API36覆盖安装保留资料 | 沿用发行密钥，继续实体设备/长时间/完整手机页验收；联网发行需另行固化 HTTPS 与权限 |
| 通知 | MVP 要求手机推送，现有契约有通知与实时通道规划 | 确定推送通道、设备令牌登记和权限流程；前台消息、后台推送及已读状态要与服务端对齐 |

以上是源码核对，不等于 Android 构建或运行验证。计划执行时，先补一份可复现的构建和设备基线记录。

## 3. 第一版范围

1. 账户：语言选择、注册、密码／验证码登录、找回密码、会话恢复与退出；资料、头像、隐私、黑名单、通知和 MD3 浅／深色外观设置。四个产品主题暂不进入 Android 首版。
2. 个人闭环：首页聚合；短计划按日、任务存档与长计划月历、独立年度任务板；专注时段与番茄、暂停继续、手动签到、统计、文本／清单备忘录。年度任务继续使用 12 月跨度、七色、独立 0–100% 进度和多子任务语义。
3. 陪伴闭环：好友申请与分组、团队与队友进度、文字私信和群聊、提醒、通知内处理邀请、举报入口；权限仍由服务端检查。
4. 双端一致：手机和 Windows 账号同时在线，核心计划、学习状态、签到结果、备忘录和未读状态可恢复同步；断网状态、待同步与冲突对用户可见。
5. Android 原生体验：系统返回、状态栏与导航栏、安全区、键盘避让、照片选择、通知权限与深链入口按实际设备验证；只申请功能确需的权限。

后台管理已转向独立管理员网站，不作为 Android 普通用户导航。MVP 之外的开放式社交、多手机同时在线、复杂排行榜、图片／语音聊天和独立平板工作台不进入首版。

## 4. 移动端信息架构提案

手机采用单列任务流。用户已确认主导航改为左侧 MD3 `NavigationDrawer`：顶栏左上角显示“···”按钮，点击后展开并收纳「首页、计划、专注、陪伴、收件箱」五个主入口，不使用底部 `NavigationBar`。统计、备忘录、设置和退出作为侧边栏次级入口；收件箱统一通知、私信／群聊和申请／邀请的入口。五个页面的真实内容、双语、大字体和返回行为仍按 A0/A1 分别验证；此决策不等于五页已实现。

| 页面 | 手机端主要内容与操作 | 特别约束 |
|---|---|---|
| 首页 | 当前专注、下一段计划、今日完成率、签到、未读和队友摘要；优先提供一个清晰主操作 | 聚合数据优先；加载、空态、断网、待同步明确区分 |
| 短计划 | 48 个半小时单元的可滚动昼夜时间轴；空白段新建、已有段调整首尾；保存入口保持可达 | 触控命中与防重叠必须实机验证；键盘出现后不遮挡保存 |
| 月计划 | 完整月历、日期详情、任务存档架与批量套用 | 月份切换与多选反馈不能依赖鼠标 Hover |
| 年度任务 | 12 个月可读刻度、跨度外框、内部进度填充、七色、子任务与双向增减 | 使用可滚动或分段视图保留月份与充能框的对应关系，不等比压缩桌面 12 列 |
| 专注与签到 | 当前时段、剩余时间、暂停／继续／结束和手动签到 | 前后台切换、锁屏与进程重建后以持久时间事实恢复；离线签到只显示待校验 |
| 陪伴与收件箱 | 好友、团队、聊天、提醒、邀请和通知处理 | 陌生人与非队友权限边界、未读去重、网络失败反馈一致 |
| 设置 | 账户、隐私、通知、外观、同步状态与本机数据 | 桌面窗口和托盘选项不进入手机设置；危险操作单独确认 |

### 4.1 MD3 页面与组件规则

- Android 从统一的浅色／深色 `ColorScheme`、`TextTheme`、形状与组件主题出发，使用语义色表达主操作、表面、错误和状态。可用 `ColorScheme.fromSeed` 建立初始色板；品牌色种子和色值在 A0 视觉稿中定稿。系统明暗模式优先，动态取色可后续评估。
- 顶层页面使用 `Scaffold`、`AppBar` 与 `NavigationDrawer`；顶栏左侧自定义三点按钮调用 `ScaffoldState.openDrawer()`，不用自动生成的汉堡按钮。主操作按语义选 `FilledButton`，次级操作用 `OutlinedButton` 或文本按钮。输入、分段选择、卡片、底部弹层、对话框和反馈分别选用 Flutter 对应的 MD3 Material 组件，并在组件主题中统一调整。
- 计划时间轴与年度月份充能框属于产品专属交互，可以定制绘制和手势；外围的导航、编辑、确认、错误反馈与无障碍语义仍按 MD3。年度七色是任务数据语义，需保证文字、百分比和进度形状在浅／深色下可辨，不能只靠颜色表达。
- 认证到二级页需统一检查系统大字体、键盘避让、系统返回、可点击区域、屏幕阅读器标签、减少动态效果及浅／深色对比。MD3 样式与业务状态分离，未来增加产品主题时复用同一页面模型和交互结构。

仅设置 `useMaterial3: true` 不足以完成手机界面；导航必须在页面中实际采用 MD3 组件。设计与实现参考 [Flutter 的 Material Design 指南](https://docs.flutter.dev/ui/design/material)、[Flutter 主题指南](https://docs.flutter.dev/cookbook/design/themes)、[`NavigationDrawer` API](https://api.flutter.dev/flutter/material/NavigationDrawer-class.html)和 [`Scaffold.drawer` API](https://api.flutter.dev/flutter/material/Scaffold/drawer.html)。

### 4.2 A0 手机主 Shell 线框（v0.2，侧边栏决策已确认）

本节按 2026-09-27 用户决策替换原底栏 v0.1 提案；导航形态已确认，不表示各业务页已经实现。Android 应按设备宽度和系统字体保留可读性，不压缩文字，也不复用 Windows Canvas／Focus Orb。

```text
首次启动：品牌启动态 → 首次语言选择 → 会话恢复 → 登录／注册，或本机离线入口
登录态：┌ ···  页面标题                         刷新／状态 ┐
       │ 当前任务／页面内容／明确的加载、空、失败或离线反馈 │
       └─────────────────────────────────────────────┘
点击左上角 ··· → 左侧抽屉：
       首页 / 计划 / 专注 / 陪伴 / 收件箱
       ────────────────────────────────
       统计 / 备忘录 / 设置 / 退出
```

五个 `NavigationDrawerDestination` 使用首页、日历、计时器、团队、收件箱图标；统计、备忘录、设置和退出在分隔线下作为次级列表项。收件箱未读数用徽标，只有当前账号的数据可见；未登录离线状态的陪伴与收件箱显示需登录说明，不显示其他账号社交缓存。系统返回先关闭抽屉或弹层，位于其他主入口时回首页，再从首页退出 Shell。页面详情使用独立 MD3 `AppBar` 返回。

| 页面／入口 | 内容与主操作 | 加载、空、失败及离线反馈 | MD3 表现要点 |
|---|---|---|---|
| 首页 | 今日进度、当前／下一专注、签到状态、未读摘要；主操作进入当前计划或开始专注；提供统计和备忘录快捷入口 | 首次加载用明确进度；无计划给创建入口；失败可重试；离线标注缓存时间与本机状态 | `Scaffold`、`AppBar`、语义分组的 `Card`、`FilledButton`，不把多个主操作堆成按钮墙 |
| 计划 | 日／月／年分段切换；日圆盘选时和编辑、月历与任务存档、年度月份跨度与进度 | 每种跨度独立显示加载和空态；错误保留本机草稿并可重试；离线写入须显示「仅本机／待同步」 | `SegmentedButton`、日期选择器、卡片或列表项；短计划使用 24 小时圆盘、半小时微调与固定底部保存，年度按月滚动而不缩成 12 列小字 |
| 专注 | 当前专注、剩余时间、开始／暂停／继续／结束 | 恢复中与活动中区分；断网不伪报服务端完成；本机可恢复时明确标注本机状态 | 用单一 `FilledButton` 表达当前主操作，其他操作采用低层级按钮；时间数字支持系统大字体 |
| 陪伴 | 好友关系、团队和队友摘要；进入好友／团队详情 | 空态给添加好友或加入团队入口；失败可重试；陌生人／非队友数据始终由服务端权限控制；社交写操作离线禁用 | `ListTile`、`Card`、MD3 菜单与确认对话框；不能只用颜色表达在线和关系状态 |
| 收件箱 | 通知、私信／群聊、好友申请、团队邀请及处理结果 | 未读数与已读同步；无内容显示空态；请求失败保留未读提示并可重试；推送未接入前以应用内拉取为准 | `NavigationDrawer` 未读徽标、分组列表、`Badge`、`ModalBottomSheet`／`AlertDialog` |
| 统计、备忘录、资料与设置（二级入口） | 趋势与记录、清单／文本备忘录、账户／隐私／通知／外观／本机同步状态 | 登录态错误区分网络、认证和权限；本机缓存须显示归属范围；危险操作二次确认 | 标准 MD3 列表、表单、图表容器与按钮；大字体和键盘弹出时操作仍可达 |

公共状态约束：加载态不显示占位业务成功；空态说明下一步；错误态提供重试并保留可恢复输入；断网态展示数据来源、最后同步时间和待同步数。签到只有服务端确认后才显示成功。浅／深色使用语义化 `ColorScheme`，外观默认跟随系统并提供系统／浅色／深色选择的实现提案；品牌种子色须另行评审。四个产品主题不进入这套基线。

### 4.3 A0 源码级契约与 Android 差距（初始盘点；运行态进展见 §10–§14）

| 领域 | 源码可见现状 | A0 差距／后续动作 |
|---|---|---|
| 认证与账号 | Flutter 有认证、资料、头像、隐私、会话和黑名单 API；`AuthPage` 含「使用离线模式」入口 | 登录／注册与资料需重建为移动 MD3 页面；Android 会话当前写入 `SharedPreferences`，A1 评估并迁移到受保护存储，禁止把令牌复制到日志或本地业务库 |
| 个人数据 | 客户端已有首页、日／月／年计划、专注、签到、统计和备忘录 API／模型；服务端可见对应 REST Controller | 数据层可复用但页面未通过 Android 验收；需按每个页面状态、错误码和数据字段核对契约；专注前后台恢复、Android 本地事务仍需设备运行验证 |
| 离线导入 | 客户端 `OfflineStore`、ownerScope、outbox 与 `/sync/import-preview`、`/sync/import` 已有实现；服务端 `SyncImportController` 有对应路由 | 未登录本机离线入口已确认进入 Android 首发；导入前预览、目标账号确认和冲突策略不可省略；真实 HTTP 与跨设备回放仍未完成 |
| 首次同步 | 接口清单草案记载 `/sync/bootstrap`，本次服务端 Controller 检索只找到 `SyncImportController`，Flutter 源码也未发现该调用 | 草案不能作为已交付契约；A1/A4 决定由哪些现有读取接口组合恢复，或先补齐并固化 bootstrap 契约 |
| 聊天、实时与推送 | Flutter 和服务端有团队聊天、通知的 REST 读取／发送／已读接口 | 本次 Flutter 与服务端源码检索未发现 WebSocket 或推送 SDK／令牌登记实现；REST 聊天不等于实时通道，前台刷新、后台推送和去重分别列入 A3 接口差距 |
| Android 外壳与发行 | Manifest 仍是 `innocence_flutter` 默认标签；Gradle applicationId 为 `com.innocence.app.innocence_flutter`；release 使用 debug 签名；仅可见 INTERNET 权限 | 应用名、图标、正式 ID、推送权限、正式签名和升级路径属于 A5；当前设置不可视为可发布 |
| 工具与设备 | 本次 `flutter doctor -v` 发现 Android SDK 已安装但缺 `cmdline-tools` 且许可证未知；当前 `flutter devices` 无 Android 设备、无 AVD | 完成工具安装／许可证后再创建模拟器，并连接至少一台真实 Android 手机；在两类设备真实启动之前 A0 不通过 |

源码级盘点不代表 API 可达、服务端已启动、设备可启动或真机功能已验证。每个差距只有取得对应运行态证据后才可改为完成。

## 5. 数据、会话与离线边界

- Android 请求继续使用 `/api/app/v1`、Bearer 会话和设备标识；客户端现有 `android` 值已由服务端归入 mobile 槽位。正式联调必须覆盖第二台手机替换／拒绝、Windows 会话保留和旧令牌失效。
- 本地业务缓存沿用 `ownerScope`：`local:profileUuid` 与 `account:userId` 不互读。网络错误不能等同令牌失效；401、权限拒绝和账号不匹配分别处理。`clientEntityId`、`operationId` 与 `baseRevision` 仅用于幂等和冲突，不作为身份。
- Android 首版支持未登录本机离线资料入口，并沿用已登录后断网读写计划、专注和备忘录的方向。只有用户显式进入本机离线模式后，Android 重启才恢复同一 `local:profileUuid`；未创建过本机资料时不自动伪造旧资料。离线资料与账号缓存隔离，登录后必须先做导入预览与目标账号确认，确认前不得上传正文。真实 HTTP 导入与断网补传仍待验证。
- 日计划、备忘录、专注事件、年度区间和签到意图分别遵守既有冲突规则；不能用统一的最后写入覆盖。只有服务端确认的签到才显示为成功。
- 访问令牌应迁移到适合 Android 的受保护存储；不能放入业务表、同步队列、日志或样本。生产地址、推送密钥和正式签名材料不进仓库。
- 每个移动页面先对照 `docs/06-contract-inventory.md` 固化字段、状态码、空值与失败语义，再接入真实调用。`/sync/bootstrap`、WebSocket 和推送投递的实际可用性须用代码与运行态分别核对，不能因规划文档列出即认定已实现。

## 6. 实施顺序与门槛

阶段与现行 P01–P06 并行标记，仅表示 Android 工作包；它们不自动推进项目总门禁。

| 阶段 | 交付物 | 退出条件 |
|---|---|---|
| A0 基线与设计 | Android 构建／设备清单、手机页面地图、主流程线框、MD3 浅／深色方案与组件清单、离线首发范围决定、接口差距表 | 手机导航和离线边界确认；MD3 页面基线可评审；模拟器与至少一台真机可启动 |
| A1 账户与移动 Shell | MD3 手机认证与语言入口、三点按钮 + `NavigationDrawer` 主导航、资料／设置、本机身份隔离和会话恢复 | 注册／登录／退出、401 与设备槽位负向回放；浅／深色、大小字体、键盘和系统返回可用 |
| A2 个人闭环 | 首页、日／月／年计划、专注、签到、统计和备忘录的移动呈现 | 一条真实「计划→专注→签到→统计」闭环；本地重启与断网恢复；失败状态无伪成功 |
| A3 陪伴与通知 | 好友、团队、文字聊天、提醒、收件箱、WebSocket 与手机推送 | 申请／邀请／提醒／消息／已读闭环；陌生人、非队友和黑名单负向路径；前后台通知一致 |
| A4 同步与稳定性 | Windows↔Android 双端回放、冲突与幂等矩阵、进程重建、性能和无障碍修正 | 断线重试、重复操作、跨账号、权限拒绝、缺字段与服务端失败均保留正确数据边界 |
| A5 发行候选 | 应用名和图标、正式签名、版本与升级、Release 包、安装／卸载／升级记录 | MD3 页面与真机矩阵通过；产物可安装且签名正确；无真实凭据入库；未完成项如实写入发行说明 |

优先从 A0 → A1 → A2 实现可用的手机个人闭环；A3 中接口缺口与推送通道可提前调研，但接入状态必须单独记录。任何阶段的 mock 数据、截图或仅源码存在，都不满足退出条件。

## 7. 验收矩阵与证据

测试记录至少区分「源码／部件验证」「Android 构建」「模拟器运行」「真机运行」「服务端 HTTP 回放」「Windows↔Android 双端回放」。每项保存实际命令、结果、设备与系统版本、变更文件；尚未执行写未执行。

| 维度 | 最小验收场景 |
|---|---|
| 设备与布局 | 小屏和常见手机宽度、系统大字体、深浅系统栏、竖屏、键盘弹出、系统返回、通知权限拒绝 |
| MD3 界面 | 浅／深色 `ColorScheme`、导航与选中态、按钮层级、输入和表单反馈、对话框与底部弹层、加载／空态／错误态、语义标签与触控可达性 |
| 账户与权限 | 认证失败、令牌过期、第二手机会话、跨账号缓存、租户不匹配、好友／队友越权、黑名单 |
| 数据与同步 | Windows 和手机交替编辑同一天计划；断网写入与重试；重复 `operationId`；日计划／备忘录／专注／年度区间／签到冲突 |
| 个人闭环 | 48 段编辑及防重叠、月历批量套用、年度进度 0%／中间值／100%、专注暂停与恢复、签到失败和统计刷新 |
| 消息与通知 | 前台与后台通知、未读同步、重复推送去重、邀请处理失败、WebSocket 中断后的拉取恢复 |
| 发行 | APK/AAB 实际产物、签名检查、干净安装、旧版本升级、权限清单、正式地址和崩溃记录 |

必须覆盖认证失败、租户不匹配、权限拒绝、缺失字段和生成／上传失败等项目负向路径。涉及头像与推送时还需检查拒绝授权、文件类型／大小错误、离线和服务端异常。样本仅使用合成或脱敏数据。

## 8. 近期可执行动作

1. 按已确认的三点侧边栏与未登录本机离线首发范围，继续完善 A0 手机页面地图；列出每页的主操作、加载／空／错误／离线态和浅／深色表现。
2. 核对 Android Gradle、Manifest、应用 ID、图标和签名现状；在模拟器及一台真机取得可复现启动记录，记录 `flutter doctor`、`flutter analyze`、`flutter test` 和 Android 构建的实际结果。
3. 对照客户端调用、服务端路由与 `docs/06-contract-inventory.md` 建立 Android 契约差距表，优先认证、首页、同步、计划、专注、通知和实时通道。
4. A1 编码前先确认认证页面与主 Shell 的移动稿，再按「内部状态与模型 → 业务接入 → 页面 → 负向与真机验证」执行。

## 9. 后续四主题

Android 首版的 A0–A5 不以四主题切换或四套专属视觉作为门禁。需要主题化时，再从 `Innocence-UI设计规划.md` 的原文提示词与 Windows 已确认语义出发，逐一设计 Android 的色彩、材质和装饰；MD3 导航、页面状态、可访问性和业务模型继续作为共同基础。Windows 四主题当前需求与验收范围不因本决策改变。

## 10. A0 实际执行记录（2026-09-26）

本次完成源码盘点、MD3 手机 IA 评审稿和本地 Debug APK 构建基线；不是 A0 通过，也不是 Android 手机页面完成。页面地图和导航／离线范围仍待用户确认，尚无模拟器或真机启动证据。

| 实际命令 | 结果 | 说明 |
|---|---|---|
| `flutter --version` | Flutter 3.44.4 stable；Dart 3.12.2 | Flutter SDK 位于 `D:\soft\flutter` |
| `flutter doctor -v` | Flutter／Windows 正常；Android toolchain 报错 | Android SDK 36.1.0 已识别，但缺 `cmdline-tools` 且 Android license status unknown；无 AVD／手机 |
| `flutter analyze --no-pub` | 退出码 0；No issues found | 未改 Flutter 产品代码 |
| `flutter test --no-pub` | 退出码 0；63 项全部通过 | 当前测试集，不代表 Android UI 或真机验证 |
| `flutter build apk --debug --no-pub` | 最终构建成功，13.6 秒 | 当前进程临时设置系统代理和 `-Dorg.gradle.project.kotlin.incremental=false`；未写入项目或持久环境。未加跨盘缓存规避参数的初次构建失败于 Kotlin 增量缓存根目录跨盘（`C:` Pub Cache 与 `F:` 工程） |
| `flutter devices` / `flutter emulators` / SDK `adb devices -l` | 仅 Windows、Chrome、Edge；No emulators available；adb 列表为空 | 设备启动待补 |
| `aapt dump badging …app-debug.apk` 与 `Get-FileHash -Algorithm SHA256` | package `com.innocence.app.innocence_flutter`、version `1.1.1+4`；APK 159,663,316 字节；SHA-256 `6DDC8D44F6A9000D0348527545BA4BAA9925F890498C342F0A3F6F0899D70749` | 产物位于 `client/flutter_app/build/app/outputs/flutter-apk/app-debug.apk`，为调试包，不可当作发行候选 |

构建按需安装了 NDK 28.2.13676358、Build-Tools 36.0.0、Android Platforms 35／36 与 CMake 3.22.1。构建期间有 AGP 9 Kotlin DSL 迁移警告及旧 SDK XML 读取警告；本次未改 Gradle 配置，A5 前应统一检查插件兼容性和正式签名。Android SDK command-line tools、AVD 和实体设备仍未准备好。具体环境问题与 A0 待确认项记录在当前 RESUME 和检查点 0063。

## 11. A0 Android 模拟器启动验证（2026-09-27）

已用 Android Studio 所带 SDK／Emulator 建立 Pixel 7 虚拟设备，并在 Android 16（API 36）冷启动当前 Debug APK。此记录只覆盖本机模拟器启动和页面冒烟，不代表 MD3 手机 UI、真实服务端联调或实体手机验收完成。

| 实际命令／检查 | 结果 | 边界 |
|---|---|---|
| 官方 Windows command-line tools 下载、SHA-256 校验与解压 | 15859902 包的 SHA-256 为 `90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a`，与 Android Developers 页面公布值一致；工具安装在 `F:\AndroidSdk-Innocence\cmdline-tools\latest` | C 盘空间不足，SDK 原路径的 `cmdline-tools`、`.temp` 和 `system-images` 使用目录联接指向 F 盘；未改仓库构建配置 |
| `sdkmanager --sdk_root=F:\AndroidSdk-Innocence --install "system-images;android-36;google_apis_playstore;x86_64"` | 首次下载的压缩包读取失败；改用 F 盘 Java 临时目录重试后退出码 0，revision 7 安装完成；C 盘 SDK 通过联接也识别该镜像 | 失败尝试不计作安装成功；`flutter doctor -v` 仍报告部分 Android licenses 未接受 |
| `avdmanager create avd -n Innocence_API36_Pixel7 -k "system-images;android-36;google_apis_playstore;x86_64" -d pixel_7`，`avdmanager list avd`，`emulator -list-avds` | AVD 已创建且两个列表均可见；AVD 用户数据经目录联接存放在 `F:\AndroidSdk-Innocence\avd` | 创建时命令行输出 `devices.xml` 缺失提示，但 AVD 列表与实际开机均成功；此提示仍需留意后续设备配置 |
| `emulator -accel-check`，`adb devices -l`，`adb shell getprop sys.boot_completed` | WHPX 可用；`emulator-5554` 为 device；启动完成值为 `1`；Android 16／API 36，1080×2400、420 dpi | 当前只有模拟器，没有实体手机 |
| `adb install -r app-debug.apk`，`adb shell am start -W -n com.innocence.app.innocence_flutter/.MainActivity` | 安装 `Success`；冷启动 `Status: ok`，`TotalTime: 7140` ms；应用进程保持运行、前台 Activity 为 MainActivity | 未登录真实账号，未回放后端 HTTP 或双端同步 |
| `adb shell input tap`、`screencap`、按应用 PID 筛选 `logcat` | 语言选择 → 认证页 → 离线确认 → 本机首页均可显示；筛选结果未见 `FATAL EXCEPTION`、`E/flutter`、`Unhandled Exception` 或 `FlutterError` | 截图保存在 `F:\AndroidSdk-Innocence\captures\`；现有页面仍是旧视觉，不能算作 MD3 重建完成；离线入口是否进入 Android 首发仍待确认 |
| `flutter devices`、`flutter emulators` | Flutter 识别 Android 16 的 `emulator-5554` 和 `Innocence_API36_Pixel7` AVD | Android Studio 的 Device Manager 可以使用同一标准 AVD；本次未从 IDE 的 Run 按钮执行项目 |

A0 仍待五项导航和未登录离线范围决策、至少一台实体设备启动，以及 SDK 许可警告处理。后续 MD3 页面重建应以本次截图为改造前基线，重新在模拟器验证浅／深色、系统大字体、键盘和返回行为。

## 12. A1 独立前置工作：MD3 语言与认证入口（2026-09-27）

不依赖导航分组决策的 Android 入口已先行重建。Android 分支采用 `ColorScheme.fromSeed` 的浅／深色 Material 3 基线，随系统明暗切换；首次语言页、会话恢复加载页和认证页使用移动端独立布局。认证保留现有密码／验证码／注册／重置、发送验证码及未登录离线入口的业务方法，展示改为 `Scaffold`、`AppBar`、`Card`、`SegmentedButton`、`TextField`、`FilledButton` 与 `OutlinedButton`。种子色是首版临时基线，不代表四主题移动适配已经完成；Windows 仍走原四主题和桌面认证路径。

| 实际命令／检查 | 结果 | 边界 |
|---|---|---|
| `dart format`、`flutter analyze --no-pub` | 格式化无额外变更；analyze 退出码 0，`No issues found` | 仅静态检查 |
| `flutter test --no-pub` | 退出码 0，65 项通过；新增 2 项覆盖 MD3 浅／深色和语言选择持久化 | 现有测试运行于宿主环境，Android 认证页主要由模拟器视觉／交互检查覆盖 |
| 临时设置 `GRADLE_OPTS=-Dorg.gradle.project.kotlin.incremental=false` 后 `flutter build apk --debug --no-pub` | 退出码 0；Debug APK 为 180,060,590 字节，SHA-256 `4E88976EE176FB9F3317DE1B45F0ACEE10EF6589D1B5257BB5C7283C83B911AA` | 不是 Release 或正式签名包；临时 Gradle 参数用于规避跨盘 Kotlin 增量缓存问题 |
| `adb install -r app-debug.apk`、`adb shell am start -W -n com.innocence.app.innocence_flutter/.MainActivity` | 安装 `Success`，启动 `Status: ok`；Android 16／API 36 Pixel 7 模拟器持续运行 | 未使用真实账号或服务端，不代表注册／登录接口验收 |
| 模拟器截图、空邮箱提交、系统返回、按 PID 筛选 `logcat` | 中／英文语言与认证页、浅／深色、1.5 倍字体、空邮箱提示、重置页返回登录均可见；未筛到 Flutter 致命异常 | 截图位于 `F:\AndroidSdk-Innocence\captures\innocence-md3-*.png`；软键盘仅见输入工具栏，遮挡路径未确认通过；其余业务页仍为旧视觉 |

C 盘清理核对：失败解压产生的 `cmdline-tools` 中间目录已由解压流程回滚；原临时下载包已移出 C 盘并删除，核对时原路径和重复嵌套目录均不存在。SDK 的 `cmdline-tools`、`.temp`、`system-images` 与用户 `avd` 这四个 C 盘目录是指向 F 盘的有效目录联接，模拟器仍依赖它们，故保留。另有 `C:\Users\HP\AppData\Local\Temp\jna-2312`（748,032 字节）含工具运行产生的旧 JNA DLL；精确清理命令被本机执行策略在启动前拒绝，未删除，也不将其记为清理完成。

A0 总门槛与 A1 总门槛仍未通过：当时五项底栏提案与未登录离线首发范围待确认，尚无实体手机、SDK 剩余许可、真实登录／负向接口、键盘遮挡和主 Shell 验收。其后用户已确认改用三点按钮侧边栏；离线首发范围的更晚决策见 §14。

Android Studio 2026.1 的安装记录指向 `D:\soft\ad s\bin\studio.exe`，`flutter emulators` 可列出 `Innocence_API36_Pixel7`，`flutter devices` 可识别正在运行的 Android 16 模拟器。尝试以本机 computer-use 运行时核对 IDE 的 Device Manager／Run 按钮时，运行时初始化失败（找不到指定路径），因此 IDE 图形界面操作未验证；本节的安装与启动证据均来自 Android Studio SDK／Emulator 的命令行工具。

## 13. 侧边栏决策与 Android MD3 Shell 首批实现（2026-09-27）

用户明确选择左侧栏，并指定左上角“···”按钮收纳主功能；原五项底栏提案不再作为当前方案。首批 Android 专属 Shell 已在 `HomePage` 的 Android 分支接入 `AndroidHomeShell`：顶栏三点按钮触发 `ScaffoldState.openDrawer()`，MD3 `NavigationDrawer` 承载首页、计划、专注、陪伴、收件箱；统计、备忘录、设置与退出位于分隔线下。Windows 分支仍走 `AdaptiveDesktopHome`。

五个主入口目前展示当前会话模型的真实摘要与可用动作：首页显示今日计划、专注、签到与在线未读；计划可查看／勾选今日任务并打开既有编辑器；专注可开始、暂停／继续、结束及在服务端条件允许时签到；陪伴和收件箱可进入既有好友／团队／通知页。未登录离线时，陪伴与收件箱只显示登录要求，不呈现可能属于其他账号的社交摘要。当前月／年计划的独立手机页、聊天与通知详情、好友／团队／设置二级页尚未完成 MD3 重建；现有入口连接旧功能页不代表这些页面通过 A1/A2/A3 验收。当时未登录离线首发范围仍待确认，之后的用户决定见 §14。

| 实际命令／检查 | 结果 | 边界 |
|---|---|---|
| `flutter analyze --no-pub` | 退出码 0，`No issues found` | 静态检查，不代表设备交互 |
| `flutter test --no-pub --reporter expanded` | 退出码 0，68 项通过；新增 3 项验证三点抽屉、目的地切换、系统返回、离线社交摘要隔离与今日任务回调 | 使用合成模型；真实登录与租户负向路径仍待回放 |
| 临时设置 `GRADLE_OPTS=-Dorg.gradle.project.kotlin.incremental=false`，`flutter build apk --debug --no-pub` | 最终构建成功；APK 180,080,431 字节，SHA-256 `3CDD880F1E3AB384F0E165C9844DF9C6691D1A4C31DF3BE5031ADFA485CF8ECC` | Debug APK 非正式签名包 |
| `adb install -r`、`adb shell am start -W` | 最终 APK 安装 `Success`；冷启动 `Status: ok`、`TotalTime: 3131` ms；应用 PID 12576 保持运行 | Android 16／API 36 Pixel 7 模拟器；无实体手机 |
| 模拟器点击、系统 Back、浅／深色与 1.5 倍系统字体截图 | 三点按钮打开侧边栏，五个入口与次级入口可见；计划页可进入，返回首页；离线陪伴页仅显示登录要求；深色大字体下侧栏入口未见截断 | 截图 `F:\AndroidSdk-Innocence\captures\innocence-nav-*.png`；未逐页做真实数据业务闭环 |
| `adb logcat -d --pid=12576 -v brief` 筛选 Flutter 致命异常 | 未见 `FATAL EXCEPTION`、`E/flutter`、`Unhandled Exception`、`FlutterError` 命中 | 只覆盖本次模拟器运行窗口 |

此时 Android A0 尚差未登录离线首发范围、实体手机和 SDK 许可；A1 总门槛尚差资料／设置 MD3、真实认证及负向接口、键盘避让和真机系统返回。主导航形态已定，不应再恢复底栏。离线范围的后续决定见 §14。

## 14. Android 未登录本机离线首发决策与重启恢复（2026-09-27）

用户对“未登录时的‘离线使用’入口，是否保留在 Android 首发版？”明确回答“是的”。因此入口属于 Android 首发范围，不再是 A0 待决项。离线使用只进入本机 `local:profileUuid` 资料域；陪伴和收件箱仍显示需登录，不展示其他账号的社交缓存。离线签到仅为待校验意图，不能标记成服务端成功。登录后的导入预览、目标账号确认及冲突策略保持原约束。

实现上，Android 在用户显式进入本机离线模式后记录入口状态。下次进程启动时先查找既有 SQLite 本机资料，再恢复相同 ownerScope 的计划、专注、备忘录与本地设置；若资料不存在，清除入口状态并返回认证页，不静默创建新身份。成功保存在线会话或明确退出会清除离线入口状态，SQLite 资料保留供后续确认导入。该入口状态只适用于 Android，Windows 原有启动行为不变。

宿主测试覆盖显式离线 → 持久化计划 → 新控制器恢复、保留在线凭据时离线选择优先、退出后清理入口状态、在线会话保存清理状态与缺失资料负向路径。Android 16／API 36 Pixel 7 模拟器重新安装 Debug APK 后，点击“Continue offline”并确认，首页呈现“On-device profile”；`am force-stop` 后 `am start -W` 为 `LaunchState: COLD`、`Status: ok`，再次显示离线首页和本机资料标识。通过三点侧边栏点击“Sign out”后，冷启动显示“Password login”和“Continue offline”；本机 SQLite 文件仍存在，再次显式进入离线模式可回到本机首页。APK 为 180,082,003 字节，SHA-256 `4419C41C4BCF247722C4897E2EB6797EE91B27F24196EB523BA3AE50EDC47AC0`；应用 PID 13123 的 `logcat` 未筛出 `FATAL EXCEPTION`、`E/flutter`、`Unhandled Exception` 或 `FlutterError`。模拟器复验不代替实体手机、真实认证与导入 HTTP 回放；A0 仍缺实体手机启动与 SDK license 处理，A1/A2 页面和真实业务闭环仍未完成。
