---
schema_version: 1
document_type: checkpoint
sequence: "0093"
created_at: "2026-10-04T22:14:27+08:00"
phase: P01
type: DONE
status: complete
title: "地址与密钥自动获取模型、协议验证及新版启动"
objective: "DEC-0052：按用户要求简化BYOK接入，只提供链接与Key即可获取模型、选择并自动验证协议；完成本机开发构建和替换窗口"
completed:
  - fact: "服务地址解析和强类型模型列表独立适配；同origin GET /models及有限/v1回退，原始id顺序/去重/严格校验，不硬编码或猜测模型"
    evidence: "chat_discovery.dart、chat_provider.dart；真实loopback GET/Bearer/空列表与缺id/HTTP错误回归"
  - fact: "主设置地址+Key/获取/下拉选择/保存并连接，高级手动模型及协议；成功验证后才用既有原生加密仓储保存，旧数据格式无需迁移"
    evidence: "assistant_chat_page.dart、chat_controller.dart、chat_repository.dart；配置/布局/失败保留旧连接用例"
  - fact: "地址/密钥修改使列表失效，换origin不沿用密钥；取消/身份切换丢弃结果并停止后续探测；普通聊天拒绝未开放的工具调用"
    evidence: "chat_discovery_test.dart、chat_page_test.dart；切身份/取消/跨服务/离线/未开放工具负向"
  - fact: "DeepSeek Chat reasoning_content只在当前上下文回传，不保存或显示在历史；缺少推理字段的恢复历史对官方Chat工具请求显式关闭思考"
    evidence: "chat_provider.dart、chat_assistant_test.dart；loopback回传验证，官方DeepSeek设备/服务仍待验"
  - fact: "168项Flutter全量与analyze通过，Windows Release/Android联网Debug构建成功，旧开发窗口已替换为PID12676并有响应"
    evidence: "build/discovery-*.log；2026-10-04T22:13:14启动、22:15:48只读复核JSON"
changed_files:
  - path: "client/flutter_app/lib/features/assistant/data/chat_discovery.dart"
    change: "服务地址/真实模型目录/错误类型外部适配器"
  - path: "client/flutter_app/lib/features/assistant/data/chat_provider.dart"
    change: "模型列表GET、有限协议探测、取消、错误脱敏及DeepSeek推理上下文"
  - path: "client/flutter_app/lib/features/assistant/data/chat_repository.dart"
    change: "共用地址/密钥校验，保留原加密配置格式"
  - path: "client/flutter_app/lib/features/assistant/application/chat_controller.dart"
    change: "owner绑定发现/连接，成功后保存，普通聊天工具拒绝"
  - path: "client/flutter_app/lib/features/assistant/presentation/assistant_chat_page.dart"
    change: "简化设置及实际模型选择，高级手动入口，列表失效与身份/取消交互"
  - path: "client/flutter_app/test/features/assistant/chat_discovery_test.dart"
    change: "12项新增模型发现/协议/身份/取消/错误/权限回归"
  - path: "client/flutter_app/test/features/assistant/chat_assistant_test.dart"
    change: "fixture模型目录与实际reasoning_content回传断言"
  - path: "client/flutter_app/test/features/assistant/chat_page_test.dart"
    change: "更新主配置流程，新增3项双主题布局/选择及换服务保护"
  - path: "docs/planning/Innocence-AI智能助手B方案实施与契约.md"
    change: "先确认第13节外部发现契约与DEC-0052，再记录实际实现状态"
  - path: "docs/development/AI对话助手配置与验收.md"
    change: "新主流程、DeepSeek根地址、边界和0093证据，与0092历史区分"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "2.39存档用户原文和设置流程，覆盖旧手动主流程"
  - path: "docs/03-execution-plan.md"
    change: "接入简化状态和后续真实服务验证"
  - path: "docs/06-contract-inventory.md"
    change: "登记外部模型发现，不新增Innocence后端端点"
  - path: "docs/07-dataflow-and-module-map.md"
    change: "模型发现/选择/验证/原加密仓储数据流"
  - path: "docs/08-project-profile.md"
    change: "DEC-0052接入语义和指针"
  - path: "AGENTS.md"
    change: "实际项目摘要和0093边界"
  - path: "progress/0000__AI-RESUME.md"
    change: "当前状态/0093/下一序号0094和新版运行证据"
  - path: "progress/INDEX.md"
    change: "顺序追加0093"
  - path: "progress/0093__20261004__P01__DONE__model-discovery-and-simple-connection.md"
    change: "本不可变里程碑记录"
