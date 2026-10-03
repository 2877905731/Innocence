---
schema_version: 1
document_type: checkpoint
sequence: "0087"
created_at: "2026-10-03T17:29:29+08:00"
phase: P01
type: DONE
status: complete
title: "Android月计划与年度任务独立手机页及离线保存恢复验证"
objective: "用户询问Android月计划和年度任务是否未完成，并要求继续；补齐独立手机页，按既有计划语义和两主题实现并验证本机离线子集。"
completed:
  - fact: "独立Android日/月/年入口接入当前SessionController；完整月历、日期编辑、存档增改删/从今日归档及多日取消/跳过/覆盖套用已实现。日期完整触控目标至少48dp，切月清空选择，失败不伪造空计划或保存成功。"
    evidence: "android_plans_view.dart；android_month_year_test.dart闰月/多选/批量策略/失败路径；API36实际套用两天。"
  - fact: "年度12月刻度吸顶并与任务卡横向同步，48dp月份几何一致；唯一充能组件、七色、±10/5/1、完成/减量重开、任务增改删及独立子任务编辑/删除/勾选已实现。Windows继续原布局并复用抽取的绘制组件。"
    evidence: "annual_charge_span.dart；年度部件/桌面回归通过；API36实际0→15→14、子任务勾选、滑至12月及纵向吸顶截图。"
  - fact: "日计划/年度保存明确返回成功与失败，编辑器失败保留草稿；年度表单固定保存区域避让软键盘，反向月份/空标题/非法整数进度不静默改写。"
    evidence: "SessionController/TodayPlanEditorDialog/_AnnualEditor；宿主320dp/1.5字体/280dp键盘中英文两主题与失败重试用例；API36真实Gboard保存区截图。"
  - fact: "108项全量用例通过；最后调整日期触控尺寸后9项专项再次通过，analyze无问题，最终离线Debug APK构建成功。"
    evidence: "client/flutter_app/build/qa/android-month-year/内analyze-results.log、full-test-results.log、plan-specific-results.log及android-build.log。"
  - fact: "API36隔离合成本机资料下，双主题、存档两日套用、年度进度/子任务持久化与冷启动恢复核对成功；同一本机ownerScope，SQLite完整性和实际业务值一致，当前PID日志错误筛选0。"
    evidence: "build/qa/android-month-year/runtime-ui-results.json、runtime-persistence-results.json、runtime-cold-start.log及截图；COLD/Status ok/2395ms，PID3460。"
changed_files:
  - path: "client/flutter_app/lib/features/plans/presentation/pages/android_plans_view.dart"
    change: "新增手机月历/存档/年度任务独立页面、吸顶同步刻度及年度/子任务编辑器。"
  - path: "client/flutter_app/lib/features/plans/presentation/widgets/annual_charge_span.dart"
    change: "从桌面抽取共享年度充能绘制与12月网格，不改变进度/跨度语义。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "原桌面两个充能调用点接入共享组件，保留桌面布局及原测试键。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/android_home_shell.dart"
    change: "计划目的地接入独立页面、当前身份键和月年刷新回调，移除未完成占位文字。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
    change: "绑定现有会话计划数据/动作，日计划与年度保存使用明确结果回调。"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "saveTodayPlan/saveAnnualSegment/_runBusyAction返回bool，原有异常提示/busy清理和业务存储沿用。"
  - path: "client/flutter_app/lib/features/plans/presentation/widgets/today_plan_editor_dialog.dart"
    change: "增加结果式保存回调，失败保留草稿且不显示保存完成，兼容原void回调。"
  - path: "client/flutter_app/test/features/home/android_home_shell_test.dart"
    change: "补齐Shell新计划模型与回调fixture，继续验证既有导航。"
  - path: "client/flutter_app/test/features/plans/android_month_year_test.dart"
    change: "7项手机闰月/批量/进度与子任务/几何吸顶同步/字段校验/失败草稿/双主题双语窄屏键盘用例。"
  - path: "client/flutter_app/test/app/session_controller_month_year_test.dart"
    change: "2项真实SQLite重开/owner隔离/outbox与无会话/注入写入失败用例。"
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "记录本轮独立手机页实现、证据与尚未验收范围，历史章节保持。"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "2.36记录手机页面/触控/吸顶同步/编辑失败规则，后续规划按当前两主题决定更新。"
  - path: "docs/03-execution-plan.md"
    change: "更新Android当前步骤，保留P01/G01及正式发行基线。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新当前状态、0087基线及月年源码/验收/发行边界，下一序号0088。"
  - path: "progress/INDEX.md"
    change: "升序追加0087。"
  - path: "progress/0087__20261003__P01__DONE__android-month-year-mobile-plans.md"
    change: "本轮独立里程碑与可复核证据。"
