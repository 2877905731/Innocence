---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0155"
created_at: "2026-11-03T01:38:02+08:00"
phase: P01
type: DONE
status: complete
title: "三端1.3.4已公开，七资产匿名完整下载和双标签核对"
objective: "按用户授权完成后台发布、在线更新和手动绑定番茄并重新发行；保留未覆盖的实体门禁。"
completed:
  - fact: "用户授权的源码与双注释标签推送完成，v1.3.4及v1.3.4-harmonyos.1公开；latest=v1.3.4。"
    evidence: "双标签固定fcc4317d940066193cbd6c65ac312b29bc9bd6a6；主Release#431760442，鸿蒙#431762427。"
  - fact: "七资产远端大小/摘要/精确正文和匿名完整GET下载SHA256均通过。"
    evidence: "build/qa/v1.3.4/public-download-checks.json；Windows安装器/便携ZIP、Android原签名APK、鸿蒙未签名ARM64HAP/说明及两份SHA256SUMS。"
  - fact: "0153三端构建与275客户端/127后端验证、0154生产后台发布及鉴权下载完成。1.3.3以前需先手动覆盖本版一次。"
    evidence: "release-gates.json/public-artifacts-verified.json和0154 production-safe.json；不改写旧v1.3.3标签。"
  - fact: "本轮HDC目标数0，没有覆盖本人平板；上一私有版仍是1.3.3，不把公开HAP当作已安装或通用直装包。"
    evidence: "hdc list targets内部捕获，仅输出计数0；个人Profile/签名包未公开。"
changed_files:
  - path: "docs/releases/v1.3.4.md"
    change: "0153同源公开正文，明确后台更新、唯一学习账本、一次手动引导和验证边界。"
  - path: "docs/releases/v1.3.4-harmonyos.1.md"
    change: "0153同源公开正文，明确未签名HAP及电脑签名覆盖资格。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新当前公开版本、生产与待验状态，避免重复发行/部署。"
evidence:
  - command: "git push origin main；git push --atomic origin refs/tags/v1.3.4 refs/tags/v1.3.4-harmonyos.1（使用当前系统代理，凭据不输出）"
    result: "源码及两个注释标签成功；origin main是标签源码同一提交或后续文档后代。"
  - command: "python client/flutter_app/build/qa/release134.py stage/publish"
    result: "两发行草稿七资产大小/SHA256全部通过后公开，无覆盖旧资产。"
  - command: "python client/flutter_app/build/qa/v1.3.4/verify_downloads.py"
    result: "7次匿名完整下载状态200/字节数/流式摘要通过，双注释标签和正文精确一致，latest v1.3.4。"
compatibility_and_security:
  contract_impact: "新增更新入口在1.3.4起可用；原设备资料保留覆盖，Windows安装器无Authenticode，Android使用原证书。"
  tenant_impact: "公开GitHub发行沿原分发方式；软件内更新仍需当前在线账号与服务器授权，离线隐藏。"
  sensitive_data: "公开白名单仅七资产，无设备标识、个人证书、Profile、密钥或本人设备签名包。"
risks_or_blockers:
  - "完整实体/同步/供应商/实况窗权益门禁保持；当前没有连接的鸿蒙设备，不宣称本轮平板已更新。"
next_actions:
  - id: NEXT-USER-RUNTIME
    action: "按新公开版本收集真实设备反馈；后续客户端版本本机编译后在后台上传发布，无需为单纯上传再部署后端。"
    inputs: [docs/releases/v1.3.4.md, docs/development/在线更新与绑定番茄.md]
---
