---
schema_version: 1
document_type: checkpoint
sequence: "0111"
created_at: "2026-10-12T16:57:58+08:00"
phase: P01
type: DONE
status: complete
title: "真机竖屏升级与实况窗权益定位、Android重启和Windows系统通知回执"
objective: "记录用户授权的平板覆盖与竖屏确认、通知原生运行子集及权益定位；真机实时倒计时保持待开发者账号和华为权益"
completed:
  - fact: "用户已保存草稿并明确允许覆盖安装重启。ARM64诊断候选官方验签/设备绑定核对后覆盖启动，本机资料/液态玻璃恢复；用户确认竖屏页面正常。"
    evidence: "用户原文与HDC安装/启动、仅本机私有的自身应用画面；未读取真实业务SQLite或保存合成任务。"
  - fact: "用户实际计时回执Live1003500005/代理1700002；前者在API26 SDK明确对应实况窗权益未开通。当前SDK验签Profile在内存检查未含Live/Push能力。"
    evidence: "physical-capability-receipt.json及FocusNotice通用日志；不输出Profile/设备标识。1700002为额度受限，不能由此独断所有应用额度或审核状态。"
  - fact: "API26独立.focusqa包系统桌面TIMER胶囊00:53到00:48，间隔5秒；暂停57秒且timer/capsule暂停标记均冻结，继续恢复。清理、自然到点一次、重复同步、身份变化与缺字段拒绝有原生收据。"
    evidence: "harmony-live-background-first/second.png、harmony-qa-paused/stable/resumed/identity-final-receipt/invalid-fields等本机QA文件。补齐layoutData/正式图标及有效停止载荷。"
  - fact: "代理提醒失败与Live失败分别报告，前台到点普通通知去重；权益缺失不再误报仅需普通通知授权。普通通知暂停401及跨原截止点消失修正。"
    evidence: "QA强制权益拒绝：暂停7秒等待12秒后7312=1/7313=0且仍7秒；继续、提前结束跨新截止点0/0、自然完成及复读0/1。verify_pause_boundary.py PASS。"
  - fact: "Windows生产通知区气泡实际被系统显示，独立原生入口观测SHOW和HIDE/TIMEOUT均1；无窗口时拒绝。"
    evidence: "生产win32_window.cpp/图标链接，focus-notice-windows-native-final.log；不读写用户窗口尺寸偏好，不注入系统回执。"
  - fact: "Android同发行证书离线Release候选较早版本覆盖API36成功/冷启动1772ms/错误筛选0；独立QA实际整机重启后完成通知恰好1、运行通知0。"
    evidence: "android-reboot-durable-notice-receipt.json与通用通知正文/QA持久化收据；先启动QA并等30秒包状态落盘，前两次未收到不计通过。最终能力提示版重新构建验签、未再次覆盖，原生提醒代码相同。"
  - fact: "最终ARM64签名Debug29.2秒/x64未签名24.5秒、Windows Release77秒/Android Release119.8秒均成功；最终HAP SDK验签/CRC/114Dart及3native文件精确字节/方向/权限/ELF通过。"
    evidence: "candidate-verification.json；ARM64 116045316bytes/SHA9a169440…，x64 117281505bytes/SHA532e3891…；Android65427988bytes/SHA6d4a4e52…，原证书/无INTERNET/版本8/non-debug PASS。"
  - fact: "最终ARM64修正版覆盖安装成功，首次锁屏拒绝10106102；用户随后解锁打开，当前进程及新权益状态回执存在。"
    evidence: "physical-pause-boundary-final-receipt.json、physical-rights-final-opened-receipt.json及最新通用回执backgroundAndLiveRightsRequired/1003500005/1700002；提示文本UI抓取未取得确证。"
  - fact: "用户确认没有AGC应用和开发者账号，选择先自行注册实名认证。官方AGC页已打开/读到实况窗调测服务说明并保留官方OAuth登录页；应用字段与TIMER/代理申请草稿就绪。"
    evidence: "用户异步答复与浏览器DOM；没有代创建应用、提交权益、输入账号/实名资料、接受协议或发送邮件。QA包已卸载，两个本轮专用模拟器已关闭。"
