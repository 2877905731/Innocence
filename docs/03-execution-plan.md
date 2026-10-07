---
schema_version: 1
document_type: execution_plan
project_name: "Innocence"
project_profile_path: docs/08-project-profile.md
baseline:
  project_root: "F:\\springmvc1\\Innocence"
  runtime: "Flutter + Java 21 + Spring Boot 3.3.2 + MyBatis + MySQL 8 + Redis"
  current_phase: P01
  current_gate: G01
  evidence: "2026-10-07 v1.2.3+8正式发布（0105）：188 Flutter/4配置跳过、19离线/73后端/4 DPAPI，Windows/Android正式包版本/签名/权限/CRC/摘要通过；API36覆盖冷启动备忘录保留/错误筛选0；四项公开下载200。鸿蒙0106独立未签名预览公开，0107单设备签名安装启动及PC全屏通过；G01及真实模型/HTTP/完整设备矩阵仍待"
android_track:
  status: in_progress
  plan_path: docs/planning/Innocence-Android版本实施规划.md
  current_step: "v1.2.3+8正式离线APK已发行，同证书/无INTERNET；0105记录正式v1.2.2覆盖升级冷启动备忘录保留与公开下载。实体设备/OEM/Vulkan/长期恢复/同步及A0–A5继续待"
  ui_system: "Material Design 3 交互基础 + 简约白色／液态玻璃两套视觉（2026-09-29 用户新决定覆盖移动适配后置）"
  note: "Android 首发已确认左上角三点侧边栏（首页／计划／专注／陪伴／收件箱）及未登录本机离线入口；两主题使用同一会话和业务模型。主题接入不代表全部详情页或实体手机验收，真实导入回放仍须单独验证。规划不改变 P01/G01 状态"
harmonyos_tablet_track:
  status: unsigned_preview_published_physical_signed_install_start_verified
  plan_path: docs/planning/Innocence-鸿蒙平板版本实施规划.md
  checkpoint: "0107"
  user_scope: "Air系列平板/HarmonyOS 7，全屏复用PC页面；不做Windows窗口尺寸调整。0098先规划、0099恢复核对，用户随后明确开始制作；0100首批实现"
  order: [H0_toolchain_and_minimal_hap, H1_fullscreen_pc_shell, H2_offline_storage, H3_page_and_touch_parity, H4_online_contract_and_assistant, H5_device_and_release]
  pending_decisions: "真实设备型号代码已核对LRT-W20/HarmonyOS7/API26，具体市场年款与方向策略继续核实；平板槽位在H4前确认；正式联网包范围及H5公开分发仍待完整验收"
  evidence_boundary: "0106独立未签名预览4资产摘要/匿名下载、两架构完整编译/10回归和新版x64模拟器安装/冷启动/PC全屏通过；0104历史四主题/初始存储证据保留。0107实际aarch64平板的单设备Profile、ARM64构建112.3秒/官方验签、安装和解锁后启动通过，App root/截图2800×1840、PC语言/计划页面有画面，PID三个错误筛选0；设备签名包仅F盘私有。当前保留用户页面，真机冷启动/输入/业务恢复、旧模拟器输入法与玻璃编辑、HUKS/槽位/联网及H5/G01仍待；Debug声明INTERNET，不计正式离线分发"
assistant_track:
  decision: "DEC-0050/0090采用B；DEC-0051/0092修正为自填API Key的全局聊天助手；DEC-0052/0093地址与密钥发现模型"
  status: byok_chat_discovery_implemented_fixture_verified_live_provider_and_device_pending
  plan_path: docs/planning/Innocence-AI智能助手B方案实施与契约.md
  order: [byok_multiturn_chat, app_tool_registry, live_provider_and_device_verification, remaining_plan_and_template_tools]
  next_step: "聊天主入口与14项工具、地址与密钥获取模型/自动协议验证已实现；用户在软件填真实服务地址和Key、选择返回模型并保存连接，核对实际发现/生成与函数调用，再补完整登录HTTP/同步/未接工具与设备矩阵"
  evidence_boundary: "七项端点、真实SQL/SQLite、双协议loopback fixture、原生Windows DPAPI与双端开发构建有证据；真实模型/完整登录HTTP/Android Keystore设备及Windows运行画面未验；C持续规则不包含，正式离线发行与原G01门禁保持"
