---
schema_version: 1
document_type: checkpoint
sequence: "0110"
created_at: "2026-10-11T16:14:27+08:00"
phase: P01
type: DONE
status: complete
title: "鸿蒙竖屏与三端专注系统提醒适配及Android原生验证"
objective: "补齐竖屏与专注本地系统通知；记录实现、构建和原生子集，不将鸿蒙实况窗准入或真机运行计为完成"
completed:
  - fact: "核对原宿主锁横屏，三个宿主均未接专注完成系统通知；云端通知收件箱和Windows托盘不等于此功能。鸿蒙改auto_rotation，PC侧栏保持，双列和指标按内容宽度重排。"
    evidence: "宿主module.json5和原生通道源码；6项平板回归包含四主题768×1244/600×960、旋转保留专注/计划导航及768×430键盘高度。"
  - fact: "计时按快照referenceTime和实际经过秒数推进，前后台恢复追赶；暂停冻结及番茄阶段保持。原生适配串行，同一截止时间不每秒重发，身份变化取消旧提醒，自然完成与提前结束区分。"
    evidence: "196 Flutter通过/5平台专属跳过；新增时钟/阶段、桥接并发、权限与原生失败回归。"
  - fact: "Android系统Chronometer显示倒计时，暂停冻结/继续新截止点，AlarmManager和非导出receiver发到点通知；权限和精确闹钟缺失明确显示，关键通知状态同步提交持久化。"
    evidence: "API36独立.focusqa包4原生组通过；拒绝通知权限通过；am kill后pid为空，系统仍发7303完成通知并移除7302计时通知。测试不写业务SQLite。"
  - fact: "鸿蒙接系统代理提醒、通知权限与Live View Kit TIMER适配；TIMER不可用时普通通知只显示快照/结束时间，应用明确动态倒计时不可用。暂停/结束/身份切换取消代理提醒，实况窗设置SDK规定的aliveTime。"
    evidence: "ARM64/x64 ArkTS完整构建通过；SDK普通通知isCountDown标记未支持。场景准入及实际设备效果未验证。"
  - fact: "Windows自然完成通过现有托盘通道发系统气泡，重复同步不重复提示，点击可恢复主界面。"
    evidence: "Windows Release62.8秒构建成功；桥接完成一次及语言变化回归通过，原生实际显示未执行。"
  - fact: "最终开发包生成，ARM64沿原暂存签名配置构建，只保存在F盘；官方SDK验签、HAP/Android CRC、114个共享Dart及三个原生宿主文件精确字节、方向/代理权限与所有ELF架构通过。"
    evidence: "ARM64签名Debug116016345bytes/SHA256 e75a00f900f9aef94d32de3b868b98dcab6d6e3f25c7d4b2111b8a9aaf9079b0；x64未签名Debug117255243bytes/SHA256 3f21f9e263df73b301a98f112413b9f8dac0aabde863e4e3b499a4a45fbf70e2；Android Debug180878612bytes/SHA256 f434b1a5dee081efd5ad22f336d5d7086db5f9dff90277ff326e0e37caebf5c5。"
