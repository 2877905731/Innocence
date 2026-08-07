---
schema_version: 1
document_type: agent_policy
project_name: "Innocence"
language: "zh-CN"
authority: project_root
read_order:
  - level: L0
    required: true
    path: progress/0000__AI-RESUME.md
    purpose: current_state_and_next_action
  - level: L1
    required: true
    path: progress/INDEX.md
    purpose: locate_relevant_history
  - level: L2
    required: conditional
    paths:
      - docs/03-execution-plan.md
      - docs/07-dataflow-and-module-map.md
      - docs/06-contract-inventory.md
      - docs/08-project-profile.md
      - docs/02-contract-and-compatibility-rules.md
    purpose: task_specific_context
---

# AGENT_POLICY

## execution_order

1. 读取 L0（RESUME），核对 `state`、`current_phase`、`current_gate`、`next_actions`。
2. 读取 L1（INDEX），只选择与当前任务相关的历史检查点。
3. 仅当 `read_when` 条件匹配时才读取 L2 文档。
4. 已知 commit ID 或窄代码范围时，不重扫整个外部仓库。

## project_facts

```yaml
project_summary: "Innocence 是面向学习、自律、陪伴和团队互助的双端产品（Flutter 手机端 + 桌面端），15 个产品模块已全部封板，第一版按 MVP 范围开发。前端 UI 于 2026-08-07 决定全面推翻重写，三个主题并存可切换，主题提示词由用户提供。"
data_owner: "Innocence 自有数据；用户数据归用户，由 Innocence 服务托管"
current_milestone: "P00 治理基线落地 → P00.5 UI 设计体系（待用户提供三个主题提示词）"
```

## invariants

以下为本项目实际启用的约束；完整项目化说明见 `docs/08-project-profile.md`。

| id | default | rule |
|---|---|---|
| TRUTHFUL-SCOPE | enabled | 占位、mock-only、未验证输出不得标记为完成 |
| TENANT-ISOLATION | enabled | 业务数据必须绑定当前登录用户上下文，禁止越权读写 |
| CONTRACT-BEFORE-CLIENT | conditional | 接口契约与字段语义固化后再实现前端调用 |
| NO-SECRET-COPY | enabled | 仓库、样本、日志不保存真实凭据（邮件密码等走环境变量） |
| NO-SILENT-NORMALIZATION | conditional | 业务语义差异必须进入决策记录，不得静默改写 |
| UI-REWRITE | enabled | 前端页面按新设计推翻重建，不沿用旧布局；功能逻辑与数据层保留 |
| THEME-PROMPTS-ARCHIVED | enabled | 用户提供的主题提示词必须存档（docs/planning/Innocence-UI设计规划.md），后续生成以存档为准 |

## context_policy

```yaml
large_file_reading: targeted_reads_first
history_reading: index_then_relevant_checkpoint
context_compression: reread_resume_and_index_before_continuing
resume_updated_at: update_on_resume
archive: move_without_delete
absolute_line_limits: false
```

## evidence_policy

```yaml
required_for_completion:
  - command
  - result
  - changed_files
forbidden_claim: "已测试"
required_negative_paths:
  - authentication_failure
  - tenant_mismatch
  - permission_denied
  - missing_field
  - generation_failure
sensitive_logging:
  - full_request
  - personal_identity
  - password_or_code
  - email_address
```

## implementation_policy

```yaml
feature_flow:
  - contract_or_scope_confirmed
  - internal_model
  - implementation
  - verification
  - checkpoint_if_milestone
external_data_boundary: adapter_or_mapper_required
text_output_verification: exact_bytes
structured_output_verification: structure_and_business_values
```

## progress_policy

```yaml
resume_path: progress/0000__AI-RESUME.md
index_path: progress/INDEX.md
checkpoint_path: progress/<sequence>__<timestamp>__<phase>__<type>__<slug>.md
checkpoint_order: global_ascending
index_order: ascending_append
checkpoint_when:
  - independently_verifiable_milestone
  - user_decision
  - continuing_blocker
  - historical_correction
ordinary_code_change: record_in_git_and_resume_only
immutable_checkpoint: true
correction_method: add_CORRECTION_do_not_edit_old_checkpoint
checkpoint_schema: progress/_templates/checkpoint-template.md
```

## archive_policy

```yaml
trigger: phase_gate_or_compression_review
docs_archive: docs/archive/<file>-<date>.md
progress_archive: progress/archive/<original_filename>
preserve: searchable_history_and_index_reference
archive_event: create_DONE_checkpoint
```

## version_control_policy

```yaml
commit_language: zh-CN
remote_actions_without_authorization: forbidden
secrets_logs_build_artifacts_in_git: forbidden
```