home_visual_refinement:
  decision: "DEC-0054/0095覆盖DEC-0053视觉：用户要求包括橙色阶梯图形在内按最早minimalism.html重做简约白，当前方案归为废案；面板与背景明确区分"
  implementation: "MinimalWhiteHero与MinimalWhiteBackdrop重建黑白灰排版和中性画布，WhiteSurfacePanel实色白/1px边界/直角/无阴影；窗口/侧栏/计划页签/共享表面同步。FocusTimerDial继续读取现有计时源；业务/四主题存储/Focus Orb行为及正式发行保持"
  evidence_path: docs/development/简约白最早基准重建与验收.md
  remaining: "Windows原生L/M/S多DPI、实体Android/输入法与长期性能仍待验"
invariants:
  - id: INV-001-TRUTHFUL-SCOPE
    enabled: true
    rule: 占位、mock-only、未验证输出不计完成；证据字段必须真实
  - id: INV-002-TENANT-ISOLATION
    enabled: true
    rule: 业务数据必须绑定当前登录用户上下文，越权访问有负向测试
  - id: INV-003-CONTRACT-FIRST
    enabled: true
    rule: 接口契约与字段语义固化后再实现前端调用
  - id: INV-004-NO-SECRETS
    enabled: true
    rule: 邮件密码等凭据走环境变量（INNOCENCE_MAIL_PASSWORD），不进仓库
  - id: INV-005-UI-REWRITE
    enabled: true
    rule: 前端页面按新设计推翻重建，不沿用旧布局；功能逻辑与数据层保留
  - id: INV-006-THEME-PROMPTS-ARCHIVED
    enabled: true
    rule: 用户提供的主题提示词必须存档于 docs/planning/Innocence-UI设计规划.md
  - id: INV-007-OFFLINE-OWNER-ISOLATION
    enabled: true
    rule: 未登录离线资料、账号缓存与服务端租户必须由 ownerScope 隔离，登录后先预览并确认目标账号再导入
