---
schema_version: 1
document_type: checkpoint
sequence: "0065"
created_at: "2026-09-27T01:22:19+08:00"
phase: P01
type: DONE
status: complete
title: "Android MD3 语言与认证入口、C 盘安装残留核对"
objective: "在 Android 导航与离线范围待决时，完成可独立验证的 MD3 入口页面，并核对 C 盘失败安装残留；不宣称 A0/A1 总门槛通过。"
completed:
  - fact: "Android 独立采用系统浅／深色 MD3 主题，重建首次语言选择、加载和认证展示；Windows 四主题与认证业务方法保持原路径。"
    evidence: "client/flutter_app/lib/app/android_md3_theme.dart、app.dart、android_language_selection_page.dart、auth_page.dart；Android 16 Pixel 7 模拟器截图 innocence-md3-*.png。"
  - fact: "新增 MD3 主题亮度及语言持久化测试；Flutter 静态检查和全部测试通过。"
    evidence: "flutter analyze --no-pub：No issues found；flutter test --no-pub：65 项全部通过。"
  - fact: "更新 Debug APK 并安装到 Android 16／API 36 Pixel 7 模拟器；中英文、浅深色、1.5 倍字体、空邮箱负向提示和重置页系统返回已做运行态检查。"
    evidence: "adb install -r：Success；am start -W：Status: ok；F:/AndroidSdk-Innocence/captures/innocence-md3-*.png；APK SHA-256 4E88976EE176FB9F3317DE1B45F0ACEE10EF6589D1B5257BB5C7283C83B911AA。"
  - fact: "核对 C 盘失败安装中间包／目录不存在；保留模拟器正常运行所需的四个指向 F 盘的目录联接。"
    evidence: "Test-Path 旧 zip 与重复嵌套 cmdline-tools 均为 False；Get-Item 显示 cmdline-tools、.temp、system-images、avd 的 LinkType=Junction、Target 均位于 F:/AndroidSdk-Innocence。"
changed_files:
  - path: "client/flutter_app/lib/app/android_md3_theme.dart"
    change: "新增 Android Material 3 浅／深色基线。"
  - path: "client/flutter_app/lib/app/app.dart"
    change: "按 Android 平台使用 MD3 主题、语言入口和启动页。"
  - path: "client/flutter_app/lib/features/auth/presentation/pages/android_language_selection_page.dart"
    change: "新增 Android 独立语言选择页。"
  - path: "client/flutter_app/lib/features/auth/presentation/pages/auth_page.dart"
    change: "新增 MD3 认证展示和重置页系统返回处理，复用既有认证方法。"
  - path: "client/flutter_app/test/app/android_md3_entry_test.dart"
    change: "新增主题亮度和语言持久化测试。"
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "记录 A1 前置工作、构建／模拟器证据、C 盘核对和剩余门槛。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新当前 Android 基线、未决事项和下一步。"
  - path: "progress/INDEX.md"
    change: "追加本检查点。"
  - path: "progress/0065__20260927__P01__DONE__android-md3-entry-and-c-drive-cleanup-audit.md"
    change: "记录独立可验证阶段成果与未完成边界。"
evidence:
  - command: "dart format lib/app/android_md3_theme.dart lib/app/app.dart lib/features/auth/presentation/pages/android_language_selection_page.dart lib/features/auth/presentation/pages/auth_page.dart test/app/android_md3_entry_test.dart"
    result: "Formatted 5 files (0 changed)。"
  - command: "flutter analyze --no-pub; flutter test --no-pub"
    result: "analyze 退出码 0，无问题；测试退出码 0，65 项全部通过。"
  - command: "临时设置 GRADLE_OPTS=-Dorg.gradle.project.kotlin.incremental=false；flutter build apk --debug --no-pub；Get-FileHash -Algorithm SHA256 app-debug.apk"
    result: "构建成功；APK 180,060,590 字节；SHA-256 4E88976EE176FB9F3317DE1B45F0ACEE10EF6589D1B5257BB5C7283C83B911AA。"
  - command: "adb install -r app-debug.apk; adb shell am start -W -n com.innocence.app.innocence_flutter/.MainActivity; adb shell screencap -p; adb logcat -d --pid=8232 -v brief（筛选异常关键字）"
    result: "安装 Success、启动 Status: ok；模拟器截图可见目标状态；按该次 PID 筛选未见 FATAL EXCEPTION／E/flutter／Unhandled Exception／FlutterError。"
  - command: "Get-Item 四个 C 盘目录联接；Test-Path 旧 zip 与重复嵌套目录；Get-ChildItem C:\\Users\\HP\\AppData\\Local\\Temp\\jna-2312"
    result: "四个联接均指向 F 盘且保留；旧包与重复目录不存在；JNA 临时目录仍有 6 个文件，共 748,032 字节。"
  - command: "尝试对精确的 C:\\Users\\HP\\AppData\\Local\\Temp\\jna-2312 执行 Remove-Item 清理"
    result: "执行前被本机策略拒绝（CreateProcess rejected: blocked by policy）；未删除，未绕过策略。"
compatibility_and_security:
  contract_impact: "仅移动端视觉与本地语言入口改动；认证提交／发送验证码沿用既有方法，未修改 HTTP 契约；真实认证接口未联调。"
  tenant_impact: "未登录真实账号，不涉及跨租户数据读取；离线按钮保留现状，首发范围仍待用户决定。"
  sensitive_data: "未写入真实凭据；截图为无账号输入的模拟器页面。"
risks_or_blockers:
  - "Android A0 仍缺导航／未登录离线范围决策、实体设备启动和剩余 SDK 许可处理；A1 主 Shell、资料／设置、令牌存储与服务端负向回放未完成。"
  - "软键盘在该模拟器中只显示输入工具栏，键盘遮挡未判定通过；其余 Android 业务页仍为旧视觉。"
  - "C 盘 JNA 临时目录约 0.7 MB 仍在，自动执行策略拒绝删除；正常运行所需的目录联接不能按失败残留删除。"
next_actions:
  - id: NEXT-ANDROID-DECISIONS
    action: "确认五项底栏与 Android 未登录本机离线首发范围，再实现 MD3 NavigationBar 主 Shell。"
    inputs: ["docs/planning/Innocence-Android版本实施规划.md §4.2–4.3"]
  - id: NEXT-ANDROID-DEVICE
    action: "连接实体手机复验入口、键盘与系统返回；由设备所有者处理 Android SDK 剩余许可。"
    inputs: ["client/flutter_app/build/app/outputs/flutter-apk/app-debug.apk", "flutter doctor -v"]
  - id: NEXT-ANDROID-A1
    action: "继续资料／设置、会话安全存储和认证失败／租户不匹配等服务端负向回放。"
    inputs: ["docs/06-contract-inventory.md", "docs/planning/Innocence-Android版本实施规划.md"]
---

# 检查点说明

本检查点的 DONE 仅指 Android MD3 入口子集及 C 盘残留核对完成。A0/A1 总门槛、实体设备、完整手机业务 UI 和真实服务端联调均未完成。
