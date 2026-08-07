---
schema_version: 1
document_type: git_version_control_policy
project_name: "Innocence"
commit_policy:
  language: zh-CN
  one_logical_change_per_commit: true
  allowed_english_tokens:
    - id
    - path
    - protocol_field
    - commit_prefix（docs:/feat:/fix:/refactor: 等惯例前缀）
  forbidden_content:
    - build_artifact
    - runtime_log
    - real_configuration
    - secret
    - sensitive_fixture
remote_policy:
  add_remote_without_user_authorization: forbidden
  push_without_user_authorization: forbidden
  create_remote_pr_without_user_authorization: forbidden
branch_policy:
  naming: main 为主干直接开发
  merge_strategy: 当前个人开发阶段直接提交 main；引入协作后改 feature 分支 + PR
progress_separation:
  checkpoint: event_record
  code_commit: code_history
  archive_operation: independent_commit
---

# Git 版本控制策略

## 提交规范（已确认）

- commit 消息使用**中文**（用户明确要求，2026-08-07）
- 一个提交只包含一个逻辑变更
- 禁止提交：构建产物、运行日志、真实配置含密钥、凭据、敏感样例

## 远端操作

- 任何 push / 加 remote / PR 操作必须经用户授权

## 分支策略

- 当前：个人开发阶段，直接提交 `main`
- 引入协作后：`feature/<模块>` 分支 + PR 评审
