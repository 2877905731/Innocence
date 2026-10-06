---
schema_version: 1
document_type: checkpoint
sequence: "0092"
created_at: "2026-10-04T21:16:32+08:00"
phase: P01
type: CORRECTION
status: complete
title: "按用户修正实现自填密钥的聊天助手、软件工具与新版启动"
objective: "纠正0090/0091固定三候选与服务端专用密钥的主交互，落实用户要求的Codex Chat式BYOK对话助手；按明确授权编译并启动新版替换开发窗口。窄范围代码/fixture/本机构建与启动里程碑完成，不宣布真实模型、全部软件操作或原项目门禁通过。"
completed:
  - fact: "DEC-0051：用户澄清要自行接API Key、通过对话框规划和操控软件；主入口改多轮聊天，原排程保留为次级工具。允许当前本机资料经BYOK按需发往用户指定模型，覆盖原服务端专用密钥/本机只规则/固定三候选主交互；原权限、半小时、手动签到/进度和C持续调度边界保持。"
    evidence: "当前会话用户原文与docs/planning/Innocence-UI设计规划.md 2.38；0090/0091文件没有编辑。"
  - fact: "已实现自填完整端点/模型/密钥、Chat Completions及Responses、多轮上下文、聊天/操控软件、发送/停止、具体动作确认和操作结果；当前为整段回复。配置与可见历史按当前身份隔离，身份变化/停止取消后续动作；恢复对话不重放旧工具。"
    evidence: "chat_controller.dart/chat_provider.dart/chat_repository.dart/assistant_chat_page.dart；153项Flutter最终全量包含22项新增聊天、loopback HTTP、真实SQLite工具和布局回归。"
  - fact: "完整连接配置在Windows通过用户级DPAPI、Android通过Keystore AES-GCM原生通道加密保存，无明文兜底；不参与业务API/同步/日志/聊天。聊天正文仅按owner分区，没有加密。"
    evidence: "assistant_crypto.h/assistant_vault.h、MainActivity.kt、chat_repository.dart；共享生产DPAPI函数的实际原生4检查PASS；Android只编译，Keystore设备验收未执行。"
  - fact: "14项软件工具接现有Session/SQLite/API：资料读取、日计划稳定新增/结果查询/撤销、存档、备忘录增改删、年度任务/新子任务、专注、导航/主题/语言。严格字段/身份/修订检查，具体写动作先确认；单轮同载荷写调用复用结果。导航真正切到目标页面，年度读取失败拒绝旧缓存与写入。"
    evidence: "assistant_app_tools.dart、app.dart、SessionController及两端Shell；真实SQLite合成数据验证原ID/完成/实际时长/outbox/撤销、备忘录、年度子任务/0进度、专注与年度失败路径。"
  - fact: "UAI-07客户端提案接口已实现：当前Bearer身份，严格字段/日期/网格/修订校验，同请求同载荷复用、异载荷409，仅存提案不写计划；确认后走原validate/execute preview_apply/query/undo。"
    evidence: "AssistantModels.ClientProposalRequest、AssistantService.clientProposal、AssistantController；后端73项全量/17套/failure0/error0，包含4项新增MySQL事务与MockMvc边界回归。"
  - fact: "最终Windows Release32.7秒及Android联网Debug12秒成功。用户授权编译后替换旧窗口，按开发exe绝对路径核对后关闭同路径进程；最终21:12:52启动PID19476，21:16:32窗口Innocence/handle788624/Responding=true，stdout/stderr均0字节、指定致命标记0。"
    evidence: "build/chat-windows-build.log、chat-android-build.log、chat-runtime-launch.json、chat-runtime-review.json；没有开启图形自动操作或在真实资料中写合成任务。"
  - fact: "配置/工具/当前证据边界及DEC-0051已同步进契约、数据流、产品范围、双端/UI规划、AGENTS、RESUME和INDEX。"
    evidence: "docs/development/AI对话助手配置与验收.md；文档检查23文件UTF8精确字节回转及严格YAML通过，git diff --check exit0。"
