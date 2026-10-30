---
schema_version: 1
document_type: checkpoint
sequence: "0142"
created_at: "2026-10-31T02:01:17+08:00"
phase: P01
type: DONE
status: complete
title: "Android通知剩余时间1.3.2公开，原签名联网APK与两资产下载核对"
objective: "按用户明确指令重新发布Android通知剩余时间修正版"
source_commit: "aece2584d3c83b719883e0c15ffddf9f9164c96d"
completed:
  - fact: "用户明确要求重新发布，Android v1.3.2+14已正式公开，latest=v1.3.2。"
    evidence: "Release#429332577；源码aece2584d3c83b719883e0c15ffddf9f9164c96d和注释标签精确同步，公开仅APK及SHA256SUMS。"
  - fact: "通知主体直接显示专注/番茄剩余时间，保留原玻璃与侘寂字体。"
    evidence: "0140原生10组/拒绝权限/20回归与后台实际递减、暂停截图字节相同的证据沿用；本轮原生代码无变化，正式包倒计时布局/DEX已核对。"
  - fact: "原签名联网正式包及发行门禁通过。"
    evidence: "81023831bytes/SHA5e1a4a69928e24ff0f0d9b6c3858f5fb2084c685855713f6d7f5739cdc5eb926；版本14/1.3.2、原证书c3921809…/正确包名/非debug/INTERNET/三ABI生产HTTPS/五字体许可CRC通过。源码分析无问题，233通过/6平台条件跳过、离线4/联网2；正式构建53.2秒。"
  - fact: "远端发布内容和匿名下载核对完成。"
    evidence: "两资产远端digest/大小、本地说明整文、匿名HEAD200/长度和实际校验和文件精确字节均一致。main及注释标签指向本轮源码。"
changed_files:
  - path: "CHANGELOG.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "README.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "README_EN.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "client/flutter_app/pubspec.yaml"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "docs/03-execution-plan.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "docs/development/平板竖屏与专注系统提醒.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "docs/development/独立番茄闹钟.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "docs/releases/v1.3.2.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "progress/0000__AI-RESUME.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "progress/0141__20261031__P01__DONE__android-countdown-v132-release-ready.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "progress/0142__20261031__P01__DONE__android-countdown-v132-published.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
  - path: "progress/INDEX.md"
    change: "本轮Android1.3.2发行准备、下载说明或公开验证记录；通知实现见0140。"
evidence:
  - command: "android/package_release.ps1 -Edition Online；python build/qa/v1.3.2/verify_apk.py"
    result: "exit0；分析/233项6跳过/离线4/联网2及53.2秒正式构建，原证书/版本/网络/布局DEX/字体/CRC/三ABI地址通过。"
  - command: "Java21/SnakeYAML2.5 VerifyRelease132Documents 141；git diff --check"
    result: "11文件严格UTF8字节回转、5份无重复键YAML、141/142指针、INDEX全部路径/升序、版本/下载链接及diff通过。"
  - command: "git -c http.proxy=<当前系统代理> push --atomic origin main refs/tags/v1.3.2；release132.py publish/check"
    result: "源码和注释标签同步；草稿两资产SHA/大小通过后公开。原Git配置代理失效及无代理直连失败均不计成功，改为当前系统代理仅对本次命令生效，未修改全局配置。"
  - command: "GitHub只读核对main/tag/tag_commit/latest；匿名GET SHA256SUMS.txt和HEAD两资产"
    result: "远端源码/标签/正文/两资产摘要和大小精确一致、latest=v1.3.2，匿名200长度及校验和整文件字节通过。"
compatibility_and_security:
  contract_impact: "Android版本递增与通知显示；HTTP/SQLite/身份和阶段/统计语义保持，Windows和鸿蒙下载沿v1.3.0。"
  tenant_impact: "未操作真实账号或资料；原发行证书用于保资料覆盖升级。"
  sensitive_data: "公开白名单仅APK/SHA256SUMS；Git凭据与签名密码只在既有受保护配置和进程内，未进入日志或Git。"
risks_or_blockers:
  - "系统自动折叠多通知组时为系统摘要，展开后看各自动态数字；本轮不是厂商私有状态栏胶囊。"
  - "真实手机/OEM、省电/Doze/强行停止与原G01仍待；本轮未操作实体设备或服务器。"
next_actions:
  - id: NEXT-ANDROID-V132-ACCEPTANCE
    action: "交付原签名联网APK，用户直接覆盖旧正式版，不先卸载；核对本机资料、通知紧凑/展开、暂停/继续/后台及阶段切换，按实际手机反馈继续。"
    inputs: [docs/releases/v1.3.2.md]
---