changed_files:
  - {path: "client/flutter_app/lib/core/platform/focus_notice_bridge.dart", change: "后台能力与实况窗权益状态独立映射"}
  - {path: "client/flutter_app/lib/app/app.dart", change: "中英文权益/后台不可用与暂停提示"}
  - {path: "client/flutter_app/ohos/entry/src/main/ets/entryability/FocusNoticeChannel.ets", change: "真实SDK载荷、失败隔离、完成清理/去重、暂停删除计划修正与安全Debug收据"}
  - {path: "client/flutter_app/test/core/platform/focus_notice_bridge_test.dart", change: "扩展真实原生能力结果映射回归"}
  - {path: "client/flutter_app/tool/harmonyos.ps1", change: "独立x64未签名Debug通知QA入口，生产入口保持"}
  - {path: "client/flutter_app/tool/focus_notice_probe.dart", change: "无账号/HTTP/业务SQLite的合成计时原生验证"}
  - {path: "client/flutter_app/windows/runner/tests/CMakeLists.txt", change: "链接生产原生窗口/图标与Flutter DLL"}
  - {path: "client/flutter_app/windows/runner/tests/focus_notice_native_test.cpp", change: "实际系统气泡回执及缺窗口检查，保护用户偏好"}
  - {path: "client/flutter_app/harmonyos/README.md", change: "真机竖屏/升级结果与权益依赖"}
  - {path: "docs/development/平板竖屏与专注系统提醒.md", change: "实际设备子集、暂停跨截止点和证据边界"}
  - {path: "docs/development/鸿蒙专注提醒权益接入.md", change: "错误码/权益定位、申请草稿与开发者账号接入步骤"}
  - {path: "docs/planning/Innocence-鸿蒙平板版本实施规划.md", change: "更新当前设备状态与0111续验/用户账号决策"}
  - {path: "progress/0000__AI-RESUME.md", change: "当前状态、账号依赖及0111/0112指针"}
  - {path: "progress/INDEX.md", change: "升序追加0111"}
  - {path: "progress/0111__20261012__P01__DONE__focus-runtime-and-harmony-rights.md", change: "本次窄里程碑、用户决策及未完成范围"}
evidence:
  - command: "flutter --no-version-check test --no-pub；dart analyze lib test tool/focus_notice_probe.dart"
    result: "exit0；196通过/5平台专属跳过/41秒，No issues found；focus-notice-rights-final-full-tests.log及final-analyze.log。竖屏布局未再修改，0110的6项专项证据沿用。"
  - command: "pwsh tool/harmonyos.ps1 -Action build -Architecture x64 -Unsigned -FocusNoticeProbe -DirectGit；HDC install/aa start/uitest；python verify_pause_boundary.py"
    result: "QA构建24.7秒exit0；实际系统通知暂停跨截止点、继续/清理/完成去重PASS；harmony-pause-boundary-verification.json。QA强制权益缺失入口仅限.focusqa。"
  - command: "pwsh tool/harmonyos.ps1 -Action build -DirectGit；同命令 -Architecture x64 -Unsigned；python verify_candidates.py/verify_device_binding.py"
    result: "最终ARM6429.2秒/x6424.5秒；官方SDK verify-app及单设备内存匹配PASS，114Dart/3native/CRC/方向/代理权限/全部ELF PASS；签名材料仅F盘私有。"
  - command: "HDC -s127.0.0.1:18710 install -r/aa start；shell -b应用 cat UIAbility/cache/focus_notice_capability.json"
    result: "最终安装成功，首次锁屏拒绝；用户解锁打开后当前进程存在，新回执backgroundAndLiveRightsRequired/1003500005/1700002。只读取固定通用Debug能力文件；没有复制owner/session偏好或真实业务库。"
  - command: "cmake构建windows/runner/tests；build/qa/focus-notice/windows/Release/focus_notice_native_test.exe"
    result: "exit0，userNotificationState5、notificationAccepted1、systemBalloonShow1、systemBalloonHideOrTimeout1。完整Flutter到点UI与免打扰未执行。"
  - command: "build_android_candidate.ps1；gradlew QA原生检查构建；adb instrument -e mode backgroundArm；adb reboot；cmd notification list/get（只读QA键）"
    result: "正式候选119.8秒/原发行证书和离线权限PASS；QA构建69秒，实际重启后7303=1/7302=0、通用正文正确，QA active=false/completed=qa/background。旧原生4组/拒权限/am kill子集见0110，不替代OEM/Doze/强行停止。"
  - command: "浏览器打开官方AGC、读取DOM并保留OAuth登录页；用户异步答复"
    result: "确认当前未登录，官方增长栏目有实况窗调测服务；用户尚无开发者账号，先自行注册实名。初始页面读取曾超时，改用文档内Playwright后读到页面；未执行创建/权益提交。"
  - command: "Java21+SnakeYAML2.5 VerifyFocusFollowupDocuments.java；PowerShell Parser；git diff --check"
    result: "exit0/PASS：7文档严格UTF8精确字节回转、4无重复键YAML、全部INDEX升序/路径、0111/0112指针及changed_files；PowerShell Parser PASS，diff检查exit0，仅既有LF/CRLF提示。"
