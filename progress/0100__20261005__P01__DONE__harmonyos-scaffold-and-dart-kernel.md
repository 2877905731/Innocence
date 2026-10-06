---
schema_version: 1
document_type: checkpoint
sequence: "0100"
created_at: "2026-10-05T21:13:25+08:00"
phase: P01
type: DONE
status: complete
title: "鸿蒙原生宿主与PC平板能力首批实现，ARM64 Dart kernel通过，原生SDK待接"
objective: "用户明确开始制作鸿蒙版本；完成可独立核对的宿主、共享PC页面与Dart编译，接续H0原生门禁，不将其计为可安装鸿蒙产品"
completed:
  - fact: "用户开始制作指令覆盖0098的仅计划等待状态；默认横屏/反向横屏用于PC工作台，方向仍可在设备核实时调整"
    evidence: "用户原文：开始制作鸿蒙版本；实施专档与UI存档已同步"
  - fact: "维护仓库Flutter OH3.41.10-ohos-1.0.1/Dart3.11.5及OH引擎已隔离准备，原生45文件模板生成后接入tablet、全屏和产品标签"
    evidence: "commit adaf911c35c9136a7d18fc424d714c9ec7724e60；OH引擎3fb08d34b6f96a15fbb219b903c9d0ab37b6c2e0；flutter create exit0/Wrote45 files；维护仓库已由旧Gitee迁至CPF-Flutter"
  - fact: "PC布局与Windows能力拆分；鸿蒙设备身份harmonyos，四主题PC材质、首页侧栏保留，窗口尺寸/拖动/托盘/Orb入口和桌面设置隐藏；键盘高度不切Small Canvas"
    evidence: "RuntimeCapabilities与DesktopPresentationLayout；Bridge13处能力守卫；平板部件/设置回归和8张合成图"
  - fact: "首轮鸿蒙强制本机模式，空账户API地址，恢复本机资料；SQLite选择OH原生工厂，四个OH插件固定commit，仅暂存工程使用依赖覆盖"
    evidence: "AppConfig离线门禁；OH package_config含file_selector_ohos/path_provider_ohos/shared_preferences_ohos/sqflite_ohos；pub解析77依赖后因原生SDK缺失失败；SQLite/Preferences原生运行未验"
  - fact: "最终共享113个Dart文件与暂存工程逐字节匹配；标准/OH源码分析无问题，ARM64 Dart kernel编译exit0"
    evidence: "app/.dart_tool/flutter_build/e0e8513c1a536fa42a1e916c5cc46858/app.dill：59006184字节/SHA256c8e33793f93d2e0ec3783f06675573297db02bfdb208ad58202928abc2b3a2bb；不是HAP"
changed_files:
  - path: client/flutter_app/ohos
    change: "维护者生成的原生宿主，tablet/横屏全屏/SDK26目标与Innocence标签；模板图标和示例测试保留为脚手架，不计业务验收"
  - path: client/flutter_app/harmonyos/README.md
    change: "固定工具链、开发命令、实际证据和原生SDK交接点"
  - path: client/flutter_app/harmonyos/pubspec_overrides.yaml
    change: "固定4个适配插件及Dart3.11兼容FFI/sqlite3；只复制到暂存工程"
  - path: client/flutter_app/tool/harmonyos.ps1
    change: "doctor/create/prepare/analyze/kernel/build，进程环境恢复、独立stage与可选Git代理/迁移/长路径处理"
  - path: client/flutter_app/lib/core/config/runtime_capabilities.dart
    change: "平台身份、PC布局、窗口能力和本机恢复策略"
  - path: client/flutter_app/lib/core/config/app_config.dart
    change: "真实鸿蒙识别与宿主验证flag、未知平台不回落Windows、首轮本机门禁"
  - path: client/flutter_app/lib/core/layout/desktop_presentation.dart
    change: "平板按逻辑宽度选PC工作台；键盘高度不切手机/Small"
  - path: client/flutter_app/lib/core/platform/desktop_widget_bridge.dart
    change: "所有Windows原生调用按窗口能力守卫"
  - path: client/flutter_app/lib/core/widgets/desktop_close_button.dart
    change: "窗口控制集合和独立尺寸/关闭/最小化按钮在非Windows不显示"
  - path: client/flutter_app/lib/core/widgets/desktop_drag_region.dart
    change: "拖动按窗口能力守卫"
  - path: client/flutter_app/lib/core/widgets/desktop_resize_frame.dart
    change: "边缘缩放按窗口能力守卫"
  - path: client/flutter_app/lib/core/widgets/secondary_page_scaffold.dart
    change: "详情页窗口控件按窗口能力隐藏"
  - path: client/flutter_app/lib/core/widgets/glass_panel.dart
    change: "平板复用PC玻璃材质"
  - path: client/flutter_app/lib/core/widgets/glass_motion_backdrop.dart
    change: "平板复用PC光场"
  - path: client/flutter_app/lib/app/app_visual_theme.dart
    change: "平板使用PC主题面板与直角等规则"
  - path: client/flutter_app/lib/app/session_controller.dart
    change: "平板恢复显式本机资料状态"
  - path: client/flutter_app/lib/core/local/offline_store.dart
    change: "OHOS使用sqflite原生工厂；schema/ownerScope/事务沿原链路"
  - path: client/flutter_app/lib/features/home/presentation/pages/home_page.dart
    change: "平板进入完整AdaptiveDesktopHome"
  - path: client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart
    change: "平板不提供或进入Focus Orb"
  - path: client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart
    change: "平板隐藏Windows专用桌面设置"
  - path: client/flutter_app/test/core/layout/harmony_tablet_presentation_test.dart
    change: "身份/离线API/键盘侧栏/原生通道/四主题矩阵与可选宿主捕获"
  - path: client/flutter_app/test/features/settings/offline_settings_page_test.dart
    change: "同一设置回归覆盖Windows可见与平板隐藏的桌面入口"
  - path: docs/planning/Innocence-鸿蒙平板版本实施规划.md
    change: "记录开始实现、首批成果与H0原生门禁未过"
  - path: docs/planning/Innocence-UI设计规划.md
    change: "归档用户开始制作原文与实际平板呈现"
  - path: docs/03-execution-plan.md
    change: "平台track指向0100及SDK交接点"
  - path: docs/08-project-profile.md
    change: "新增平台状态，布局不改变会话政策"
  - path: progress/0000__AI-RESUME.md
    change: "0100/0101及当前真实状态与下一步"
  - path: progress/INDEX.md
    change: "升序追加0100"
