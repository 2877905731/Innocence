---
schema_version: 1
document_type: checkpoint
sequence: "0140"
created_at: "2026-10-31T01:30:18+08:00"
phase: P01
type: DONE
status: complete
title: "Android通知主体直接显示剩余时间，原生与后台暂停画面验证"
objective: "按用户要求，Android通知像鸿蒙一样优先显示剩余时间，替换轮次正文"
completed:
  - fact: "专注、旧绑定番茄和独立番茄共用紧凑/展开RemoteViews，阶段标题旁直接显示大号剩余时间，正文使用剩余时间快照。"
    evidence: "TimerNoticeContent.kt及timer_notice.xml；运行Chronometer由System UI推进，暂停隐藏动态控件并显示固定文本，轮次仅保留原阶段计算。"
  - fact: "本机原生构建和相关回归通过。"
    evidence: "JDK21 Gradle重试33秒成功，最终串行10组原生全部PASS，拒绝通知权限PASS，20项Flutter回归通过。"
  - fact: "取得实际系统通知动态、暂停和大字体深色画面。"
    evidence: "API36只读模拟器独立focusqa包：24:44→24:19/1:29:44→1:29:19，am kill及pidof为空后仍递减；暂停两张PNG间隔3秒，均25:00/01:30:00且SHA256完全相同。英文1.5倍深色展开组显示24:25/1:29:25。"
  - fact: "本轮仅完成源码与独立QA验证。"
    evidence: "未改版本或公开发行资产、未签发新正式APK、未推送或操作服务器/实体设备。QA卸载、字体和夜间模式恢复、本轮模拟器关闭。"
changed_files:
  - path: client/flutter_app/android/app/src/main/kotlin/com/innocence/app/innocence_flutter/TimerNoticeContent.kt
    change: "系统通知主体倒计时、冻结文本及双语快照公共适配"
  - path: client/flutter_app/android/app/src/main/res/layout/timer_notice.xml
    change: "紧凑/展开共用的阶段与大号剩余数字布局"
  - path: client/flutter_app/android/app/src/main/kotlin/com/innocence/app/innocence_flutter/FocusNoticeChannel.kt
    change: "专注与旧绑定番茄接入主体倒计时，去除轮次正文"
  - path: client/flutter_app/android/app/src/main/kotlin/com/innocence/app/innocence_flutter/PomodoroNotices.kt
    change: "独立番茄接入公共通知布局，原阶段逻辑保留"
  - path: client/flutter_app/android/app/src/androidTest/kotlin/com/innocence/app/innocence_flutter/FocusNoticeNativeTest.kt
    change: "剩余正文/原生布局/小时双语及受限QA预览模式"
  - path: docs/development/独立番茄闹钟.md
    change: "通知显示范围、系统分组和未发行边界"
  - path: docs/development/平板竖屏与专注系统提醒.md
    change: "补Android通知主体适配及证据指针"
  - path: progress/0000__AI-RESUME.md
    change: "当前状态、下次发行和实体通知待验"
  - path: progress/INDEX.md
    change: "按升序追加0140"
  - path: progress/0140__20261031__P01__DONE__android-notice-remaining-countdown.md
    change: "当前里程碑与明确验证边界"
evidence:
  - command: "JAVA_HOME=JDK21；gradlew :app:assembleDebug :app:assembleDebugAndroidTest -Pinnocence.notificationQa=true -Pkotlin.incremental=false --console=plain"
    result: "exit0/33秒。首轮未禁用增量时两个第三方插件跨盘缓存失败；重试通过，未修改依赖或永久构建设置。"
  - command: "adb install两QA APK；pm grant POST_NOTIFICATIONS；appops SCHEDULE_EXACT_ALARM allow；am instrument -w FocusNoticeNativeTest"
    result: "最终串行10/10通过：倒计时暂停继续/到点去重/身份旧会话/缺字段/绑定阶段/独立时钟/原生布局小时双语。首次6组后被预览instrumentation打断，不计通过。"
  - command: "pm revoke POST_NOTIFICATIONS；am instrument -w -e mode denied；随后恢复授权"
    result: "Denied notification permission: PASS；两类同步permissionRequired，7302/7303/7304/7305/7306均不存在。"
  - command: "flutter test --no-pub test/core/platform/focus_notice_bridge_test.dart test/features/focus/independent_pomodoro_test.dart --reporter expanded"
    result: "exit0/20项通过，覆盖身份切换、拒绝权限、本机持久化、四主题窄宽布局和独立生命周期。"
  - command: "am instrument受限focusqa预览；cmd statusbar expand-notifications；am kill/pidof；screencap/pull；深色与font_scale=1.5"
    result: "running.png/background.png数字递减；paused.png/paused-later.png均131683bytes/SHAf1a02b7118c628bd5e14006d61a190a6ca8c5ad3cf59601300fd4b59a60e1c1f。英文大字体深色展开数字完整。动态UI使uiautomator dump无法获取idle，未将其计为通过，使用实际PNG与原生控件断言。"
compatibility_and_security:
  contract_impact: "仅Android显示适配；Flutter通道字段、HTTP、SQLite、阶段/统计与到点提醒语义不变。最低API24具备所用原生API。"
  tenant_impact: "原owner/key校验、取消旧身份通知及独立计时隔离保持；未访问真实业务资料。"
  sensitive_data: "通知仍仅通用阶段/时间，未包含身份、任务或凭据；本机日志/APK/截图均在Git忽略的build目录。"
risks_or_blockers:
  - "系统自动合并多通知时，折叠组摘要采用系统模板和快照；展开组后显示各自动态数字。不是厂商私有状态栏胶囊。"
  - "真实Android/鸿蒙4手机、OEM、省电/Doze、强行停止仍待；API36不替代实体矩阵。"
  - "公开v1.3.1仍为0139发行包，本轮无新正式安装包或远端发布。原G01保持开放。"
next_actions:
  - id: NEXT-ANDROID-COUNTDOWN-DELIVERY
    action: "后续Android发行纳入本轮改动，原证书/生产HTTPS构建，覆盖保资料后按真实手机验通知紧凑/展开、暂停/继续/阶段切换/后台。"
    inputs: [docs/development/独立番茄闹钟.md]
---
