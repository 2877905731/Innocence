---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0149"
created_at: "2026-11-02T21:25:51+08:00"
phase: P01
type: DONE
status: complete
title: "助手年度任务路由与诊断修复，多对话创建切换删除本机验证"
objective: "按鸿蒙年度工具确定性失败反馈核查共享调用，修复联网新建/编辑及错误信息，并增加按身份隔离的多个可删除对话；不重跑真实任务、不部署或发行。"
completed:
  - fact: "只读核查现网近72小时容器29行日志，10个用户提供的关联ID均未命中；API Nginx access_log关闭，缺失不能证明请求未到后端。"
    evidence: "既有授权SSH只读日志分类计数与/etc/nginx/conf.d/innocence-api-https.conf核对；未复制原始业务日志或凭据。"
  - fact: "确认共享年度工具为新建草稿同时填id/clientEntityId UUID，导致StudyPlanApi走PUT而服务端路径参数为Long；联网新建现留空id走POST，本机稳定UUID保留。进度默认0及子任务对象映射原已存在，不作为已证实数据库根因。"
    evidence: "AssistantAppTools→真实SessionController/StudyPlanApi→TCP loopback六项；Controller/Service/MySQL事务六项，最小year2027/title=x/1–1月/空备注空子任务创建成功。"
  - fact: "现有年度任务按真实ID编辑，保留70%进度和已完成子任务；当前账号幂等键无需预登记，跨账号独立。工具错误穿透bool封装，保留错误码/可读原因/请求标识与可用HTTP状态。"
    evidence: "annual_tool_http_test.dart和AnnualPlanHttpIntegrationTest；401/403/404/缺字段/非法路径与跨租户负向通过，所有MySQL合成夹具事务回滚。"
  - fact: "后端新增UUID请求追踪/响应头，只记录静态路由模板、验证后的标识、状态及耗时；路径类型和不可读JSON返回400/1001，不输出正文、查询、身份或凭据。"
    evidence: "RequestTraceFilterTest三项：响应头与body一致、后续请求无串号、敏感输入不入日志、非法JSON拒绝。未部署现网。"
  - fact: "多对话按在线账号/本机owner隔离，支持新建、切换、确认删除、独立草稿/模式、当前选择恢复及旧历史安全迁移；最后一个删除后新建空对话，业务任务保留。"
    evidence: "chat_conversations_test七项和四主题×320/1280宽度八项页面回归；1.5倍字体/键盘宿主截图，生成/待确认管理阻止、停止/身份变化、失败保留、密钥文本过滤均覆盖。"
  - fact: "267项客户端通过、6项条件跳过，120项后端通过；Android/鸿蒙配置各21项专项、静态分析、三端构建及124 Dart/4 ArkTS精确字节和包结构摘要核对通过。"
    evidence: "build/qa/assistant-annual-verification.json及client/flutter_app/build/qa/assistant-annual-*.log；宿主截图在build/qa/chat-conversations，均不进Git。"
