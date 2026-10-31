---
schema_version: 1
document_type: checkpoint
sequence: 0109
created_at: '2026-10-07T14:36:57+08:00'
phase: P01
type: DONE
status: complete
title: 鸿蒙平板Release本机包GitHub分发与公开下载核对
objective: 完成0108用户验收后授权的GitHub鸿蒙Release分发，保持个人设备Profile私有并明确未签名和验收范围
completed:
- fact: 独立ARM64 Release/AOT本机包生成，包内无INTERNET权限、JIT kernel和个人设备材料
  evidence: 最终构建exit0/Hvigor44.9秒；27698894bytes/SHA256884fd2a77a11ecb72ef7036e17fcdc4b93217e2934167a1fa19270b874b0a83e；ZIP CRC/版本8/tablet横屏/API/三份ARM64 ELF/113Dart与原生宿主一致性通过，官方SDK确认未签名
- fact: Release全屏启动时序修正，在首帧后应用SystemUiMode并扩展原生SYSTEM安全区
  evidence: 首轮x64有首页但root从y72开始；过早全屏调用随后产生空白，移动到首帧后及宿主安全区扩展后，最终x64编译44.3秒/安装/启动/进程冷启动、2800×1840 PC白色首页通过
- fact: 最终源码分析无问题，10平板布局/离线回归通过；当前Release模拟器PID致命异常/溢出筛选0，输入法12800008/9仍2
  evidence: flutter analyze lib test exit0/4.4秒；10回归2秒；API26/x86_64/PID3134，原生图片已目视核对；未操作当前真实平板进程
- fact: 源提交及注释标签精确推送，GitHub Release公开且不是pre-release；双端正式latest仍v1.2.3
  evidence: 源码2825dea9198f18af50b940c5bc1d822fb252a12a/注释标签c7e0f94eb5defb47f14c957980f59707aacd100a；官方Git Database API非force快进/对象SHA精确保留；Release#405446873/draft=false/prerelease=false/make_latest=false
- fact: HAP/离线说明/SHA256共3资产已公开，远端摘要和正文匹配，匿名下载3/3 HTTP200及长度匹配
  evidence: https://github.com/2877905731/Innocence/releases/tag/v1.2.3-harmonyos.1；公开API摘要逐项匹配/正文UTF8精确一致，public-download-checks.json三项200
changed_files:
- path: client/flutter_app/tool/harmonyos.ps1
  change: 新增debug/release选择、独立Release暂存和本机版网络权限移除
- path: client/flutter_app/lib/main.dart
  change: 仅鸿蒙在首帧后配置沉浸式全屏
- path: client/flutter_app/ohos/entry/src/main/ets/pages/Index.ets
  change: 原生宿主全宽高及SYSTEM安全区扩展，键盘处理保留
- path: docs/releases/v1.2.3-harmonyos.1.md
  change: 公开Release说明，明确未签名和Debug真机/Release模拟器证据
- path: README.md / README_EN.md / CHANGELOG.md / client/flutter_app/harmonyos/README.md
  change: 鸿蒙Release下载入口、构建和验收范围
- path: AGENTS.md / docs/03-execution-plan.md / docs/planning/Innocence-鸿蒙平板版本实施规划.md
  change: 当前发布里程碑/轨道与分发结果
- path: progress/0000__AI-RESUME.md / progress/INDEX.md / progress/0109__20261007__P01__DONE__harmonyos-release-aot-github-published.md
  change: 0109发布结果、当前状态和后续真实设备门禁
evidence:
- command: build-harmony-release-safe.py arm64/x64（tool/harmonyos.ps1 -Action build -BuildMode release -Unsigned -Architecture ...）
  result: 最终ARM64 exit0/Hvigor44.9秒，x64 exit0/44.3秒；Debug私有签名配置及原HAP摘要未变
- command: verify-harmony-release-package.py（ZIP/ELF/113Dart/native宿主/官方SDK verify-app/设备标识仅内存比对）
  result: PASS；release/debug=false/libapp AOT present/kernel absent/permissions=[]/unsigned；源和公开暂存signingConfigs=[]；无个人设备标识和签名材料
