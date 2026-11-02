---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0151"
created_at: "2026-11-03T00:22:26+08:00"
phase: P01
type: DONE
status: complete
title: "三端1.3.3联网发行就绪，原签名APK与公开未签名HAP七资产核对"
objective: "按用户明确推送并发布Release的指令整合0148–0150，准备三端1.3.3+15与准确源码标签；个人平板签名包不公开。"
completed:
  - fact: "Windows安装器/便携ZIP、Android原证书联网APK与鸿蒙ARM64联网AOT未签名HAP构建成功，统一1.3.3+15。"
    evidence: "Android207.3秒正式构建，原证书c3921809…；Windows File/ProductVersion=1.3.3+15；鸿蒙81.3秒构建、官方验签工具确认无签名块。"
  - fact: "267项Flutter通过、6条件跳过、离线入口4/联网传输2及分析通过；125 Dart/4 ArkTS分发副本和字体许可逐字节、APK/HAP/ZIP完整性、三ABI/Windows/HAP AOT生产地址及严格七资产白名单通过。"
    evidence: "client/flutter_app/build/qa/v1.3.3/release-gates.json与public-artifacts-verified.json；运行源码与8bfcbbc相同，本轮只有发行说明/状态文档变更。"
  - fact: "主发行限定setup.exe/portable.zip/online.apk/SHA256SUMS，鸿蒙独立发行限定未签名HAP/说明/SHA256SUMS；两组校验清单与文件精确一致，不含个人签名材料。"
    evidence: "主三包24720857/30954880/81187735字节；HAP53516769字节；摘要详见发行目录SHA256SUMS和本轮验证JSON。"
  - fact: "GitHub当前main是本机祖先、写权限可用，v1.3.3及v1.3.3-harmonyos.1无标签冲突；生产依赖JAR620fbc32…/健康UP/注册0已只读确认。"
    evidence: "release133.py inspect：main734ec600…、latest v1.3.2；SSH只读核对，没有重复迁移/部署/本人平板安装。"
changed_files:
  - path: "CHANGELOG.md"
    change: "本轮三端发行准备、下载说明或进度；运行功能沿0148–0150。"
  - path: "README.md"
    change: "本轮三端发行准备、下载说明或进度；运行功能沿0148–0150。"
  - path: "README_EN.md"
    change: "本轮三端发行准备、下载说明或进度；运行功能沿0148–0150。"
  - path: "docs/releases/v1.3.3.md"
    change: "本轮三端发行准备、下载说明或进度；运行功能沿0148–0150。"
  - path: "docs/releases/v1.3.3-harmonyos.1.md"
    change: "本轮三端发行准备、下载说明或进度；运行功能沿0148–0150。"
  - path: "progress/0000__AI-RESUME.md"
    change: "本轮三端发行准备、下载说明或进度；运行功能沿0148–0150。"
  - path: "progress/INDEX.md"
    change: "本轮三端发行准备、下载说明或进度；运行功能沿0148–0150。"
  - path: "progress/0151__20261103__P01__DONE__v133-three-platform-release-ready.md"
    change: "本轮三端发行准备、下载说明或进度；运行功能沿0148–0150。"
evidence:
  - command: "android/package_release.ps1 -Edition Online；windows/package_release.ps1 -SkipVerification；tool/harmonyos.ps1 -Action build -BuildMode release -Edition Online -Unsigned"
    result: "三端正式构建/打包成功；Windows复用同源267/6及分析门禁，Android另离线4/联网2。"
  - command: "python client/flutter_app/build/qa/v1.3.3/verify_public_artifacts.py；版本/源码/七资产白名单及校验清单核对"
    result: "原APK签名/版本15/1.3.3/包名/INTERNET/非debug/SDK24、公开HAP未签名/tablet/ARM64/AOT/版本/网络、字体许可CRC与125 Dart/4 ArkTS精确字节通过。"
  - command: "release133.py inspect；SSH只读依赖核对"
    result: "origin可写、main祖先、双标签无冲突；生产后端依赖摘要一致/健康UP/注册关闭。"
  - command: "当前YAML/路径/版本及git diff --check"
    result: "结构、下载名/版本/路径和差异通过，真实发布状态将在下一检查点记录。"
compatibility_and_security:
  contract_impact: "仅按既有授权发行当前功能，无新业务接口/迁移；后端0148/0149已在0150部署，软件内在线更新模块不包含。"
  tenant_impact: "当前身份隔离、旧资料迁移与导入预览保持，不重跑真实任务或修改真实账号。"
  sensitive_data: "严格七资产白名单；个人HAP/Profile/私钥/凭据及QA截图均仅忽略目录，未入Git/公开资产。"
risks_or_blockers:
  - "本检查点为就绪，双Release还未公开，必须继续执行已授权推送/上传/发布/匿名校验。"
  - "Windows安装器未Authenticode签名；公开鸿蒙HAP仍需接收者自己的签名/Profile/HDC。"
  - "原完整实体/同步/真实模型/费用、长期性能与鸿蒙TIMER权益和G01门禁仍待，不因公开发行关闭。"
next_actions:
  - id: NEXT-PUBLISH-NOW
    action: "立即沿用户授权提交本轮文档、创建双注释标签并原子推送origin main及两标签；草稿上传严格七资产，核对SHA/大小/正文后公开，latest=v1.3.3，再验匿名下载并追加0152。无需重复询问发布许可。"
    inputs: [docs/releases/v1.3.3.md, docs/releases/v1.3.3-harmonyos.1.md]
---
