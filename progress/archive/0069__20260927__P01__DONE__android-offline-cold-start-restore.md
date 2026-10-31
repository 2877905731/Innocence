---
schema_version: 1
document_type: checkpoint
sequence: "0069"
created_at: "2026-09-27T11:43:46+08:00"
phase: P01
type: DONE
status: complete
title: "Android 本机离线资料冷启动恢复子集"
objective: "落实 0068 的离线首发决策，修复 Android 进程重启后回到登录页的问题，并验证本机身份隔离。"
completed:
  - fact: "Android 仅在用户显式进入离线模式后记录入口状态；进程重启优先读取既有 SQLite 本机资料并恢复同一 ownerScope 的计划和状态，缺失资料时不静默创建新身份。"
    evidence: "session_controller.dart 的启动与 _loadOfflineProfile 路径；session_controller_offline_restore_test.dart 的恢复和缺失资料用例。"
  - fact: "成功保存在线会话或明确退出会清除离线入口状态；显式离线选择即使留有旧在线凭据也不会在启动时读取在线业务数据；Windows 默认不启用该启动恢复。"
    evidence: "auth_local_storage.dart 的入口标志清理；SessionController 的 Android 默认值；对应宿主测试。"
  - fact: "完整 Flutter 检查通过，Debug APK 在 Android 16／API 36 Pixel 7 模拟器重新安装；离线首页强制结束进程后冷启动仍回到本机资料首页。"
    evidence: "analyze：No issues found；flutter test：72 项通过；APK SHA-256 4419C41C4BCF247722C4897E2EB6797EE91B27F24196EB523BA3AE50EDC47AC0；adb am start：LaunchState COLD、Status ok；UI hierarchy 再次包含 Home、Offline mode、On-device profile。"
  - fact: "模拟器中通过侧边栏明确退出后，冷启动返回认证页，本机 SQLite 文件保留；再次手动选择离线可回到本机首页。"
    evidence: "UI hierarchy 先出现 Password login、Continue offline，run-as 可见 innocence_local.db；再次确认离线后出现 Home、On-device profile。"
changed_files:
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "Android 显式离线入口持久化、冷启动恢复和本机数据集中加载。"
  - path: "client/flutter_app/lib/features/auth/data/auth_local_storage.dart"
    change: "记录离线入口标志，并在保存或清除在线会话时清理标志。"
  - path: "client/flutter_app/test/app/session_controller_offline_restore_test.dart"
    change: "新增本机计划恢复、旧在线凭据隔离、退出、缺失本机资料与在线会话保存负向／状态测试。"
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "记录冷启动恢复行为、模拟器结果与尚未验收边界。"
  - path: "progress/0069__20260927__P01__DONE__android-offline-cold-start-restore.md"
    change: "记录独立可验证的 Android 离线恢复子里程碑。"
evidence:
  - command: "flutter analyze --no-pub"
    result: "退出码 0，No issues found。"
  - command: "flutter test --no-pub --reporter expanded"
    result: "退出码 0，72 项通过；新增 4 项离线重启与标志清理测试。"
  - command: "GRADLE_OPTS=-Dorg.gradle.project.kotlin.incremental=false；flutter build apk --debug --no-pub"
    result: "退出码 0；Debug APK 180,082,003 字节，SHA-256 4419C41C4BCF247722C4897E2EB6797EE91B27F24196EB523BA3AE50EDC47AC0。"
  - command: "adb -s emulator-5554 install -r app-debug.apk；adb shell am force-stop；adb shell am start -W；adb shell uiautomator dump"
    result: "安装 Success；首次进入离线首页后强制结束进程，冷启动 Status ok、LaunchState COLD、TotalTime 2001 ms；重启后 UI hierarchy 仍有 Home、Offline mode 与 On-device profile。"
  - command: "adb -s emulator-5554 logcat -d --pid=13123 -v brief | Select-String 'FATAL EXCEPTION|E/flutter|Unhandled Exception|FlutterError'"
    result: "本轮冷启动进程筛选命中 0 条。"
  - command: "adb shell input tap；adb shell am force-stop；adb shell am start -W；adb shell uiautomator dump；adb shell run-as com.innocence.app.innocence_flutter ls databases"
    result: "侧边栏 Sign out 后冷启动 Status ok、LaunchState COLD，显示 Password login 与 Continue offline；本机数据库文件仍存在；再次确认离线后显示 Home 与 On-device profile。"
  - command: "git diff --check -- client/flutter_app/lib/app/session_controller.dart client/flutter_app/lib/features/auth/data/auth_local_storage.dart docs/03-execution-plan.md docs/08-project-profile.md"
    result: "退出码 0，无空白错误；仅有行尾转换提示。"
compatibility_and_security:
  contract_impact: "none；仅移动端本机启动行为，不改变 API。"
  tenant_impact: "仅恢复 local:profileUuid；显式离线优先于保留的在线 token，但不发出受保护接口请求或展示其他账号社交数据。"
  sensitive_data: "测试令牌为合成值；未记录真实凭据。"
risks_or_blockers:
  - "未在实体 Android 手机验证；Android Studio Device Manager 图形界面尚未核对，SDK license 警告仍待设备所有者处理。"
  - "未做真实登录／导入预览与目标账号确认的 HTTP 回放；A1/A2 MD3 业务详情页和发布包均未完成。"
  - "C 盘 0.7 MB JNA 临时目录的精确清理此前被本机策略拒绝，未声称已删除。"
next_actions:
  - id: NEXT-ANDROID-DEVICE
    action: "连接实体 Android 设备做离线入口、资料持久化与系统返回复验，处理 SDK license 提示。"
    inputs: ["client/flutter_app/build/app/outputs/flutter-apk/app-debug.apk", "docs/planning/Innocence-Android版本实施规划.md"]
  - id: NEXT-ANDROID-A1-A2
    action: "继续资料／设置与月／年计划 MD3 手机页，联调真实认证和离线导入确认负向路径。"
    inputs: ["docs/06-contract-inventory.md", "client/flutter_app/lib/features/home/presentation/pages/android_home_shell.dart"]
---