changed_files:
  - path: client/flutter_app/lib/features/assistant/data/chat_repository.dart
    change: "当前owner配置/历史仓储，连接配置先原生加密再保存"
  - path: client/flutter_app/lib/features/assistant/data/chat_provider.dart
    change: "两协议HTTP适配、工具结果/推理项回传、超时/响应限制及安全错误"
  - path: client/flutter_app/lib/features/assistant/application/chat_tools.dart
    change: "工具定义、准备结果和取消边界"
  - path: client/flutter_app/lib/features/assistant/application/chat_controller.dart
    change: "全局多轮聊天/确认/停止/身份隔离/重复写抑制/可见历史恢复"
  - path: client/flutter_app/lib/features/assistant/application/assistant_app_tools.dart
    change: "14项工具接原业务，具体确认/修订检查/实际结果与读取失败拒绝"
  - path: client/flutter_app/lib/features/assistant/presentation/assistant_chat_page.dart
    change: "聊天主入口、配置对话框、模式/发送停止/具体确认与响应式布局"
  - path: client/flutter_app/lib/app/app.dart
    change: "主入口换聊天，原排程次级入口；接全局导航/主题/语言"
  - path: client/flutter_app/lib/app/session_controller.dart
    change: "持有全局聊天与工具；释放和账号注销清理"
  - path: client/flutter_app/lib/features/home/presentation/pages/home_page.dart
    change: "向双端Shell传入助手导航通知"
  - path: client/flutter_app/lib/features/home/presentation/pages/android_home_shell.dart
    change: "监听助手目标页面，沿用五主入口及工具页"
  - path: client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart
    change: "监听助手导航，保持自适应画布和Focus Orb"
  - path: client/flutter_app/windows/runner/assistant_crypto.h
    change: "用户级DPAPI共享实现"
  - path: client/flutter_app/windows/runner/assistant_vault.h
    change: "加密/解密MethodChannel，严格字节输入与大小边界"
  - path: client/flutter_app/windows/runner/flutter_window.cpp
    change: "注册和释放助手原生密钥通道"
  - path: client/flutter_app/windows/runner/flutter_window.h
    change: "持有助手通道成员"
  - path: client/flutter_app/windows/runner/CMakeLists.txt
    change: "链接crypt32"
  - path: client/flutter_app/android/app/src/main/kotlin/com/innocence/app/innocence_flutter/MainActivity.kt
    change: "Android Keystore AES-GCM及同名MethodChannel"
  - path: client/flutter_app/test/features/assistant/chat_assistant_test.dart
    change: "15项聊天/双协议/原生通道边界/真实SQLite工具回归"
  - path: client/flutter_app/test/features/assistant/chat_page_test.dart
    change: "7项两主题宽度/大字体键盘/密钥配置布局回归及合成PNG"
  - path: client/flutter_app/test/native/assistant_crypto_test.cpp
    change: "共享真实DPAPI实现，4项合成凭据检查"
  - path: server/innocence-server/src/main/java/com/innocence/server/modules/assistant/domain/AssistantModels.java
    change: "严格ClientProposalRequest与整数单日修订"
  - path: server/innocence-server/src/main/java/com/innocence/server/modules/assistant/service/AssistantService.java
    change: "客户端提案owner锁/幂等/修订/校验，不调用模型或直接写计划"
  - path: server/innocence-server/src/main/java/com/innocence/server/modules/assistant/controller/AssistantController.java
    change: "UAI-07受保护端点"
  - path: server/innocence-server/src/test/java/com/innocence/server/modules/assistant/AssistantIntegrationTest.java
    change: "3项新增客户端提案/实际事务/幂等/撤销/跨owner负向"
  - path: server/innocence-server/src/test/java/com/innocence/server/modules/assistant/AssistantBoundaryTest.java
    change: "1项新增未认证/越权字段/缺字段/修订类型HTTP边界"
  - path: docs/development/AI对话助手配置与验收.md
    change: "用户配置步骤、真实支持工具和验收边界"
  - path: docs/development/AI助手本机开发与验收.md
    change: "标注原排程为历史B1及次级入口，指向当前配置说明"
  - path: docs/planning/Innocence-AI智能助手B方案实施与契约.md
    change: "第12节BYOK/工具/UAI-07覆盖冲突旧设计，更新状态"
  - path: docs/01-product-scope.md
    change: "第16模块改为BYOK聊天与当前实现边界"
  - path: docs/02-contract-and-compatibility-rules.md
    change: "BYOK原生加密及当前资料模型发送边界"
  - path: docs/03-execution-plan.md
    change: "聊天轨道与真实供应商/设备/未接工具后续"
  - path: docs/06-contract-inventory.md
    change: "登记UAI-07及fixture/真实HTTP证据边界"
  - path: docs/07-dataflow-and-module-map.md
    change: "客户端直接模型节点/两协议与原业务工具流"
  - path: docs/08-project-profile.md
    change: "RULE-015按DEC-0051修正"
  - path: docs/planning/Innocence-MVP第一版功能范围.md
    change: "当前BYOK/14工具范围与待验事实"
  - path: docs/planning/Innocence-Android版本实施规划.md
    change: "聊天及Keystore开发构建，正式离线包保持"
  - path: docs/planning/Innocence-接口清单草案.md
    change: "七接口当前实现及客户端提案契约索引"
  - path: docs/planning/Innocence-Windows自适应桌面体验.md
    change: "主聊天响应式/次级排程与矩阵证据边界"
  - path: docs/planning/Innocence-Windows信息架构与组件体系.md
    change: "assistant主入口与全局导航实现"
  - path: docs/planning/Innocence-UI设计规划.md
    change: "2.38存档用户原文并修正主交互"
  - path: AGENTS.md
    change: "更新第16模块当前事实"
  - path: progress/0000__AI-RESUME.md
    change: "当前目标/DEC-0051/待办与最终本机启动证据"
  - path: progress/INDEX.md
    change: "升序追加0092，下一序号0093"
  - path: progress/0092__20261004__P01__CORRECTION__byok-chat-assistant.md
    change: "用户方向纠正与代码/fixture/构建启动里程碑"
