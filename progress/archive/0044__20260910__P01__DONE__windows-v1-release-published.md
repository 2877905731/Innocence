---
schema_version: 1
document_type: checkpoint
sequence: "0044"
created_at: "2026-09-10T01:51:46+08:00"
phase: P01
type: DONE
status: complete
title: "Windows 1.0.0 首个正式版本发布"
objective: "把已获用户确认的 Windows 预览版整理为可安装、可卸载、可校验且可重复构建的第一版正式 Release"
completed:
  - fact: "用户确认 0042 修复后的认证页顶部和品牌区域可以真实拖动 Windows 窗口。"
    evidence: "2026-09-10 用户反馈：可以了"
  - fact: "Flutter 应用版本升级为 1.0.0+1，Windows 文件属性统一显示 ProductName=Innocence、ProductVersion=1.0.0+1。"
    evidence: "pubspec.yaml 与 Runner.rc；Get-Item VersionInfo 输出"
  - fact: "新增可重复执行的 Windows 发布脚本，同时生成每用户安装器、便携 ZIP 与 SHA256SUMS.txt。"
    evidence: "windows/package_release.ps1 与 windows/installer.iss；Inno Setup 6.7.3 编译成功"
  - fact: "安装器已在隔离目录完成静默安装、启动响应检查和静默卸载，卸载目录无文件残留。"
    evidence: "INSTALLER_SMOKE=PASS；Responding=True；MainWindowTitle=Innocence；UNINSTALL_REMAINING=0"
  - fact: "GitHub v1.0.0 已作为非草稿、非预发布的正式 Release 发布，标签指向首发构建提交 bf567792405187dd1b402ab4a7f116a8393321b2。"
    evidence: "https://github.com/2877905731/Innocence/releases/tag/v1.0.0；release id 385730394"
  - fact: "安装器、便携包与校验清单三个资产均已完整上传。"
    evidence: "GitHub API 返回 asset_count=3 且所有资产 state=uploaded"
changed_files:
  - path: "client/flutter_app/pubspec.yaml"
    change: "版本升级为 1.0.0+1"
  - path: "client/flutter_app/windows/runner/Runner.rc"
    change: "统一 Windows 产品名称、描述和版权元数据"
  - path: "client/flutter_app/windows/installer.iss"
    change: "新增 Inno Setup 每用户安装、快捷方式和卸载定义"
  - path: "client/flutter_app/windows/package_release.ps1"
    change: "新增验证、构建、ZIP、安装器和 SHA256 一键发布流程"
  - path: "client/flutter_app/README.md"
    change: "记录正式 Windows 打包方式和代码签名要求"
  - path: "CHANGELOG.md"
    change: "新增 1.0.0 首发变更日志与限制说明"
  - path: "docs/03-execution-plan.md"
    change: "覆盖离线能力仍待实现和拖窗未验收的旧状态"
  - path: "progress/0044__20260910__P01__DONE__windows-v1-release-published.md"
    change: "记录正式发布证据"
  - path: "progress/INDEX.md"
    change: "登记检查点 0044"
  - path: "progress/0000__AI-RESUME.md"
    change: "切换为 Windows v1 已发布状态并关闭认证页拖窗待办"
evidence:
  - command: "pwsh -NoProfile -File windows/package_release.ps1"
    result: "flutter analyze 无问题；51 项 Flutter 测试通过；Windows 1.0.0+1 Release 构建成功"
  - command: "ISCC.exe installer.iss"
    result: "Inno Setup 6.7.3 successful compile；setup.exe size=12,430,821 bytes"
  - command: "静默安装到 build/installer-smoke/<guid>，启动后静默卸载"
    result: "INSTALLER_SMOKE=PASS；卸载残留 0"
  - command: "mvn test"
    result: "36 项通过，0 失败，0 错误，BUILD SUCCESS"
  - command: "Get-FileHash 与 SHA256SUMS.txt 逐项比对"
    result: "Setup 与 Portable 均一致"
  - command: "GitHub REST API 创建 releases/tags/v1.0.0 并上传三个资产"
    result: "draft=False；prerelease=False；target=bf567792405187dd1b402ab4a7f116a8393321b2；asset_count=3"
compatibility_and_security:
  contract_impact: "none；本次只修改客户端版本/元数据和发布构建流程"
  tenant_impact: "none"
  sensitive_data: "GitHub 凭据仅在发布进程内使用，未输出或写入仓库；构建资产保持 Git 忽略"
risks_or_blockers:
  - "v1.0.0 安装器没有 Authenticode 证书签名，SmartScreen 可能提示未知发布者；发布页已明确披露。"
  - "用户已确认普通边框缩放和认证页拖窗可用，但完整 100%/125%/150% DPI 八方向矩阵及离线同步真实 HTTP 回放仍未关闭。"
next_actions:
  - id: NEXT-001
    action: "为后续 Windows 版本配置可信 Authenticode 代码签名证书和签名流水线。"
    inputs: ["client/flutter_app/windows/package_release.ps1"]
  - id: NEXT-002
    action: "使用 v1.0.0 完成 100%/125%/150% DPI 下的八方向缩放、最大化和 Focus Orb 完整矩阵。"
    inputs: ["v1.0.0 Windows x64"]
  - id: NEXT-003
    action: "用合成账号和真实登录会话完成离线同步 HTTP 回放、冲突策略、幂等与租户负向验证。"
    inputs: ["docs/06-contract-inventory.md", "server/innocence-server"]
---