compatibility_and_security:
  contract_impact: "仅本机提醒能力状态及独立QA入口；不改HTTP、业务签到/完成、同步、设备槽位或既有公开资产。"
  tenant_impact: "原生校验owner/session前缀，提前结束/身份变化清持久化旧截止点；实际QA身份清理和旧截止点复读不误发完成。真实登录HTTP认证失败未执行。"
  sensitive_data: "通知正文及日志只含通用计时/状态/错误码；Debug回执无身份任务，Release不生成。Profile/证书/验签/设备标识全部F盘忽略目录，仓库无签名或构建日志。"
negative_paths:
  authentication_failure: "未改认证链路，真实HTTP认证失败未执行；本地缺身份取消旧提醒见0110及独立QA。"
  tenant_mismatch: "独立QA身份变化和跨截止点复读无误完成；原生输入owner/key不匹配拒绝。"
  permission_denied: "Android拒绝通知权限原生路径见0110；鸿蒙实况窗权益拒绝1003500005真机实证，普通快照明确降级。"
  missing_field: "鸿蒙独立QA缺字段invalid_arguments；Flutter平台异常/缺插件与能力映射回归通过。"
  generation_failure: "代理提醒1700002与Live权益缺失分别失败/不阻断其他可用能力，前台完成去重通过；真实模型生成失败属于原G01未执行。"
risks_or_blockers:
  - "真机实时倒计时未完成：开发者账号/AGC应用/TIMER调测权益/新Profile待用户注册实名后接入。代理提醒1700002受限，后台完成保证仍未取得。"
  - "提示文本实际UI确证、权益开通后实体动态/暂停继续/锁屏/进程回收/到点仍待；SDK生命周期15秒至8小时及长时/系统隐藏策略另验。"
  - "Windows实际系统气泡子集通过，完整Flutter到点UI/免打扰/退出进程不在该结果内；Android实体/OEM/Doze/强行停止和完整设备矩阵继续待。"
  - "未推送/发布新版本或发送申请邮件；整体H0-H5/G01及既有其他未验项保持开放。"
next_actions:
  - id: NEXT-FOCUS-HARMONY-DEVELOPER
    action: "用户先自行注册华为开发者及实名。账号准备好后按接入材料核对同包名APP ID/创建应用、申请TIMER调测权益、新Profile和原证书覆盖；远端操作需用户具体授权，禁止静默增加业务联网。"
    inputs: ["docs/development/鸿蒙专注提醒权益接入.md", "client/flutter_app/build/harmonyos-h0/signed-device/0111/Innocence-portrait-focus-arm64-device-debug.hap"]
  - id: NEXT-FOCUS-PHYSICAL-RUNTIME
    action: "权益到位后核对真机逐秒变化、暂停/继续、后台/锁屏/进程回收与到点提醒；TIMER和代理提醒分别取证。现有最终包已打开，无需重复请求已有安装授权。"
    inputs: ["docs/development/平板竖屏与专注系统提醒.md", "client/flutter_app/build/qa/focus-notice/native-followup/candidate-verification.json"]
---

用户确认：“草稿已保存，可以覆盖安装并重启”“已转为竖屏，页面正常”“有通知，但数字不变化”“已开始，计时页面保持打开”。

后续确认：“还没有创建华为开发者应用”“已解锁并打开 Innocence”“还没有开发者账号，我先注册和实名认证”。这记录账号前提与用户选择，不代填注册或取得远端申请授权。

本检查点完成本机原生续验、真机问题定位和可复核候选。真实平板仍未实时变化，等待华为权益；模拟器成功和构建成功均不替代此验收。
