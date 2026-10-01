---
schema_version: 1
document_type: checkpoint
sequence: "0064"
created_at: "2026-09-27T00:49:39+08:00"
phase: P01
type: DONE
status: complete
title: "Android 16 Pixel 7 模拟器与 Debug APK 启动冒烟"
objective: "补齐 Android A0 的模拟器设备与现有 APK 运行证据；此检查点不代表 A0 全部通过或 MD3 手机界面完成。"
completed:
  - fact: "Android 官方 command-line tools 的 Windows 包经公布 SHA-256 校验后安装；API 36 Google Play x86_64 系统镜像 revision 7 安装完成，C 盘 SDK 可经目录联接识别 F 盘组件。"
    evidence: "工具包 SHA-256 90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a；sdkmanager --list_installed 列出 system-images;android-36;google_apis_playstore;x86_64。"
  - fact: "Pixel 7 AVD 已创建；WHPX 可用，Android 16／API 36 启动完成；Flutter 和 adb 均识别 emulator-5554。"
    evidence: "avdmanager list avd、emulator -list-avds、emulator -accel-check、adb devices -l、getprop sys.boot_completed=1、flutter devices／emulators。"
  - fact: "Debug APK 安装及冷启动成功；语言选择、认证、离线确认与本机首页可显示，应用进程保持运行。"
    evidence: "adb install 返回 Success；am start -W 返回 Status: ok、LaunchState: COLD、TotalTime: 7140 ms；三张运行态截图位于 F:/AndroidSdk-Innocence/captures/。"
changed_files:
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "追加 2026-09-27 模拟器启动命令、结果与未完成边界。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新 Android A0 模拟器基线、剩余实体设备／决策／许可事项及下一步。"
  - path: "progress/INDEX.md"
    change: "登记本检查点 0064。"
  - path: "progress/0064__20260927__P01__DONE__android-api36-emulator-smoke.md"
    change: "记录 AVD、APK 安装、页面冒烟与限制。"
  - path: "F:/AndroidSdk-Innocence/"
    change: "新增本机 Android 工具、系统镜像、AVD 数据和截图；C 盘 Android SDK 与用户 AVD 目录新增指向 F 盘的目录联接。"
evidence:
  - command: "Get-FileHash -Algorithm SHA256 innocence-commandlinetools-win-15859902_latest.zip"
    result: "SHA-256 与 Android Developers 公布的 90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a 一致。"
  - command: "sdkmanager --sdk_root=F:\\AndroidSdk-Innocence --install system-images;android-36;google_apis_playstore;x86_64"
    result: "第一次镜像压缩包读取失败；设置 F 盘 Java 临时目录后重试，退出码 0，revision 7 安装完成。"
  - command: "avdmanager create avd -n Innocence_API36_Pixel7 -k system-images;android-36;google_apis_playstore;x86_64 -d pixel_7; avdmanager list avd; emulator -list-avds"
    result: "创建命令输出 devices.xml 缺失提示，但两个列表均显示 Innocence_API36_Pixel7，随后实际启动成功。"
  - command: "emulator -accel-check; adb devices -l; adb shell getprop sys.boot_completed; adb shell getprop ro.build.version.sdk"
    result: "WHPX installed and usable；emulator-5554 device；boot_completed=1；SDK=36。"
  - command: "adb install -r app-debug.apk; adb shell am start -W -n com.innocence.app.innocence_flutter/.MainActivity"
    result: "Success；Status: ok；LaunchState: COLD；Activity MainActivity；TotalTime: 7140 ms。"
  - command: "adb shell input tap; adb shell screencap -p; adb pull; adb logcat -d --pid=3789 -v brief（筛选致命 Flutter／异常关键字）"
    result: "语言页、认证页、离线提示与本机首页截图成功；应用 PID 保持 3789；筛选无 FATAL EXCEPTION／E/flutter／Unhandled Exception／FlutterError 命中。"
  - command: "flutter doctor -v; flutter devices; flutter emulators"
    result: "Flutter 可识别 Android 16 模拟器和 1 个 AVD；doctor 仍提示部分 Android licenses 未接受。"
compatibility_and_security:
  contract_impact: "未修改接口或客户端业务代码；未使用真实登录账号，未进行 HTTP／同步回放。"
  tenant_impact: "仅在新模拟器本地选择语言并进入本机离线资料；没有跨账户读取或上传。"
  sensitive_data: "none；截图与日志筛选不含真实凭据或个人身份资料。"
risks_or_blockers:
  - "Android A0 仍缺至少一台实体手机的启动证据，导航分组和未登录离线首发范围仍待确认。"
  - "当前手机 UI 沿用旧视觉，尚未按 MD3 重建；模拟器启动不等于 A1 页面验收。"
  - "flutter doctor 仍报告部分 Android SDK licenses 未接受；AVD 创建时曾输出 devices.xml 缺失提示，后续设备配置需留意。"
  - "尚未通过 Android Studio IDE 的 Run 按钮执行；本次使用其 SDK／Emulator 命令行工具和标准 AVD，IDE 的 Device Manager 可使用同一 AVD。"
next_actions:
  - id: NEXT-ANDROID-DECISIONS
    action: "确认五项底栏和 Android 未登录本机离线资料首发范围。"
    inputs: ["docs/planning/Innocence-Android版本实施规划.md §4.2–4.3"]
  - id: NEXT-ANDROID-PHYSICAL
    action: "连接真实 Android 手机，安装当前 Debug APK，记录启动、系统版本与关键首屏；处理 SDK 许可提示。"
    inputs: ["client/flutter_app/build/app/outputs/flutter-apk/app-debug.apk", "flutter doctor -v"]
  - id: NEXT-ANDROID-A1
    action: "以已确认的页面地图实现 Android MD3 认证与主 Shell，并用本检查点的模拟器重复浅／深色、字体、键盘和返回验收。"
    inputs: ["docs/planning/Innocence-Android版本实施规划.md", "F:/AndroidSdk-Innocence/captures/"]
---

# 检查点说明

本检查点只宣布 Android 模拟器首次启动与基础页面冒烟完成。当前 APK 是旧 UI 的 Debug 产物；A0 总门槛、MD3 重建、实体设备与真实账号功能仍未完成。
