---
schema_version: 1
document_type: platform_implementation_plan
project_name: "Innocence"
platform: HarmonyOS_tablet
created_at: "2026-10-05"
updated_at: "2026-10-06"
status: emulator_pc_shell_running_input_method_and_device_pending
authority: "用户要求鸿蒙平板全屏复用PC页面；先规划后明确开始制作"
target_device: "用户原文airpaid；暂按华为MatePad Air系列理解，具体年款/型号待设备核实"
target_os: "HarmonyOS 7（用户提供）"
related_checkpoint: "0104"
related_gate: "沿用P01/G01；新增H0-H5平台验收，不将规划计为实现"
---

# Innocence 鸿蒙平板版本实施规划

## 1. 已确认的目标与实施状态

用户原文：

> 我想做一个华为鸿蒙平板的版本，页面布局完全使用pc版，但是他不需要做到窗口尺寸调整，因为本身就是全屏打开的

设备补充原文：

> airpaid 鸿蒙os7

后续指令原文：

> 要不你先做一个计划

据此确定页面方向：鸿蒙平板使用PC版的导航、首页、日/月/年计划、专注、统计、备忘录、陪伴、收件箱、设置与助手页面，保留现行主题和业务语义。应用以全屏工作台打开，不提供Windows式窗口尺寸调整。

0098的交付是实施计划，前期少量试改经0099核对恢复。用户随后明确“开始制作鸿蒙版本”，进入0100首批实现：生成原生工程、接入PC页面能力规则、固定鸿蒙插件并通过共享代码分析和ARM64 Dart kernel编译。用户提供官方ZIP后，0102继续完成DevEco26/API26、四插件注册、ArkTS/ARM64原生编译和未签名Debug HAP；0104已在API26/x64模拟器安装启动；真实平板调试签名和完整原生业务验收仍待。0097及之前的Windows/Android开发成果和正式v1.2.2资产继续作为各自基线。

“MatePad Air系列”是对用户设备名称的暂定理解，不据此猜测屏幕尺寸、年款、处理器或物理分辨率。H0从实际设备信息取得这些值。

## 2. 页面与交互范围

| 项目 | 平板目标 |
|---|---|
| 全局结构 | 复用PC完整工作台：侧边导航、顶部页面信息、主内容及对应详情/上下文区域 |
| 业务页面 | 复用现有PC页面和组件，不换成Android手机摘要Shell或手机月/年详情页 |
| 主题 | 按PC现行四主题复用；简约白以0095/DEC-0054为准，不恢复旧柑橘方案 |
| 窗口操作 | 移除L/M/S尺寸按钮、八方向拖边、拖动标题区、最小化/关闭控件和窗口边界记忆 |
| Focus Orb与托盘 | 不接Windows桌面悬浮球、托盘、开机自启或置顶；主页面专注功能与计时仍保留 |
| 设置 | 保留业务、账号、语言、主题与隐私设置；隐藏Windows窗口行为设置，不能留下不可用开关 |
| 全屏与安全区 | 使用系统允许的全屏内容区；处理状态栏、导航/手势区和安全区，隐藏系统栏另作设备验证 |
| 屏幕密度 | 按实际逻辑像素布局，调整列宽、边距、表格与滚动；不把整个PC窗口等比缩成一张图 |
| 软键盘 | 输入时保持当前导航、PC页面和草稿；通过内容滚动/避让露出输入与提交，不因高度减少切换为Small Canvas |
| 触控 | 给按钮、时间范围/年度进度手柄足够触控面积；必要操作不能仅靠悬停、右键或双击，键鼠入口可保留 |
| 系统返回 | 页面/弹层逐级返回；草稿取消与会话退出语义明确，不调用Windows关闭窗口接口 |

首轮验收建议以横屏全屏为主，因为它最接近PC工作台。用户尚未要求锁定横屏；H0确认设备与系统能力后确定方向策略。若支持竖屏，也保持PC页面体系，用列宽重排和滚动保证可达，不切入手机Shell。系统分屏/自由窗口不是本轮产品目标，但系统改变可用区域时仍须保护数据和输入状态。

