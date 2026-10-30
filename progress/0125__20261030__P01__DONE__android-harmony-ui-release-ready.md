---
schema_version: 1
document_type: checkpoint
sequence: "0125"
created_at: "2026-10-30T13:53:58+08:00"
phase: P01
type: DONE
status: complete
title: "用户授权重新发布Android/鸿蒙UI修正版，1.2.6双端本机包就绪"
objective: "先完成用户要求的Android/鸿蒙UI发行准备，并明确HAP下载点文件安装与网页分发的区别；本检查点尚未计GitHub公开完成。"
completed:
  - fact: "用户直接要求先把更新好ui的两个端重新发布，并询问GitHub Release下载后直接安装；本轮授权公开Android/鸿蒙UI更新，个人单设备签名材料仍私有。"
    evidence: "本轮人类原文；两端指既有任务的Android/鸿蒙，Windows沿用v1.2.5链接"
  - fact: "两端升为1.2.6+11；Android同发行证书/非Debug/无INTERNET，79727911bytes/SHA256 701927a4f9f299092a03b1b904a9f123d33949364cf9b987f9c10f92422964b1，Gradle102.7秒。"
    evidence: "build/qa/v1.2.6/android-build.log及verification-manifest.json"
  - fact: "ARM64 Release/AOT未签名HAP构建exit0/209.0秒含解析，53017333bytes/SHA256 c9908a16255050ebe47cd80dc2eebdd5d547c93b331fc3d64a633118aeaa30a4。--no-codesign显式使用，原私人暂存签名配置逐字节未变，仓库签名配置为空。"
    evidence: "build_harmony126.py及harmony-build-result.json；SDK确认没有签名块，未误计验签成功"
  - fact: "包CRC、五份字体许可资源/字体清单及119 Dart/着色器/原生宿主逐字节通过，HAP版本/平板/非Debug/离线及ARM64 ELF通过，APK发行证书与历史一致；公开包无Profile/CER/私钥文件。"
    evidence: "verify126.py exit0；verification-manifest.json"
  - fact: "本轮相关回归11通过/5平台条件跳过，指定HarmonyOS目标另13通过；源码分析无问题。未重复宣称0118全量231为本次新结果。"
    evidence: "ui126-tests.log、ui126-analyze.log及v1.2.6/harmony-host-tests.log"
  - fact: "两份发布说明/五项资产白名单与SHA清单齐备；说明Android APK可交给系统安装器安装，原生HAP签名不等于文件管理器直装，网页Deeplink是另一体验。"
    evidence: "notes126.py；README中英文/CHANGELOG/INSTALL更新，所有公开下载未包含个人签名材料"
  - fact: "0124临时自用入口已按原30分钟窗口停止，未续期。远端main为175338f31adac709fd3d015f8d677518d7f3c180，本地祖先核对通过，具备push权限，无v1.2.6双标签冲突。"
    evidence: "server-readiness.json stopped/false；release126.py inspect"
changed_files:
  - path: "client/flutter_app/pubspec.yaml"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "client/flutter_app/ohos/AppScope/app.json5"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "client/flutter_app/harmonyos/INSTALL.zh-CN.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "README.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "README_EN.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "CHANGELOG.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "docs/releases/v1.2.6.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "docs/releases/v1.2.6-harmonyos.1.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "docs/03-execution-plan.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "docs/08-project-profile.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "progress/0000__AI-RESUME.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "progress/INDEX.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
  - path: "progress/0125__20261030__P01__DONE__android-harmony-ui-release-ready.md"
    change: "双端UI发行版本、说明/下载入口或本次证据和续接记录"
evidence:
  - command: "flutter test --no-pub相关4文件；指定harmonyos目标3文件；dart analyze lib test"
    result: "exit0；11/5条件跳过、13目标回归、No issues found"
  - command: "build/qa/v1.2.6/build_android.ps1；build_harmony126.py；verify126.py"
    result: "均exit0；Android102.7秒、Harmony含解析209.0秒；两包/字体/源码/权限/身份/签名边界核对通过"
  - command: "release126.py inspect；notes126.py"
    result: "远端祖先/推送权限及新标签无冲突；2份发行说明/5白名单文件及摘要就绪，尚未上传或公开"
  - command: "Java21/SnakeYAML2.5 VerifyReady126Documents.java；git diff --check"
    result: "exit0/PASS：13文档严格UTF8字节回转、5无重复键YAML、0125/0126指针、INDEX升序与路径/changed_files；diff --check通过"
compatibility_and_security:
  contract_impact: "仅发行版本升11/1.2.6，无业务/持久化/网络契约变化"
  tenant_impact: "none；未操作实体设备或真实业务数据库"
  sensitive_data: "个人CER/Profile/私钥/密码/单设备签名包只留F盘忽略目录；公开仅同发行签名APK和未签名HAP及说明/摘要，不包含私人安装URL"
risks_or_blockers:
  - "GitHub源码/双标签/5资产上传及公开、远端摘要和匿名下载仍待，不能把本机包记为公开完成"
  - "公开HAP不能点文件直装；指定设备网页资格、个人包覆盖/资料恢复、实体字体/光场/性能仍待"
  - "TIMER/代理权益及完整H5/G01继续待；业务认证/租户/权限/缺字段/生成失败负向本轮未回放"
next_actions:
  - id: NEXT-UI126-PUBLISH
    action: "按已明确人类授权推送当前源码及v1.2.6/v1.2.6-harmonyos.1注释标签，创建2份Release/上传5白名单资产并核对摘要，匿名HEAD/长度/正文和latest；保留旧发行/私人材料，实际公开后追加0126，不重复询问发布权限"
    inputs: ["docs/releases/v1.2.6.md", "docs/releases/v1.2.6-harmonyos.1.md", "client/flutter_app/build/qa/v1.2.6/verification-manifest.json", "client/flutter_app/build/qa/release126.py"]
---