changed_files:
  - path: client/flutter_app/lib/app/session_controller.dart
    change: "保留最近ApiException并透传年度请求标识"
  - path: client/flutter_app/lib/core/network/api_client.dart
    change: "业务请求UUID追踪及错误requestId保留"
  - path: client/flutter_app/lib/core/network/api_exception.dart
    change: "增加可选requestId"
  - path: client/flutter_app/lib/core/utils/request_id.dart
    change: "共享安全随机UUID生成"
  - path: client/flutter_app/lib/features/assistant/application/assistant_app_tools.dart
    change: "在线新建空id、编辑保留状态、实际结果核对和诊断"
  - path: client/flutter_app/lib/features/assistant/application/chat_controller.dart
    change: "多对话状态/写队列/草稿/身份边界及工具错误透传"
  - path: client/flutter_app/lib/features/assistant/application/chat_tools.dart
    change: "结构化ChatToolFailure"
  - path: client/flutter_app/lib/features/assistant/data/chat_repository.dart
    change: "按owner保存ChatWorkspace v2并安全迁移/删除"
  - path: client/flutter_app/lib/features/assistant/domain/chat_conversation.dart
    change: "独立对话模型和严格持久化格式"
  - path: client/flutter_app/lib/features/assistant/presentation/assistant_chat_page.dart
    change: "宽屏侧栏、窄屏抽屉、新建切换及删除确认"
  - path: client/flutter_app/lib/features/plans/data/study_plan_api.dart
    change: "年度写入追踪头"
  - path: client/flutter_app/test/features/assistant/annual_tool_http_test.dart
    change: "实际客户端TCP年度创建/编辑与HTTP错误六项"
  - path: client/flutter_app/test/features/assistant/chat_assistant_test.dart
    change: "仓储夹具兼容、多层诊断回传及本机稳定ID重试"
  - path: client/flutter_app/test/features/assistant/chat_conversation_page_test.dart
    change: "四主题宽窄布局、草稿、删除确认八项"
  - path: client/flutter_app/test/features/assistant/chat_conversations_test.dart
    change: "多对话隔离/迁移/持久化失败/停止七项"
  - path: client/flutter_app/test/features/assistant/chat_page_test.dart
    change: "先恢复workspace再注入页面夹具"
  - path: server/innocence-server/src/main/java/com/innocence/server/common/api/ApiResponse.java
    change: "公共响应使用当前请求追踪ID"
  - path: server/innocence-server/src/main/java/com/innocence/server/common/web/GlobalExceptionHandler.java
    change: "类型错误及不可读JSON明确返回400/1001"
  - path: server/innocence-server/src/main/java/com/innocence/server/common/web/RequestTrace.java
    change: "线程范围追踪绑定和清理"
  - path: server/innocence-server/src/main/java/com/innocence/server/common/web/RequestTraceFilter.java
    change: "验证UUID及安全关联日志"
  - path: server/innocence-server/src/test/java/com/innocence/server/common/web/RequestTraceFilterTest.java
    change: "三项追踪一致性/隔离与敏感内容负向"
  - path: server/innocence-server/src/test/java/com/innocence/server/modules/plan/service/AnnualPlanHttpIntegrationTest.java
    change: "真实MySQL事务年度HTTP六项"
  - path: docs/development/助手年度任务修复与多对话.md
    change: "根因、日志边界、迁移及本轮验收范围"
  - path: docs/development/AI对话助手配置与验收.md
    change: "现行多对话使用步骤和0149证据"
  - path: docs/planning/Innocence-AI智能助手B方案实施与契约.md
    change: "第14节固化年度ID/诊断及多对话契约"
  - path: docs/02-contract-and-compatibility-rules.md
    change: "年度标识与多对话兼容指针"
  - path: docs/03-execution-plan.md
    change: "助手本机完成状态与后续真实设备范围"
  - path: docs/06-contract-inventory.md
    change: "现行年度接口及请求追踪说明"
  - path: docs/07-dataflow-and-module-map.md
    change: "年度和多对话数据流，并将0148说明移出YAML头恢复结构"
  - path: docs/08-project-profile.md
    change: "当前助手范围及门禁说明"
  - path: progress/0000__AI-RESUME.md
    change: "恢复状态和0148/0149未发布后续动作"
  - path: progress/INDEX.md
    change: "升序追加0149"
  - path: progress/0149__20261102__P01__DONE__assistant-annual-fix-and-multiple-conversations.md
    change: "本检查点"
