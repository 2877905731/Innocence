---
schema_version: 1
document_type: checkpoint
sequence: "0090"
created_at: "2026-10-04T15:31:58+08:00"
phase: P01
type: DECISION
status: complete
title: "用户采用智能助手B，模块范围及首批开发契约落档"
objective: "记录用户明确‘采用b方案’，将B作为第16模块的正式产品方向，并完成范围、内部模型与首批开发契约及关联文档同步；不将方向确认当成实现完成。"
completed:
  - fact: "DEC-0050：智能助手采用B，按日计划闭环→月历与存档/重排→独立年度拆解推进；C持续规则未采用。"
    evidence: "用户本轮原话‘采用b方案’；B专档第1–3节；项目计划书8.16及模块看板。"
  - fact: "新增B专档11节，定义内部模型、UAI-01–06、字段/认证/空值/版本/错误/超时/幂等/事务和带冲突检查的撤销。"
    evidence: "docs/planning/Innocence-AI智能助手B方案实施与契约.md；接口索引均为contract_defined_not_implemented。"
  - fact: "窄代码核对发现日计划请求/响应无dayRevision，旧saveTodayPlan替换条目，纳入共享修订与稳定实体新增的必须改造项。"
    evidence: "TodayPlanResponse、SaveTodayPlanRequest、Flutter TodayPlan；StudyPlanService.java:225及237/255删除条目逻辑；B专档第7节。"
  - fact: "产品/MVP/项目画像、治理契约、数据流、接口/数据模型及Android/Windows/UI范围同步为B，原15模块封板与现行离线发行记录保留。"
    evidence: "SCOPE-009、RULE-015、assistant_track、planned_extensions、UAI-01–06、UI2.37及双端指针。"
  - fact: "18份产品/设计/契约文档严格UTF8字节回转、跨文档指针、唯一新范围/规则、6接口未实现状态、11节与五类负向标记校验PASS；git diff --check通过。"
    evidence: "Python标准库脚本输出result=PASS/files=18/assistant_endpoints=6/spec_sections=11/runtime_implementation=false。"
changed_files:
  - path: "AGENTS.md"
    change: "增加B专档读取入口，区分原15模块与第16模块范围确认。"
  - path: "docs/planning/Innocence-AI智能助手B方案实施与契约.md"
    change: "新增正式B范围、内部模型与首批开发契约。"
  - path: "docs/planning/Innocence-AI智能助手与自动化系统方案评审.md"
    change: "状态改为B已选；A/C保留比较，当前规格指向B专档。"
  - path: "docs/01-product-scope.md"
    change: "登记SCOPE-009及C范围边界。"
  - path: "docs/02-contract-and-compatibility-rules.md"
    change: "助手生成/执行/撤销幂等与身份/授权指针。"
  - path: "docs/03-execution-plan.md"
    change: "增加B1/B2/B3实施轨道及真实性边界。"
  - path: "docs/06-contract-inventory.md"
    change: "登记UAI-01–06，均为契约定义、尚未实现。"
  - path: "docs/07-dataflow-and-module-map.md"
    change: "登记待实施B链路与旧日计划兼容改造项。"
  - path: "docs/08-project-profile.md"
    change: "增加RULE-015及B专档指针。"
  - path: "docs/planning/Innocence-项目计划书.md"
    change: "新增8.16智能助手模块与状态行。"
  - path: "docs/planning/Innocence-MVP第一版功能范围.md"
    change: "增加7.15后续增量范围，不改写v1.2.2功能事实。"
  - path: "docs/planning/Innocence-接口清单草案.md"
    change: "增加4.15助手接口契约指针与兼容要求。"
  - path: "docs/planning/Innocence-数据库表结构草案.md"
    change: "增加待实施助手模型/修订与保留规则指针。"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "2.37存档用户原话及B页面/交互。"
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "助手入口/批次，保持离线发行，联网实施另验。"
  - path: "docs/planning/Innocence-Windows信息架构与组件体系.md"
    change: "新增助手工具入口及三档状态连续性。"
  - path: "docs/planning/Innocence-Windows自适应桌面体验.md"
    change: "增加B关联指针，Orb行为保持。"
  - path: "docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md"
    change: "增加B与ownerScope/业务outbox边界指针。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新已选B状态、DEC-0050、待实施项和下一步。"
  - path: "progress/INDEX.md"
    change: "升序追加0090。"
  - path: "progress/0090__20261004__P01__DECISION__ai-assistant-b-adopted.md"
    change: "记录选择与文档完成事实。"
evidence:
  - command: "Get-Content SaveTodayPlanRequest.java / TodayPlanResponse.java；rg -n saveTodayPlan/deleteDailyPlanItemsByPlanId StudyPlanService.java"
    result: "核对当前日计划无修订号；保存中存在删除旧条目的路径。没有宣称已有并发与稳定ID保证。"
  - command: "Python标准库文档校验脚本，通过管道调用bundled python.exe -"
    result: "PASS：18文件UTF8字节回转/指针，新SCOPE-009/RULE-015各1，6个UAI未实现接口、11节及五类负向标记。只做文档校验，非运行态接口证据。"
  - command: "git -c core.safecrlf=false diff --check"
    result: "无输出，退出0；新增未跟踪文档另以脚本检查行尾空白。"
  - command: "Get-FileHash -LiteralPath docs/planning/Innocence-AI智能助手B方案实施与契约.md -Algorithm SHA256"
    result: "BC1FCC48344DE076AD267022E35856168F6E0F1DCC6C2B0B7DEFDC25D326D6D4。"
  - command: "Python import yaml；require.resolve yaml/js-yaml"
    result: "当前bundled运行时均无YAML解析包；未安装依赖，改为标准库严格编码/指针/字段与状态检查，不声明已完成全量YAML解析。"
  - command: "none（业务实现、SQL迁移、模型连接、构建与真实HTTP）"
    result: "未执行；用户本轮选择方案，本检查点只记录方向与开发输入，不表示模块实现完成。"
compatibility_and_security:
  contract_impact: "B1六项新接口已定义并登记，但尚未提供服务；旧业务接口保持运行基线，必要兼容改造已写入开发前置项。"
  tenant_impact: "仅文档；要求当前用户/ownerScope隔离、程序核验授权与版本、未登录资料不上云。"
  sensitive_data: "没有读取或保存真实模型密钥、用户数据、个人身份或凭据；原始指令仅为用户方案选择。"
risks_or_blockers:
  - "真实供应商与凭据尚未配置；可先建设模型适配/规则/业务执行，不重复询问方向，不标记为持续阻塞。"
  - "日计划共享修订必须覆盖全部旧写路径；仅助手入口版本校验不足以保护双端新修改。"
  - "模块代码、真实生成/HTTP/设备与同步尚未验收；原P01/G01、Android A0–A5等门禁保持。"
next_actions:
  - id: NEXT-AI-B1
    action: "按B专档第10节开始B1内部模型/规则/适配器与日计划修订建设，再执行/撤销及双端页面；不再次要求用户选择A/B/C，不扩入C。"
    inputs: ["docs/planning/Innocence-AI智能助手B方案实施与契约.md", "docs/06-contract-inventory.md"]
---

# 决策说明

DEC-0050确认B产品方向。B专档中的字段、错误码、限制与模型为依项目基线制定的开发契约，不能解读为用户逐项另行指定。供应商、收费与发布版本尚未决定。0089保持历史原文，当前评审文档仅更新选择状态。
