---
schema_version: 1
document_type: checkpoint
sequence: "0102"
created_at: "2026-10-06T18:05:39+08:00"
phase: P01
type: DONE
status: complete
title: "F盘官方鸿蒙SDK与ARM64/x64未签名原生HAP通过，签名及设备运行待验"
objective: "接用户提供的DevEco26 ZIP，完成F盘工具环境、原生编译和产物核验；本检查点不宣布鸿蒙运行或发行完成"
completed:
  - fact: "官方ZIP本机摘要、CRC与安装器Authenticode签名核对；从官方包解压DevEco26及SDK API26到F盘"
    evidence: "ZIP3295837057字节/SHA256 33ce2d302ecccdbc27287bd6523bd32c6f4da32c80d6c7f33057b83b1eefb9d9；Get-AuthenticodeSignature Valid/Huawei Technologies Co., Ltd.；未取得官网发布摘要，未声称对照官网摘要"
  - fact: "HarmonyOS工具链可用，Preferences/路径/文件选择/SQLite四插件注册和ArkTS/native编译通过"
    evidence: "DevEco26.0.0.851/SDK26.0.0.105 API26/Node24.14.1/ohpm26.0.0.630/Hvigor6.26.8；doctor HarmonyOS项通过"
  - fact: "ARM64未签名Debug HAP通过完整原生编译，继续时摘要一致；此构建完成于2026-10-05，本记录写于2026-10-06"
    evidence: "115144159字节/SHA256 f10e480b990245d5e3ae8461941cdf108a4e7bb65c902d0c99a96ee10d3998d7；Hvigor18.7秒，ZIP CRC/ARM64 ELF/tablet/横屏/API18→26/1.2.2+7核对通过"
  - fact: "补Windows本地模拟器x64编译入口，单独工程与未签名包，不覆盖ARM64产物"
    evidence: "build -Unsigned -Architecture x64 exit0/Hvigor156.6秒；116763248字节/SHA256 23bb2b3b6af57f23ce72da76014ec14f6bd5d66c4c04b8cff1527312a811b928；ZIP CRC与x86_64 Flutter/SQLite ELF通过"
  - fact: "工具缓存/用户目录/IDE配置均设置F盘，Windows Path重复导致旧Node的问题已修正"
    evidence: "prepare x64退出后15项进程环境恢复PASS；脚本语法PASS，113共享Dart与5原生配置字节一致"
  - fact: "DevEco已打开暂存工程，用户亲自完成IDE账号登录；实际签名页需设备Profile"
    evidence: "界面显示登录成功、缺少设备无法新建Profile；hdc list targets exit0/目标0；设备管理器首次协议及隐私选项等待用户自行处理"
changed_files:
  - path: client/flutter_app/tool/harmonyos.ps1
    change: "DevEco自动识别、F盘进程用户与缓存、Path去重/恢复、Unsigned及独立x64构建、IDE打开与暂存签名保留"
  - path: client/flutter_app/ohos/build-profile.json5
    change: "DevEco26兼容target26.0.0，移除显式compile版本，兼容API18保持"
  - path: client/flutter_app/ohos/oh-package.json5
    change: "移除未覆盖产品业务的模板hypium依赖"
  - path: client/flutter_app/ohos/entry/build-profile.json5
    change: "移除默认ohosTest target，保留样例源码参考"
  - path: client/flutter_app/harmonyos/README.md
    change: "记录两架构未签名包、工具与F盘环境、命令及运行边界"
  - path: docs/planning/Innocence-鸿蒙平板版本实施规划.md
    change: "更新SDK/HAP实际进展、登录/设备及运行门禁，不修改0101历史事实"
  - path: docs/03-execution-plan.md
    change: "鸿蒙track更新为未签名原生HAP就绪、签名与运行待验"
  - path: docs/08-project-profile.md
    change: "同步真实鸿蒙进展和INTERNET/离线与会话边界"
  - path: progress/0000__AI-RESUME.md
    change: "更新继续时间、当前目标、下一步与0102证据"
  - path: progress/INDEX.md
    change: "按升序追加0102"
  - path: progress/0102__20261006__P01__DONE__harmonyos-sdk-and-unsigned-hap.md
    change: "记录本次独立可核验的工具及编译里程碑"