evidence:
  - command: "ssh -i build/deployment/ssh-control/id_ed25519_innocence -o BatchMode=yes -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes root@85.189.40.87 python3 -（输入只读容器/Nginx日志计数脚本）"
    result: "29行保留容器日志、10个关联ID均0匹配；API_ACCESS_LOG_DISABLED=True；只读，无生产数据变更。"
  - command: "flutter test --no-pub --reporter expanded（client/flutter_app）"
    result: "267项通过、6项条件跳过；包括模型失败/停止、类型化诊断、年度TCP和多对话回归。"
  - command: "dart analyze lib test（client/flutter_app）"
    result: "No issues found。"
  - command: "mvn -q verify（server/innocence-server）"
    result: "120 tests、0 failures/errors/skips；含本轮9项后端专项，合成MySQL夹具回滚。"
  - command: "flutter test --no-pub test/features/assistant/annual_tool_http_test.dart test/features/assistant/chat_conversations_test.dart test/features/assistant/chat_conversation_page_test.dart --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos；android配置同组命令"
    result: "各21项通过；为显式目标平台的宿主验证，不是实体三端证据。"
  - command: "flutter build windows --release --dart-define-from-file=config/production.json"
    result: "Release exe构建成功。"
  - command: "./gradlew.bat :app:assembleDebug -Pinnocence.notificationQa=true -Pkotlin.incremental=false --console=plain（client/flutter_app/android）"
    result: "独立.focusqa APK构建成功，未安装主应用。"
  - command: "& ./tool/harmonyos.ps1 -Action build -BuildMode release -Edition Online -Unsigned（client/flutter_app；PS7）"
    result: "ARM64 AOT联网未签名Release HAP构建成功，未签名安装。"
  - command: "python build/qa/verify_assistant_annual_artifacts.py"
    result: "124份Dart/4份ArkTS分发副本字节一致；Windows MZ及APK/HAP CRC/大小/SHA256通过；后端与客户端计数和两目标配置日志核对通过。"
  - command: "dart --packages=client/flutter_app/.dart_tool/package_config.json build/qa/verify_assistant_frontmatter.dart；git diff --check"
    result: "10份当前YAML头解析通过；差异无空白错误。"
compatibility_and_security:
  contract_impact: "不改年度业务字段/权限/数据库结构，仅修复在线创建路由并新增可选追踪头及错误字段；ChatWorkspace v2本机格式带旧历史迁移，不新增云同步。0148 SQLite v9候选保留。"
  tenant_impact: "业务仍取Bearer或本机owner；对话、草稿和连接均按原身份隔离；跨租户统一404。多对话切换/恢复不授予工具执行权限。"
  sensitive_data: "未读取真实模型密钥、未保存原始请求/个人数据/原始线上日志；真实任务未重跑，SQLite/HTTP为合成夹具，MySQL均回滚。"
risks_or_blockers:
  - "0148和0149均未部署、推送、安装主应用或公开发行；用户现网仍为原版本，不能宣称线上问题已消失。"
  - "真实供应商发现/生成/工具与费用、实体三端旧历史/输入/密钥/操作和完整同步矩阵仍待。"
  - "每对话沿用最近120条可见历史上限，正文未加密且不云同步；已有年度子任务编辑仍走原页面。"
  - "鸿蒙TIMER审核及G01等原门禁不变，在线更新模块仍仅有资源评估。"
next_actions:
  - id: NEXT-RELEASE-CANDIDATES
    action: "正式发行时合并0148计时/封面和0149助手；先备份/迁移并部署学习接口及追踪，再原签名升版本分发，不以QA APK或未签名HAP冒充正式包。"
    inputs: [docs/development/计时阶段与学习入账.md, docs/development/助手年度任务修复与多对话.md]
  - id: NEXT-ASSISTANT-DEVICE
    action: "正式包在原设备使用独立合成资料验年度最小创建/编辑和多对话迁移/切换/删除；用户自行配置真实供应商，核对读取范围、操作确认和实际结果，不重跑真实计划。"
    inputs: [docs/development/AI对话助手配置与验收.md]
---

本检查点完成本机修复和隔离验证。旧版日志没有足够关联信息，源码与隔离集成链路证明了错误的创建路由，但未据此编造用户当时的HTTP状态或SQL异常；也未将用户已撤回的repeatSuppressed推断当作线上证据。