phases:
  - id: P00
    name: baseline_and_governance
    deliverables:
      - AGENTS.md
      - progress/0000__AI-RESUME.md
      - progress/INDEX.md
      - docs/00-current-state-audit.md
      - docs/01-product-scope.md
      - docs/02-contract-and-compatibility-rules.md
      - docs/03-execution-plan.md
      - docs/04-future-integration.md
      - docs/05-git-version-control-policy.md
      - docs/06-contract-inventory.md
      - docs/07-dataflow-and-module-map.md
      - docs/08-project-profile.md
    gate:
      id: G00
      criteria:
        - documents_consistent（docs 间互相引用无断链）
        - baseline_evidence_reproducible（git log 可复现）
        - planning_docs_unchanged（并存引用，不迁移）
  - id: P00.5
    name: ui_design_system
    deliverables:
      - docs/planning/Innocence-UI设计规划.md（信息架构 + 双端布局 + 视觉令牌 + 组件）
      - docs/planning/Innocence-Windows自适应桌面体验.md（Large / Medium / Small / Focus Orb）
      - docs/planning/Innocence-Windows信息架构与组件体系.md（页面清单 + 导航地图 + 跨尺寸优先级 + Flutter 呈现接口）
      - Windows 四个主题设计（并存可切换，提示词由用户提供并先存档）；Android 首版另按 MD3 规划
      - 页面清单与导航地图（登录 → 主框架 → 首页 → 二级页）
    actions:
      - 四个主题提示词已存档；Windows 信息架构与组件接口已获用户确认
      - Windows 按「信息架构 → 桌面布局 → 视觉令牌 → 主题 → 组件」产出；Android A0 单独确定 MD3 手机布局与组件
      - 生成 Flutter 前端时优先将 `docs/design/templates/` 中对应 HTML 作为构图、信息层级和视觉令牌参考；若 AI 参考 HTML 不便或 HTML 到 Flutter 的转换效率较低，可忽略 HTML 代码，仅依据提示词、设计令牌和页面结构实现
      - Windows 页面按 Large / Medium / Small 三档自适应重排，Focus Orb 作为用户主动进入的最小状态；不得等比缩放完整页面
    gate:
      id: G00.5
      status: passed
      passed_at: "2026-08-10T09:22:16+08:00"
      criteria:
        - theme_prompts_archived（提示词原文存档）
        - four_themes_designed（色彩/质感/动效可落地）
        - desktop_adaptive_canvas_approved（四形态信息优先级、断点与状态连续性固化）
        - page_inventory_approved（页面清单与导航地图用户确认）
  - id: P01
    name: account_and_basics
    actions:
      - 认证/会话/权限/设置模块收尾；会话槽位、黑名单、租户边界与头像上传服务端真实 HTTP 回放已完成
      - 按新 UI 重建：登录、注册、找回密码、资料、隐私、设置页面
      - DesktopPresentationTier、自适应 6+2 主 Shell、72×72 圆形 Focus Orb、认证入口与设置资料链路已落地；设置页与 Orb 必须绑定当前视觉主题，DPI 与真实文件选择待实机验收
      - 按 `docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md` 完成未登录离线入口、local profile、本地仓储、离线安全设置分区与登录后导入确认
    gate:
      id: G01
      status: in_progress
      criteria:
        - auth_flow_ui_redesigned（源码、部件测试与 Windows Release 构建已通过；DPI 实机待验收）
        - session_policy_verified（1 手机 + 1 电脑；真实 HTTP 回放已通过）
        - negative_tests_passed（拉黑/越权访问；服务层与真实 HTTP 回放已通过）
        - offline_access_and_owner_scope_verified（无需登录可进入本地资料；离线资料、账号缓存和服务端租户互不可见；登录前无受保护接口请求）
  - id: P02
    name: learning_core_loop
    actions:
      - 计划/定时/签到/备忘录/首页收尾（已实现部分验收）
      - 按新 UI 重建：首页聚合、计划（短/长/超长）、定时与番茄、签到、备忘录页面
      - 今日计划编辑器使用固定可见的48段昼夜时间轴，完整中英文覆盖，并保证选时后无需额外填写即可保存
      - 今日计划时段按计划使用循环浅色渐变；计划卡显示等量同色小时间条并联动动画；已有时段支持首尾拖动且不得越过相邻计划，新建仅允许从空白段开始
      - 计划层级按 2026-09-23 最新决策：短计划当前安排可保存为任务存档；长计划完整月历显式展示存档架、新建入口及批量套用；超长计划为独立年度任务板，七色高辨识的唯一脉冲充能框以用户编辑月份为完整外框、以持久化 0–100% 任务进度为内部填充，取消单独进度条；充能框与 12 月槽位共用坐标、月份刻度滚动吸顶，+10/−10、+5/−5、+1/−1 成对控制并可直接完成或减量回退，多子任务完成/编辑/删除独立保留；今日计划增加本月超长任务分页，首页今日完成率以当天完成比例计算；旧周视图只保留兼容辅助
      - Windows 首页 Hero 按主题 + 本地日期 + 语言稳定轮换文案，四主题使用独立艺术字构图，侘寂主题允许英文主标题；Android 首版按 MD3 首页呈现
      - 玻璃态通用主操作改用蓝紫主题色，绿色仅用于成功语义
    gate:
      id: G02
      criteria:
        - personal_loop_closed（计划→学习→记录→签到→统计）
        - today_plan_editor_redesigned（48段时间轴和保存始终可见；选时后可直接保存）
        - today_plan_range_editing_verified（多计划颜色可区分；计划条数量与半小时格一致；首尾拖动防重叠；占用段不触发新建）
        - planning_horizons_operational（短计划保存后可编辑并归档；月历可前后月滑动、管理任务存档并批量套用；年度任务可按月筛选、编辑跨度和子任务、独立增量或直接完成、删除；今日页可浏览本月超长任务，首页今日完成率随勾选变化）
        - theme_hero_rotation_verified（Windows 四主题文案池、同日稳定、跨午夜轮换、双语与专注态优先级通过；Android 首版不以四主题 Hero 为门禁）
        - glass_action_palette_aligned（蓝紫主操作，绿色仅表达成功）
        - focus_timer_redesigned
  - id: P03
    name: social_skeleton
    actions:
      - 好友、团队、私信、团队群聊、提醒、队友进度可见（主要剩余开发量）
      - 按新 UI 重建：好友、团队、会话、通知页面
      - WebSocket 实时通道落地
    gate:
      id: G03
      criteria:
        - team_loop_closed（建队→看进度→提醒→完成通知→群聊）
        - ws_realtime_working
        - privacy_boundary_verified（陌生人不可私信、仅队友可见学习数据）
  - id: P04
    name: results_and_governance
    actions:
      - 统计中心完善、举报处理、敏感词管理、公告与定向通知、后台管理
      - 按新 UI 重建：统计中心、后台页面
      - Windows 统计中心所有内层指标卡跟随四主题；顶部返回、刷新和窗口操作固定，正文独立滚动；Android 统计页按 MD3 独立设计
    gate:
      id: G04
      criteria:
        - stats_complete（趋势图 7/30 天、双完成率、失败摘要、队友摘要）
        - admin_governance_working（举报→审核→处罚留痕）
        - admin_audit_trail_present
  - id: P05
    name: adaptive_desktop_experience
    actions:
      - 落地 canvas / orb 原生 Windows shell；canvas 内由 Flutter 响应 Large / Medium / Small
      - 完成窗口边缘吸附、置顶、托盘、DPI、多屏和安全状态持久化；首次 Canvas 按当前显示器工作区约 `84% × 82%` 居中显示为适中 Large，之后严格恢复用户上次的 Canvas 尺寸与位置
      - 页面不在 P05 末尾补做响应式；P01-P04 重建页面时同步实现三档布局
      - 完成四主题跨尺寸视觉统一与桌面通知联动
      - 顶部常驻从左到右逐级缩小的三个圆环，分别一键进入 Large / Medium / Small Canvas，不使用弹出菜单；四边和四角由 Flutter 透明缩放框触发原生 Windows sizing loop，顶层 WM_NCHITTEST 只作补充，预设和手动尺寸共用窗口记忆
    gate:
      id: G05
      criteria:
        - large_canvas_supports_full_workspace（完整工作台与并列上下文）
        - large_canvas_is_first_launch_default（首次按工作区约 84%×82% 居中，接近 Codex 桌面窗口占屏比例，完整但不过度占屏）
        - canvas_bounds_are_user_memory（用户拖拽后的 Canvas 尺寸与位置跨设置页、Orb 和后续启动保持；仅对旧版过大历史值执行一次迁移）
        - small_canvas_supports_core_actions（专注、计划、消息、通知核心操作）
        - focus_orb_restores_context（主动收纳、状态可见、恢复不丢上下文）
        - resize_state_continuity_verified（拖拽跨断点不丢页面、草稿、滚动与计时状态）
        - resize_presets_and_cursors_working（大中小预设进入对应断点；Windows Release 在四边四角真实拖动后尺寸改变，方向光标、最小尺寸、最大化与 Focus Orb 行为正确）
        - cross_device_notify_working
        - visual_consistent（Windows 四主题跨尺寸一致；Android 首版另按 MD3 与共同业务语义验收）
  - id: P06
    name: mvp_acceptance
    actions:
      - 对照 MVP 完成标准 9 条逐条验收
      - Windows 四主题可切换与跨尺寸观感验收；Android 首版 MD3 页面及双端业务语义一致性分别验收
      - Windows Large / Medium / Small / Focus Orb 在 100% / 125% / 150% DPI 与多屏场景验收
    gate:
      id: G06
      criteria:
        - mvp_9_criteria_all_passed
        - four_themes_switchable
        - release_candidate_confirmed
