---
schema_version: 1
document_type: checkpoint
sequence: "0096"
created_at: "2026-10-04T23:48:16+08:00"
phase: P01
type: DONE
status: complete
title: "Android API36覆盖安装、冷启动核对与模拟器窗口居中"
objective: "按用户要求启动Android版并核对实际运行，把桌面上的模拟器主窗口和工具栏整体居中"
completed:
  - fact: "启动既有Innocence_API36_Pixel7 AVD并覆盖安装0095同一Debug APK，保留本机资料"
    evidence: "emulator-5554 boot_completed1；install -r Success；APK SHA256548c612672d59f7c0f43f6688cdca430f4ed1f8ed69f055aa1c387aff9a22af6"
  - fact: "Android16/API36冷启动正常，本机离线首页和资料恢复，原生简约白字标/白面板边界可见"
    evidence: "am start -W：Status ok/COLD/TotalTime3368ms/WaitTime3372ms；sky实际首页观察"
  - fact: "23:47:14进程4472及MainActivity仍在前台，三个错误筛选计数为0"
    evidence: "build/qa/android-minimal-runtime/runtime-check.json；只保存计数，不保存个人全量logcat"
  - fact: "通过sky拖标题栏将主窗口及工具栏整体居中，保持运行供用户操作"
    evidence: "主图364×835原点967,59、工具栏54×508原点1511,104；2560×1440/150%工作区中心误差约2px，window-position.json"
changed_files:
  - path: docs/development/简约白最早基准重建与验收.md
    change: "追加Android实际启动/只读错误筛选/原生首页与居中证据、交互边界"
  - path: docs/planning/Innocence-Android版本实施规划.md
    change: "追加0096启动子集与开发APK实际安装状态，正式发行和设备门禁保持"
  - path: progress/0000__AI-RESUME.md
    change: "0096/下一0097、Android实际运行摘要与原生子集待验范围"
  - path: progress/INDEX.md
    change: "顺序追加0096"
  - path: progress/0096__20261004__P01__DONE__android-startup-and-centered-emulator.md
    change: "本次启动与窗口居中检查点"
evidence:
  - command: "Start-Process emulator.exe -avd Innocence_API36_Pixel7 -gpu swiftshader_indirect -no-snapshot-load -no-boot-anim -WindowStyle Normal"
    result: "23:39:04启动launcher PID24748；emulator-5554在线/boot_completed1；未wipe userdata"
  - command: "adb -s emulator-5554 install -r client/flutter_app/build/app/outputs/flutter-apk/app-debug.apk"
    result: "Success；包com.innocence.app.innocence_flutter、版本1.2.2/code7，沿用0095摘要"
  - command: "adb shell am force-stop com.innocence.app.innocence_flutter；adb shell am start -W -n com.innocence.app.innocence_flutter/.MainActivity；adb shell pidof"
    result: "Status ok、LaunchState COLD、TotalTime3368ms、WaitTime3372ms、进程4472；cold-start.log"
  - command: "adb logcat -d --pid=4472 -v brief只在内存筛选；dumpsys activity activities；getprop；wm size/density"
    result: "23:47:14 Android16/API36/1080×2400/420dpi、MainActivity前台；FATAL/未处理Flutter异常/RenderFlex overflow均0；runtime-check.json"
  - command: "sky.get_window_state/activate_window；sky.drag标题栏from180,14 to86,23后刷新；Get-CimInstance Win32_VideoController只读分辨率"
    result: "原生首页黑色INN/CNCE及面板分界可见；主窗口加工具栏居中，位置见window-position.json。首次drag遇user input要求刷新，按返回状态刷新后完成；未继续接管用户主题浏览"
  - command: "adb shell screencap -p /sdcard/Download/innocence-runtime-20261004.png；adb pull到build/qa/android-minimal-runtime/current-runtime.png"
    result: "成功保存当前实际模拟器画面；用户已切換复古主题，不能将最终截图误标为白色"
compatibility_and_security:
  contract_impact: "none；本轮无源码/接口/版本变更，开发安装不替换正式离线资产"
  tenant_impact: "none；install -r保留资料，未操作业务表单、登录或发送数据，不添加/删除用户任务"
  sensitive_data: "未读取真实Key/密码；不保存全量个人logcat，画面为本机离线通用用户"
risks_or_blockers:
  - "实际启动/首页子集不替代完整导航/表盘交互、实体设备/OEM/Vulkan/键盘、Windows多DPI或长时间性能"
  - "认证失败/租户不匹配/权限拒绝/字段缺失/生成失败沿原fixture证据，真实模型/HTTP/同步回放继续待验"
next_actions:
  - id: NEXT-NATIVE-MATRIX
    action: "模拟器保持运行供用户继续操作；进一步补完整原生交互、Windows多DPI和实体手机，不重复重启或接管用户当前浏览"
    inputs: [docs/development/简约白最早基准重建与验收.md, client/flutter_app/build/qa/android-minimal-runtime/]
---
