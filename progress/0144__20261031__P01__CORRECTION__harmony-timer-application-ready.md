---
schema_version: 1
document_type: checkpoint
sequence: "0144"
created_at: "2026-10-31T23:13:06+08:00"
phase: P01
type: CORRECTION
status: complete
title: "推送已由本人开通，TIMER开发调测申请附件可审阅并纠正前置范围"
objective: "承接用户本人同意协议并开通推送服务的回复，核对服务状态，准备实际表单及合规格式附件；不把申请准备当成权益或真机实时功能完成。"
completed:
  - fact: "用户本人开通推送，当前应用推送页可见关闭推送服务；配置数据存储位置中国。未重复同意协议或开通。"
    evidence: "当前人类回复；Cua现有应用iframe按钮及配置标签"
  - fact: "当前实况窗规则明确纯端侧无需推送，云侧创建/更新/结束需要推送；纠正0143过宽前置表述。保留PushToken设备名单与标准权益两个路径，不假定名单入口已可用。"
    evidence: "应用管理/开放能力管理/实况窗服务申请规则；当前Push配置未出现名单入口"
  - fact: "申请允许实名个人/企业，限大陆HarmonyOS手机/平板、用户主动且起止明确的实时事件，不超过8小时；需Word业务说明和JPG设计图及开发者承诺。已进入表单，290字符草稿填入，未提交。"
    evidence: "Cua实际申请规则与表单；TIMER-application-form-review.png，页面标审批3工作日"
  - fact: "生成真实两页DOCX和2200×1670 JPG，ZIP仅含这两文件，402437字节，归档CRC/成员/载荷精确字节通过；无设备/Token/签名或凭据内容。"
    evidence: "create_application_doc.py；application-artifacts.json；ZIP SHA256 d162044693e3f59a7f20d16bad10de578837d7d5408ad18a6afae6ab6460fc58"
  - fact: "DOCX用本机Word只读导出PDF、Poppler两页PNG并逐页核对，去除模板标题装饰线后重渲染通过；JPG目视清楚标设计预览非真机截图。附件、表单和具体范围已交用户核对，等待上传提交确认。"
    evidence: "render_docx.py首次缺soffice.exe失败；render_application_word.ps1 pages=2/pdf_exists=true/read_only=true；pdftoppm及view_image两页/JPG"
changed_files:
  - path: "docs/development/鸿蒙专注提醒权益接入.md"
    change: "追加开通事实、纯端侧与推送边界、表单和附件状态"
  - path: "docs/planning/Innocence-鸿蒙平板版本实施规划.md"
    change: "追加0144实际准备进度与待验"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新0144状态、申请确认与后续路径"
  - path: "progress/INDEX.md"
    change: "追加0144"
  - path: "progress/0144__20261031__P01__CORRECTION__harmony-timer-application-ready.md"
    change: "当前更正与附件证据，不改0143历史"
evidence:
  - command: "Cua核对已开推送/开放能力申请规则，填写290字符草稿并保存iframe截图"
    result: "现有应用/实况窗服务；3工作日页面提示；选择文件仍空，无上传/提交动作"
  - command: "依赖运行时Python create_application_doc.py；Word只读PDF导出；运行时Poppler pdftoppm；view_image"
    result: "真实OOXML/两文件归档载荷通过；标准LO renderer缺依赖失败已定位，Word导出2页及两页PNG/JPG目视核对通过"
compatibility_and_security:
  contract_impact: "none；无业务/原生源码变更，无新包构建或安装"
  tenant_impact: "未读取业务SQLite或创建真实合成计时，未操作服务器或公开发行"
  sensitive_data: "附件及截图仅F盘忽略目录；未读取输出ClientSecret/UDID/PushToken，不上传签名材料"
risks_or_blockers:
  - "尚待用户确认大陆范围、开发者承诺、具体ZIP上传及本应用申请提交；本检查点不表示已提交或获批"
  - "PushToken未获取、名单未登记；现有Profile仍缺实况窗入口权益。纯端侧不依赖推送不代表无需实况窗权益"
  - "TIMER通知卡片和状态栏胶囊尚未在当前实体版本验证；暂停/继续/后台/锁屏/结束、番茄跨阶段和代理提醒及G01仍待"
next_actions:
  - id: NEXT-HARMONY-TIMER-SUBMIT
    action: "接具体上传提交确认后先核对表单仍为同一应用/内容；按浏览器file-uploads文档上传现有ZIP并提交，保存真实成功/待审状态。若需新承诺超出当前范围，交用户审阅。随后核对名单入口或实际审批，不重复登录/开推送，不以等待3工作日当获批；Token如需取得仅F盘私有且单设备提交前具体确认。保资料不卸载，不发申请邮件或改公开资产"
    inputs: ["docs/development/鸿蒙专注提醒权益接入.md", "client/flutter_app/build/qa/harmony-live-20261031/application-artifacts.json", "client/flutter_app/build/qa/harmony-live-20261031/Innocence-TIMER-liveview-application.zip", "client/flutter_app/build/qa/harmony-live-20261031/TIMER-application-form-review.png"]
---