evidence:
  - command: "D:/soft/flutter/bin/flutter.bat analyze --no-pub"
    result: "退出码0，No issues found，34.4秒；analyze-results.log。"
  - command: "D:/soft/flutter/bin/flutter.bat test --no-pub --reporter expanded"
    result: "退出码0，108项All tests passed，41秒；在最终日期触控层、大字体尺寸和411dp完整七列布局调整之前。"
  - command: "D:/soft/flutter/bin/flutter.bat test --no-pub --reporter expanded test/features/plans/android_month_year_test.dart test/app/session_controller_month_year_test.dart"
    result: "最终触控层/大字体/411dp完整七列布局调整后退出码0，9项All tests passed，7秒；不重复把全量108项写成最终改动后再次执行。"
  - command: "进程设置GRADLE_OPTS=-Dorg.gradle.project.kotlin.incremental=false；D:/soft/flutter/bin/flutter.bat build apk --debug --no-pub --dart-define=INNOCENCE_OFFLINE_ONLY=true"
    result: "最终构建退出码0，assembleDebug35.2秒；独立复制Innocence-android-month-year-debug.apk，159926002 bytes，SHA256 14920A1224C746C985DCA044B39EFF5C0EB877E768F65F058DF8D2FC9ADB28E7。Debug签名，不作为正式发行包。"
  - command: "emulator -avd Innocence_Release_API36 -data <build/qa/android-month-year/third-userdata.img> -cache <third-cache.img> -port 5634 -no-window -no-snapshot -gpu swiftshader；adb -s emulator-5634 install -r <本轮Debug APK>"
    result: "新隔离userdata，API36启动完成；安装Success。5558/5562初试没有ADB监听，netsh核对IPv4/IPv6保留5533–5632后改用5634成功；未修改系统端口保留范围，停止的仅是本轮自建无窗口模拟器。"
  - command: "adb -s emulator-5634 shell cmd connectivity airplane-mode enable；uiautomator dump/input/screencap（build/qa/android-month-year/ui.py辅助）"
    result: "飞行模式开启，显式进入本机离线；创建QA_Archive/QA_Daily30min并覆盖套用2026-10-04/05；QA_Annual_20261003跨度1–12/鎏金黄/初始0%，+10/+5/−1后14%，QA_Subtask勾选；双主题及Gboard固定保存目视可见。"
  - command: "adb -s emulator-5634 shell am force-stop com.innocence.app.innocence_flutter；adb -s emulator-5634 shell am start -W -n com.innocence.app.innocence_flutter/.MainActivity"
    result: "最终Status ok、LaunchState COLD、TotalTime2395ms/WaitTime2405ms；直接恢复同一本机入口与液态玻璃，月历2个计划日及年度14%/子任务1/1保留。"
  - command: "adb exec-out run-as com.innocence.app.innocence_flutter cat databases/innocence_local.db；Python sqlite3 PRAGMA integrity_check及计划/存档/年度/子任务业务值断言"
    result: "完整性ok；2026-10-04/05各QA_Daily30min未完成；QA_Archive1份；年度2026/1–12/gold/14%；QA_Subtask完成1，四表属于同一local资料域。只读取隔离合成资料，报告不输出原始owner标识。"
  - command: "adb shell input swipe（年度刻度水平至12月及内容纵向）；uiautomator/screencap；adb logcat -d --pid=3460 -v brief筛选FATAL EXCEPTION/E/flutter/Unhandled Exception/FlutterError/RenderFlex overflow"
    result: "最终APK覆盖安装Success；411dp月历七列完整可见，日列129×137px触控区域；月份12可见且任务网格同步，纵向滚动后月份刻度继续可见、子任务勾选可见；当前PID指定错误模式0命中。一次截图pull瞬时失败，单独重试成功，未将失败截图计为证据。"
  - command: "python build/qa/android-month-year/verify_runtime.py（安装最终APK后）"
    result: "退出码0；最终包冷启动/完整七列触控尺寸/两日计划/14%年度与独立子任务/吸顶横滑/指定日志模式和SQLite业务值全部断言通过。模拟器曾失去连接；无存活模拟器进程后用同一隔离userdata重启，再安装最终包，未清除资料。"
  - command: "最终包设置切换简约白色后，uiautomator/input/screencap核对月/年页；adb logcat -d --pid=3746 -v brief筛选指定Flutter错误模式"
    result: "最终简约白月历七列及年度14%实际截图可见，PID3746指定错误模式0命中；与最终液态玻璃截图并存。"