next_actions:
  - id: NEXT-001
    action: "使用本地服务完成 import-preview/import 的真实 HTTP 回放，覆盖幂等重试、目标账号不匹配、保留云端与本地覆盖两种冲突策略"
    inputs:
      - docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md
  - id: NEXT-002
    action: "在 Windows Release + 100%/125%/150% DPI 下完成八方向真实拖动验收；自动化环境不可用时不得将此项标记完成"
    inputs:
      - docs/planning/Innocence-Windows自适应桌面体验.md
---

## 2026-10-07 鸿蒙预览已分发（0106）

`v1.2.3-harmonyos-preview.1` / Release#404950703 已公开，4项资产摘要与匿名下载通过；两架构原生编译、10平板配置回归及新版x64安装/进程冷启动/PC全屏子项通过。当前为未签名Debug，实体平板仍需设备Profile/签名；输入法错误2条、玻璃编辑/业务恢复及H5/G01仍待。正式Windows/Android latest继续v1.2.3。

## 2026-10-07 真实平板签名安装与启动（0107）

用户实际LRT-W20/HarmonyOS7/API26/aarch64通过USB调试授权，单设备Debug Profile与当前设备在内存中匹配，全部材料位于F盘。ARM64签名HAP默认构建exit0/Hvigor112.3秒、官方SDK验签、包CRC/版本8/ELF/113共享源码核对通过。HDC安装成功；锁屏10106102由用户手动解锁后解决，EntryAbility启动/进程存在，2800×1840 PC全屏语言/计划页面有真机画面。当前PID三个错误筛选0，仅覆盖当前启动子集。

设备绑定的签名HAP保存在本机忽略目录，公开预览资产与历史发布说明保持原范围。检查期间用户页面发生变化且计划编辑出现未保存内容，停止点击并保持用户页面，等待用户处理草稿后再确认重启；真机冷启动、业务保存恢复/覆盖升级与完整H5/G01继续待。
