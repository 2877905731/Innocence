---
schema_version: 1
document_type: checkpoint
sequence: 0108
created_at: '2026-10-07T13:59:39+08:00'
phase: P01
type: DECISION
status: complete
title: 用户验收鸿蒙平板版本并明确授权GitHub发布
objective: 记录用户验收与发布渠道，不把用户口头验收改写成未执行的自动化设备检查
completed:
- fact: 用户明确表示已验收当前平板版本，可以进行发布
  evidence: 用户原文：我验收了，可以进行发布了
- fact: 用户明确选择沿用GitHub发布流程
  evidence: 用户回复：GitHub 发布（沿用现有流程）
- fact: GitHub公开分发准备ARM64 Release本机包，单设备调试签名/Profile继续只在本机F盘保存
  evidence: 已向用户说明现有签名绑定平板，公开包保持未签名并附自行签名说明；无华为应用市场上架操作
changed_files:
- path: progress/0108__20261007__P01__DECISION__harmonyos-user-acceptance-and-github-release.md
  change: 新增不可变验收和渠道授权决策
- path: progress/0000__AI-RESUME.md
  change: 当前目标切换GitHub发布，保留独立未验门禁
- path: progress/INDEX.md
  change: 升序追加0108
- path: docs/planning/Innocence-鸿蒙平板版本实施规划.md
  change: 归档用户原话与本次发布范围
evidence:
- command: none（用户消息与渠道选择）
  result: 用户验收/授权GitHub发布；具体使用路径与性能数据未由用户逐项提供，不代填为自动通过
compatibility_and_security:
  contract_impact: 保持当前本机离线功能与PC全屏；不开放账号/同步/BYOK或新设备槽位
  tenant_impact: 不写用户业务数据；本轮不终止正在使用的平板进程，不把发布授权推导为丢弃草稿
  sensitive_data: 设备绑定Debug HAP/Profile及私钥只在F盘忽略目录，GitHub公开包不包含个人设备标识/材料
risks_or_blockers:
- 发布前执行Release原生构建及包核对；Release模式与签名类型分别验证，不能将调试证书描述为通用正式分发签名。
- 用户验收记录与0107自动启动证据并存，独立业务恢复/负向/性能/联网及H5/G01不据此代填自动完成。
next_actions:
- id: NEXT-HARMONY-GITHUB
  action: 构建独立ARM64 Release暂存工程、核对无INTERNET/版本/API/AOT/CRC/无设备材料，准备发布说明、摘要及源标签，推送并公开GitHub Release；核对公开下载。
  inputs:
  - client/flutter_app/tool/harmonyos.ps1
  - docs/planning/Innocence-鸿蒙平板版本实施规划.md
---