evidence:
  - command: "D:/soft/flutter/bin/cache/dart-sdk/bin/dart.exe analyze lib test"
    result: "最终exit0/No issues found!；备份Dart改为.bak，分析范围排除独立工具和缓存"
  - command: "Flutter OH配套dart.exe analyze app/lib"
    result: "最终exit0/No issues found!；Dart3.11.5及真实OH插件依赖"
  - command: "Flutter test --no-pub：desktop_presentation_test/adaptive_canvas_theme_test/adaptive_annual_progress_test/android_focus_layout_test/offline_settings_page_test"
    result: "exit0/25项通过，约14秒；范围仅上述原双端路径"
  - command: "Flutter test --no-pub --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos：harmony_tablet_presentation_test/offline_settings_page_test/offline_release_test"
    result: "最终exit0/10项通过，约2秒；额外捕获命令生成8张宿主PNG，两个1024和1360画布/四主题，无部件异常；CJK QA字体不计设备字体证据"
  - command: "tool/harmonyos.ps1 -Action kernel -DirectGit -GitHelperPath C:/Users/HP/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/git/mingw64/bin"
    result: "exit0；assemble --define=TargetPlatform=ohos-arm64 --define=BuildMode=debug kernel_snapshot_program；约9秒首次成功，脚本复核成功。前两次defines和显式入口参数失败已修正，不计为成功证据"
  - command: "Flutter OH build hap --debug --no-pub --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos --dart-define=INNOCENCE_OFFLINE_ONLY=true"
    result: "exit1/No Hmos SDK found. Try setting the HOS_SDK_HOME environment variable；引擎资源已下载，无HAP，不能把kernel当安装包"
  - command: "PowerShell Parser检查tool/harmonyos.ps1；git diff --check"
    result: "脚本语法PASS；diff检查exit0，既有CRLF警告非错误"
compatibility_and_security:
  contract_impact: "账号API和BYOK首轮关闭；未改后端允许列表/两槽位，不将harmonyos上报成windows"
  tenant_impact: "本机SQLite/ownerScope/迁移沿原业务，无真实数据写入；原生恢复仍待验证"
  sensitive_data: "未保存账号验证码/真实Key/签名材料；用户验证码由用户自行填官网，仓库仅开发源码/文档；签名和工具/缓存产物忽略"
risks_or_blockers:
  - "官方DevEco/HarmonyOS SDK/ohpm/hvigor尚缺，需用户在官网下载后给ZIP或安装目录；本机开发工具大文件与缓存已隔离F盘"
  - "ArkTS/原生插件/HAP未编译，Preferences/SQLite/文件选择/前后台/锁屏/签名/返回/触控/真实字体和设备兼容未验，H0-H5不整体通过"
  - "具体Air设备型号/系统build/模拟器或实体设备待确认；首轮默认横屏属于可调整实现基准，未固化业务方向"
  - "HUKS、设备槽位、联网/正式发行与模板图标产品化在后续门禁；没有提交/推送/发布"
next_actions:
  - id: NEXT-HARMONY-SDK
    action: "读取用户提供的官方工具ZIP或DevEco目录，核对版本/完整性，配置隔离SDK并完成pub原生注册、最小HAP和完整应用编译；用户完成签名授权后接设备"
    inputs: ["client/flutter_app/harmonyos/README.md", "client/flutter_app/tool/harmonyos.ps1", "docs/planning/Innocence-鸿蒙平板版本实施规划.md"]
---

本检查点完成的是鸿蒙首批代码与Dart编译里程碑，原生SDK门禁继续进行。用户已给开始制作授权，无需重复询问是否开始；工具下载/签名需实际账号环境或文件输入。0098/0099保持不变，既有脏工作区和原正式资产保留。
