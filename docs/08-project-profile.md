---
schema_version: 1
document_type: project_profile
project_name: "Innocence"
project_type: "other（双端自有产品：Flutter 手机端 + 桌面端 + Spring Boot 后端）"
data_owner: "Innocence 自有数据；用户数据归用户，由 Innocence 服务托管"
authorization_boundary: "服务端用户数据以登录用户为边界；未登录离线数据以本机 ownerScope 为边界，未经用户确认不得绑定或上传；陌生人不可私信/看资料；仅队友可见学习数据；后台管理权限仅限内容治理与账号治理"
default_invariants:
  - id: STANDALONE-FIRST
    enabled: disabled
    rationale: "自有产品无宿主系统，不适用"
  - id: UPSTREAM-OWNS-DATA
    enabled: disabled
    rationale: "数据全部自有，无上游系统"
  - id: TENANT-ISOLATION
    enabled: enabled
    rationale: "所有业务查询/写入必须绑定当前登录用户（userId），黑名单/好友/团队关系构成访问边界"
  - id: CONTRACT-BEFORE-CLIENT
    enabled: enabled
    rationale: "接口清单草案已固化统一约定与字段，前端实现以草案为准；UI 重建不回改接口"
  - id: EXACT-OUTPUT
    enabled: disabled
    rationale: "无外部字节级输出要求"
  - id: NO-SECRET-COPY
    enabled: enabled
    rationale: "邮件密码经 INNOCENCE_MAIL_PASSWORD 环境变量注入（application-local-secret.yml 不进仓库）"
  - id: NO-SILENT-NORMALIZATION
    enabled: enabled
    rationale: "业务规则差异（如签到判定口径）必须以 DECISION 记录，禁止静默改规则"
project_specific_rules:
  - id: RULE-001
    enabled: true
    rule: "git commit 消息使用中文"
    verification: "提交历史语言检查"
  - id: RULE-002
    enabled: true
    rule: "前端 UI 推翻重建：页面布局与观感全部重新设计，不沿用旧布局；功能逻辑与数据层保留"
    verification: "页面重建对照 docs/planning/Innocence-UI设计规划.md 验收"
  - id: RULE-003
    enabled: true
    rule: "Windows 四个主题并存可切换：主题不改变业务结构；2026-09-29 用户要求 Android 立即接入简约白色与液态玻璃，两主题沿用移动端独立布局与 Material 3 交互基础"
    verification: "Windows 与 Android 设置中切换两主题即时生效；Android 手机布局、触控、对比度、动画与真机单独验收"
  - id: RULE-004
    enabled: true
    rule: "用户提供的主题提示词必须原文存档到 docs/planning/Innocence-UI设计规划.md，后续生成以存档为准"
    verification: "存档章节存在且含提示词原文"
  - id: RULE-005
    enabled: true
    rule: "1 台手机 + 1 台电脑同时在线；超出时拒绝新设备或替换旧会话"
    verification: "会话策略验收（G01）"
  - id: RULE-006
    enabled: true
    rule: "桌面端支持未登录离线资料与已登录断网缓存两个隔离数据域；业务数据先写本地，登录后先预览目标账号并由用户确认导入；冲突按实体类型处理，禁止用统一最后修改覆盖所有数据"
    verification: "离线入口、本地持久化、ownerScope 隔离、幂等补传、导入确认与冲突矩阵验收（G01/G02）"
  - id: RULE-007
    enabled: true
    rule: "签到成功需同时满足手动点击与当天计划完成；学习时长不足条件仍保留"
    verification: "签到判定验收（G02）"
  - id: RULE-008
    enabled: true
    rule: "本地环境限制：Dart analyze 可能超时、Maven 依赖受限，验证策略以代码级校对 + 接口对齐为主，证据必须真实"
    verification: "检查点证据字段"
  - id: RULE-009
    enabled: true
    rule: "team 上限 5 人、一人一团队、队长专属移除/解散权限、解散后数据全删"
    verification: "团队规则验收（G03）"
  - id: RULE-010
    enabled: true
    rule: "Windows 端采用 Large/Medium/Small 自适应画布 + 用户主动 Focus Orb；首次按工作区约 84%×82% 居中进入适中 Large，之后恢复用户边界，不以小挂件启动；跨尺寸只重排布局，不重建业务状态"
    verification: "窗口尺寸矩阵、DPI、多屏、状态连续性与四主题验收（G05/G06）"
  - id: RULE-011
    enabled: true
    rule: "计划层级固定为短计划按日、长计划按月、超长计划按年；周视图仅作兼容辅助，日计划模板可批量套用到月历日期"
    verification: "日/月/年视图、模板批量套用、年度月区间拖动与跨月/跨年边界验收（G02）"
  - id: RULE-012
    enabled: true
    rule: "Windows 首页 Hero 按主题与本地日期稳定轮换；侘寂主题允许英文主标题；Android 首页保留移动信息架构并接入简约白色、液态玻璃主题视觉"
    verification: "Windows 四主题、双语、同日稳定、跨午夜切换与 Small Canvas 溢出验收（G02/G05）；Android 两主题首页另做触控与窄屏验收"
  - id: RULE-013
    enabled: true
    rule: "Windows 无框窗口缩放采用 Flutter 八方向透明命中层触发原生 sizing loop，并保留顶层 WM_NCHITTEST 作为补充；必须真实拖动后尺寸发生变化才算通过"
    verification: "Windows Release 在 100%/125%/150% DPI 下完成四边四角真实拖动、最大化与 Focus Orb 负向验收（G05/G06）"
  - id: RULE-014
    enabled: true
    rule: "Android 保留 Material Design 3 导航、表单与可访问性交互，但主题二简约白色和主题四液态玻璃立即覆盖全局令牌、入口、主 Shell 和业务页；仅开启 useMaterial3 或令牌接入不算页面验收"
    verification: "Android A0–A5 按两主题手机导航、组件状态、动态效果、可访问性及真机页面矩阵验收；Windows 四主题范围保持原样"
  - id: RULE-015
    enabled: true
    rule: "智能助手B由DEC-0051修正为BYOK多轮聊天主入口；DEC-0052简化为地址与密钥发现模型、选择后验证协议并加密保存，高级设置可手动配置。当前资料按需发送给指定模型，原排程为次级工具。白名单变更须经确定性校验/当前身份与具体确认；共享单日修订、幂等和带冲突检查的撤销必需；不包含C持续规则"
    verification: "按B专档各批验收；真实生成/负向/实际写入/重启/同步/双端证据齐全，方向确认不等于实现；Android现行离线发行和原门禁保持"
  - id: RULE-016
    enabled: true
    rule: "DEC-0054覆盖DEC-0053的柑橘视觉：简约白以最早minimalism.html为基准重建，黑白灰、直角/无阴影/无渐变，浅灰画布与实色白面板及清晰细边线区分；移除橙色阶梯并重建排版Hero。专注表盘仍读取原FocusSession，双端删标语标签/保留正文；Android保留MD3交互，四主题存储/年度业务七色/Focus Orb行为与业务语义不变"
    verification: "表盘tick/暂停/继续/正常及提前结束/重新开始、L/M/S和320dp大字体宿主回归；原生设备和多DPI另验，证据0094"
