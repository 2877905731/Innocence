---
schema_version: 1
document_type: checkpoint
sequence: "0068"
created_at: "2026-09-27T11:43:45+08:00"
phase: P01
type: DECISION
status: complete
title: "Android 首发保留未登录本机离线入口"
objective: "固化用户对 Android 首发离线入口范围的明确选择，并保持原有身份与导入边界。"
completed:
  - fact: "Android 正式首发保留未登录时的‘离线使用’入口；离线首发范围不再是 A0 待决项。"
    evidence: "针对‘未登录时的“离线使用”入口，是否保留在 Android 首发版？’，用户回复‘是的’。"
  - fact: "本机资料仍限定于 local:profileUuid，离线状态不得显示其他账号社交缓存；登录后的导入预览、目标账号确认与冲突处理不因本次决定省略。"
    evidence: "docs/02-contract-and-compatibility-rules.md 的认证与租户规则；docs/planning/Innocence-Android版本实施规划.md §5、§14。"
changed_files:
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "将离线入口纳入 Android 首发范围，更新 A0 线框、数据边界和后续执行记录。"
  - path: "docs/03-execution-plan.md"
    change: "Android 轨道更新为导航与离线范围均已确认，保留设备与验收差距。"
  - path: "docs/08-project-profile.md"
    change: "Android 规划引用状态同步本次决策。"
  - path: "progress/0068__20260927__P01__DECISION__android-offline-first-release.md"
    change: "记录用户决策及适用边界。"
evidence:
  - command: "Get-Content progress/0000__AI-RESUME.md；Get-Content progress/INDEX.md；rg -n '离线|A0' docs/planning/Innocence-Android版本实施规划.md docs/03-execution-plan.md"
    result: "原待决项存在于 RESUME、执行计划和 Android 规划；0068 为下一全局序号。"
  - command: "git diff --check -- docs/03-execution-plan.md docs/08-project-profile.md"
    result: "退出码 0，无空白错误；仅有行尾转换提示。"
compatibility_and_security:
  contract_impact: "none；不改变服务端接口或导入字段。"
  tenant_impact: "未登录本机资料和登录账号缓存仍按 ownerScope 隔离，确认前不上传正文。"
  sensitive_data: "none。"
risks_or_blockers:
  - "用户决策并不等于 Android 离线场景已通过全部设备、同步与发行验收。"
next_actions:
  - id: NEXT-ANDROID-OFFLINE-RESTORE
    action: "确保 Android 显式进入离线模式后可在进程冷启动时恢复同一份本机资料，并验证退出与缺失资料负向路径。"
    inputs: ["client/flutter_app/lib/app/session_controller.dart", "client/flutter_app/lib/core/local/offline_store.dart"]
---
