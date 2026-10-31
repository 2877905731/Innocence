---
schema_version: 1
document_type: checkpoint
sequence: "0143"
created_at: "2026-10-31T16:54:30+08:00"
phase: P01
type: CORRECTION
status: complete
title: "鸿蒙真机联调前置核对，补充官方PushToken设备调测名单路径"
objective: "处理用户接入平板后开始通知卡片/顶部胶囊联调，完成设备和材料核对；纠正把新Profile视作唯一联调路径的过窄表述，不计实时功能已经完成。"
completed:
  - fact: "用户明确要求下拉通知栏实时倒计时，以及收起面板后顶部胶囊继续显示，随后连接平板并授权开始工作。"
    evidence: "当前人类指令；未从页面内容推断额外授权"
  - fact: "一台LRT-W20/API26，已装1.3.0+12/非Debug。首次启动因锁屏10106102拒绝；用户本人解锁后EntryAbility启动和进程存在，2800×1840首页可见且当前专注未开始。"
    evidence: "inspect_harmony_live_device.py --open；本机device-current-app.jpeg；未覆盖、卸载或启动合成计时记录"
  - fact: "当前设备UDID只在内存中与官方已验证的单设备Profile比对，匹配；该Profile仍无com.huawei.service.liveView.entry。"
    evidence: "device-inspection.json仅布尔/型号/版本，无UDID或Token"
  - fact: "实况窗卡片与CAPSULE_TYPE_TIMER已在现有原生代码中；SDK26普通通知isCountDown标为不支持。未以普通快照冒充动态显示。"
    evidence: "FocusNoticeChannel.ets timer/placeholder/capsule；本机notificationRequest.d.ts"
  - fact: "登录过期后由用户本人完成登录；现有同包名应用已定位。推送服务当前可见立即开通，尚未开通；我未同意或提交任何服务协议。已请求用户本人审阅并按选择开通。"
    evidence: "用户登录完成回复；iframe可见按钮/标签核对；push-service-agreement.png实际为开通介绍页截图，不是已签协议"
  - fact: "官方现行文档提供设备调测名单：按本应用PushToken登记，添加设备不做本地构建实况窗权限校验，最多24小时生效、有效期随Token。故Profile缺entry并不能单独排除官方设备名单联调路径。"
    evidence: "Cua读取doccenter-capabilities/liveview-joint-commission-test全文；新Profile路径与调测名单分别记录"
  - fact: "标准实况窗服务权益须场景/方案附件申请，文档称3工作日内结果，通过后重生成Profile；正式权益还需实际联调截图和验收，不将本次设计预览当正式验收。"
    evidence: "liveview-rights及2026-10-30更新的liveview-formal-authority"
  - fact: "已准备TIMER说明及2200×1670/284373bytes方案PNG，明确设计预览非真机截图；只通用标题和剩余时间，含运行/暂停/番茄休息、三触点、结束清理及跨阶段待验边界。尚未取得、上传PushToken，方案未上传，申请未提交。"
    evidence: "build/qa/harmony-live-20261031/TIMER-application-draft.md、proposal-readiness.json及方案PNG已目视核对"
changed_files:
  - path: "docs/development/鸿蒙专注提醒权益接入.md"
    change: "补当前设备/账号前置与官方名单联调路径，区分正式权益和设计附件"
  - path: "docs/planning/Innocence-鸿蒙平板版本实施规划.md"
    change: "追加0143实际进度与未完成门禁"
  - path: "progress/0000__AI-RESUME.md"
    change: "0143当前状态/新路径与等待用户服务协议决策"
  - path: "progress/INDEX.md"
    change: "追加0143"
  - path: "progress/0143__20261031__P01__CORRECTION__harmony-liveview-device-trial-preparation.md"
    change: "本次窄范围证据与联调前提补充，不改历史检查点"
evidence:
  - command: "Python inspect_harmony_live_device.py及--open"
    result: "1设备/API26/1.3.0+12/非Debug；解锁后启动成功、running=true；设备Profile匹配true/liveView entry false。初次PNG路径及Windows绝对接收路径失败，改JPEG和私有目录相对接收成功；未输出原始UDID"
  - command: "Cua华为应用/推送页只读检查；官方liveview-rights/joint-commission-test/formal-authority"
    result: "定位现有APP ID及项目；推送未开通，待用户协议决策；3工作日标准权益与24小时调测名单分别确认，未提交/开通/发邮件"
  - command: "Python build_timer_proposal.py及view_image"
    result: "284373bytes/<3MiB，设计预览标注/布局与文案目视核对；附件及草稿只在F盘忽略目录，未上传"
  - command: "Java21/SnakeYAML2.5 VerifyHarmonyLiveDocuments.java；git diff --check"
    result: "exit0/PASS：5文档严格UTF8字节回转、4无重复键YAML、0143/0144指针、INDEX升序/路径及changed_files；diff --check通过"
compatibility_and_security:
  contract_impact: "none；未改业务/原生/Flutter源码，未构建或安装新包"
  tenant_impact: "调试工具未提取业务SQLite或创建合成真实业务记录；现有应用与资料保持"
  sensitive_data: "首次hdc列表在工具输出含连接序列号，此后改内存选择并仅输出摘要；未输出UDID/Token/密码/ClientSecret，未写入Git。应用详情只读导航不整页输出；设备图/申请材料只留F盘，未执行服务器管理或GitHub远端操作"
risks_or_blockers:
  - "当前等待用户本人审阅华为推送服务协议并按选择完成开通；不能代替用户接受新法律协议"
  - "本应用PushToken尚未获取，设备未加调测名单，TIMER开发/正式权益未申请；实际卡片和胶囊逐秒显示尚未验证"
  - "名单加入后可能需24小时生效，Token变化需按实际失效重核；标准权益申请有审核，不能承诺立即获批"
  - "最后一次只读按钮状态/滚动组合调用超时并重置浏览器会话，未重试滚动或点击开通；不据此推断服务状态变化。下一次先重新观察，勿重复开通或代签协议"
  - "后台番茄跨阶段接力、到点代理权益及H5/G01仍待；业务认证/租户/缺字段等负向本轮未执行"
next_actions:
  - id: NEXT-HARMONY-LIVE-TOKEN-TRIAL
    action: "接用户开通推送服务的回复，先只读核对真实开通状态。按官方SDK配置本应用client_id并获取PushToken，标识仅留F盘私有，不输出日志。应用信息页含ClientSecret，必须精确读取Client ID字段，不整页输出。优先核对实况窗调测设备管理；具体单设备Token/应用/范围可审阅后按操作时确认提交。若需更新Profile沿原证书/同AppID保资料。登记后按真实生效状态验通知卡片/胶囊/暂停继续/结束，不能绕系统校验或伪造Profile，不重问解锁/登录/一般开发授权"
    inputs: ["docs/development/鸿蒙专注提醒权益接入.md", "client/flutter_app/build/qa/harmony-live-20261031/device-inspection.json", "client/flutter_app/build/qa/harmony-live-20261031/TIMER-application-draft.md", "client/flutter_app/build/qa/harmony-live-20261031/official-reference-links.json"]
---
