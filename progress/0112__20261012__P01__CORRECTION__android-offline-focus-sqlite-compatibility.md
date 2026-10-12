---
schema_version: 1
document_type: checkpoint
sequence: "0112"
created_at: "2026-10-12T18:27:04+08:00"
phase: P01
type: CORRECTION
status: complete
title: "Android离线专注SQLite兼容性修复及同证书本机安装包"
objective: "修复开始离线专注对SQLite JSON函数的依赖，验证真实事务及安卓原生存储，生成可覆盖安装的本机候选；用户手机复验仍待"
completed:
  - fact: "用户明确使用离线入口，提示原文为开始离线专注失败。定位到startFocusSession在插入计时记录前无条件执行json_set/json/json_extract，即使当前没有助手执行记录也会依赖JSON扩展。"
    evidence: "用户异步答复、offline_store.dart原1099行及控制器离线分支；手机系统版本和底层异常尚未取得，因此不能断言用户手机已复现此根因。"
  - fact: "移除生产JSON SQL，改为在原事务中按owner和execution种类读取、Dart解析并更新撤销资格；保留created_at、其他字段、过期摘要及其他身份数据。专注结束仍不会恢复旧撤销资格，数据库schema保持v6。"
    evidence: "offline_assistant_store.dart的_assistantInvalidateUndo及startFocusSession调用；无JSON扩展的回归真实保留SQLite事务。"
  - fact: "同一兼容性用例修改前exit1/专注未激活，修改后exit0；33项相关回归通过，含完整控制器离线生命周期/同owner重启恢复、其他身份不变、缺执行字段摘要、保存失败后的撤销资格/修订/outbox原子回滚。"
    evidence: "build/qa/android-offline-focus/before-test.log与regression.log；新增3项兼容性用例及既有存储/恢复/助手回归。"
  - fact: "API36独立focusqa包使用生产OfflineStore和Android原生sqflite，SQLite3.44.3具有JSON函数；修改前本机计时生命周期本身已成功，不能把API36作为原问题复现。修复后开始、暂停、关闭重开数据库恢复、继续、结束全部成功/专注记录1/outbox1，最终收据无异常。"
    evidence: "after-receipt.json；原生QA只写独立包的合成数据库，不读写原产品资料。初轮探针末尾统计查询错误使用已关闭连接，已修正为重新打开连接；该探针错误不是产品故障。"
  - fact: "本机Android离线Release构建37.7秒成功；版本仍1.2.3+8、原发行证书一致、无INTERNET、non-debug及提醒权限核对通过。安装包65427988bytes/SHA25605fdc52a3cebb0ce65d1b14ecdb05aa553bc8c11571e9b26af5a4d165b21eb6b。"
    evidence: "release-build.log、artifact-manifest.json及Innocence-android-offline-focus-fix.apk；不替换旧发行资产。独立QA已卸载，本轮无窗口模拟器已关闭。"
changed_files:
  - {path: "client/flutter_app/lib/core/local/offline_assistant_store.dart", change: "按当前身份在事务内用Dart更新撤销资格，去掉SQLite JSON扩展要求"}
  - {path: "client/flutter_app/lib/core/local/offline_store.dart", change: "开始离线专注调用兼容的撤销保护"}
  - {path: "client/flutter_app/test/core/local/offline_focus_compatibility_test.dart", change: "禁止JSON SQL的真实SQLite回归、完整控制器生命周期、身份/字段保持及事务回滚"}
  - {path: "progress/0000__AI-RESUME.md", change: "0112当前状态、候选及手机验收下一步；保留鸿蒙权益待办"}
  - {path: "progress/INDEX.md", change: "升序追加0112"}
  - {path: "progress/0112__20261012__P01__CORRECTION__android-offline-focus-sqlite-compatibility.md", change: "本次修复、命令和证据边界"}
evidence:
  - command: "flutter --no-version-check test --no-pub test/core/local/offline_focus_compatibility_test.dart --plain-name 'offline controller starts, pauses, restores and finishes without JSON SQL'（修改前）"
    result: "exit1；专注active预期true/实际false。测试适配器拒绝JSON SQL，其余操作使用真实FFI SQLite；不是旧版安卓真机证据。"
  - command: "flutter --no-version-check test --no-pub test/core/local/offline_focus_compatibility_test.dart test/core/local/offline_store_test.dart test/app/session_controller_offline_restore_test.dart test/features/assistant/assistant_store_test.dart"
    result: "exit0；33通过；build/qa/android-offline-focus/regression.log。未重复无关全量或其他平台构建。"
  - command: "D:/soft/flutter/bin/cache/dart-sdk/bin/dart.exe analyze lib test"
    result: "exit0/No issues found；build/qa/android-offline-focus/analyze.log。"
  - command: "gradlew :app:assembleDebug -Ptarget=build/qa/android-offline-focus/focus_store_probe.dart -Pdart-defines=SU5OT0NFTkNFX09GRkxJTkVfT05MWT10cnVl -Pinnocence.notificationQa=true -Pkotlin.incremental=false -Pkotlin.compiler.execution.strategy=in-process；adb install -r；adb shell am start -W及run-as读取QA收据"
    result: "修复后QA构建exit0/10秒，安装Success/COLD3840ms；after-receipt.json全部生命周期true且focusRows1。仅独立focusqa包，未执行产品UI点击或真实手机覆盖。"
  - command: "build/qa/android-offline-focus/build_release.ps1（进程内加载已有加密发行签名凭据；flutter build apk --release --no-pub --dart-define=INNOCENCE_OFFLINE_ONLY=true；apksigner verify/aapt dump）"
    result: "exit0/37.7秒；原证书/无INTERNET/版本8/non-debug/提醒权限PASS，最终摘要见上述fact和artifact-manifest.json。未输出凭据。"
compatibility_and_security:
  contract_impact: "不修改HTTP/同步/schema/助手撤销业务语义；只修复本机SQLite功能可用性假设。"
  tenant_impact: "只更新当前owner的execution文档，查询和更新均绑定owner+kind+document_id；跨owner和非execution字段保持有回归。"
  sensitive_data: "只使用合成资料；原生探针、日志和APK在F盘忽略目录；签名凭据沿已有用户加密文件并仅进入构建进程环境，不进仓库或日志。"
risks_or_blockers:
  - "用户手机系统版本、SQLite实际错误及覆盖安装后的效果尚未取得；不把API36或受限FFI环境当作实体旧安卓验收。"
  - "认证失败/通知权限拒绝/真实生成失败不属于本次修改链路，未重复相关HTTP/原生/供应商回放；原G01及鸿蒙实况窗权益待办继续保留。"
next_actions:
  - id: NEXT-ANDROID-FOCUS-PHYSICAL
    action: "用户把本机修正版APK传到手机直接覆盖安装，不卸载旧版；确认原资料保留及开始/暂停/继续/结束。如仍失败，依据手机系统版本和脱敏异常继续定位。"
    inputs: ["client/flutter_app/build/qa/android-offline-focus/Innocence-android-offline-focus-fix.apk", "client/flutter_app/test/core/local/offline_focus_compatibility_test.dart"]
---

用户报告安卓开始专注后失败，随后明确为离线使用、提示“开始离线专注失败”。这是本机持久化链路修复，不是新正式发行。SQLite官方文档说明JSON函数从3.38.0起才默认包含，旧版本需编译启用扩展，不能要求所有安卓宿主具备该能力：[SQLite JSON官方说明](https://www.sqlite.org/json1.html)。本次证据支持明确的兼容性缺陷和修复；用户手机的实际根因及修复效果仍需设备回执确认。
