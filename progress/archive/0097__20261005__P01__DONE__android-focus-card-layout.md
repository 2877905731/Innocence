---
schema_version: 1
document_type: checkpoint
sequence: "0097"
created_at: "2026-10-05T00:10:02+08:00"
phase: P01
type: DONE
status: complete
title: "Android专注数字与表盘布局修正、回归和实际新版启动"
objective: "按用户Android首页截图修正专注卡大片空白/表盘偏置，编译并在原模拟器核对实际新布局"
completed:
  - fact: "首页与详情改为独立数字计时/状态/任务和表盘同组，底部通栏主动作，窄屏大字体居中重排且小时数单行"
    evidence: "AndroidHomeShell的_focusCard/_focusTimerOverview、8张合成PNG及实际首页/详情截图"
  - fact: "原FocusSession/ticker、导航和开始/暂停/继续/结束回调、忙状态禁用保留"
    evidence: "24相关用例通过，四主题/双语/三状态/三尺寸共72组合及动作断言；桌面表盘原回归继续"
  - fact: "静态分析及Debug构建成功，覆盖安装保留资料/原复古主题，实际首页入口正常进入详情"
    evidence: "analyze37.1秒/Debug19秒/install -r Success；最终COLD3381ms/PID3451"
  - fact: "00:10:02前台运行及三个错误计数0；模拟器恢复完整可见并居中，留专注详情运行"
    evidence: "runtime-check.json/window-position.json；原生sky观察及SDK窗口偏好备份恢复，不wipe userdata"
changed_files:
  - path: client/flutter_app/lib/features/home/presentation/pages/android_home_shell.dart
    change: "专注独立卡片、测量重排与单行时长，详情复用和原动作/禁用"
  - path: client/flutter_app/test/features/home/android_home_shell_test.dart
    change: "fixture允许注入原专注回调和忙状态"
  - path: client/flutter_app/test/features/home/android_focus_layout_test.dart
    change: "13项布局/动作/忙状态用例和8张合成PNG"
  - path: docs/planning/Innocence-UI设计规划.md
    change: "存档用户原文及Android专注排版规则"
  - path: docs/planning/Innocence-Android版本实施规划.md
    change: "实现/实际安装子集与门禁边界"
  - path: docs/development/Android专注卡布局修正与验收.md
    change: "真实命令、结果、摘要、截图和窗口恢复"
  - path: AGENTS.md
    change: "当前实现摘要"
  - path: progress/0000__AI-RESUME.md
    change: "0097/下一0098、Android运行证据与后续范围"
  - path: progress/INDEX.md
    change: "顺序追加0097"
  - path: progress/0097__20261005__P01__DONE__android-focus-card-layout.md
    change: "本次可独立核对里程碑"
  - path: F:/AndroidSdk-Innocence/avd/Innocence_API36_Pixel7.avd/emulator-user.ini
    change: "工作区外既有AVD窗口偏好备份后仅调整显示位置/比例，非业务数据"
evidence:
  - command: "flutter test android_focus_layout_test.dart android_home_shell_test.dart white_home_refinement_test.dart --no-pub --reporter expanded（完整test/features/home前缀）"
    result: "最终24项通过/12秒；前两轮忙状态用例等待/点击时机失败日志保留，未跳过；长时长换行已修正并加单行断言"
  - command: "D:/soft/flutter/bin/flutter.bat analyze --no-pub"
    result: "exit0/No issues found/37.1秒"
  - command: "./gradlew.bat assembleDebug（quoted kotlin.incremental=false/compiler.execution.strategy=in-process与offlineOnly=false定义）"
    result: "BUILD SUCCESSFUL/19秒/207 tasks；APK180731995 bytes，SHA25653468169747a90c1901cd4c61d04983568d4f3e73edecc86d47e4392f1727756"
  - command: "adb install -r；adb shell am force-stop/am start -W；重开窗口后am start -W"
    result: "Success；最终Status ok/COLD/TotalTime3381ms/WaitTime3384ms；PID3451，本机资料和原主题保持"
  - command: "uiautomator dump只读取进入专注位置；adb input tap 540 1857；screencap/pull；当前PID logcat只在内存筛选"
    result: "首页与专注详情实际可见，未开启时段；00:10:02前台MainActivity、FATAL/FlutterError或Unhandled/RenderFlex overflow均0"
  - command: "SDK窗口帮助；adb emu kill；备份窗口ini后仅改window.x/y/scale；sky重新定位并drag标题栏后刷新"
    result: "恢复完整显示，主图348×799原点979,85、工具栏54×508原点1499,130，2560×1440/150%工作区中心误差约1px；未wipe资料"
compatibility_and_security:
  contract_impact: "none；Android呈现和测试fixture，不改计时、业务、后端、正式版本或发布资产"
  tenant_impact: "none；保留本机资料，未写真实专注/任务/签到或登录内容，合成资料不入库"
  sensitive_data: "不读取真实Key/密码，不保存全量个人logcat；设备画面为通用本机用户"
risks_or_blockers:
  - "原生API36为待开始首页/详情导航子集，实际运行/暂停/结束、实体设备/OEM/Vulkan/输入法、Windows多DPI和长期性能仍待验"
  - "认证失败/租户不匹配/权限拒绝/字段缺失/生成失败沿原fixture证据，真实供应商/HTTP/同步未回放"
next_actions:
  - id: NEXT-FOCUS-DEVICE
    action: "保留当前新版和用户操作，继续实体手机/键盘/大字体及实际专注全状态验收；不重复覆盖或重启当前浏览，不自动发布"
    inputs: [docs/development/Android专注卡布局修正与验收.md, client/flutter_app/build/qa/android-focus-layout/runtime/]
---
