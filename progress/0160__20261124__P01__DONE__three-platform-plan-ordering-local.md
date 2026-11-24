---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0160"
created_at: "2026-11-24T22:58:23+08:00"
phase: P01
type: DONE
status: complete
title: "三端今日与年度任务手动排序本机实现，持久化与隔离验证及三端构建"
objective: "按用户要求为Windows、Android、鸿蒙平板的今日任务、年度任务及年度子任务增加排序；本检查点仅确认本机实现、验证与构建，不代表生产或设备已更新。"
completed:
  - fact: "三端今日任务、年度任务及年度子任务均接入排序入口；共享面板支持拖动手柄和上移/下移，完整列表确认保存、取消不写入、失败保留草稿。年度月份筛选共用全年顺序。编辑器内新增/编辑的任务和年度子任务也可调整草稿顺序。"
    evidence: "Android独立计划页面与Windows/鸿蒙PC页面的实际回调均接入SessionController；共享排序组件手机宽度及Windows编辑器用例通过。"
  - fact: "新增Bearer PUT /plans/reorder，按日/年/年度父任务校验完整ID集合、重复、归属与revision，在事务内仅写sort_order并推进版本；保留任务ID、时段、完成状态、实际时长及年度月份/颜色/进度/子任务内容。"
    evidence: "PlanOrderHttpIntegrationTest通过真实Controller/Service/MySQL映射；131项后端全量0失败/错误/跳过，认证401、跨租户父任务404、权限403及缺字段/重复/不完整/陈旧版本400均被拒绝。"
  - fact: "离线排序按ownerScope原子更新并进入原daily_plan/annual_segment快照outbox；重启保留顺序，现有导入预览和账号确认边界不变。今日编辑器不再把手动顺序重置为时间排序。"
    evidence: "SQLite实际文件、任务/子任务ID和业务值、owner隔离、陈旧/不完整/重复拒绝、注入第二条更新失败后的顺序/revision/outbox整体回滚均通过。"
  - fact: "Windows Release、鸿蒙ARM64联网未签名Release、Android联网Debug及后端JAR构建成功；鸿蒙暂存130个Dart文件与源文件逐字节一致。"
    evidence: "build/qa/plan-order-20261124/verification.json记录大小/SHA256/ZIP CRC；Android Debug v2签名与三ABI核对通过；版本仍为1.3.4+16开发构建，不是新发行。"
changed_files:
  - path: client/flutter_app/lib/features/plans/domain/models/plan_order.dart
    change: "显式排序范围、完整清单及版本字段的内部模型与JSON适配。"
  - path: client/flutter_app/lib/features/plans/presentation/widgets/plan_order_button.dart
    change: "三端共享排序面板与编辑草稿排序控件。"
  - path: client/flutter_app/lib/features/plans/presentation/widgets/today_plan_editor_dialog.dart
    change: "保留混合手动顺序、任务ID与实际时长，新日任务末尾追加，双布局草稿排序。"
  - path: client/flutter_app/lib/features/plans/presentation/pages/android_plans_view.dart
    change: "Android年度任务/子任务排序与子任务编辑草稿排序。"
  - path: client/flutter_app/lib/features/home/presentation/pages/android_home_shell.dart
    change: "Android今日任务清单排序。"
  - path: client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart
    change: "Windows/鸿蒙首页、今日、年度和本月年度预览及子任务的排序入口。"
  - path: client/flutter_app/lib/features/home/presentation/pages/home_page.dart
    change: "传递三端共用排序回调。"
  - path: client/flutter_app/lib/app/app.dart
    change: "连接SessionController排序动作。"
  - path: client/flutter_app/lib/app/session_controller.dart
    change: "在线/本机排序、刷新与身份切换后不应用旧结果。"
  - path: client/flutter_app/lib/features/plans/data/study_plan_api.dart
    change: "排序HTTP适配器。"
  - path: client/flutter_app/lib/core/local/offline_store.dart
    change: "引入排序模型及排序存储part。"
  - path: client/flutter_app/lib/core/local/offline_plan_order_store.dart
    change: "ownerScope事务、版本/完整集合校验和原快照outbox。"
  - path: client/flutter_app/test/features/plans/plan_order_test.dart
    change: "真实SQLite重启/回滚、手机排序失败重试、Windows编辑器保序。"
  - path: server/innocence-server/src/main/java/com/innocence/server/modules/plan/controller/PlanOrderController.java
    change: "受保护的排序端点。"
  - path: server/innocence-server/src/main/java/com/innocence/server/modules/plan/dto/request/ReorderPlanRequest.java
    change: "严格范围、ID和版本校验DTO。"
  - path: server/innocence-server/src/main/java/com/innocence/server/modules/plan/service/PlanOrderService.java
    change: "完整范围检查及原子顺序更新。"
  - path: server/innocence-server/src/main/java/com/innocence/server/modules/plan/mapper/StudyPlanMapper.java
    change: "按当前用户及父实体限定的纯顺序UPDATE。"
  - path: server/innocence-server/src/main/java/com/innocence/server/modules/plan/service/StudyPlanService.java
    change: "年度保存/删除与排序共用owner锁。"
  - path: server/innocence-server/src/test/java/com/innocence/server/modules/plan/service/PlanOrderHttpIntegrationTest.java
    change: "真实MySQL及HTTP的顺序/ID/业务值和认证、租户、权限、字段、版本负向。"
  - path: docs/development/计划手动排序.md
    change: "归档用户范围、交互、契约与兼容边界。"
  - path: docs/06-contract-inventory.md
    change: "新增排序接口索引。"
  - path: docs/07-dataflow-and-module-map.md
    change: "新增三端排序数据流。"
  - path: docs/03-execution-plan.md
    change: "记录本机排序工作轨道与待发布边界。"
  - path: progress/0000__AI-RESUME.md
    change: "更新恢复状态、下一动作及最新检查点。"
  - path: progress/INDEX.md
    change: "按序追加0159。"
