---
schema_version: 1
document_type: checkpoint
sequence: "0104"
created_at: "2026-10-06T23:36:13+08:00"
phase: P01
type: DONE
status: complete
title: "鸿蒙模拟器HAP安装与全屏PC页面启动，四主题及原生存储初始化有证据"
objective: "解决模拟器许可路径导致的后台等待，完成x64安装启动及PC页面/Preferences/SQLite初始化核对；不宣布业务恢复或真机发行完成"
completed:
  - fact: "独立原生工具读C盘许可而IDE确认在F盘，导致后台y/N等待；通过仅工具目录重定向解决"
    evidence: "idea.log明确Please read carefully... (y/N)；C盘目录仅本轮诊断47字节状态，安全移到archive/0103/windows-cli-license-cache并建Junction到F盘既有同版本配置，许可字节不改；CLI默认识别F盘实例并成功启动"
  - fact: "API26/x64系统与HDC连接，最新版未签名x64 HAP安装及EntryAbility启动成功"
    evidence: "param get const.ohos.apiversion=26，uname -m=x86_64；HDC install输出install bundle successfully，aa start输出start ability successfully。包117220024字节/SHA256 06ff364610cae8b66ec8e9f2cf428af1d71c4e2c60225d60bd96f2573df17fdc"
  - fact: "PC横屏全屏宿主、首页/计划/本机设置及四主题有鸿蒙原生画面；液态玻璃进程冷启动后恢复"
    evidence: "uitest dumpLayout App root为目标bundle/[0,0][2800,1840]，snapshot_display原生2800×1840；简约白/液态玻璃/侘寂/中古纪切换可见；aa force-stop/start后玻璃恢复。没有把这些画面当作完整四主题业务/设备矩阵"
  - fact: "原生SQLite初始化通过只读schema与完整性核对，未声称QA业务已写入"
    evidence: "本App隔离模拟器DB/WAL副本，Python exit0/PASS：user_version6、17表、integrity_check=ok、计划/任务行0"
  - fact: "简约白通过鸿蒙触控/滚动/原生文字输入进入QA_NATIVE计划及QA_TASK任务草稿"
    evidence: "uitest uiInput inputText/点击/滑动返回No Error且画面精确显示名称；随后小艺输入法首次协议/隐私页打开，尚未保存，待用户亲自选择"
changed_files:
  - path: client/flutter_app/harmonyos/README.md
    change: "更新模拟器安装/全屏/四主题/Preferences与SQLite初始证据，记录输入法页面及真机待验"
  - path: docs/planning/Innocence-鸿蒙平板版本实施规划.md
    change: "指向0104并补原生运行子项与边界"
  - path: docs/03-execution-plan.md
    change: "track更新为模拟器PC页面运行、输入法与真机待"
  - path: docs/08-project-profile.md
    change: "同步真实原生进展，不扩大门禁完成范围"
  - path: progress/0000__AI-RESUME.md
    change: "更新当前状态/待用户操作/下一步，清除过时SDK下载待办，记录0104"
  - path: progress/INDEX.md
    change: "升序追加0104"
  - path: progress/0104__20261006__P01__DONE__harmonyos-emulator-install-and-pc-shell.md
    change: "封存本次模拟器安装启动里程碑与明确未完成项"
evidence:
  - command: "安全路径检查/Move-Item仅工具Emulator26.0目录/New-Item Junction；Emulator -list -details；启动已有Emulator.exe"
    result: "exit0/PASS；旧47字节状态保留，F盘既有配置字节一致，C盘仅目录链接；未重写许可/隐私选择，系统随后启动"
  - command: "hdc -t 127.0.0.1:5555 install app-x64/build/ohos/hap/entry-default-unsigned.hap；shell aa start -b com.innocence.tablet.innocence_flutter -a EntryAbility"
    result: "exit0/install bundle successfully；exit0/start ability successfully；API26/x86_64；真实平板未安装"
  - command: "uitest dumpLayout/uiInput；snapshot_display/file recv；aa force-stop/start"
    result: "PC全显示root2800×1840、四主题切换与玻璃进程冷启动可见；原生QA截图保留F盘build/qa/harmony-native；当前已恢复简约白"
  - command: "本AppDB/WAL file recv；Python verify-native-sqlite-initial.py/verify-harmony-runtime.py"
    result: "exit0/PASS：SQLite v6/17表/integrity ok、计划任务行0；API26/x64进程/F盘目录链接/全显示root/6原生图核对。仅初始化和Preferences恢复，不证明业务SQLite写入恢复"
  - command: "hilog -x -P <本App PID> -L E,F；uitest uiInput inputText"
    result: "发现Flutter输入法12800008/12800009，玻璃编辑阶段黑屏；简约白输入QA_NATIVE/QA_TASK有画面，随后小艺输入法首次协议/隐私页待用户。初始小写flutter过滤为空不能证明无错误"
  - command: "Python verify-documents.py；git diff --check"
    result: "本检查点生成后执行，结果同步RESUME；旧0102/0103字节SHA256生成前后保持一致"
compatibility_and_security:
  contract_impact: "none；首轮仍强制本机模式，未改后端/会话槽位/在线助手契约"
  tenant_impact: "仅隔离模拟器本机账号/草稿，没有在真实账号写合成业务；SQLite初始业务行0"
  sensitive_data: "账号/设备授权/输入法隐私由用户操作；不保存凭据/验证码/真实身份或设备标识；只读DB/WAL是隔离本机初始化数据并保存在忽略目录，不纳入Git"
risks_or_blockers:
  - "小艺输入法首次协议/隐私页必须用户亲自选择；QA_NATIVE/QA_TASK草稿尚未保存，业务SQLite写入与冷启动恢复仍待"
  - "输入法12800008/12800009及玻璃编辑黑屏需初始化完成后复验；当前仅四主题显示/切换，不是完整触控、软键盘和性能矩阵"
  - "真实平板USB开发者/调试及电脑授权/Profile、ARM64签名和实际安装仍待；两架构包仍未签名Debug，Debug声明INTERNET，不是正式离线发行包"
  - "authentication_failure/tenant_mismatch/permission_denied/missing_field/generation_failure尚未在真实鸿蒙业务链路完整执行；HUKS/槽位/联网、H0-H5/G01整体和发行仍待"
next_actions:
  - id: NEXT-HARMONYOS-OFFLINE-RECOVERY
    action: "用户处理当前输入法页面后返回QA编辑器，保存QA_NATIVE/QA_TASK，进程冷启动/SQLite结构与业务值/owner关联核对，复验玻璃编辑与输入服务；用户真机连接后再生成Profile和ARM64签名包"
    inputs: ["client/flutter_app/harmonyos/README.md", "client/flutter_app/build/harmonyos-h0/harmony-runtime-manifest.json", "client/flutter_app/tool/harmonyos.ps1"]
---

# 检查点说明

这份记录封存API26/x64模拟器安装启动与PC页面的可核验证据。未保存草稿、未完成业务恢复、未取得真实平板Profile或发行授权；旧0102/0103保留原事实，不因后续解决而改写。
