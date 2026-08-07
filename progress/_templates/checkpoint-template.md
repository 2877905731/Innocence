---
schema_version: 1
document_type: checkpoint
sequence: "NNNN"
created_at: "yyyy-MM-ddTHH:mm:ss+08:00"
phase: PNN
type: DONE
status: complete
title: "<一句话标题>"
objective: "<本检查点处理的窄范围目标或用户决策>"
completed:
  - fact: "<实际完成的事实>"
    evidence: "<来源行号、样本或其他证据>"
changed_files:
  - path: "<准确路径>"
    change: "<变更摘要>"
evidence:
  - command: "<实际执行的命令；未执行则写 none>"
    result: "<命令结果；未执行则写 未执行>"
compatibility_and_security:
  contract_impact: "<none 或说明>"
  tenant_impact: "<none 或说明>"
  sensitive_data: "<none 或说明>"
risks_or_blockers:
  - "none"
next_actions:
  - id: NEXT-001
    action: "<下一次可以直接执行的动作>"
    inputs: []
---

# 检查点说明

- `type` 取值：DONE（里程碑完成）/ DECISION（用户决策）/ BLOCKED（持续阻塞）/ CORRECTION（历史纠正）
- 检查点不可变；纠正历史时新增 CORRECTION 检查点，不改旧文件
- 证据字段必须填写真实命令与结果；未执行写 `未执行`，禁止用「已测试」代替