- command: flutter analyze --no-pub lib test；flutter test --no-pub --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos 三项平板/设置/离线入口文件
  result: 源码分析No issues found/4.4秒；10项通过/2秒
- command: Emulator -start MatePad Air 12 -bootMode coldboot -noWindow；verify-harmony-release-emulator.py；Emulator -stop MatePad Air 12
  result: 最终exit0，x64 Release安装/启动/进程冷启动/PC首页2800×1840 PASS，fatal/overflow0、输入法2；仅loopback模拟器目标，所有本轮启动的模拟器已stop exit0。期间一次就绪超时，后改按唯一loopback目标等待，未重启HDC或变更用户设备
- command: verify-v1.2.3-docs.py；git diff --check；commit-harmony-release.py；push-harmony-release-api.py
  result: 14源文件UTF8/6唯一YAML、INDEX路径升序、版本及空签名配置PASS；凭据/真实设备标识0；中文提交及源码/标签对象SHA精确推送
- command: publish-harmony-release.ps1；check-harmony-release-downloads.py
  result: Release#405446873公开/非pre-release；3远端SHA256与本地匹配，正文精确一致，双端latest=v1.2.3；匿名下载HTTP200/长度3/3
release_assets:
- name: Innocence-v1.2.3-harmonyos-arm64-release-unsigned.hap
  bytes: 27698894
  sha256: 884fd2a77a11ecb72ef7036e17fcdc4b93217e2934167a1fa19270b874b0a83e
- name: HARMONYOS-RELEASE-README.md
  bytes: 4410
  sha256: cd4afb4e2b7e606c504dadc2bc2ebd2ebddf319a2c69fbfcafb44b476d1d328f
- name: SHA256SUMS.txt
  bytes: 216
  sha256: 387437efafe9f7f28fcff87d67eb2a37deaff76ec0f593a076fb50f2782fd210
compatibility_and_security:
  contract_impact: 保持PC全屏、本机离线和应用内1.2.3+8；只移除Release模板网络权限，不开放账号/同步/BYOK/槽位/原生保险库
  tenant_impact: 用户实际平板进程和业务资料不变；仅本轮QA模拟器被安装/终止，不读写真实业务库，不以用户验收代填租户负向
  sensitive_data: Debug设备Profile/HAP/私钥/密码仅F盘忽略目录。公开3资产不包含个人设备标识、签名材料或原始日志；GitHub凭据仅内存使用。
negative_paths:
  authentication_failure: 本轮未新增真机/HTTP回放，继续保持原独立门禁
  tenant_mismatch: 本轮未新增真机/HTTP回放，继续保持原独立门禁
  permission_denied: 本轮未新增真机/HTTP回放，继续保持原独立门禁
  missing_field: 本轮未新增真机/HTTP回放，继续保持原独立门禁
  generation_failure: 本轮未新增真机/HTTP回放，继续保持原独立门禁
risks_or_blockers:
- 公开包为ARM64 Release编译的未签名HAP，接收者需自行Profile/签名；不等于通用正式证书或应用市场上架。
- 用户验收和0107真实平板证据对应设备Debug包；ARM64 Release未重装正在使用的平板。真实Release升级/业务恢复、完整输入/触控/性能、旧模拟器输入法2条及HUKS/槽位/联网和完整H5/G01继续待。
next_actions:
- id: NEXT-HARMONY-PHYSICAL-RELEASE
  action: 用户需要后续升级时，在本机Release工程配置设备签名、保留现有身份/资料，核对真实ARM64覆盖/冷启动和业务数据；当前不终止用户进程。
  inputs:
  - client/flutter_app/harmonyos/README.md
  - client/flutter_app/tool/harmonyos.ps1
- id: NEXT-HARMONY-H4
  action: 完整输入/触控/恢复矩阵与HUKS/设备槽位/联网契约继续按实际门禁推进；华为应用市场上架另需用户后续要求。
  inputs:
  - docs/planning/Innocence-鸿蒙平板版本实施规划.md
---

# 发布说明

0108授权的GitHub分发已完成。0102–0108检查点及旧公开预览/正式资产保持原记录，整体H5/G01不随此窄范围发布关闭。
