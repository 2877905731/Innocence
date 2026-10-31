---
schema_version: 1
document_type: checkpoint
sequence: '0106'
created_at: '2026-10-07T00:54:24+08:00'
phase: P01
type: DONE
status: complete
title: 鸿蒙平板1.2.3未签名开发预览独立发布，真机签名仍待
objective: 用户在鸿蒙制作中授权推送小版本并追问为何未发布鸿蒙；纠正前轮仅沿双端正式流程的范围理解，补发明确标注未签名的开发预览，不冒称实体平板可直接安装或H5完成
completed:
- fact: '独立 GitHub 预发布已公开，Release #404950703，prerelease=true/draft=false，4项资产的远端摘要与本机一致、匿名下载4/4 HTTP200及长度一致'
  evidence: 'HARMONYOS-PREVIEW-README.md: ID616099334/3714bytes/sha256:42a57dd146e88dcc4a95457c761d5226c7e97b92956c84145372ac99d52286d7；Innocence-v1.2.3-harmonyos-arm64-debug-unsigned.hap: ID616091579/115600935bytes/sha256:489f3b6bc237569851073fb1359c1e765523fd2be806bb6ee6044b5462c188a3；Innocence-v1.2.3-harmonyos-x64-emulator-debug-unsigned.hap: ID616095742/117220024bytes/sha256:1c86495fccae7a35479e3db3361cdf96123bb7d9db7567f66b806d3d60002b41；SHA256SUMS.txt: ID616099431/340bytes/sha256:5f842a66dee353cf98fa230b1e68fdd2dcb1d34c45630905ae711d1f0a3815bf'
- fact: 源码与注释标签已通过官方 Git Database API 精确保留对象SHA并快进同步；Windows/Android正式latest仍为v1.2.3
  evidence: 预览源码0152a77f400b2b8dea352693f5879456754a5826；注释标签09e8dee820ec78418a1760c8bdd2db77b72dcdf3；前轮发行记录759bfd4一并同步，未force/未改原正式资产
- fact: ARM64与x64按1.2.3+8当前源码完整原生编译，两包CRC/版本/API/ELF/图标与共享源码一致性通过，旧0102/0104包原样保留
  evidence: Hvigor104.7秒/118.5秒；ARM64 115600935bytes/489f3b6b…，x64 117220024bytes/1c86495f…；tablet/横屏、compatible18/target26、两架构Flutter/SQLite ELF、各113共享Dart及assets/shaders逐字节一致，空signingConfigs/未包含签名材料与数据库
- fact: 新版x64 HAP在API26/x86_64模拟器安装、启动并完成进程冷启动；简约白PC原生首页全屏
  evidence: HDC install/start成功；bm versionName1.2.3/versionCode8；aa help确认force-stop用位置参数，纠正最初误用-b后PID变化；App root[0,0][2800,1840]、原生截图2800×1840/文字可见。仅当前PID筛选Flutter致命异常0/RenderFlex溢出0，输入法12800008/9仍2条
- fact: 10项鸿蒙平板配置回归通过；下载说明区分ARM64实体平板与x64模拟器并解释签名要求
  evidence: flutter test --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos 三组目标exit0/10 passed；身份/PC键盘侧栏/四主题/Orb隐藏及本机设置/禁止账号API子集；HAP为未签名Debug，实体设备未验
changed_files:
- path: README.md
  change: 增加鸿蒙未签名预览下载入口和范围
- path: README_EN.md
  change: 同步英文预览入口和实体设备签名要求
- path: CHANGELOG.md
  change: 新增独立鸿蒙预览发行记录，不改旧正式资产事实
- path: client/flutter_app/README.md
  change: 增加预览与原生开发流程入口
- path: client/flutter_app/harmonyos/README.md
  change: 更新发布授权及预览范围，旧HAP路径保留历史时点
- path: docs/releases/v1.2.3-harmonyos-preview.1.md
  change: 可核对的包/运行证据、已知输入问题、设备签名与使用说明
- path: docs/planning/Innocence-鸿蒙平板版本实施规划.md
  change: 记录用户追问、发布范围纠正与独立预览决策
- path: docs/03-execution-plan.md
  change: 同步预览公开与原生运行子项，真机及整体门禁继续待
