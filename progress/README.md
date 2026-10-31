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

1. **RESUME（0000__AI-RESUME.md）**：每次接手的第一份文档，只保留当前状态、能力边界、未完门禁和下一步。阶段推进或用户决策后更新。
2. **INDEX.md**：检查点索引，保留全量条目并升序追加；归档仅改位置和 `archived`，标题/序号与历史事实不改。
3. **检查点**：不可变。命名 `NNNN__yyyyMMdd[HHmm]__Pxx__TYPE__slug.md`，仅以下时机创建：
   - 可独立验证的里程碑（DONE）
   - 用户决策（DECISION）
   - 持续阻塞（BLOCKED）
   - 历史纠正（CORRECTION）
4. **普通代码变更**：只记 git 和 RESUME，不建检查点。
5. **证据纪律**：检查点必须记录 command / result / changed_files，禁止用「已测试」代替真实结果。

## 当前压缩规则

RESUME不继续累积旧PID、构建日志和已结束的发行任务；每条未完事项保留门禁及专档指针，已完成/被覆盖的动作移至历史。INDEX按序号或关键词定位，不要求全量读取。归档前保留RESUME/INDEX完整快照，逐文件校验正文不变，更新活动引用；旧检查点的历史路径按INDEX解析，不能修改不可变正文。2026-11-01批次归档0058–0131，当前根目录保留0132起的近期检查点。详见[归档清单](../docs/archive/documentation-compression-20261101.json)。
