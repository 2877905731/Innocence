---
schema_version: 1
document_type: checkpoint
sequence: "0126"
created_at: "2026-10-30T14:02:29+08:00"
phase: P01
type: DONE
status: complete
title: "Android与鸿蒙1.2.6 UI修正版公开、五项下载与安装范围核对"
objective: "完成用户明确要求的双端GitHub重新发布，并准确回答下载后直接点装的能力边界。"
completed:
  - fact: "v1.2.6+11 Android及v1.2.6-harmonyos.1已公开，Release#428699277/#428699913，latest=v1.2.6；5资产远端SHA/正文及匿名HEAD200长度通过，源码c20f84b与双注释标签精确同步。Android原发行证书/离线APK79727911bytes/701927a4…可交系统安装器；鸿蒙未签名ARM64 AOT53017333bytes/c9908a16…仍需接收者Profile/签名/HDC，个人材料不公开。内置字体/连续羽化均已进入新包，119Dart/五资源/CRC核对及11相关+13鸿蒙目标/分析通过；实体新画面/安装/性能/权益和G01仍待。Windows下载沿v1.2.5；旧临时入口已停止不续期。"
    evidence: "两Release官方API、Git对象精确同步及5条public-download-checks.json"
  - fact: "用户要的Android APK下载后可由系统安装器安装；鸿蒙原生HAP不是同一分发链路。此前Deeplink临时页已明确为网页分发，未用签名成功冒充文件管理器直装。"
    evidence: "两份Release正文、README中英文及INSTALL说明；官方Deeplink/签名/HDC文档"
changed_files:
  - path: "progress/0000__AI-RESUME.md"
    change: "更新双端公开状态与实机/安装门禁"
  - path: "progress/INDEX.md"
    change: "追加0126"
  - path: "docs/03-execution-plan.md"
    change: "双端1.2.6公开回执与平台当前步骤"
  - path: "docs/08-project-profile.md"
    change: "公开发行证据追加"
  - path: "progress/0126__20261030__P01__DONE__android-harmony-ui-v126-published.md"
    change: "本次具体发布、摘要与匿名下载独立证据"
evidence:
  - command: "git commit/annotated tag；push126_api.py通过官方Git Database API非force快进"
    result: "源码c20f84b6972ea65b2ced6673237024bb46d219c9，前置8提交逐个blob/tree/commit SHA精确保留，双注释标签SHA核对；无force覆盖"
  - command: "release126.py publish"
    result: "两公开非预发行，Release#428699277/#428699913，2+3白名单资产SHA256及长度一致；旧Release未覆盖"
  - command: "release126.py check"
    result: "5项匿名HEAD200/Content-Length等于本机；GitHub SHA256/正文和latest=v1.2.6通过。未将HEAD或部分下载描述为完整包安装验收"
  - command: "本轮build/tests/verify126.py"
    result: "0125：Android102.7秒/Harmony含解析209.0秒，两包/五字体许可/119Dart/CRC/版本/离线/签名边界通过；11相关+5跳过、13指定目标回归及分析无问题"
  - command: "Java21/SnakeYAML2.5 VerifyPublished126Documents.java；git diff --check"
    result: "exit0/PASS：5文档严格UTF8字节回转/无重复键YAML、0126/0127指针、INDEX升序/路径及changed_files；diff --check通过"
compatibility_and_security:
  contract_impact: "仅发行版本1.2.6+11；无数据库迁移/业务接口改动"
  tenant_impact: "none；未操作实体设备或真实业务数据库"
  sensitive_data: "只上传APK、未签名HAP及公开说明/摘要；个人CER/Profile/私钥/密码/签名HAP/临时私有URL仍在F盘忽略目录。Android签名使用原本机受保护配置，没有明文凭据写Git"
risks_or_blockers:
  - "鸿蒙公开HAP不能点文件直装；网页指定设备资格、私有包覆盖/资料恢复及真机安装尚无新反馈"
  - "真实Android/鸿蒙字体/光束/性能、H5/G01与TIMER/代理权益仍待，不由公开下载通过代填"
  - "认证失败、租户不匹配、业务权限拒绝、缺字段、生成失败负向本轮视觉发行未回放"
next_actions:
  - id: NEXT-UI126-PHYSICAL
    action: "交付两个Release/Android APK及明确鸿蒙文件安装限制；保持旧应用/资料，按后续用户真实反馈核对画面、升级及性能。未经新授权不公开个人签名材料或续临时入口；常规原生鸿蒙安装需合资格分发或电脑签名/HDC路线"
    inputs: ["docs/releases/v1.2.6.md", "docs/releases/v1.2.6-harmonyos.1.md", "client/flutter_app/harmonyos/INSTALL.zh-CN.md"]
---
