---
schema_version: 1
document_type: platform_implementation_plan
project_name: Innocence
platform: HarmonyOS_tablet
created_at: "2026-10-05"
updated_at: "2026-11-03"
status: v133_public_and_self_use_backend_live_timer_evidence_pending
authority: "用户要求鸿蒙平板全屏复用PC页面，已明确开始制作及联网"
target_device: "LRT-W20 / HarmonyOS7 / API26 / aarch64，实际已核对；不推测市场年款"
related_checkpoint: "0152"
related_gate: "P01/G01及HarmonyOS H0-H5；未封闭完整门禁"
history_archive: docs/archive/Innocence-鸿蒙平板版本实施规划-20261101.md
---

# Innocence 鸿蒙平板版本实施规划

本页保留现行范围、阶段和待验。逐次工具安装/构建/模拟器/发布过程已[原样归档](../archive/Innocence-鸿蒙平板版本实施规划-20261101.md)，完整证据按[检查点索引](../../progress/INDEX.md)定位。

## 当前交付与下一步

0152：三端1.3.3已按用户指令公开；鸿蒙仍仅未签名HAP/说明/校验和，个人设备包不公开。源码双标签固定同一提交，构建/签名边界与远端摘要/公开下载核对见本轮检查点，完整实体/权益门禁不因发行关闭。

0150：用户连接原平板并授权直接更新，1.3.3+15个人原签名ARM64联网Release已覆盖安装启动；签名/应用标识/UID/首次安装时间一致，已有登录资料与旧助手对话恢复可见。三个主题的原创Innocence字标有实际2800×1840画面；每日文案退为次要层级。0148学习入账及0149请求追踪后端完成备份/隔离恢复后部署，线上合成账号最小年度创建、幂等入账和认证/权限/跨租户负向通过并清理。个人包不公开，完整升级保资料、长时计时/后台/权益、真实模型及完整H5仍未因此关闭，范围见[1.3.3个人更新](../releases/v1.3.3-harmonyos-self-use.md)。

当前公开包为 **1.3.3+15 ARM64 Release/AOT联网HAP**（0152），公开包未签名；本人原证书/有效单设备Profile的私有Release在LRT-W20已安装启动、PC画面核对（0133），不公开个人包。横竖屏自动重排保留，竖屏有用户确认。共享源码与插件/原生HUKS/重启解密/TLS、真实HTTPS/独立tablet槽位已有子集证据；不能代替完整实体业务、恢复和性能。

**TIMER开发调测申请由用户提交，当前审核中（0145）。** 预计11月4日前后反馈只是按3工作日估算。查看入口、申请范围、附件、Profile/名单路径和后续验证集中在[鸿蒙专注提醒权益接入](../development/鸿蒙专注提醒权益接入.md)，本计划不重复追加申请流水。当前没有实况窗新授权/Token名单生效证据；卡片和胶囊实体逐秒变化、代理提醒和后台跨阶段仍待。

## 已确认的产品与技术边界

- 用户原始目标：“页面布局完全使用pc版……不需要做到窗口尺寸调整，因为本身就是全屏打开的”；后续已明确开始制作、支持竖屏并启用三端联网。
- 平板使用PC导航及首页、日/月/年计划、专注/独立番茄、统计、备忘录、陪伴、收件箱、设置和助手；不进入Android手机Shell，不显示Windows窗口控件/托盘/拖边/Focus Orb。
- 横竖屏按实际内容宽度重排与滚动，不能整体缩小页面。处理安全区、系统字号、软键盘与触控命中；键盘出现时保留页面/草稿，不切换为Windows Small Canvas。
- 共用业务逻辑、SQLite/outbox/ownerScope、原专注计时真源和四主题存储语义。计划按日/月/年，独立番茄不依附总专注；主题提示词权威仍在UI设计规划。
- 0132契约已确认真实`harmonyos`设备身份与`tablet`独立名额，可与Android手机/Windows电脑同时在线，同类新登录仅替换同类；不得伪装Windows。在线/离线显式构建，正式联网使用生产HTTPS而非本机回环地址。
- 本机资料独立，登录导入需预览和目标账号确认；头像/文件、助手按owner原生安全存储，无明文兜底。BYOK助手/14工具及未接工具范围沿原契约，不扩展C持续规则。
- 工具链/SDK/镜像/缓存/签名材料放F盘；Windows/Android工具链保持独立。标准Flutter不直接等于支持HAP，沿仓库鸿蒙适配与已锁定插件构建。

