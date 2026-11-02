---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0152"
created_at: "2026-11-03T00:34:54+08:00"
phase: P01
type: DONE
status: complete
title: "三端1.3.3正式公开，七资产匿名完整下载SHA与源码双标签核对通过"
objective: "完成用户推送并发布Release的明确指令，按0151已验证候选公开并核对实际下载；个人签名包不公开。"
source_commit: "0dadcfca2e5a48d0042e2b07bc268a832fe229bb"
completed:
  - fact: "v1.3.3主发行和v1.3.3-harmonyos.1独立鸿蒙发行均已公开，版本1.3.3+15，latest=v1.3.3。"
    evidence: "Release#431690582/431693216；主发行4资产、鸿蒙3资产；两组正文与本地说明全文精确一致。"
  - fact: "源码和两注释标签原子推送origin成功，双标签固定同一0dadcfca2e5a48d0042e2b07bc268a832fe229bb；GitHub只读核对来源一致。"
    evidence: "git push --atomic origin main refs/tags/v1.3.3 refs/tags/v1.3.3-harmonyos.1，main734ec60快进至0dadcfc；使用进程级当前系统代理，未改全局Git配置。"
  - fact: "严格七资产的远端大小/SHA256和全部匿名完整GET下载内容SHA与本机相同，两个校验清单和说明字节一致。"
    evidence: "client/flutter_app/build/qa/v1.3.3/public-download-checks.json；7条anonymous_get_status=200/full_download_hash=true；Release IDs与latest/正文/双标签均匹配。"
  - fact: "原证书Android联网APK81187735字节、Windows安装器24720857/便携30954880、鸿蒙公开未签名ARM64 AOT HAP53516769已交付。"
    evidence: "267客户端/6跳过、离线4/联网2、分析/三端构建/签名权限/字体CRC/125Dart/4ArkTS等门禁沿0151；公开HAP官方工具确认无签名块，不含个人Profile/私钥。"
  - fact: "0150部署的学习入账/追踪后端摘要620fbc32…、健康UP和注册0只读确认；本轮没有重复迁移、重启后端或安装本人平板。"
    evidence: "RELEASE_BACKEND_DEPENDENCIES_HEALTHY；本人已装同版1.3.3保留，个人包与签名材料继续仅F盘。"
changed_files:
  - path: "client/flutter_app/README.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "client/flutter_app/harmonyos/README.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/02-contract-and-compatibility-rules.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/03-execution-plan.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/07-dataflow-and-module-map.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/08-project-profile.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/development/AI对话助手配置与验收.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/development/助手年度任务修复与多对话.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/development/计时阶段与学习入账.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/planning/Innocence-AI智能助手B方案实施与契约.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/planning/Innocence-Android版本实施规划.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "docs/planning/Innocence-鸿蒙平板版本实施规划.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "progress/0000__AI-RESUME.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "progress/0152__20261103__P01__DONE__v133-three-platform-github-published.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
  - path: "progress/INDEX.md"
    change: "记录本次实际公开发行、当前版本/下载指针与剩余验收范围。"
evidence:
  - command: "git -c http.proxy=<当前系统代理> push --atomic origin main refs/tags/v1.3.3 refs/tags/v1.3.3-harmonyos.1"
    result: "main快进、双注释标签成功；远端标签对象及所指源码精确一致，无force/全局配置修改。"
  - command: "python client/flutter_app/build/qa/release133.py publish"
    result: "两草稿严格白名单上传七文件，逐项远端digest/大小通过后公开；主发行431690582、鸿蒙431693216。"
  - command: "python client/flutter_app/build/qa/v1.3.3/verify_downloads.py"
    result: "七匿名完整下载200/流式SHA256与本机一致，说明/校验清单字节、正文、非草稿/非预览、注释标签/来源和latest=v1.3.3通过。"
  - command: "SSH只读生产依赖JAR/健康/注册策略核对"
    result: "JAR620fbc3268ea11eb0229f9789bbf7c94caafb3aaf938e29189cf3f86d0bac0f3，health UP，registration0；无生产写操作。"
  - command: "当前UTF8/YAML/INDEX/版本与下载指针核对；git diff --check"
    result: "结构和字节核对通过，差异无空白错误；本发布记录随后同步main，版本标签不重写。"
compatibility_and_security:
  contract_impact: "按0151候选发行，业务/数据库/身份语义未新增修改；所需后端已在0150上线，软件内在线更新分发模块未包含。"
  tenant_impact: "未操作真实账号或资料，原身份隔离、导入确认和本人平板资料保持；不把公开下载当完整运行验收。"
  sensitive_data: "七资产严格白名单；原Android发行证书用于覆盖，公开HAP无签名/Profile/私钥，个人设备包和QA原始画面/凭据均不公开。"
risks_or_blockers:
  - "Windows安装器未Authenticode签名；鸿蒙公开HAP仍需接收者自己的有效签名/Profile/DevEco/HDC，本人已装私有同版不重复覆盖。"
  - "完整实体Android/OEM、WindowsDPI/输入/长期性能、鸿蒙后台/锁屏/权益、完整同步及真实模型/费用矩阵继续待，原P01/G01不因发行关闭。"
  - "在线账号后台版本发布和软件内更新仍仅有资源评估；本次通过GitHub提供安装文件。"
next_actions:
  - id: NEXT-CURRENT-V133-FEEDBACK
    action: "交付主发行和鸿蒙发行链接；使用当前1.3.3按实际反馈补运行矩阵，保账号资料和原签名，不重复发行/迁移或公开个人材料。"
    inputs: [docs/releases/v1.3.3.md, docs/releases/v1.3.3-harmonyos.1.md]
---