compatibility_and_security:
  contract_impact: "无后端接口/字段/版本号/发行配置变更；复用已有日计划/任务存档/年度模型。内部保存回调明确返回bool；TodayPlanEditorDialog兼容旧void回调。"
  tenant_impact: "UI仅绑定当前SessionController/ownerScope，身份变化重建页面；SQLite用例验证其他ownerScope空读。真实跨账号HTTP与权限回放尚未执行。"
  sensitive_data: "验收使用自建隔离userdata与合成任务，未登录真实账号；未读取或写入用户真实计划/凭据。日志、APK、SQLite副本、AVD镜像和截图留在忽略的build/qa目录，不进入Git。"
negative_paths:
  authentication_failure: "无会话返回false，401注入失败提示/busy恢复；不作为实际HTTP证据。"
  tenant_mismatch: "SQLite其他account资料域月/年/存档读取为空；真实targetUserNo回放待补。"
  permission_denied: "403注入拒绝写入，返回false，不显示保存成功；实际联网拒绝待补。"
  missing_field: "标题/子任务空值、倒置月份/非法进度字段验证；400注入拒绝路径。"
  generation_failure: "本轮无内容生成链路；采用合成FileSystemException覆盖本地输出/保存失败，不能作为生成服务验收。"
risks_or_blockers:
  - "实体Android设备/OEM/Vulkan、真实设备字体/系统返回完整矩阵与长时间性能仍未验收；宿主与API36不替代实体手机。"
  - "登录/云同步/跨租户权限的真实HTTP路径未执行，当前正式Android发行范围继续为本机离线。"
  - "正式版本仍v1.2.1+6；本轮Debug包不进入已发布资产，也不能用于正式签名升级。未推送origin或发布新版本；P01/G01与A0–A5继续未通过。"
  - "共享充能抽取有现有桌面回归证据，未重做Windows实际多尺寸/DPI视觉矩阵或Windows构建。"
next_actions:
  - id: NEXT-ANDROID-MONTH-YEAR-DEVICE
    action: "在实体设备核对两主题月历/年度刻度、键盘/系统返回、大字体与长期恢复；若用户请求新版本，再用原发行密钥构建并验证升级保留。"
    inputs: ["client/flutter_app/lib/features/plans/presentation/pages/android_plans_view.dart", "client/flutter_app/build/qa/android-month-year/", "docs/planning/Innocence-Android版本实施规划.md"]
---

# 运行证据位置

- 本轮本地Debug离线包：`client/flutter_app/build/qa/android-month-year/Innocence-android-month-year-debug.apk`。
- 简约白：`month-white-applied.png`、`annual-white-14.png`、`annual-keyboard.png`；液态玻璃：`month-glass-cold-restored.png`、`annual-glass-cold-restored.png`、`annual-glass-ruler-scrolled.png`、`annual-glass-sticky-subtask.png`。
- 原始构建/回归日志与结构化运行断言均位于同一忽略目录。证据为本机保留，源代码和当前进度记录进入本地Git提交。