evidence:
  - command: "D:/soft/flutter/bin/flutter.bat analyze --no-pub（client/flutter_app）"
    result: "exit 0，No issues found，5.4秒；build/discovery-analyze.log"
  - command: "D:/soft/flutter/bin/flutter.bat test --no-pub（client/flutter_app）"
    result: "exit 0，168项通过，18秒；build/discovery-full-test.log；前153项+15新增"
  - command: "D:/soft/flutter/bin/flutter.bat build windows --release --no-pub"
    result: "exit 0，30.8秒；build/discovery-windows-build.log"
  - command: "./gradlew.bat assembleDebug -Pkotlin.incremental=false -Pkotlin.compiler.execution.strategy=in-process -Pdart-defines=SU5OT0NFTkNFX09GRkxJTkVfT05MWT1mYWxzZQ==（flutter_app/android）"
    result: "BUILD SUCCESSFUL 12秒，207 tasks：22 executed/185 up-to-date；INNOCENCE_OFFLINE_ONLY=false开发包，不安装"
  - command: "Start-Process -FilePath 核对的Release绝对exe -WindowStyle Normal -PassThru；WaitForInputIdle；Get-Process -Id 12676只读复核；FileShare.ReadWrite仅计日志字节及错误标记"
    result: "22:13:14 PID12676，inputIdle=true、Innocence窗口；22:15:48 Responding=true、handle1116304、stdout/stderr均0字节、指定fatalMarkers均0"
  - command: "Get-FileHash SHA256 runner/data/app.so/Debug APK；aapt dump badging Debug APK"
    result: "摘要见正文；package 1.2.2/code7/min24/target36、arm64-v8a/armeabi-v7a/x86_64、INTERNET；仅开发产物"
  - command: "Java21 AssistantDocQa.java读取25份文档manifest，严格UTF8字节回转与SnakeYAML重复键拒绝；git diff --check"
    result: "PASS：25份UTF8精确字节及严格YAML；git diff --check exit 0"
compatibility_and_security:
  contract_impact: "只新增客户端外部模型列表适配，B专档第13节；无新Innocence业务接口，原保存结构/owner/工具/业务修订与幂等不变"
  tenant_impact: "绑定当前owner/epoch，切身份丢弃列表/停止探测，不保存旧结果；GET和验证不带软件业务数据"
  sensitive_data: "不读取或使用真实Key；loopback合成凭据。用户Key只在输入内存/Authorization和既有原生加密仓储，不进代码/日志/同步；服务原始错误正文不显示"
risks_or_blockers:
  - "真实模型列表、密钥权限、基础对话及工具能力/费用须用户在软件中配置后核验；模型列表存在不代表可调用"
  - "真实登录HTTP/同步、Android Keystore与实体设备、Windows实际设置页/多DPI/四主题仍待验，宿主PNG及进程证据不替代"
  - "原日任务编辑/删除/重排、存档批量、已有年度子任务编辑尚未接工具；C持续调度不包含"
next_actions:
  - id: NEXT-AI-CHAT-LIVE
    action: "用户在软件中填写服务地址+Key获取模型并选择连接；验证真实模型列表/生成/软件工具能力/费用，凭据不贴聊天或仓库，再补HTTP/同步及原生设备门禁"
    inputs: ["docs/development/AI对话助手配置与验收.md", "docs/planning/Innocence-AI智能助手B方案实施与契约.md"]
---

# 地址与密钥自动获取模型、协议验证及新版启动

用户原文：“你可以把接入方式做的更简单一点吗，就是给出api key和链接以后可以自动检测有什么模型，类似于zcode的接入方式”。据此记录DEC-0052，覆盖DEC-0051手动完整端点/模型/协议的主设置流程；0092历史保持不可变。

获取目录只查询用户指定origin，不跨域或重定向。响应必须有data数组和非空原始id，保留服务顺序和可选name；无效目录显式拒绝。根地址未声明版本时可有限尝试/v1；空/缺id不回退、认证/权限/余额/频率/网络错误不回退。选模型后最多两个基础路径×两个协议，仅兼容性错误允许继续验证；失败不覆盖旧有效配置。列表不作模型工具权限证明，不猜测过期名称。

主界面采用“服务地址→API Key→获取可用模型→选择模型→保存并连接”，高级设置保留手动方式。单模型自动选、多模型用户选；列表刷新，改地址/Key失效，换origin不复用旧Key。地址支持旧完整标准路径且保留提示协议，旧配置不迁移；验证请求只有简短文本，没有工具和业务资料。身份/取消验证分别覆盖控制器迟到结果和供应商后续回退。

五类负向证据：authentication_failure（GET401/403）、tenant_mismatch（延迟模型发现期间换owner）、permission_denied（离线发行联网拒绝、聊天模式拒绝意外工具）、missing_field（目录缺id）、generation_failure（空/无效响应、连接失败保留旧配置）。真实loopback检验HTTP方法/路径/鉴权及协议结果；Flutter宿主检查玻璃320/白色1280、字体1.5与键盘280下选择模型并连接，PNG已目视核对，没有布局异常。所有模型请求使用合成Key，未读取用户保存的真实凭据。

Windows runner SHA256：`e97f66d4a8f46295510119f1383b64edd69f9df67993510160b4569d5c485120`；实际Dart产物`data/app.so`：`5c21d85e5dca2dd729f27ab71e6c5d00c370c4a822f6561baf295dc051a845d2`；Android联网Debug APK：`c6f0baa2d18381ed1ffdde516b3dc3d2d0a1211fa72ce7ee7dc9ff1303c0193f`。按此前“编译好后启动新版，替换旧窗口”授权，只关闭核对同绝对exe路径的旧开发进程；PID12676已经启动且复核有响应。没有安装Android、启动后端、更新版本/正式资产、发布或提交/推送。

本轮后端及原生加密没有变更，0092的73项后端和4项Windows DPAPI证据保留，不当作本轮重新执行。Windows/Android编译及宿主回归不证明真实供应商、Android Keystore设备或Windows原生聊天设置页已验收；P01/G01和正式v1.2.2+7无INTERNET发行保持。
