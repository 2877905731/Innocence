---
schema_version: 1
document_type: checkpoint
sequence: "0050"
created_at: "2026-09-17T01:30:41+08:00"
phase: P01
type: DONE
status: complete
title: "中英文 README 与项目徽章同步"
objective: "新增英文版 README，并为中英文版本加入一致且符合真实项目状态的 Shields.io 徽章"
completed:
  - fact: "新增 README_EN.md，完整覆盖项目简介、状态、目录、技术栈、本地开发、文档、许可证和项目地址。"
    evidence: "README_EN.md 已创建，并与中文 README 互相提供语言切换链接。"
  - fact: "中文和英文 README 均展示正式 Logo 与六枚一致徽章。"
    evidence: "两个文件各包含 6 个 img.shields.io 地址，并均包含 README.md、README_EN.md 和 Logo 相对路径。"
  - fact: "徽章内容按仓库实际许可证和技术栈校正。"
    evidence: "根 LICENSE 为 GNU AGPL v3；pubspec 要求 Dart >=3.4；pom.xml 使用 Java 21 和 Spring Boot 3.3.2；因此未采用用户示例中的 MIT 与 Python。"
changed_files:
  - path: "README.md"
    change: "加入双语切换和 AGPL、Flutter、Dart、Java、Spring Boot、平台徽章。"
  - path: "README_EN.md"
    change: "新增完整英文 README，包含与中文版一致的 Logo、语言切换和徽章。"
  - path: "progress/0000__AI-RESUME.md"
    change: "记录双语 README 与徽章决策。"
  - path: "progress/INDEX.md"
    change: "追加 0050 完成检查点。"
evidence:
  - command: "PowerShell 统计 README.md 与 README_EN.md 中的徽章、语言链接、Logo 和 AGPL 标记"
    result: "两个文件 BadgeCount 均为 6；中英文链接、Logo 路径和 AGPL 标记均存在。"
  - command: "git diff --check"
    result: "通过，仅有 Git 行尾转换提示，无空白错误。"
  - command: "git push origin main"
    result: "中英文 README 与徽章更新已推送到 GitHub origin/main。"
compatibility_and_security:
  contract_impact: "none；仅修改文档。"
  tenant_impact: "none"
  sensitive_data: "none"
risks_or_blockers:
  - "none"
next_actions:
  - id: NEXT-001
    action: "后续功能或版本状态变化时同步维护中英文 README，避免内容漂移。"
    inputs: ["README.md", "README_EN.md"]
---

# 检查点说明

- 用户给出的 MIT/Python 徽章仅作为样式示例；本仓库实际使用 AGPL-3.0、Flutter/Dart 与 Java/Spring Boot，因此采用对应徽章。
