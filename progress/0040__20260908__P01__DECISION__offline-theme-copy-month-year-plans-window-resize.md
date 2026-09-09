---
schema_version: 1
document_type: checkpoint
sequence: "0040"
created_at: "2026-09-08T21:35:39+08:00"
phase: P01
type: DECISION
status: complete
title: "离线模式、主题每日标语、年月计划与八方向缩放规划"
objective: "在不修改业务代码的前提下，审查现状、固化四项新需求的详细实施方案，并覆盖相悖的现行计划。"
completed:
  - fact: "固化无需登录的 local profile、已登录断网缓存、ownerScope 隔离、本地业务库、sync_outbox、登录后导入预览和按实体冲突规则。"
    evidence: "docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md 第 4 节；docs/08-project-profile.md RULE-006。"
  - fact: "首页固定 Hero 改为四主题各 7 条、按主题+本地日期+语言稳定轮换，并明确四套艺术字与可访问性规则。"
    evidence: "详细规划第 5 节；docs/planning/Innocence-UI设计规划.md 2.28。"
  - fact: "计划层级改为短计划按日、长计划按月、超长计划按年；日模板支持月历批量套用，旧周概览和 weekly-templates 仅作迁移兼容。"
    evidence: "详细规划第 6 节；docs/06-contract-inventory.md U16-U23 与 DEC-002。"
  - fact: "代码审查确认现有无框窗口只依赖顶层 WM_NCHITTEST 时存在 Flutter 子 HWND 覆盖边缘、消息分派顺序、无 Flutter 备用触发和缺少真实拖动验收的问题；规划改为 Flutter 八方向透明命中层触发原生 sizing loop。"
    evidence: "详细规划第 3.4、7 节；docs/planning/Innocence-Windows自适应桌面体验.md 第 7、11 节。"
  - fact: "本检查点只改 Markdown 规划、契约与进度文档，没有实施 Flutter、C++、Java 或 SQL 代码。"
    evidence: "用户明确要求先写计划且不修改代码；本轮 apply_patch 目标均位于 docs/ 与 progress/。"
changed_files:
  - path: "docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md"
    change: "新增四项需求的权威详细实施规划、审查结论、阶段顺序和完成定义。"
  - path: "docs/08-project-profile.md"
    change: "更新离线数据边界、日/月/年计划、主题 Hero 与真实缩放项目规则。"
  - path: "docs/01-product-scope.md"
    change: "覆盖仅已登录断网补传和三个主题的旧范围表述。"
  - path: "docs/02-contract-and-compatibility-rules.md"
    change: "增加离线身份、ownerScope、幂等写入、敏感日志和日/月/年计划兼容约束。"
  - path: "docs/03-execution-plan.md"
    change: "将 P01/P02/P05 动作和门禁同步为离线、每日 Hero、月年计划与真实缩放要求。"
  - path: "docs/06-contract-inventory.md"
    change: "登记导入预览/提交、日模板、月年摘要和年度区间的待实现契约。"
  - path: "docs/07-dataflow-and-module-map.md"
    change: "加入 Windows 本地业务库、ownerScope 与离线导入数据流。"
  - path: "docs/planning/Innocence-MVP第一版功能范围.md"
    change: "把无需登录离线、本地持久化和日/月/年计划纳入 MVP。"
  - path: "docs/planning/Innocence-项目计划书.md"
    change: "覆盖旧离线、全局最后修改覆盖、长计划按周和超长计划按天定义。"
  - path: "docs/planning/Innocence-接口清单草案.md"
    change: "增加离线导入、月年计划和年度区间接口方向，并标记旧周路由为兼容。"
  - path: "docs/planning/Innocence-数据库表结构草案.md"
    change: "区分客户端本地库与服务端补传记录，新增年度计划区间模型。"
  - path: "docs/planning/Innocence-Windows信息架构与组件体系.md"
    change: "加入离线入口/状态、月历/年历页面、状态归属与四主题季节图案。"
  - path: "docs/planning/Innocence-Windows自适应桌面体验.md"
    change: "用双层八方向缩放链路和 Release 实机矩阵覆盖旧命中区假设。"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "存档用户原话并新增 2.28 当前执行约束。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新当前状态、用户决策、未完成项和后续动作。"
  - path: "progress/INDEX.md"
    change: "追加 0040 决策检查点索引。"
evidence:
  - command: "rg -n \"enum SessionStatus|SessionStatus\\.|SharedPreferences|SocketException|setChildContent|SetChildContent|WM_NCHITTEST|WM_SETCURSOR|MessageHandler\\(|weekly-templates|plans/week\" client/flutter_app/lib client/flutter_app/windows/runner server/innocence-server/src/main/java"
    result: "退出码 0；确认 SessionStatus 只有初始化/未认证/已认证路径、业务持久化仍以 SharedPreferences/API 为主、计划仍调用 week/weekly-templates、Windows 当前存在顶层命中与子窗口铺满链路。"
  - command: "rg -n \"长计划按周|长计划以一周|长计划以周|超长计划按天|超长计划以.?天|冲突处理规则采用.?最后修改覆盖|采用.?最后修改覆盖\" 当前权威治理与规划文档"
    result: "退出码 1；除明确标记为历史/被覆盖的存档与新规划覆盖说明外，当前权威表述未再命中旧规则。"
  - command: "git diff --check"
    result: "退出码 0；仅出现工作区既有 LF/CRLF 转换提示，无空白错误。"
compatibility_and_security:
  contract_impact: "新增 U14-U23 待实现契约；旧 /week 与 /weekly-templates 保留迁移兼容，不再定义产品语义。"
  tenant_impact: "未登录 local profile、账户缓存和服务端租户按 ownerScope 隔离；服务端身份继续只从 Bearer token 解析。"
  sensitive_data: "导入预览只提交清单摘要；outbox/日志不得保存令牌、邮箱、验证码、完整请求或用户正文。"
risks_or_blockers:
  - "代码尚未实施；本检查点不代表离线、月历、年历、每日标语或边框缩放已可用。"
  - "本地数据库包、最终 DTO 与数据库迁移需在编码阶段按当前工具链和真实接口回放锁定。"
next_actions:
  - id: NEXT-001
    action: "先固化 offline ownerScope、同步导入、日模板、月摘要、年摘要和年度区间 DTO/迁移，再实现客户端仓储。"
    inputs: ["详细实施规划", "接口清单", "数据库草案"]
  - id: NEXT-002
    action: "独立实现 DesktopResizeFrame → startWindowResize → Windows sizing loop，并先完成八方向 Release 实测。"
    inputs: ["Windows 自适应桌面体验", "现有 runner 代码"]
---

# 决策说明

本检查点覆盖 DEC-0025 中“长计划按周、超长计划逐周复用日期持久化”和此前“顶层 WM_NCHITTEST 命中存在即可视为缩放完成”的现行执行含义。历史检查点不修改，仅保留审计价值。
