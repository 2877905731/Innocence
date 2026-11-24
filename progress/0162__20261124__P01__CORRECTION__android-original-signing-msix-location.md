---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0162"
created_at: "2026-11-24T23:27:29+08:00"
phase: P01
type: CORRECTION
status: complete
title: "更正原Android签名材料缺失判断，Codex虚拟化目录原材料已解锁并核对"
objective: "补充0160未发现的本机MSIX目录映射证据，不改写原检查点。"
completed:
  - fact: "0160核对默认LOCALAPPDATA目录不存在属实，但不足以判断原发行材料丢失。用户要求直接重新编译发布后，在Codex MSIX的LocalCache/Local目录找到原p12和DPAPI凭据，成功解锁。没有新建替代签名或重置密钥。"
    evidence: "ORIGINAL_ANDROID_CREDENTIAL_UNLOCK_PASS；本机build/qa/v1.3.5/signing-readiness.json仅保存目录和公开证书指纹，凭据值不保留。"
  - fact: "1.3.5+17联网Release APK沿用c39218092db96b3c4085b0853bb781399b7d4fe1747a9d1032844b8154c05837原证书，与已有正式版本一致。"
    evidence: "android/package_release.ps1显式SigningDirectory成功；apksigner及正式包验证脚本通过。"
changed_files:
  - path: progress/0162__20261124__P01__CORRECTION__android-original-signing-msix-location.md
    change: "追加历史更正，保留0160原文。"
  - path: progress/0000__AI-RESUME.md
    change: "清除原签名材料缺失阻塞；后续从私有QA记录解析MSIX映射目录。"
evidence:
  - command: "仅枚举signing-credentials.clixml与innocence-android-release.p12路径；Import-Clixml解锁，不输出密码/材料正文"
    result: "MSIX虚拟目录两文件存在，DPAPI解锁通过。"
  - command: "android/package_release.ps1 -Edition Online -SkipVerification -SigningDirectory <原材料本机目录>；python client/flutter_app/build/qa/v1.3.5/verify_public_artifacts.py"
    result: "Release构建成功，1.3.5+17原指纹一致；无Debug替代签名。"
compatibility_and_security:
  contract_impact: "none；仅更正材料发现范围。"
  tenant_impact: "none"
  sensitive_data: "不复制/重建/公开原密钥，凭据仅DPAPI解密后进入构建进程环境，包验证只记录公开证书指纹。"
risks_or_blockers:
  - "默认目录未必映射至桌面应用虚拟目录；后续显式使用私有QA记录的原目录，禁止因路径差异创建新证书替代。"
next_actions:
  - id: NEXT-ORIGINAL-SIGNING
    action: "后续沿原材料与同一公开证书指纹构建升级包，路径线索见本机signing-readiness.json。"
    inputs: [client/flutter_app/build/qa/v1.3.5/signing-readiness.json]
---