- path: docs/08-project-profile.md
  change: 同步实际分发范围与未完成项
- path: AGENTS.md
  change: 同步当前里程碑
- path: progress/0000__AI-RESUME.md
  change: 记录0106并保持后续签名/输入/业务恢复起点
- path: progress/INDEX.md
  change: 升序追加0106
- path: progress/0106__20261007__P01__DONE__harmonyos-unsigned-preview-release.md
  change: 封存预览发行里程碑；0102–0105不修改
evidence:
- command: harmonyos.ps1 -Action build -Unsigned [-Architecture x64] -DirectGit；prepare-harmony-preview.py
  result: 两架构exit0/Hvigor104.7秒及118.5秒；原生包结构/目标API/CRC/ELF/图标/113共享Dart和assets/shaders一致性PASS、旧4包SHA保持、3文件SHA256SUMS精确核对
- command: flutter test --no-pub --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos harmony_tablet_presentation_test/offline_settings_page_test/offline_release_test
  result: exit0/10通过；宿主配置回归，不当作真机触控/存储证据
- command: Emulator -start "MatePad Air 12" -bootMode coldboot -noWindow；hdc install；aa start；verify-harmony-preview-runtime.py
  result: API26/x64模拟器、安装与两次启动成功/进程PID变化；1.2.3+8及PC全屏首页核对PASS，输入法错误2条继续待；前次-b语法失败不计冷启动成功
- command: select-v1.2.3.py/verify-v1.2.3-docs.py；独立8暂存文件UTF8/说明字节/校验清单核对；git diff --cached --check
  result: exit0；排除18无关旧资料、凭据模式0；预览说明与离线说明逐字节一致；无build/日志/签名材料入Git，旧检查点字节保持
- command: push-harmony-preview-api.py；publish-harmony-preview.ps1；check-harmony-preview-downloads.py
  result: 非force快进、对象SHA精确保留/标签一致；Release#404950703公开/预发布，4资产远端size/digest与本机一致、发布正文UTF8精确一致、匿名HEAD4/4 HTTP200；正式latest=v1.2.3
compatibility_and_security:
  contract_impact: none；客户端源码沿f7922f6，当前仍强制本机模式，未开放账号/同步/BYOK或新槽位；Debug声明INTERNET，不能称为无网络权限正式离线包
  tenant_impact: 仅已有隔离模拟器本机资料及原生首页运行，不写真实业务；没有以初始化或启动声称资料升级恢复
  sensitive_data: 未签名包与公开说明不含设备Profile/密钥/数据库；凭据仅内存，所有工具/日志/HAP/签名材料仅在F盘忽略目录；不操作隐私同意或设备授权页面
risks_or_blockers:
- ARM64 HAP未签名，不能直接安装到真实平板；需要用户连接并完成开发者调试/授权及设备Profile，DevEco登录不等于签名完成；未上架华为应用市场
- 小艺输入法首次隐私、玻璃编辑黑屏与12800008/9、业务保存/冷启动/覆盖升级、完整触控/文件/HUKS/设备槽位及联网仍待；此里程碑仅为开发预览分发
- authentication_failure/tenant_mismatch/permission_denied/missing_field/generation_failure未在完整真实鸿蒙业务链路执行；相关宿主与此前fixture不可替代设备证据，H0-H5/G01不封板
next_actions:
- id: NEXT-HARMONYOS-PHYSICAL-SIGNING-AND-RECOVERY
  action: 用户USB连接真实平板并亲自完成调试授权后生成Profile与本机签名HAP；另处理输入法隐私再复验玻璃/业务保存恢复、覆盖升级和完整触控，正式分发需实际签名与设备证据
  inputs:
  - client/flutter_app/harmonyos/README.md
  - docs/releases/v1.2.3-harmonyos-preview.1.md
  - client/flutter_app/tool/harmonyos.ps1
---

# 检查点说明

本次完成明确标注未签名的鸿蒙开发预览分发。0105的Windows/Android正式发行事实保留；本次纠正未覆盖用户鸿蒙发布目标的范围理解，不将预览分发等同于实体平板可安装正式包或H5完成。0102–0105保持原字节。