evidence:
  - command: "dart analyze lib test"
    result: "退出0，No issues found。"
  - command: "flutter test --no-pub --reporter expanded"
    result: "退出0，278通过/6平台条件跳过。随后补写SQLite故障注入后，排序专项3项单独重跑通过。"
  - command: "flutter test --no-pub test/features/plans/plan_order_test.dart"
    result: "退出0，3项通过，含实际SQLite中途失败事务回滚。"
  - command: "flutter test --no-pub --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos --dart-define=INNOCENCE_OFFLINE_ONLY=false --dart-define=INNOCENCE_API_BASE_URL=https://85.189.40.87/api/app/v1/ test/core/layout/harmony_tablet_presentation_test.dart test/features/plans/plan_order_test.dart"
    result: "退出0，9项通过/0跳过，含PC导航/旋转/键盘/四主题宿主及排序专项；非真机交互证据。"
  - command: "mvn -q test；mvn -q -DskipTests package"
    result: "均退出0；Surefire XML合计131项，0失败/错误/跳过；JAR构建成功。"
  - command: "flutter build windows --release --no-pub，显式联网define与生产地址"
    result: "退出0，59.4秒成功；构建仅本机，未启动/覆盖用户程序。"
  - command: "tool/harmonyos.ps1 -Action build -BuildMode release -Edition Online -Unsigned"
    result: "退出0，201.0秒生成53764881字节未签名ARM64 HAP；130个Dart副本逐字节一致。未签名安装。"
  - command: "设置进程GRADLE_OPTS=-Dorg.gradle.project.kotlin.incremental=false -Dorg.gradle.project.kotlin.compiler.execution.strategy=in-process；flutter build apk --debug --no-pub，显式联网define与生产地址"
    result: "首次默认增量编译因C盘Pub缓存/F盘项目的Kotlin路径失败；关闭增量后退出0，53.0秒生成176678934字节Debug APK。原签名默认目录不存在，未生成正式签名Release包，不作为覆盖升级包交付。"
  - command: "apksigner verify --verbose；aapt dump badging；Python ZIP CRC/SHA256与鸿蒙Dart副本逐字节比较；git diff --check"
    result: "Debug APK v2签名通过，1.3.4+16/三ABI；APK/HAP/JAR无CRC错误，130个Dart无差异；diff无空白错误。摘要见本机verification.json。"
compatibility_and_security:
  contract_impact: "新增排序端点，无SQL结构迁移；旧保存/读取接口保留。新版在线排序依赖部署此后端，旧生产服务尚无该端点。"
  tenant_impact: "服务端身份来自Bearer；离线按ownerScope查询/事务；排序前完整集合及revision检查；不新增自动导入、模型工具或完成通知。"
  sensitive_data: "未访问生产数据或修改真实任务；Android签名默认文件仅作存在性核对后失败，无凭据写入仓库/日志。generation_failure不适用，本功能不调用模型。"
risks_or_blockers:
  - "Android原发行证书及DPAPI签名材料当前默认目录缺失，正式签名包与原签名覆盖升级待恢复材料后执行；当前Debug不可作为原证书升级。"
  - "未部署后端、未推送或公开Release、未安装设备；实际三端拖动/触控、完整跨设备同步仍待。公开与个人设备基线仍为0155/0156的1.3.4，P01/G01保持开放。"
next_actions:
  - id: NEXT-PLAN-ORDER-DELIVERY
    action: "取得用户本轮发布指令并恢复原Android签名材料后，沿本机编译与原证书路径出正式包；部署排序后端并按用户范围分发/覆盖三端。不得把当前Debug或未签名HAP作为原证书升级，不重建真实任务验证。"
    inputs: [docs/development/计划手动排序.md]
---

本轮开始时已有鸿蒙补件文档、0157/0158恢复记录和其他非本任务文件的未提交修改；均保留，未回退或清理。0160是本机实现里程碑，公开发布与生产验收须另记证据。
