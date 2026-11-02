---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0153"
created_at: "2026-11-03T01:24:55+08:00"
phase: P01
type: DONE
status: complete
title: "在线账号版本发布与手动绑定番茄本机实现，三端1.3.4构建及单一学习入账验证"
objective: "按用户授权本机编译、服务器发布传输并重新发行；本检查点仅确认本机实现和构建，生产与公开发行后续独立核对。"
completed:
  - fact: "后台支持流式上传、草稿、摘要复核、发布/下架、原子清单和审计；应用接口按账号及平台鉴权，内部Nginx传输配置具备限速/连接/空间预算。"
    evidence: "npm run build通过；后端127项0失败/错误/跳过，含发布重启持久化、篡改、权限、缺字段、跨平台和真实MySQL唯一学习入账。"
  - fact: "恢复开始专注绑定番茄；新模式主专注只作为总窗口，学习片段唯一入账，手动学习/休息阶段保留；联动暂停/结束并在总窗口到点截断。"
    evidence: "flutter test --no-pub：275通过/6平台条件跳过；离线4/联网2；Dart分析无问题。模式0/1/2保留旧自动绑定兼容与导入语义。"
  - fact: "Windows/Android/HarmonyOS 1.3.4+16已构建，原APK签名、公开未签名HAP、127 Dart/5 ArkTS副本及三端生产地址/版本/CRC/字体/摘要通过。"
    evidence: "build/qa/v1.3.4/public-artifacts-verified.json；Windows版本资源1.3.4.16；APK原证书c3921809…；HAP官方验签确认无签名块。"
  - fact: "用户明确确认本机编译、服务器发布与传输；鸿蒙指定设备开发分发不能通用应用内安装，UI与发行说明显示电脑签名覆盖方式。"
    evidence: "本轮用户追问及答复；SDK/官方bundle installer系统API边界；未申请系统特权或公开个人Profile。"
changed_files:
  - path: "client/admin_web/src/ReleasesPage.tsx"
    change: "版本上传、发布/下架与审计页面及配套api/导航/样式。"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/update/ReleaseService.java"
    change: "原子持久化版本服务和鉴权控制器、空间与完整性校验及HTTP负向。"
  - path: "client/flutter_app/lib/features/updates/update_controller.dart"
    change: "在线更新检查、Range续传、摘要和账号隔离、安装前再次授权及三端原生通道。"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "更新身份及绑定番茄联动、总窗口不重复入账；配套模型、离线存储、UI和后台规则。"
  - path: "infra/deploy/compose.yaml"
    change: "更新包持久挂载、Nginx internal传输、私有上传和备份/部署说明。"
  - path: "docs/development/在线更新与绑定番茄.md"
    change: "固化新绑定语义、接口样本、兼容性、安全/安装边界；更新契约清单和发行文档。"
evidence:
  - command: "dart analyze lib test；flutter test --no-pub；离线/联网入口分别显式define"
    result: "分析无问题；275通过/6条件跳过；离线4、联网2通过。"
  - command: "mvn -q test；mvn -q -DskipTests package；npm run build"
    result: "127项0失败/错误/跳过；后端JAR及后台生产静态包成功。"
  - command: "windows/package_release.ps1 -SkipVerification；android/package_release.ps1 -Edition Online -SkipVerification；tool/harmonyos.ps1 -Action build -BuildMode release -Edition Online -Unsigned"
    result: "复用上述同源验证，三端正式构建成功。最终公开包五个有效载荷及两份校验清单已生成核对。"
  - command: "python client/flutter_app/build/qa/v1.3.4/verify_public_artifacts.py"
    result: "127 Dart逐字节、全部ArkTS、AOT生产HTTPS、APK原签名/版本/安装权限、HAP未签名ARM64、CRC/许可/摘要通过。"
compatibility_and_security:
  contract_impact: "新增受保护发布和更新接口；manualPomodoro可选缺省false；存储flag2不需重复SQL迁移；旧绑定flag1保留。"
  tenant_impact: "更新必须使用当前认证会话，离线隐藏，账号切换清理下载；计时按原ownerScope与owner+recordKey隔离。"
  sensitive_data: "个人证书/Profile/设备标识不进源码或公开包；更新文件名由服务生成，下载凭据不进入URL/文件。"
risks_or_blockers:
  - "生产部署、真实后台上传/鉴权传输、源码推送及公开Release尚未在本检查点执行。"
  - "鸿蒙通用安装资格/TIMER、Windows代码签名和完整实体矩阵仍未获本轮验证。"
next_actions:
  - id: NEXT-DEPLOY-RELEASE
    action: "备份并隔离恢复后部署；以隔离账号核对后台发布和三平台下载/负向，清理账号，再推送并公开双Release。"
    inputs: [docs/development/在线更新与绑定番茄.md]
---
