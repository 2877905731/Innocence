---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0156"
created_at: "2026-11-03T14:08:34+08:00"
phase: P01
type: DONE
status: complete
title: "用户原平板已覆盖1.3.4，原签名/UID/首次安装时间保留并启动成功"
objective: "按用户本轮明确要求更新连接平板，复用0153–0155运行源码与原发布签名，保留资料。"
completed:
  - fact: "识别唯一原设备，安装前版本1.3.3+15；原签名ARM64联网Release 1.3.4+16已覆盖安装。"
    evidence: "hdc install -r 返回install bundle successfully，安装后bm dump为1.3.4/16。未卸载或清数据。"
  - fact: "官方HAP和Profile验签通过，原安装证书SHA256在新链中匹配，证书链与0150逐字节一致，Profile有效期/包名/应用标识核对通过。"
    evidence: "self-use/0156/candidate-safe.json：53882643字节，SHA256 1ce1282a294579a0898d2d24003d9f66b9ee40e4974bc7d909d170471bbe0753。"
  - fact: "覆盖前后appIdentifier/appId、签名、UID与firstInstallTime保持一致；启动命令成功且后续进程仍在。"
    evidence: "installation-safe.json及startup-safe.json；原始bundle输出/截图仅F盘私有。没有接管其他应用界面，不把进程存在当作完整业务恢复或提醒验收。"
  - fact: "127 Dart与5 ArkTS与当前运行源码逐字节一致，包内1.3.4/16、ARM64 Release/AOT、INTERNET和生产HTTPS核对通过。"
    evidence: "复用0153–0155同源275客户端/127后端与生产发布验证；本轮只额外构建/验签/覆盖，不重跑无关全套或重新发布。"
changed_files:
  - path: "progress/0000__AI-RESUME.md"
    change: "更新个人平板安装状态与保留的实体业务/权益门禁。"
  - path: "progress/INDEX.md"
    change: "升序追加0156。"
  - path: "client/flutter_app/harmonyos/README.md"
    change: "记录本次个人原签名1.3.4覆盖与隐私边界。"
evidence:
  - command: "tool/harmonyos.ps1 -Action build -BuildMode release -Edition Online"
    result: "原签名ARM64 Release构建成功，Hvigor67.2秒。"
  - command: "hap-sign-tool.jar verify-app；verify-profile（原始结果仅私有目录）"
    result: "官方验证通过；Profile有效、应用身份和原证书链匹配；源码/CRC/AOT/生产端点通过。"
  - command: "python client/flutter_app/build/harmonyos-h0/self-use/0156/update_tablet.py"
    result: "退出0；覆盖成功，1.3.4+16；签名/应用标识/appId/UID/首次安装时间一致，aa start成功并有应用进程。"
  - command: "hdc shell pidof；snapshot_display -f <本轮临时jpeg>及file recv"
    result: "进程持续存在；画面私有留存，本轮未验证Innocence业务页面，不写真实任务或模型请求。"
compatibility_and_security:
  contract_impact: "无新运行代码、版本或接口；0155公开包和0154后端保持，无重复发布/部署。"
  tenant_impact: "沿原身份覆盖，不迁移/删除本机或在线账号，不写真实业务记录。"
  sensitive_data: "个人签名HAP/证书/Profile/设备目标/原始bundle/画面只存F盘忽略目录，不进Git或GitHub公开资产。"
risks_or_blockers:
  - "本轮只证明兼容覆盖、身份保留与启动；完整业务资料逐行恢复、后台/锁屏提醒、TIMER权益与实体矩阵仍待。"
next_actions:
  - id: NEXT-TABLET-FEEDBACK
    action: "用户打开已更新的1.3.4，按实际反馈继续核对绑定番茄、助手和在线更新；不重复安装或清数据。"
    inputs: [docs/releases/v1.3.4-harmonyos.1.md, docs/development/在线更新与绑定番茄.md]
---
