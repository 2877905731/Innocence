---
schema_version: 1
document_type: progress_protocol
project_name: "Innocence"
files:
  resume: progress/0000__AI-RESUME.md
  index: progress/INDEX.md
  checkpoint_template: progress/_templates/checkpoint-template.md
  archive: progress/archive/
resume:
  mutable: true
  source_of_truth_for: current_state
  target_length: concise_not_hard_limited
index:
  mutable: true
  order: ascending_append
  source_of_truth_for: checkpoint_location
checkpoints:
  immutable: true
  sequence: global_ascending
  create_when:
    - independently_verifiable_milestone
    - user_decision
    - continuing_blocker
    - historical_correction
  ordinary_code_change: git_and_resume_only
  evidence_required:
    - command
    - result
    - changed_files
  forbidden_evidence_substitute: "已测试"
archive:
  trigger: phase_gate_or_compression_review
  preserve_filename: true
  mark_index: archived
---

# 进度协议

本目录承载 Innocence 的「AI 多会话连续工作」进度体系，协议与 ai-project-template v4 一致。

## 使用规则

1. **RESUME（0000__AI-RESUME.md）**：每次接手的第一份文档，三区制（状态 YAML / 增量基线 / 下一步）。阶段推进或用户决策后更新。
2. **INDEX.md**：检查点索引，只追加、不回改；归档时标记 `archived`。
3. **检查点**：不可变。命名 `NNNN__yyyyMMddHHmm__Pxx__TYPE__slug.md`，仅以下时机创建：
   - 可独立验证的里程碑（DONE）
   - 用户决策（DECISION）
   - 持续阻塞（BLOCKED）
   - 历史纠正（CORRECTION）
4. **普通代码变更**：只记 git 和 RESUME，不建检查点。
5. **证据纪律**：检查点必须记录 command / result / changed_files，禁止用「已测试」代替真实结果。