## 阶段与完成边界

| 阶段 | 已有证据 | 仍需完成 |
|---|---|---|
| H0 工具链与启动 | 官方DevEco26/API26、Flutter OH3.41.10-ohos-1.0.1/Dart3.11.5；原生/共享编译和实体安装启动 | 后续升级继续核对所选引擎/插件组合，不因版本填值认定兼容 |
| H1 全屏PC Shell | 模拟器PC四主题、实体PC页面和自动横竖屏子集 | 完整页面/安全区/系统字号/键盘/返回与草稿连续性 |
| H2 离线与身份 | SQLite原生适配/初始库、共享schema与独立番茄持久化；子集升级证据 | 实体完整业务恢复/迁移、owner切换/导入与冲突矩阵 |
| H3 全页面与触控 | 共用PC功能、四主题及字体/光场修正已进入公开包 | 长表单、手势范围/年度进度、软键盘、返回、大字号、真实内容与持续性能 |
| H4 联网与助手 | 生产HTTPS、真实设备身份/tablet独立槽位、HUKS/TLS/重启子集 | 完整同步/负向、文件选择/头像、真实BYOK模型与工具/费用/设备矩阵 |
| H5 真机与发行 | 用户验收旧设备预览、GitHub公开未签名AOT、本机私有Release覆盖启动 | 完整升级保资料/冷启动/输入/锁屏/进程重建/耗电/玻璃性能；TIMER与代理提醒授权和实机效果 |

## 维护入口与验证矩阵

| 范围 | 入口／验收要求 |
|---|---|
| 构建与安装 | `client/flutter_app/tool/harmonyos.ps1`；[工程说明](../../client/flutter_app/harmonyos/README.md)、[安装边界](../../client/flutter_app/harmonyos/INSTALL.zh-CN.md) |
| 宿主/安全存储 | `client/flutter_app/ohos/entry/src/main/ets/entryability/`；原生桥、HUKS与权限按实际SDK核对 |
| PC呈现策略 | `core/layout/desktop_presentation.dart`、`core/widgets/adaptive_canvas_shell.dart`；不调用Windows专属能力 |
| 用户输入与视觉 | 触控/键鼠/返回、中英文/大字体/输入法、四主题、弹层、横竖屏；宿主图/Android模拟器不能代替鸿蒙真机 |
| 计时与系统能力 | 两处实际递减、暂停继续/结束/身份清理、后台/锁屏/进程恢复、双计时和跨阶段分别验证；代理提醒独立验证 |
| 认证失败 authentication_failure | 错误/过期会话、重登/退出，不泄露缓存和凭据 |
| 租户不匹配 tenant_mismatch | owner变化/错目标账号/其他用户资源拒绝，取消过期待执行工具 |
| 权限拒绝 permission_denied | 文件/系统能力拒绝、非管理员访问，明确失败与降级 |
| 缺失字段 missing_field | 空标题/无效日期范围/无模型id/无效设备类型，禁止静默改语义 |
| 生成失败 generation_failure | 模型断网/超时/取消/不支持工具/无效提案，不写计划或保存失败连接 |

验收每项记录命令、结果、changed_files及设备环境。保原身份与签名，不卸载/清数据，不在真实账号创建合成记录；私钥/Profile/Token/UDID不进Git或公开资产。HAP的Release构建或签名不等于GitHub下载后原生点文件直装；临时网页入口授权已到期，不自动续期。新发行或远端修改按当次实际授权执行，P01/G01及完整H5继续开放。