change_policy:
  source_of_truth: this_file
  rule_change_checkpoint: DECISION
  affected_documents_to_sync:
    - docs/01-product-scope.md
    - docs/03-execution-plan.md
    - docs/02-contract-and-compatibility-rules.md
    - docs/06-contract-inventory.md
    - docs/07-dataflow-and-module-map.md
    - docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md
    - docs/planning/Innocence-Windows自适应桌面体验.md
    - docs/planning/Innocence-Android版本实施规划.md
    - docs/planning/Innocence-UI设计规划.md
    - docs/planning/Innocence-AI智能助手B方案实施与契约.md
---

## 2026-10-07 v1.2.3正式发行（0105）

v1.2.3+8已公开（Release#404930678），Windows安装器/便携包及Android原证书离线APK和校验清单均可下载。188客户端（4配置跳过）/19离线/73后端/4 DPAPI与包结构摘要通过；API36正式v1.2.2覆盖COLD1742ms，合成备忘录三字段及数量保留。Windows BYOK为已实现但真实供应商待验功能；Android继续无INTERNET，鸿蒙只同步调试源码，输入/业务恢复/真机签名待。发行不关闭整体G01与设备/同步门禁。

# 项目画像说明

本文为 Innocence 项目特有规则的权威来源。产品细节以 `docs/planning/` 为详稿，治理规则以本文为准。

2026-10-05新增鸿蒙平板规划（0098），用户随后要求开始制作（0100）：Air系列/HarmonyOS 7全屏复用PC页面，不提供Windows窗口尺寸调整。实施专档为 `docs/planning/Innocence-鸿蒙平板版本实施规划.md`；0102已在F盘准备官方DevEco26/API26、四插件注册，并完成共享Dart/ArkTS/ARM64原生编译和未签名Debug HAP，CRC/摘要及元数据核对通过。用户已完成DevEco登录，真实调试签名仍需连接设备生成Profile；0104已在F盘API26/x64/MatePad Air12预设安装启动HAP，PC全屏/四主题/玻璃进程冷启动恢复及SQLite初始schema有证据；独立工具许可目录差异通过仅工具目录链接解决。当前小艺输入法首次协议/隐私页待用户，QA_NATIVE/QA_TASK草稿未保存；业务恢复/真实平板Profile签名和完整门禁仍待，H0-H5/G01整体未封板。首轮强制本机模式，Debug仍声明INTERNET权限；具体设备型号和会话槽位暂待核实，不能根据PC布局把设备归成Windows或静默扩大“一台手机 + 一台电脑”规则。既有Windows自适应与Android手机规则继续适用于各自平台。

关键参考文档：
- 产品规划：`docs/planning/Innocence-项目计划书.md`
- MVP 范围：`docs/planning/Innocence-MVP第一版功能范围.md`
- 智能助手B范围/内部模型/开发契约：`docs/planning/Innocence-AI智能助手B方案实施与契约.md`（DEC-0050/0090采用B，DEC-0051/0092修正为BYOK聊天助手，DEC-0052/0093简化为地址+Key发现模型及协议验证；14项工具接原业务，真实模型/完整HTTP/同步/设备仍待，月历批量重排及原任务编辑尚未接工具；原15模块封板记录保留）。配置见`docs/development/AI对话助手配置与验收.md`。
- 接口契约：`docs/planning/Innocence-接口清单草案.md`
- 数据库契约：`docs/planning/Innocence-数据库表结构草案.md`
- UI 规划与主题存档：`docs/planning/Innocence-UI设计规划.md`
- Windows 自适应体验：`docs/planning/Innocence-Windows自适应桌面体验.md`
- Windows 信息架构与组件接口：`docs/planning/Innocence-Windows信息架构与组件体系.md`（已确认）
- Android 版本实施规划：`docs/planning/Innocence-Android版本实施规划.md`（MD3交互基础/两主题/三点侧边栏；v1.2.2+7已正式发行，包含月计划与年度任务独立手机页，沿用原签名且API36从正式v1.2.1飞行模式升级/冷启动保留已有证据；实体设备/OEM/Vulkan、其他手机详情与真实联网导入仍待验收）
- 离线模式、主题标语、年月计划与窗口缩放：`docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md`（已实现主要链路；真实同步回放与完整 DPI 矩阵待验收）
