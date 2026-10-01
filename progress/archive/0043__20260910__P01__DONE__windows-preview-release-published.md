---
schema_version: 1
document_type: checkpoint
sequence: "0043"
created_at: "2026-09-10T00:30:00+08:00"
phase: P01
type: DONE
status: complete
title: "Windows 预览版已发布到 GitHub"
objective: "提交并推送离线模式、计划体系、主题标语、窗口交互和离线设置成果，创建可下载的 Windows x64 GitHub 预览版"
completed:
  - fact: "106 个源码、测试和规划/进度文件提交到 main，并成功推送 origin/main。"
    evidence: "commit 99a6d75a383b80134844a9271b2fffaca2080e5d；origin/main 指向同一提交"
  - fact: "GitHub Release v0.0.1-preview.1 已创建为公开预发布，标签精确指向实现提交。"
    evidence: "https://github.com/2877905731/Innocence/releases/tag/v0.0.1-preview.1；draft=false；prerelease=true"
  - fact: "Windows x64 完整运行目录 ZIP 已作为 Release 资产上传。"
    evidence: "Innocence-v0.0.1-preview.1-windows-x64.zip；14,717,177 bytes；state=uploaded"
  - fact: "发布资产的 SHA256 已写入 Release 说明并在本地复核。"
    evidence: "7833EC35D7A6405F0187452323D45B10CFEC0DA5A85149123BAF73A1CDFB8115"
changed_files:
  - path: "progress/0043__20260910__P01__DONE__windows-preview-release-published.md"
    change: "新增 Windows GitHub 预览版发布检查点"
  - path: "progress/INDEX.md"
    change: "登记检查点 0043"
  - path: "progress/0000__AI-RESUME.md"
    change: "把当前状态切换为 Windows 预览版已发布并更新后续验收动作"
evidence:
  - command: "git commit -m 'feat: 完成离线计划与 Windows 发布候选'"
    result: "生成提交 99a6d75a383b80134844a9271b2fffaca2080e5d，106 files changed"
  - command: "git push origin main"
    result: "c218b7c..99a6d75 main -> main"
  - command: "GitHub REST API 创建 releases/tags/v0.0.1-preview.1 并上传 ZIP"
    result: "release id 385677354；资产 state=uploaded；size=14717177"
  - command: "GET https://api.github.com/repos/2877905731/Innocence/releases/tags/v0.0.1-preview.1"
    result: "draft=False；prerelease=True；target=99a6d75a383b80134844a9271b2fffaca2080e5d；asset_count=1"
compatibility_and_security:
  contract_impact: "none；本检查点只记录版本控制和发布状态"
  tenant_impact: "none"
  sensitive_data: "GitHub 凭据只在进程内读取并用于 API 请求，未输出、未写入仓库或 Release"
risks_or_blockers:
  - "发布包仍是 preview；登录页真实拖窗的多 DPI 手动复核与离线同步真实 HTTP 回放尚未关闭。"
next_actions:
  - id: NEXT-001
    action: "下载或使用当前 Release，在登录页顶部安全条和左侧品牌区进行真实鼠标拖动，并完成 100%/125%/150% DPI 八方向矩阵。"
    inputs: ["v0.0.1-preview.1 Windows x64"]
  - id: NEXT-002
    action: "用合成账号和真实登录会话完成离线同步 HTTP 回放、冲突策略、幂等与租户负向验证。"
    inputs: ["docs/06-contract-inventory.md", "server/innocence-server"]
---
