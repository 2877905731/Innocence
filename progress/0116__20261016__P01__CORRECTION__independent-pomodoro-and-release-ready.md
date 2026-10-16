---
schema_version: 1
document_type: checkpoint
sequence: "0116"
created_at: "2026-10-16T21:28:29+08:00"
phase: P01
type: CORRECTION
status: complete
title: "番茄独立计时范围纠正、三端实现与v1.2.5发行就绪"
objective: "用户要求独立番茄并授权重新发布"
completed:
  - fact: "v1.2.4番茄分页仅依附总专注的范围已纠正；三端独立开始/暂停/继续/结束与SQLite v8接入，原绑定兼容。228 Flutter/5条件跳过、19离线/10平板、分析及API36原生9组/拒绝权限通过；三端正式包与ARM64/x64 AOT、签名/CRC/118 Dart字节核验通过，v1.2.5+10待推送与公开。鸿蒙权益和后台8阶段窗口明确保留，未部署后端。"
    evidence: "源码、回归和本机发行核验"
  - fact: "用户原文：按我说的进行实现然后重新发布"
    evidence: "当前聊天直接授权实现与同渠道重新发行"
changed_files:
  - path: "client/flutter_app/lib/features/focus/application/pomodoro_controller.dart"
    change: "独立时钟生命周期、保存与身份隔离和原生串行调用"
  - path: "client/flutter_app/lib/features/focus/domain/models/pomodoro_timer.dart"
    change: "不依附总专注的累计时间与周期模型"
  - path: "client/flutter_app/lib/features/focus/presentation/widgets/pomodoro_timer_panel.dart"
    change: "独立计时控制、配置与能力提示"
  - path: "client/flutter_app/lib/core/local/offline_store.dart"
    change: "SQLite v8与owner独立表"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "身份、语言与生命周期接线"
  - path: "client/flutter_app/android/app/src/main/kotlin/com/innocence/app/innocence_flutter/PomodoroNotices.kt"
    change: "独立系统Chronometer/阶段闹钟/通知与恢复"
  - path: "client/flutter_app/ohos/entry/src/main/ets/entryability/FocusNoticeChannel.ets"
    change: "独立TIMER/快照/8阶段有限代理提醒"
  - path: "client/flutter_app/windows/runner/win32_window.cpp"
    change: "独立番茄阶段系统气泡"
  - path: "client/flutter_app/test/features/focus/independent_pomodoro_test.dart"
    change: "14项真实存储/身份/恢复与四主题回归"
  - path: "client/flutter_app/android/app/src/androidTest/kotlin/com/innocence/app/innocence_flutter/FocusNoticeNativeTest.kt"
    change: "新增3组独立原生计时及拒绝权限"
  - path: "docs/development/独立番茄闹钟.md"
    change: "当前独立契约与明确系统边界"
  - path: "docs/releases/v1.2.5.md"
    change: "正式发行范围、资产摘要与证据"
  - path: "docs/releases/v1.2.5-harmonyos.1.md"
    change: "鸿蒙签名和后台边界"
evidence:
  - command: "dart analyze lib test"
    result: "exit0，No issues found!"
  - command: "flutter test --no-pub --reporter expanded"
    result: "228通过/5平台条件跳过，exit0"
  - command: "flutter test --dart-define=INNOCENCE_OFFLINE_ONLY=true test/app/offline_release_test.dart test/features/assistant/chat_assistant_test.dart"
    result: "19通过"
  - command: "flutter test --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos test/core/layout/harmony_tablet_presentation_test.dart test/app/offline_release_test.dart"
    result: "10通过"
  - command: "gradlew :app:assembleDebug :app:assembleDebugAndroidTest -Pinnocence.notificationQa=true；adb am instrument"
    result: "JDK21构建119秒/9原生组PASS；另拒绝通知权限PASS。首次未引用-P参数及DevEco裁剪JBR缺jlink失败均已纠正，不计通过"
  - command: "windows/package_release.ps1 -SkipVerification；android/package_release.ps1 -SkipVerification"
    result: "最终Windows79秒/Inno14.672秒、Android201.3秒；1.2.5+10，原Android发行证书、非调试/无INTERNET"
  - command: "tool/harmonyos.ps1 -Action build -BuildMode release -Unsigned（arm64/x64）"
    result: "最终112.3/120.4秒，双Release/AOT通过"
  - command: "python build/qa/verify125.py"
    result: "全部资产CRC/ABI/版本、118共享Dart与宿主字节相等；公开HAP无INTERNET/空签名配置/SDK确认未签名"
  - command: "adb独立focusqa实际页面；总专注未开始→番茄分页→开始→暂停"
    result: "实际页面显示24:57、24:34暂停与独立动作；仅read-only API36本轮合成资料，非实体手机"
compatibility_and_security:
  contract_impact: "新独立本机时钟不上传、不自动签到、不重复计统计；旧绑定接口/记录保留"
  tenant_impact: "本机owner或认证user分区，身份切换取消旧原生通知"
  sensitive_data: "无真实账号数据；Android私钥未复制；个人鸿蒙签名材料保持F盘私有"
risks_or_blockers:
  - "鸿蒙Live View/代理权益与系统配额仍受限；有限8阶段预排不是无限后台动态接力"
  - "实际手机/平板与Windows多DPI完整矩阵仍待；未部署后端"
next_actions:
  - id: NEXT-V125-PUBLISH
    action: "按用户明确授权推送main及双版本标签，上传并公开GitHub Release，核对7资产和匿名下载"
    inputs: ["docs/releases/v1.2.5.md", "docs/releases/v1.2.5-harmonyos.1.md"]
---

0114与0115保持不可变。本条纠正独立分页与独立时钟的范围，设备与系统权益限制不改写为通过。
