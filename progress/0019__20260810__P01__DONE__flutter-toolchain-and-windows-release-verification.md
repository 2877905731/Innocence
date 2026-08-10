---
schema_version: 1
document_type: checkpoint
sequence: "0019"
created_at: "2026-08-10T14:30:42+08:00"
phase: P01
type: DONE
status: complete
title: "Flutter 工具链与 Windows Release 自动化验收"
objective: "解除 Flutter/Dart 工具链阻塞，执行依赖解析、静态分析、Flutter 测试与 Windows Release 构建"
completed:
  - fact: "将 D:\\software\\flutter\\bin 写入当前 Windows 用户 PATH，并完成 Flutter 3.44.9 Stable / Dart 3.12.2 首次初始化"
    evidence: "flutter --version 与 dart --version 返回稳定通道版本；新终端将自动继承 PATH"
  - fact: "配置 PUB_HOSTED_URL 与 FLUTTER_STORAGE_BASE_URL 中国镜像，解决 pub.dev 压缩包持续超时"
    evidence: "镜像环境下 flutter pub get 4.5 秒完成，依赖结构和 SHA-256 均由官方 pub 工具核对"
  - fact: "file_selector 的 Windows、Linux 与 macOS 原生插件注册文件由 flutter pub get 正式生成"
    evidence: "Windows Release 构建链接 file_selector_windows 成功"
  - fact: "处理首次 analyze 暴露的确定性 lint，并修复 800×600 测试视口中屏外控件未命中的测试"
    evidence: "dart fix --apply 在 9 个源码文件完成 21 项确定性修正；widget_test 使用 ensureVisible 后保留原交互断言"
  - fact: "Flutter 静态分析、完整测试和 Windows Release 构建通过"
    evidence: "analyze 为 No issues found；16 tests 全部通过；生成 build/windows/x64/runner/Release/innocence_flutter.exe"
changed_files:
  - path: "client/flutter_app/pubspec.lock"
    change: "由 Flutter 3.44.9 pub get 核对依赖并记录中国镜像源；shared_preferences_android 更新至 2.4.27"
  - path: "client/flutter_app/windows/flutter"
    change: "生成 file_selector_windows 插件注册与 CMake 列表"
  - path: "client/flutter_app/linux/flutter"
    change: "生成 file_selector_linux 插件注册与 CMake 列表"
  - path: "client/flutter_app/macos/Flutter/GeneratedPluginRegistrant.swift"
    change: "生成 file_selector_macos 插件注册"
  - path: "client/flutter_app/lib"
    change: "9 个既有源码文件应用 analyzer 建议的 const、初始化形参、未使用导入及废弃参数机械修正，不改业务分支"
  - path: "client/flutter_app/test/widget_test.dart"
    change: "点击忘记密码和重置按钮前确保控件滚入测试视口"
  - path: "docs/06-contract-inventory.md"
    change: "U13 更新为服务端 HTTP 与客户端工具链已验证、真实文件选择待验收"
  - path: "docs/03-execution-plan.md"
    change: "同步 G01 Flutter 自动化与 Windows Release 构建状态"
  - path: "progress/0000__AI-RESUME.md"
    change: "移除 Flutter 工具链阻塞，下一步收敛到 Windows 实机与 DPI"
  - path: "progress/INDEX.md"
    change: "追加 0019 检查点索引"
evidence:
  - command: "flutter doctor -v"
    result: "Flutter、Windows、Visual Studio 2026 Build Tools、Windows SDK、网络与 Windows 设备通过；仅 Android SDK 缺失"
  - command: "flutter pub get（PUB_HOSTED_URL=https://pub.flutter-io.cn）"
    result: "通过；依赖解析完成并生成 file_selector 跨平台原生注册文件"
  - command: "dart fix --apply；flutter analyze"
    result: "21 项确定性修正后 analyze 返回 No issues found"
  - command: "flutter test test/widget_test.dart；flutter test"
    result: "定向部件测试通过；完整 16 项全部通过"
  - command: "flutter build windows --release"
    result: "通过；50.2 秒生成 build/windows/x64/runner/Release/innocence_flutter.exe"
  - command: "git diff --check"
    result: "通过；仅有 Git 预计的 LF/CRLF 转换提示"
compatibility_and_security:
  contract_impact: "不改接口字段；客户端 U13 依赖与原生注册由官方 Flutter 工具生成并通过构建"
  tenant_impact: "none；本检查点未改鉴权头、会话或用户上下文逻辑"
  sensitive_data: "none；环境变量仅包含公开镜像地址和 SDK 路径"
risks_or_blockers:
  - "尚未执行 Windows 100%/125%/150% DPI 实机验收，也未在原生文件选择器中完成真实图片上传"
  - "Android SDK 未安装；不影响当前 Windows 优先阶段，但会阻塞后续 Android 构建"
next_actions:
  - id: NEXT-001
    action: "启动隔离后端与 Windows Release，以合成图片完成头像选择、上传、展示和资料刷新实机链路"
    inputs: ["Windows Release", "MySQL/Redis", "合成 JPEG/PNG"]
  - id: NEXT-002
    action: "完成 Large/Medium/Small 在 100%/125%/150% DPI 的窗口与交互矩阵"
    inputs: ["Windows DPI 环境"]
---

# 检查点说明

本检查点声明 Flutter 自动化工具链与 Windows Release 构建完成；原生文件选择与 DPI 仍按 TRUTHFUL-SCOPE 保持未完成。