evidence:
  - command: "D:/soft/flutter/bin/flutter.bat analyze --no-pub（client/flutter_app）"
    result: "exit0，No issues found，6.2秒；build/chat-analyze.log"
  - command: "D:/soft/flutter/bin/flutter.bat test --no-pub（client/flutter_app）"
    result: "最终exit0，153项全部通过（新增22项），23秒；build/chat-full-test.log"
  - command: "D:/homework/apache-maven-3.9.9/bin/mvn.cmd -q test（server/innocence-server，本轮先前执行）；汇总17份surefire TEST XML"
    result: "exit0；73项（新增4项），failure0/error0；target/chat-full-test.log与surefire-reports"
  - command: "D:/homework/apache-maven-3.9.9/bin/mvn.cmd -q -DskipTests package"
    result: "exit0，6.6秒；target/chat-package.log"
  - command: "MSVC vcvars64.bat环境；cl /nologo /EHsc /std:c++17 /Fe:build/assistant_crypto_test.exe /Fo:build/assistant_crypto_test.obj test/native/assistant_crypto_test.cpp /link crypt32.lib；执行该exe"
    result: "exit0，DPAPI密文不同/往返/篡改拒绝/空输入拒绝4检查PASS；合成fixture，不含真实Key"
  - command: "D:/soft/flutter/bin/flutter.bat build windows --release --no-pub"
    result: "最终exit0，32.7秒；runner198656 bytes SHA256 e97f66d4a8f46295510119f1383b64edd69f9df67993510160b4569d5c485120；data/app.so9126800 bytes SHA256 9f9a219a698727dc4bebd83f3ee1a579fa15a374885222d0a50aef92ad5fbf7b"
  - command: "gradlew.bat assembleDebug -Pkotlin.incremental=false -Pkotlin.compiler.execution.strategy=in-process -Pdart-defines=SU5OT0NFTkNFX09GRkxJTkVfT05MWT1mYWxzZQ==（Android）"
    result: "最终BUILD SUCCESSFUL，12秒；Debug APK180698917 bytes SHA256 a9ab99b90bde9cd6bf239cca2af2c2341a819c6adfc895788038c27a9d079d62；aapt核对version1.2.2/code7、min24/target36、INTERNET与debuggable"
  - command: "Start-Process 最终Release/innocence_flutter.exe -WorkingDirectory 同目录 -WindowStyle Normal；WaitForInputIdle；按exe绝对路径Get-Process；共享只读方式汇总启动日志"
    result: "21:12:52启动PID19476，21:16:32窗口Innocence/handle788624/Responding=true；stdout/stderr0字节、指定致命标记0。仅启动子集；原生页面/数据链路不据此判通过"
  - command: "java -cp server/innocence-server/.mvn/repository/org/yaml/snakeyaml/2.2/snakeyaml-2.2.jar server/innocence-server/target/AssistantDocQa.java server/innocence-server/target/assistant-doc-manifest.txt；git diff --check"
    result: "UTF8精确字节回转及严格YAML PASS files=23；git diff --check exit0。本地忽略QA清单首次追加缺少换行，修正清单分隔后通过，未改业务输出"