changed_files:
  - {path: "client/flutter_app/lib/features/focus/domain/models/focus_session.dart", change: "按实际时长追赶及阶段计算"}
  - {path: "client/flutter_app/lib/core/platform/focus_notice_bridge.dart", change: "通知适配、串行状态及能力结果"}
  - {path: "client/flutter_app/lib/app/session_controller.dart", change: "生命周期、owner通知同步与完成写入防陈旧覆盖"}
  - {path: "client/flutter_app/lib/app/app.dart", change: "通知/精确闹钟/实况窗状态及设置入口"}
  - {path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart", change: "竖屏PC卡片与指标重排"}
  - {path: "client/flutter_app/android/app/build.gradle.kts", change: "独立QA包和无外部依赖的原生检查runner"}
  - {path: "client/flutter_app/android/app/src/main/AndroidManifest.xml", change: "通知/精确闹钟/重启权限与私有receiver"}
  - {path: "client/flutter_app/android/app/src/main/kotlin/com/innocence/app/innocence_flutter/MainActivity.kt", change: "通知通道及授权结果"}
  - {path: "client/flutter_app/android/app/src/main/kotlin/com/innocence/app/innocence_flutter/FocusNoticeChannel.kt", change: "原生倒计时/闹钟/完成/输入校验与恢复"}
  - {path: "client/flutter_app/android/app/src/main/res/drawable/ic_focus_notice.xml", change: "系统通知单色图标"}
  - {path: "client/flutter_app/android/app/src/androidTest/kotlin/com/innocence/app/innocence_flutter/FocusNoticeNativeTest.kt", change: "真实系统通知/权限/闹钟/身份及缺字段检查"}
  - {path: "client/flutter_app/ohos/entry/src/main/module.json5", change: "自动横竖屏和代理提醒权限"}
  - {path: "client/flutter_app/ohos/entry/src/main/ets/entryability/EntryAbility.ets", change: "注册通知适配"}
  - {path: "client/flutter_app/ohos/entry/src/main/ets/entryability/FocusNoticeChannel.ets", change: "代理提醒、实况窗与明确降级"}
  - {path: "client/flutter_app/windows/runner/flutter_window.cpp", change: "完成提醒桌面通道"}
  - {path: "client/flutter_app/windows/runner/win32_window.cpp", change: "系统气泡及点击恢复"}
  - {path: "client/flutter_app/windows/runner/win32_window.h", change: "完成提醒声明"}
  - {path: "client/flutter_app/test/features/focus/focus_session_test.dart", change: "后台时钟/暂停/番茄阶段回归"}
  - {path: "client/flutter_app/test/core/platform/focus_notice_bridge_test.dart", change: "截止点、串行取消、权限与失败回归"}
  - {path: "client/flutter_app/test/core/layout/harmony_tablet_presentation_test.dart", change: "竖屏、旋转状态和键盘回归"}
  - {path: "client/flutter_app/harmonyos/README.md", change: "当前方向与通知边界"}
  - {path: "docs/planning/Innocence-鸿蒙平板版本实施规划.md", change: "用户竖屏要求与本次子集"}
  - {path: "docs/development/平板竖屏与专注系统提醒.md", change: "实现前本地通知契约及验证说明"}
  - {path: "progress/0000__AI-RESUME.md", change: "当前状态及设备验收下一步"}
  - {path: "progress/INDEX.md", change: "追加0110"}
  - {path: "progress/0110__20261011__P01__DONE__portrait-and-focus-system-notices.md", change: "本次里程碑及实际证据边界"}
evidence:
  - command: "D:/soft/flutter/bin/flutter.bat --no-version-check test --no-pub"
    result: "exit0；196通过/5平台专属跳过，78秒；build/focus-notice-full-tests.log。"
  - command: "flutter --no-version-check test --no-pub --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos test/core/layout/harmony_tablet_presentation_test.dart"
    result: "exit0；6通过/16秒；四主题合成图位于build/qa/harmony-tablet，不属于真机证据。"
  - command: "D:/soft/flutter/bin/cache/dart-sdk/bin/dart.exe analyze lib test"
    result: "exit0/No issues found；build/focus-notice-final-analyze.log。"
  - command: "gradlew :app:assembleDebug :app:assembleDebugAndroidTest -Pkotlin.incremental=false -Pkotlin.compiler.execution.strategy=in-process -Pinnocence.notificationQa=true；adb am instrument"
    result: "QA exit0/4原生组PASS；拒绝权限mode denied PASS。独立包.focusqa；非增量/in-process避开现有C/F跨盘缓存错误，未全局改Gradle属性。"
  - command: "adb -s emulator-5554 shell am instrument -w -e mode backgroundArm com.innocence.app.innocence_flutter.focusqa.test/com.innocence.app.innocence_flutter.FocusNoticeNativeTest；adb -s emulator-5554 shell am kill com.innocence.app.innocence_flutter.focusqa；adb shell cmd notification list/get（只读取QA键）"
    result: "进程pid为空；10秒截止后7303存在/7302消失；generic title/text核对。重启instrument会重启目标并取消闹钟，故后台收据用系统只读查询而非重启测试runner。"
  - command: "gradlew :app:assembleDebug -Pkotlin.incremental=false -Pkotlin.compiler.execution.strategy=in-process；flutter build windows --release --no-pub"
    result: "最终Android Debug19秒、Windows Release62.8秒均exit0；Android应用ID未带QA后缀、版本1.2.3+8及四个声明权限核对。不是正式Android发行签名包。"
  - command: "pwsh tool/harmonyos.ps1 -Action build；同命令 -Architecture x64 -Unsigned"
    result: "ARM64设备签名Debug和x64未签名Debug均exit0；最终x64 Hvigor44.4秒，ARM64以本地delivery log为准。两工程独立；未安装真实平板。"
  - command: "python build/qa/focus-notice/verify_artifacts.py（SDK verify-app）"
    result: "exit0；官方验签/CRC/全部ELF/方向/权限/114 Dart和原生文件逐字节PASS，artifact-verification.json记录最终摘要。设备Profile/验签输出仅F盘私有，不输出设备/账号标识。"
  - command: "Java21 + SnakeYAML2.5 VerifyDocuments.java；git diff --check"
    result: "exit0；6文档严格UTF8字节回转、4无重复键YAML、变更路径/全INDEX路径与升序、0110/0111指针PASS；diff检查通过，仅既有CRLF提示。QA包已卸载，本轮启动的无窗口模拟器已关闭。"
compatibility_and_security:
  contract_impact: "新增本机原生通知契约；不修改HTTP、签到、任务完成、同步或设备槽位。"
  tenant_impact: "当前身份生成owner/session键；串行清除旧身份，原生校验键归属；完成事务防身份或新session变化后的陈旧覆盖。注销/身份缺失与tenant mismatch负向覆盖，未执行真实登录HTTP认证失败。"
  sensitive_data: "通知使用通用正文，不带任务名、身份或凭据；真实签名/验签材料只在F盘忽略目录；无推送/公开发布。"
risks_or_blockers:
  - "鸿蒙TIMER场景准入未确认；真实平板横竖屏、草稿/键盘、锁屏/后台代理提醒和实况窗效果未验。SDK实况窗aliveTime为15秒到8小时；长时/暂停/系统隐藏策略另验。"
  - "Windows只有构建与桥接证据，实际气泡/免打扰仍待验；真正退出进程后不承诺到点提醒。"
  - "Android实体设备/OEM/锁屏Doze/重启恢复和正式签名升级未验；无精确闹钟授权时可能延迟，UI明确显示；强行停止应用与普通进程回收不同。"
next_actions:
  - id: NEXT-FOCUS-DEVICE
    action: "用户处理草稿并连接平板后，用0110本机签名包核对真实横竖屏与通知；TIMER场景准入、Windows气泡及实体Android另验。"
    inputs: ["docs/development/平板竖屏与专注系统提醒.md", "client/flutter_app/build/harmonyos-h0/signed-device/0110/Innocence-portrait-focus-arm64-device-debug.hap"]
---

用户原文：

> 鸿蒙平板没有做竖屏模式，然后安卓和平板能不能做成在开启计时以后可以直接在通知栏显示当前倒计时，这几个端你有做倒计时完成后的通知功能吗

本检查点完成源码适配、开发构建、Android原生子集及本机签名候选，不代表鸿蒙实况窗准入、三个端完整设备矩阵或新正式发行完成。旧0109公开发行和用户正在使用的平板进程未操作。