evidence:
  - command: "Get-AuthenticodeSignature tools/devecostudio-windows-26.0.0.851/deveco-studio-26.0.0.851.exe；Get-FileHash F:/devecostudio-windows-26.0.0.851.zip"
    result: "exit0；Valid/Huawei Technologies Co., Ltd.；ZIP SHA256与上次记录一致"
  - command: "tool/harmonyos.ps1 -Action doctor -GitHelperPath <已有Git mingw64/bin>"
    result: "exit0；HarmonyOS项通过/API26。固定维护SDK的user-branch警告及隔离用户目录Android未配置均保留，未声称全部doctor项通过"
  - command: "tool/harmonyos.ps1 -Action build -Unsigned -DirectGit -GitHelperPath <已有Git mingw64/bin>"
    result: "上一轮最终exit0/Hvigor18.7秒；build/harmonyos-h0/hap-build-final.log；默认签名命令不计通过"
  - command: "tool/harmonyos.ps1 -Action build -Unsigned -Architecture x64 -DirectGit -GitHelperPath <已有Git mingw64/bin>"
    result: "本轮exit0/Hvigor156.6秒；build/harmonyos-h0/hap-build-x64.log"
  - command: "Python build/harmonyos-h0/temp/verify-native-hap.py；x64 ZIP/ELF/元数据/摘要核验"
    result: "exit0/PASS；ARM64 CRC/两库/113共享Dart/5原生配置/四注册插件；x64 CRC与两库；清单hap-artifact-manifest.json及hap-artifact-manifest-x64.json"
  - command: "PowerShell Parser；prepare -Architecture x64前后15项进程环境逐值比较；hdc list targets"
    result: "语法PASS；prepare exit0/15项恢复PASS；HDC exit0/目标0，不输出设备标识"
  - command: "Python build/harmonyos-h0/temp/verify-documents.py；git diff --check"
    result: "文档核验在本记录生成后执行；结果同步到RESUME。git diff --check已exit0，仅有原工作区LF/CRLF提示"
compatibility_and_security:
  contract_impact: "未改后端/设备槽位/在线契约；PC呈现与harmonyos身份分开，首轮强制本机模式"
  tenant_impact: "ownerScope、SQLite schema与数据层沿0100；没有在真实账号写合成业务数据"
  sensitive_data: "账号登录由用户操作；不保存密码/验证码/账号信息；签名材料只允许暂存忽略目录。HAP未含数据库或p12/p7b"
risks_or_blockers:
  - "未签名Debug包，不是直接面向真机的安装交付；无鸿蒙安装/启动证据，H0/G01仍未通过"
  - "用户已登录DevEco，但真实调试Profile需连接设备；HDC目标0。模拟器可免签名，首次协议与隐私窗口等待用户处理"
  - "Debug声明INTERNET，客户端本机模式不等于无网络权限正式包；模板图标与样例测试不计产品验收"
  - "SQLite/Preferences冷启动与覆盖恢复、文件选择、软键盘/安全区/触控/四主题与HUKS仍待原生环境验证"
  - "authentication_failure/tenant_mismatch/permission_denied/missing_field/generation_failure本轮未在鸿蒙设备执行，按H2/H4/H5门禁补证据"
  - "具体平板型号/API/方向策略、H4槽位和正式包联网范围仍待；没有推送或发布授权"
next_actions:
  - id: NEXT-HARMONYOS-RUNTIME
    action: "用户处理设备管理器协议与隐私后，在F盘创建API26平板模拟器，安装x64未签名包；或USB连接平板完成调试Profile再生成签名ARM64包；随后冷启动/存储恢复/PC页面与触控验证"
    inputs: ["client/flutter_app/harmonyos/README.md", "client/flutter_app/tool/harmonyos.ps1", "client/flutter_app/build/harmonyos-h0/app-x64/build/ohos/hap/entry-default-unsigned.hap"]
---

# 检查点说明

本检查点仅封存官方工具链及两架构原生编译证据。生成HAP不等于鸿蒙安装运行通过；后续运行结果新增检查点，不修改旧0100/0101/0102。
