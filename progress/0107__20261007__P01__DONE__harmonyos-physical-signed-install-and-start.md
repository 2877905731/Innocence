---
schema_version: 1
document_type: checkpoint
sequence: '0107'
created_at: '2026-10-07T13:51:50+08:00'
phase: P01
type: DONE
status: complete
title: 鸿蒙实体平板单设备签名、安装启动与全屏PC页面核对
objective: 用户亲自确认USB与官方签名后，为当前实体平板构建并安装签名HAP，解锁后核对启动及PC全屏页面；不计完整H5/G01完成
completed:
- fact: 单设备Debug Profile/签名材料生成，全部材料位于F盘；当前真实平板匹配，有效期截至北京时间2026-10-21 13:17:09
  evidence: 忽略目录verification-manifest.json；Profile设备数1/UDID仅在内存匹配/validity通过，源工程signingConfigs仍为空
- fact: ARM64签名构建exit0/Hvigor112.3秒，官方SDK验签及包完整性通过
  evidence: 115983291bytes/SHA256 256390488fdbcc125d7d07e6a2cd7d2b61812efd6980265c724a0c84650b8624；CRC/版本1.2.3+8/tablet横屏/API/Flutter与SQLite ELF/113共享Dart一致性通过
- fact: 实体LRT-W20/HarmonyOS7.0.0.109(SP6C00E105R2P3)/API26/aarch64安装成功；锁屏错误10106102由用户手动解锁后解决，EntryAbility启动及PID34366存在
  evidence: install-result.json与runtime-results.json；bm dump应用根字段1.2.3/code8，嵌套插件versionCode0不用于应用版本
- fact: 原生语言页及PC计划页画面可见，App root及截图2800×1840，全屏PC侧栏/工作台，无Windows窗口控件
  evidence: 忽略目录build/qa/harmony-physical-v1.2.3/first.jpeg、current.jpeg及布局；图片已目视核对
- fact: 当前PID日志的Flutter致命异常、RenderFlex溢出和输入法12800008/9筛选计数均0
  evidence: record-harmony-physical-status.py输出selectedLogPatternCounts三项0；原始日志不落盘，不代表其他进程/完整软键盘矩阵
changed_files:
- path: AGENTS.md
  change: 当前里程碑标注实体签名安装启动及剩余真机门禁
- path: client/flutter_app/harmonyos/README.md
  change: 当前状态、F盘私有签名包及实际启动证据和后续动作
- path: docs/03-execution-plan.md
  change: 鸿蒙轨道更新到实体签名安装启动子项，保持完整门禁开放
- path: docs/planning/Innocence-鸿蒙平板版本实施规划.md
  change: 分清历史未签名预览与当前单设备签名结果
- path: progress/0000__AI-RESUME.md
  change: 当前目标/状态/待办与下一步更新，保留历史基线
- path: progress/INDEX.md
  change: 升序追加0107
- path: progress/0107__20261007__P01__DONE__harmonyos-physical-signed-install-and-start.md
  change: 新增不可变的实体签名安装启动窄范围检查点
evidence:
- command: python client/flutter_app/build/build-harmony-device-safe.py（内部执行tool/harmonyos.ps1 -Action build -DirectGit并指定GitHelperPath）
  result: exit0，Hvigor112.3秒，生成ARM64 entry-default-signed.hap；仅白名单输出写本机忽略日志
- command: python client/flutter_app/build/verify-harmony-device-package.py（官方SDK java -jar hap-sign-tool.jar verify-app）
  result: exit0，官方验签、CRC、ELF、版本/横屏/tablet、113Dart以及Profile设备/有效期/F盘核对PASS
- command: hdc -t <当前唯一实体设备，仅内存保存> install <本机ARM64签名HAP>；shell bm dump -n com.innocence.tablet.innocence_flutter
  result: 安装成功；解析应用根字段versionName1.2.3/versionCode8；设备标识不打印/不持久化
- command: python client/flutter_app/build/verify-harmony-physical-runtime.py；hdc shell aa start -b com.innocence.tablet.innocence_flutter -a EntryAbility
  result: 用户解锁后exit0/startSuccess=true，PID34366，App bounds和截图2800×1840；首次为语言页，未触发helper的cold分支
- command: hdc shell uitest dumpLayout -b com.innocence.tablet.innocence_flutter；snapshot_display；python client/flutter_app/build/record-harmony-physical-status.py
  result: exit0，全屏bounds PASS；原生PC计划页截图目视核对，三个日志筛选均0；后续用户继续操作，当前页面不用于假设已保存业务
compatibility_and_security:
  contract_impact: none；鸿蒙首轮强制本机模式，仍声明Debug INTERNET；未开放账号/BYOK/设备槽位/联网或正式离线分发
  tenant_impact: none；未写入合成任务、读取/导出真实业务库或变更ownerScope；业务恢复与租户负向未验
  sensitive_data: 真实UDID/序列号、账号、私钥、密码与原始系统日志不入Git；签名包/Profile仅F盘忽略目录，不上传公共Release
negative_paths:
  authentication_failure: 本轮未执行，继续保持门禁待验
  tenant_mismatch: 本轮未执行，继续保持门禁待验
  permission_denied: 本轮未执行，继续保持门禁待验
  missing_field: 本轮未执行，继续保持门禁待验
  generation_failure: 本轮未执行，继续保持门禁待验
risks_or_blockers:
- 检查期间用户页面发生变化，一次点击沿用了先前语言页坐标；随后观察到计划编辑未保存更改。停止点击并保留用户页面，已请求用户先处理草稿后确认重启，尚无回复。
- 未执行真机进程终止/冷启动、SQLite业务保存恢复、覆盖升级或完整软键盘/触控/四主题矩阵；旧模拟器玻璃编辑和输入法12800008/9仍须复验。
- 设备Debug Profile仅当前单设备且有有效期；公开0106资产仍为未签名包，未变更其说明或公开上传设备绑定签名包。
- HUKS/槽位/联网、真实供应商/HTTP/同步与完整H2-H5/G01继续待。
next_actions:
- id: NEXT-HARMONY-PHYSICAL-COLD
  action: 待用户处理当前草稿并确认可重启后，读取新鲜页面状态，再执行aa force-stop（bundle为位置参数）/start，以PID变化和全屏首页核对冷启动；继续本机资料恢复。
  inputs:
  - client/flutter_app/build/verify-harmony-physical-runtime.py
  - client/flutter_app/build/qa/harmony-physical-v1.2.3/runtime-results.json
- id: NEXT-HARMONY-PHYSICAL-INPUT
  action: 继续真机软键盘/触控/四主题、业务保存/升级恢复、HUKS及H4契约；如出现隐私/安全弹窗由用户亲自处理。
  inputs:
  - client/flutter_app/harmonyos/README.md
  - docs/planning/Innocence-鸿蒙平板版本实施规划.md
---

# 说明

本检查点仅完成用户当前实体平板的签名安装、启动与全屏PC页面子项。公开未签名预览及0102–0106历史记录不改写，整体H5/G01保持开放。