compatibility_and_security:
  contract_impact: "新增UAI-07；原UAI-01–06/共享单日修订/稳定新增/撤销不变；旧服务端生成仅次级排程使用。DEC-0051改变模型密钥所有者与主交互，所有软件工具仍走原业务权限"
  tenant_impact: "配置/历史/业务按当前owner隔离，工具不接受owner输入；身份变化取消当前请求与待确认动作，业务结果实际核对；线上仍使用当前Bearer服务端身份"
  sensitive_data: "无真实模型Key或外部模型调用；fixture仅合成凭据/资料；原生密文不进Git，聊天及日志禁止Key。用户对话和工具读取资料会发送至其自行配置模型，聊天正文仅owner分区未加密"
risks_or_blockers:
  - "真实服务商/模型/Key尚未提供；真实连接、函数调用、生成质量、费用/限额没有验收"
  - "完整登录HTTP/同步与Android Keystore运行、实体设备/Windows原生聊天页面多DPI四主题仍待验；宿主图片不能替代设备证据"
  - "当前不含流式回复、原日任务编辑/删除/重排、存档批量套用、已有年度子任务编辑；账号安全/管理员/隐私/社交发送/代签到与C持续自动化未开放"
  - "没有启动/部署后端，没有安装Android开发包、更新正式版本号、发布资产、提交或推送；正式v1.2.2+7离线发行与原P01/G01门禁保持"
next_actions:
  - id: NEXT-AI-CHAT-LIVE
    action: "用户在软件模型设置填写所选服务配置并测试；按当前身份验实际模型工具调用与计划保存/结果查询，不在聊天/仓库索取密钥。补真实登录HTTP/同步、Android原生密钥与实体设备、Windows运行矩阵；按当前校验/确认语义扩展剩余计划工具"
    inputs: ["docs/development/AI对话助手配置与验收.md", "docs/planning/Innocence-AI智能助手B方案实施与契约.md", "client/flutter_app/lib/features/assistant/application/assistant_app_tools.dart"]
---

# 用户方向修正及本机里程碑

用户原文：“我的意思是做一个只能助手类似与codex里面的chat模式，可以自己接入api key，做一个对话框让我可以直接通过这个对话框让ai给我做计划，操控整个软件”。本检查点记录DEC-0051及落地范围，原0090/0091作为历史方案与实现证据保留。

用户对窗口替换问题明确答复“编译好后启动新版，替换旧窗口”。最终只处理同一开发exe绝对路径的窗口，没有向真实资料保存合成验收任务。新版当前已启动，用户可从工具区进入智能助手，再在模型设置填写连接。

五类负向路径：authentication_failure（401/403、未认证提案）、tenant_mismatch（身份切换/跨owner）、permission_denied（未开放工具/越权参数）、missing_field（严格字段/类型）、generation_failure（无效/未完成模型响应）分别有fixture证据。SQLite/MySQL实际数据值与事务校验、loopback真实HTTP和Windows真实DPAPI均使用合成输入；未将这些结果标成真实供应商或全量设备验收。

本地二进制与日志位于忽略的build/target目录，未纳入Git。后端jar44642704 bytes，SHA256 65151f26363cf721b8d01c3061fdc5589f243c7ffc8a4d8385157643b6029b8e；该包仅编译，没有部署或启动。
