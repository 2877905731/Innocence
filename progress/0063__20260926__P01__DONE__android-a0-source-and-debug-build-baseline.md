---
schema_version: 1
document_type: checkpoint
sequence: "0063"
created_at: "2026-09-26T23:26:38+08:00"
phase: P01
type: DONE
status: complete
title: "Android A0 源码盘点与 Debug APK 构建基线"
objective: "开始执行 Android A0，建立 MD3 手机信息架构评审稿、源码级差距和可复现本地 Debug APK 基线；此检查点不代表 A0 设备验收或 Android UI 实现完成。"
completed:
  - fact: "Android 规划稿已加入手机页面地图、MD3 NavigationBar 线框、页面加载／空／错误／离线状态约束和源码级契约差距，均保留为待确认提案。"
    evidence: "docs/planning/Innocence-Android版本实施规划.md §4.2–4.3、§10"
  - fact: "Flutter 分析退出码为 0，现有 63 项 Flutter 测试全部通过。"
    evidence: "命令结果：No issues found；00:06 +63 All tests passed!"
  - fact: "Android Debug APK 经 Flutter 入口成功构建；aapt 核对 applicationId 和版本，SHA-256 已记录。"
    evidence: "client/flutter_app/build/app/outputs/flutter-apk/app-debug.apk；159663316 bytes；SHA-256 6DDC8D44F6A9000D0348527545BA4BAA9925F890498C342F0A3F6F0899D70749"
changed_files:
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "将规划状态设为 in_progress，加入 A0 手机 IA／MD3 状态与源码差距提案及实测基线。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新最新检查点、Android A0 基线、待确认范围与下一步。"
  - path: "progress/INDEX.md"
    change: "登记本检查点 0063。"
  - path: "progress/0063__20260926__P01__DONE__android-a0-source-and-debug-build-baseline.md"
    change: "记录 A0 初始基线证据和未完成门槛。"
evidence:
  - command: "flutter --version"
    result: "Flutter 3.44.4 stable；Dart 3.12.2。"
  - command: "flutter doctor -v"
    result: "Flutter／Windows 正常；Android SDK 36.1.0 可识别；cmdline-tools 缺失、Android license status unknown。"
  - command: "flutter analyze --no-pub"
    result: "exit 0；No issues found!"
  - command: "flutter test --no-pub"
    result: "exit 0；63 项全部通过。"
  - command: "flutter build apk --debug --no-pub"
    result: "exit 0；Built build/app/outputs/flutter-apk/app-debug.apk（13.6s）。本次进程临时使用系统代理与 -Dorg.gradle.project.kotlin.incremental=false；未持久化环境或修改项目配置。"
  - command: "flutter devices; flutter emulators; C:\\Users\\HP\\AppData\\Local\\Android\\sdk\\platform-tools\\adb.exe devices -l"
    result: "仅 Windows／Chrome／Edge；No emulators available；adb device list 为空。"
  - command: "aapt dump badging client/flutter_app/build/app/outputs/flutter-apk/app-debug.apk；Get-FileHash -Algorithm SHA256"
    result: "package com.innocence.app.innocence_flutter；version 1.1.1+4；159663316 bytes；SHA-256 6DDC8D44F6A9000D0348527545BA4BAA9925F890498C342F0A3F6F0899D70749。"
compatibility_and_security:
  contract_impact: "未修改 API、字段或后端行为；源码级盘点只标记为差距，不将规划中的 bootstrap、WebSocket 或推送视为已实现。"
  tenant_impact: "未修改账户或租户隔离；离线入口范围待用户确认，既有 ownerScope 与导入前确认规则继续有效。"
  sensitive_data: "none；日志未记录真实凭据或个人资料。"
risks_or_blockers:
  - "Android A0 尚未通过：没有 AVD／实体手机启动证据；Android SDK 缺 command-line tools 且 license status unknown。"
  - "导航是否采用五项，以及 Android 首版是否开放未登录本机离线资料，等待用户确认；A1 Shell 编码需以确认后的移动稿为准。"
  - "首次无参数 Android build 暴露 Kotlin 增量缓存跨 C:/F: 根目录问题；本次仅以一次性 Gradle 属性成功构建，未改项目配置。"
next_actions:
  - id: NEXT-ANDROID-DECISIONS
    action: "确认五项底栏（首页／计划／专注／陪伴／收件箱）与 Android 未登录本机离线资料首发范围。"
    inputs: ["docs/planning/Innocence-Android版本实施规划.md §4.2–4.3"]
  - id: NEXT-ANDROID-DEVICES
    action: "补齐 cmdline-tools 与 Android license；创建 AVD 并在模拟器启动 APK；连接至少一台真实 Android 设备完成启动记录。"
    inputs: ["client/flutter_app/android/", "Android SDK 36.1.0"]
  - id: NEXT-ANDROID-A1
    action: "A0 设计与设备门槛确认后，再实现 Android 独立 MD3 主题分支、认证页与主导航 Shell。"
    inputs: ["docs/planning/Innocence-Android版本实施规划.md", "用户确认的导航／离线范围"]
---

# 检查点说明

本检查点完成的是源码盘点和本地调试包构建基线，不是 Android A0 完成声明。当前 Android UI 尚未按 MD3 重建，Debug APK 仍使用工程默认 applicationId／名称，且未在模拟器或真机运行。