不需要Windows窗口尺寸调整，不等于不处理平板屏幕密度、安全区、系统字号和软键盘；这些属于正常可用性。

## 3. 技术路线与现有代码边界

推荐优先评估鸿蒙兼容Flutter工具链，在现有共享Flutter工程上增加鸿蒙宿主和原生适配，通过HAP进行设备调测。页面和业务代码尽量共用，平台存储、文件、密钥和生命周期通过适配层实现。H0先证明这条路线可编译/启动，再进入完整页面迁移。

华为官方资料将HarmonyOS 7对应至API 26；SDK目标、最低兼容API、Flutter鸿蒙分支和引擎版本仍须组合验证，不能仅把版本号填入配置就认为支持。现行Windows/Android使用的Flutter 3.44.4工具链应保留，鸿蒙工具链和构建缓存单独管理。[华为HarmonyOS开发者官网](https://developer.huawei.com/consumer/cn/?tab=Public)

Flutter的OpenHarmony兼容扩展由OpenHarmony-SIG维护，需要核对所选分支、Dart/Flutter API与插件适配；本计划不声称Google标准Flutter工具链已经能直接构建鸿蒙HAP。[OpenHarmony-SIG Flutter源码与说明](https://gitee.com/openharmony-sig/flutter_flutter)

| 代码位置 | 现状与计划改造 |
|---|---|
| `client/flutter_app/lib/core/config/app_config.dart` | 当前只区分Windows/Android，其他平台回落Windows；增加真实鸿蒙平台识别，不能让鸿蒙伪装成Windows；把系统类型、平板布局与原生能力分开 |
| `client/flutter_app/lib/app/app.dart`、`features/auth/presentation/pages/auth_page.dart` | 启动、语言和认证按平台决定手机/桌面入口；改用呈现策略，让平板使用PC入口，认证设备身份独立处理 |
| `client/flutter_app/lib/features/home/presentation/pages/home_page.dart` | Android进入手机Shell、Windows进入`AdaptiveDesktopHome`；平板明确接PC页面路由 |
| `client/flutter_app/lib/core/layout/desktop_presentation.dart`、`core/widgets/adaptive_canvas_shell.dart` | Windows尺寸策略与页面编排耦合；拆出全屏平板策略，共用PC页面，不带Windows尺寸操作，不因键盘降档 |
| `client/flutter_app/lib/core/platform/desktop_widget_bridge.dart`与桌面控件 | 仅在具备Windows原生能力时启用；平板不注册窗口/托盘监听，不调用桌面MethodChannel |
| `client/flutter_app/lib/core/local/offline_store.dart` | SQLite工厂当前没有鸿蒙分支；接入可验证的鸿蒙SQLite适配，保留schema version 6、事务、ownerScope及outbox语义 |
| `client/flutter_app/lib/features/assistant/data/chat_repository.dart` | 配置依赖`innocence/assistant_vault`加密通道；补鸿蒙安全存储实现，无明文兜底 |
| `server/.../modules/account/service/AccountService.java`、`SessionAuthService.java` | 当前不接受鸿蒙设备类型；联网前先固化设备类型/槽位契约，再同时改注册、登录、会话校验和退出链路 |

插件逐项核对：`shared_preferences`、`path_provider`、`sqflite`、`file_selector`及各自传递依赖。不能把“纯Dart部分可复用”当作“插件已有鸿蒙实现”。玻璃主题的`.frag`着色器、背景模糊、纹理方向、动画性能也必须在所选引擎和真机上单独核对。

若关键依赖或引擎与现有API不兼容，H0输出明确失败项及候选版本/适配方案，再选择局部原生桥或有限共享代码兼容改造；不静默重写为另一套业务工程，也不全局替换现有双端SDK。

## 4. 分阶段实施与交付门禁

| 阶段 | 主要工作 | 可检查的交付物 | 通过条件 |
|---|---|---|---|
| H0 环境与最小启动 | 确认具体设备、系统build/API与逻辑尺寸；定位/准备DevEco、HarmonyOS SDK、鸿蒙Flutter工具链；核对依赖和签名方式 | 工具链版本清单、依赖支持矩阵、最小无业务HAP、构建/启动记录 | 最小HAP在鸿蒙平板或匹配环境启动；阻塞项明确；合成数据/无真实凭据 |
| H1 平板全屏Shell | 分离平台、布局与原生能力；接PC导航/认证/二级页面框架，移除窗口控件；处理安全区与键盘 | 共用页面路由与平板策略、全屏首页/认证/二级页截图 | PC导航可达；没有手机Shell、尺寸按钮、拖边或Orb；键盘不丢页面/草稿 |
| H2 离线基础 | 接偏好/路径/SQLite与本机资料恢复；核对schema迁移、事务、outbox与身份隔离；保留原计时状态来源 | 原生存储适配、合成资料冷启动/升级恢复证据 | 日/月/年计划、年度子任务、备忘录与专注可保存/恢复；账号缓存与本机资料不串域 |
| H3 全页面与触控 | 对照PC逐页核对完整功能，适配范围/进度拖动、长表单、弹层、返回、系统字号、四主题 | 页面覆盖表、触控与视觉证据、修正清单 | 各业务入口及详情可达；无溢出/遮挡/失效操作；暂停/继续/结束及年度进度保持业务语义 |
| H4 联网与助手 | 先确认设备槽位，再接真实设备类型/会话与HTTPS环境；文件选择/头像；鸿蒙安全存储；BYOK模型发现/聊天/工具；补真实同步 | 契约决策、服务端与客户端适配、HTTP负向及真实供应商/设备证据 | 登录/退出/替换、同步/冲突、加密与跨用户负向通过；工具操作保持确认/校验/幂等/撤销边界 |
| H5 真机与发行 | 在用户平板验证安装、覆盖升级、冷启动、前后台/锁屏/进程重建、耗电、玻璃性能；准备签名/权限/摘要和说明 | 签名HAP候选包、设备验收表、发布说明、SHA-256清单 | 候选包及升级保留资料验证通过；未验证项明确；正式分发按用户后续发布指令执行 |

推荐优先交付范围是H0→H1→H2→H3的可用本机版本，随后补H4联网与助手，最后H5发行。这个顺序是实施建议，不代表用户已选择“仅离线正式发行”；正式包是否包含联网要在打包前明确。

不预报完整工期：H0完成后依据Flutter兼容性、插件原生缺口和可用真机再估算。任何阶段失败都记录命令、结果、改动和下一步，不以模拟器/宿主渲染覆盖真机验收。

## 5. 联网前必须固化的设备与数据契约

1. **真实设备类型**：建议新增`harmonyos`，与`tablet`呈现策略分开；最终值在H4前固化。认证请求、`X-Device-Type`、当前会话展示及服务端允许列表须一致，不能临时上报`windows`来绕过限制。
2. **会话槽位**：现行规则是“一台手机 + 一台电脑”。平板是否占`mobile`槽位，或新增`tablet`槽位以允许手机/电脑/平板同时在线，尚未确认。保守建议先维持两槽位上限；三设备并发属于业务变更，须记录用户决策后实施。
3. **本机资料**：平板新增独立本机资料和设备ID；登录前数据仍按ownerScope隔离，导入仍须预览目标账号并由用户确认，不自动与手机本机库合并。
4. **同步与计时**：继续原实体冲突规则、日计划修订、outbox与幂等；前后台/锁屏后按原会话时间与暂停状态恢复，不另建UI计时真源，也不承诺后台永不被系统终止。
5. **服务地址与权限**：设备不能沿用PC的`127.0.0.1`或Android模拟器专用`10.0.2.2`作为正式服务地址；构建环境显式配置HTTPS服务，权限与联网包范围匹配。
6. **助手安全**：按当前owner加密存模型配置，密钥不写明文偏好/日志/仓库，不随业务同步。模型/工具/原排程范围沿0092/0093，不把现有未接工具计为平板新增完成。

固化结果需同步接口清单、兼容规则、产品范围、数据流/设备槽位记录及相关回归；在这之前不实现依赖新设备契约的在线调用。

## 6. 验收矩阵

| 维度 | 必须覆盖的路径 |
|---|---|
| 页面一致性 | PC主导航、完整日/月/年计划、专注、统计、备忘录、陪伴、收件箱、设置与助手；管理页按当前权限可见 |
| 窗口边界 | 全屏启动；无窗口控件/拖边/Orb；屏幕实际密度、安全区；键盘出现/收起后页面与草稿保留 |
| 输入与无障碍 | 手指拖动计划范围/年度进度、系统输入法、返回、长标题/长内容、中英文、系统大字体；外接键鼠作为补充 |
| 视觉 | 四主题；简约白面板与画布边界、字标/表盘；玻璃背景/折射、滚动/弹层及持续性能 |
| 持久化 | 合成数据写入、重启、进程终止、覆盖升级、SQLite迁移、ownerScope切换、离线数据导入与冲突回滚 |
| 专注 | 待开始/进行中/暂停、继续、正常/提前结束、重新开始；前后台/锁屏/进程恢复，不修改用户真实专注作验收样本 |
| 认证失败 `authentication_failure` | 错误或过期会话、重新登录/退出；不泄露缓存/凭据 |
| 租户不匹配 `tenant_mismatch` | owner变化、错误目标账号、其他账号资源不可读写，待执行助手动作取消 |
| 权限拒绝 `permission_denied` | 文件/系统权限拒绝、非管理员访问；明确失败且不伪报成功 |
| 缺失字段 `missing_field` | 空标题、无效日期/范围、模型列表缺id、无效设备类型；错误明确，不静默改语义 |
| 生成失败 `generation_failure` | 模型断网/超时/取消/不支持工具/无效提案；不写计划、不保存失败连接、不出现后续副作用 |
| 原双端回归 | Windows的L/M/S/Focus Orb和四主题、Android手机Shell与现有两主题路径继续通过相关检查 |

每个完成项记录命令、结果、changed_files与实际设备/环境。真机未覆盖的路径保持待验；不得以Android APK启动或宿主Flutter图片证明鸿蒙原生兼容。

## 7. 工具、签名与当前准备情况

初始核对未定位DevEco/SDK，0100记录了缺少SDK的失败命令。用户随后提供`F:/devecostudio-windows-26.0.0.851.zip`；已核对ZIP CRC、记录本机SHA-256，并验证其中官方安装器的Authenticode签名为Valid/Huawei Technologies Co., Ltd.。从官方包解压到`client/flutter_app/build/harmonyos-h0/tools/DevEcoStudio26`，不替换Windows/Android工具链。DevEco26.0.0.851、SDK26.0.0.105/API26、Node24.14.1、ohpm26.0.0.630与Hvigor6.26.8已用于实际编译；HarmonyOS doctor项通过。本机摘要记录不等于已经取得并对照官网发布的摘要。

华为官方的DevEco CLI环境说明要求准备DevEco Studio和Node环境；工具版本依所选SDK/Flutter兼容矩阵锁定。[DevEco CLI环境与安装说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-deveco-cli-install)

鸿蒙设备调测需区分OpenHarmony签名和HarmonyOS签名。华为官方自动签名说明涉及“Support HarmonyOS”以及华为账号登录；由用户完成账号登录和设备相关授权，不在聊天收集密码/签名私钥，不将签名材料纳入Git。[华为自动签名说明](https://developer.huawei.com/consumer/cn/doc/doccenter-deveco-studio/ide-signing-auto)

0102/0104时已生成未签名Debug HAP；2026-10-06用户完成DevEco登录，签名页因未连接设备缺少Profile，HDC当时目标0。0104随后解决独立工具许可目录导致的y/N等待，并在API26/x64模拟器安装启动，输入法首次协议/隐私仍由用户亲自选择。0107用户USB真机授权和签名确认后，实际LRT-W20平板的单设备Debug Profile及ARM64签名包已生成、官方验签/安装/启动通过，详情见第14节。签名配置和材料只在F盘忽略目录保存，源工程签名配置保持空；不记录真实UDID/私钥。GitHub公开预览按后续发布授权执行，华为应用市场上架尚未授权。

## 8. 下一步起点与待确认事项

用户已要求开始制作。H0现已具备维护仓库Flutter OH3.41.10-ohos-1.0.1/Dart3.11.5及官方SDK26。实际`harmonyos.ps1 -Action build -Unsigned`通过完整Hvigor原生编译，生成115144159字节ARM64 Debug HAP，SHA-256/ZIP CRC/目标API26及插件库结构核对通过。默认带签名构建仍要求调试签名，不能将未签名编译结果记为H0安装启动通过。工程及可重复命令见`client/flutter_app/harmonyos/README.md`。

待确认项按依赖时间处理：横屏/竖屏策略在H0/H1前明确；会话槽位在H4前明确；联网/离线正式包与分发方式在H5前明确。用户无需现在一次性决定所有事项。

当前默认横屏/反向横屏全屏，作为PC工作台实现基准，未将其记成用户确认的唯一设备方向。首轮鸿蒙强制本机模式，未固化H4设备槽位或联网政策。共享源码/kernel/ArkTS与四插件编译已通过；0104/0106有模拟器PC全屏/四主题及冷启动子集，0107有真机签名安装启动和PC全屏页面。SQLite业务恢复、文件选择、完整触控/四主题/软键盘、HUKS、真机冷启动/覆盖升级及正式发行保持待验。Debug HAP仍声明模板INTERNET权限，不能当作无网络权限的正式离线发行包。

## 9. F盘存放决策（2026-10-05，0101）

用户原文：“已经登陆进去了”“都存放在f盘”。鸿蒙新增工具包、工具链、SDK、依赖缓存、临时文件、模拟器与构建产物全部存放在F盘。统一根目录为`F:/springmvc1/Innocence/client/flutter_app/build/harmonyos-h0`，下载目录`downloads`、解压目录`tools`；已有Flutter OH/pub-cache/app/kernel也在此范围。构建脚本新增F盘路径校验与进程TEMP/TMP/npm缓存设置，退出后恢复环境；ARM64 kernel再次exit0、环境恢复核对PASS。原生工具取得后逐项核对ohpm/Hvigor缓存和模拟器目录。

0101当时官方页面截图可见Windows DevEco Studio26.0.0.851（3.1GB），按钮/DOM控制持续超时，未发起下载。该历史记录保留；用户随后提供F盘ZIP，取得文件后的SDK及原生编译进展见0102和下节。

## 10. SDK与未签名原生HAP（2026-10-06记录，0102）

官方ZIP为3295837057字节，SHA-256 `33ce2d302ecccdbc27287bd6523bd32c6f4da32c80d6c7f33057b83b1eefb9d9`。DevEco、SDK、Flutter OH、pub/ohpm/npm/Hvigor缓存、工具用户目录与IDE配置/索引/插件/日志均配置到F盘。进程环境15项恢复核对通过；该0102时点模拟器尚未创建；0103现已在F盘创建镜像和实例。CLI诊断另在Windows用户目录生成47字节许可状态，进程目录设置不能覆盖，尚未解决该元数据例外。

原生配置适配DevEco26：兼容`5.1.0(18)`，target`26.0.0`，由工具选择compile SDK；移除不覆盖业务的模板hypium依赖及默认ohosTest target，保留样例源码。脚本新增显式`-Unsigned`，支持启动IDE和保留暂存工程中的非空签名配置；修复Windows进程内Path/PATH重复导致子进程使用旧Node的问题，不改全局环境。

最终构建于2026-10-05完成，2026-10-06继续时核对摘要一致：`build -Unsigned` exit0/Hvigor18.7秒；HAP为115144159字节，SHA-256 `f10e480b990245d5e3ae8461941cdf108a4e7bb65c902d0c99a96ee10d3998d7`。ZIP CRC通过，元数据tablet/横屏/compatible18/target26/1.2.2+7，Flutter及SQLite库为ARM64 ELF，113个共享Dart文件与暂存源码逐字节相同。四插件原生注册及编译通过；完整平台运行门禁仍需签名安装和设备证据。

2026-10-06另补Windows模拟器的x64包：脚本`-Architecture x64`单独暂存到`app-x64`并传递`--target-platform=ohos-x64`，不覆盖ARM64工程与产物。实际未签名Debug构建exit0/Hvigor156.6秒，116763248字节，SHA-256 `23bb2b3b6af57f23ce72da76014ec14f6bd5d66c4c04b8cff1527312a811b928`；ZIP CRC及Flutter/SQLite的x86_64 ELF核对通过。0102旧包及清单现保留在`build/harmonyos-h0/archive/0102`，当前图标更新包见开发README。0103镜像和设备已准备，GUI启动尚无窗口/连接；安装启动、存储恢复与H0运行门禁仍待。

## 11. 镜像和设备实例（2026-10-06记录，0103）

用户报告“下载好了”后，核对官方镜像元数据为HarmonyOS7.0.0.107/SP8、API26、Release；六主要镜像文件存在及大小核对通过，不等于已取得官方摘要并作完整性比对。设备管理器创建MatePad Air12预设：x86_64、2800×1840/360dpi、4GB RAM/6GB ROM，镜像和设备目录均在F盘task-home；真实平板型号仍以用户设备核实为准。

实际GUI启动只有后台进程，没有可操作窗口，HDC退出0/目标0；官方CLI-start退出1并提示独立服务协议，日志打包失败，computer-use直接启动未返回窗口。Windows只读检查HypervisorPresent=True，不能代替完整虚拟化、驱动或启动诊断。已请求用户在设备管理器手动启动并反馈窗口或错误。未执行HAP安装/启动，原生SQLite/Preferences恢复、PC全屏、软键盘/触控/四主题以及真机Profile仍待。CLI诊断在Windows用户目录生成47字节许可状态，未复制许可或改系统安全/隐私设置，全部元数据的F盘约束还存在此例外。

## 12. 模拟器安装与PC页面（2026-10-06记录，0104）

0103之后用户反馈“一直在获取模拟器状态”，IDE日志明确原生工具后台等待y/N。IDE确认配置在F盘，独立原生工具读C盘；仅对本轮新建工具专用目录检查、保留旧47字节状态并建立F盘目录链接，既有许可字节保持，未改隐私标记。API26/x64模拟器随后启动，最新版未签名x64 HAP安装/EntryAbility启动成功，PC全屏root2800×1840、首页/计划/设置及四主题有原生画面；液态玻璃进程冷启动恢复。这完成模拟器安装启动子项，不代表真实ARM64平板签名或H0-H5/G01整体完成。

本机SQLite初始schema v6/17表/integrity ok；计划和任务行0。简约白输入QA_NATIVE/QA_TASK并添加任务，草稿未保存；小艺输入法首次协议/隐私页需用户亲自选择。此前玻璃编辑黑屏、输入法12800008/9仍待完成初始化后复验，业务SQLite写入/冷启动、软键盘、文件选择、完整触控/四主题矩阵仍待。真实平板USB调试及授权/Profile、HUKS/设备槽位/联网与发行按后续门禁。

## 13. 鸿蒙预览分发（2026-10-07）

用户在鸿蒙制作过程中要求“推送然后发布一个小版本”，随后追问“鸿蒙的平板版本呢，为什么不发布”。此前沿 Windows/Android 正式流程发布的 v1.2.3 未包含 HAP，范围理解没有覆盖本轮平板目标；补发独立 `v1.2.3-harmonyos-preview.1` GitHub 预发布，应用内版本仍 `1.2.3+8`。提供明确标注未签名的 ARM64 平板 / x64 模拟器 Debug HAP、签名说明与 SHA-256 清单，不能称为实体平板可直接安装的正式包。华为应用市场上架仍不属于此次 GitHub 分发。

0106公开预览时无真实平板连接或非空签名配置；DevEco 登录不能代替设备 Profile。两架构按当前源码重建，旧 0102/0104 HAP 保留；10 项平板配置回归通过。公开 HAP 的包结构及运行子项以该次发布说明记录；后续0107设备签名不改变公开资产仍为未签名包的范围。原输入法/玻璃编辑、业务保存恢复/升级、HUKS/槽位/联网及 H5/G01 门禁继续待验。

## 14. 实体平板签名、安装与启动（2026-10-07，0107）

实际连接设备为LRT-W20、HarmonyOS `7.0.0.109(SP6C00E105R2P3)`、API26、aarch64；这核对了型号代码，未据此猜市场年款。用户亲自允许电脑USB调试并完成DevEco签名确认。暂存工程自动签名材料全部存在且在F盘，仓库源配置仍无签名内容；Debug Profile只绑定一台设备，在内存中与当前平板UDID匹配，有效期截至北京时间2026-10-21 13:17:09。

默认ARM64带签名构建exit0/Hvigor112.3秒，115983291字节；官方SDK `verify-app`成功，CRC/版本1.2.3+8/横屏tablet/API/两份ARM64 ELF/113共享Dart一致性通过。SHA-256为`256390488fdbcc125d7d07e6a2cd7d2b61812efd6980265c724a0c84650b8624`。包与验证清单位于本机 `build/harmonyos-h0/signed-device/v1.2.3`，不上传包含设备Profile的签名包。

实际HDC安装成功；系统包根字段versionName1.2.3/versionCode8，插件嵌套字段不作为应用版本。首次启动因锁屏返回10106102，用户手动解锁后启动成功，PID34366。App root和截图为2800×1840，语言页及PC计划页有原生画面，Windows窗口控制不出现；该PID当前日志中Flutter致命异常、布局溢出及输入法12800008/9筛选均0，不能替代完整输入法/性能矩阵。

检查期间用户正在操作平板，页面变化后的一次点击使用了先前语言页坐标，随后观察到未保存的计划编辑页；已停止点击并保持用户内容。只读画面显示PC计划页可达；未写合成业务样本、未验证SQLite业务恢复或覆盖升级。冷启动需待用户先处理草稿并确认可重启后执行；H2/H3/H4及完整H5/G01仍开放。

## 15. 用户验收与GitHub发布授权（2026-10-07，0108）

用户原文：“我验收了，可以进行发布了”；发布渠道明确选择“GitHub 发布（沿用现有流程）”。记录为用户验收与发布授权，不补写用户未提供的逐项性能或自动化结果，不执行华为应用市场上架。

沿当前本机离线范围准备独立ARM64 Release/AOT构建，移除Debug模板INTERNET权限，暂存目录app-release与现有单设备签名工程分开。GitHub公开包不包含个人设备Profile/标识、密钥与密码；现有单设备签名包继续只在本机F盘保存。公开资产保持未签名并附接收者自行配置Profile/签名说明，Release构建模式不等于已获得通用正式签名。独立源标签v1.2.3-harmonyos.1，应用内版本仍1.2.3+8；Windows/Android正式latest仍v1.2.3。

用户验收与0107真机启动证据并存；业务恢复/覆盖升级、完整触控/键盘/性能与负向、HUKS/设备槽位/联网及完整H5/G01继续按实际证据推进。当前发布不终止用户正在使用的平板进程。

## 16. GitHub Release分发完成（2026-10-07，0109）

`v1.2.3-harmonyos.1` / Release#405446873已公开，非pre-release；ARM64 Release HAP/离线说明/SHA256三资产摘要和正文精确核对，匿名HTTP200/长度3/3。源码2825dea与注释标签c7e0f94通过官方API精确推送，旧Debug预览和双端latest v1.2.3保留。

最终ARM64 Release44.9秒/27698894bytes/SHA884fd2a7…，无INTERNET/JIT及个人设备材料；113Dart与native宿主、CRC/版本8/API/三ELF一致性通过。首轮Release首页root从y72开始，过早系统UI调用产生空白，最终首帧后设置全屏并扩展宿主SYSTEM区域；x64 Release44.3秒、实际安装/进程冷启动与2800×1840 PC首页通过，fatal/overflow0，输入法12800008/9仍2。分析4.4秒/10回归通过，QA模拟器已关闭。

当前用户平板进程和设备签名Debug包未操作。用户已验收此设备调试版本；公开ARM64 Release仍需接收者本机签名，未重装真实设备或验证真实Release覆盖/业务恢复。0109完成的是授权GitHub分发，完整输入/性能/恢复与HUKS/槽位/联网及H5/G01继续待。
