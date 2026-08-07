---
schema_version: 1
document_type: future_integration_boundary
project_name: "Innocence"
execution_now: forbidden
scenario:
  host_or_upstream: "无外部宿主；以下为产品自身的远期扩展位"
  entrypoint: "各对应模块预留接口位（见 docs/06-contract-inventory.md）"
  expected_behavior: "扩展能力在不破坏第一版契约的前提下逐步启用"
preconditions:
  - existing_features_unaffected
  - explicit_user_authorization
decision_required:
  checkpoint_type: DECISION
  required_before_start: true
pending_actions:
  - id: INT-001
    action: 对象存储切换（头像等文件从本地映射目录切对象存储，接口层已按 URL 返回设计）
  - id: INT-002
    action: 手机推送通道落地（当前仅站内 + 桌面通知，手机推送待接入厂商通道）
  - id: INT-003
    action: 私信/群聊消息类型扩展（当前仅文字，预留图片/语音/文件的类型位）
  - id: INT-004
    action: 同步能力增强（当前「最后修改覆盖」，后续版本化冲突合并）
  - id: INT-005
    action: 多团队/团队扩容（当前 1 团队 5 人，规则已预留扩展项）
  - id: INT-006
    action: 私信举报、用户举报（当前仅团队交流举报）
  - id: INT-007
    action: 多层级管理员权限体系（当前单层）
  - id: INT-008
    action: AI 内容审核（当前仅敏感词拦截）
---

# 未来集成说明

本文件登记第一版明确不做、但架构上已预留的能力。启用任一项前必须：

1. 用户明确授权（DECISION 检查点）
2. 不破坏现有契约（升级走新增字段/新增版本，不回改已确认字段）
3. 通过对应阶段门禁
