---
schema_version: 1
document_type: development_notes
project_name: Innocence
updated_at: "2026-10-04"
status: historical_b1_planner_secondary_entry
---

# AI助手本机开发与验收

> 0092已按用户修正将主入口改为自填API Key的多轮聊天助手。本文保留0091的本地排程/服务端生成开发说明，该页面现从聊天页“本地排程”进入；当前配置、14项软件工具和验收边界见[AI对话助手配置与验收](AI对话助手配置与验收.md)。本文服务端环境变量不再是聊天主入口的必需配置。

本文件对应B1首批实现与检查点0091。普通请求生成保守、平衡、紧凑三套候选，编辑并校验后应用；固定直接新增指令在程序确认内容、日期与时段完全匹配后保存。仅新增日计划任务，不自动完成任务、提交签到或修改年度进度。

## 使用入口

- Windows：工具区“智能助手”，以及首页、计划页“规划一天”快捷入口。大画布并排展示；中画布详情抽屉；小画布独立详情页。
- Android：三点侧栏工具项“智能助手”，首页与计划页快捷入口；保持五个主入口。详情独立页，输入动作固定在键盘上方。
- 本机资料：规则排程示例为`英语 60分钟；数学 90分钟`或`English 60 min; Maths 90 min`，设置明确日期与可用时段。容量不足逐项说明，不舍入45分钟。
- 直接新增：`直接新增 2026-10-04 23:00-24:00 英语，保留已有任务`。示例日期使用时须替换为今天或未来30天。固定时段下三候选一致；冲突时不写入，生成失败也不保存旧候选。
- 在线账号：自然语言规划经服务端模型适配器处理。云端修订与本机修订各自维护，不能把一个账号的云端快照直接作为离线资料执行。

## 模型配置

默认关闭云端模型。服务端读取以下环境变量；客户端、Git、样本及日志不保存模型密钥。

| 环境变量 | 作用 |
|---|---|
| INNOCENCE_ASSISTANT_ENABLED | 配置完成后设为true |
| INNOCENCE_ASSISTANT_ENDPOINT | 完整HTTPS Chat Completions端点；本机协议夹具允许loopback HTTP |
| INNOCENCE_ASSISTANT_MODEL | 供应商提供且支持JSON模式的模型名；没有预设供应商或模型 |
| INNOCENCE_ASSISTANT_API_KEY | 通过服务器环境配置的凭据；不要写入配置文件或聊天 |

适配器发送`response_format={type:json_object}`和`max_completion_tokens=4096`，并独立验证所有业务字段。不同兼容服务的参数支持须在选定服务后实际回放。模型15秒超时，客户端25秒超时；响应不完整、拒绝、无效JSON、429与配置缺失均显式失败。明确非网格时长先由时间规则提出澄清。

实现参考[OpenAI Structured Outputs官方说明](https://developers.openai.com/api/docs/guides/structured-outputs)：JSON模式只保证格式，仍需程序校验字段、完整性和业务值。本轮使用[OpenAI Docs技能](C:/Users/HP/.codex/skills/.system/openai-docs/SKILL.md)核对协议，不指定默认模型，不据此宣称兼容任意供应商。

## 存储、事务与身份

后端`assistant_document`按(user_id,kind,document_id)隔离四种强类型记录；`daily_plan_revision`按账号和日期记录单调修订。旧手动保存、模板套用与同步导入走同一StudyPlanService写入口；空日期删除也推进修订。助手新增保留原任务ID、完成和实际学习时长。

SQLite数据库由5升级至6，新增`local_day_revision`与`local_assistant_document`。执行先登记prepared；任务、修订、committed记录和原daily_plan outbox在同一事务写入；异常回滚后记rejected。撤销只删除本次新增且未变化的条目。重复操作必须使用相同operationId；异载荷冲突，结果不明先查询。恢复文档保存草稿、提案与待确认ID，不存会话token；退出/换身份撤销未执行直接意图。

专注目前仅有taskName，无法精确绑定计划条目。因此开始专注会保守地取消该身份下旧助手执行的撤销资格，并推进专注当日修订；结束专注不恢复撤销资格。未来绑定稳定任务ID后可缩小保护范围。

未应用正文保留7天；执行30天后清除正文并保留最低幂等记录，超期ID返回410。后端每小时清理，本机在助手活动时清理。注销账号清除该身份助手内容。模型调用不在保存事务内；HTTP成功前不把本机结果当成云端同步成功。独立偏好页和完整执行历史列表尚未实施，归入后续批次。

## 验证命令与证据边界

在`server/innocence-server`执行：

```powershell
& 'D:\homework\apache-maven-3.9.9\bin\mvn.cmd' -q test
```

69项全量用例中21项为新助手专项：12项MySQL服务/业务值、6项控制器与字段/身份负向、3项本机HTTP模型协议。MySQL夹具使用合成用户，所有写入随测试事务回滚。HTTP夹具验证协议解析/拒绝/截断/配额，不能作为真实模型生成质量证据。

在`client/flutter_app`执行：

```powershell
& 'D:\soft\flutter\bin\flutter.bat' analyze --no-pub
& 'D:\soft\flutter\bin\flutter.bat' test --no-pub
& 'D:\soft\flutter\bin\flutter.bat' build windows --release --no-pub
& 'D:\soft\flutter\bin\flutter.bat' build apk --debug --no-pub --dart-define=INNOCENCE_OFFLINE_ONLY=true
```

Flutter全量131项，其中23项助手专项，覆盖SQLite真实事务失败回滚/outbox/稳定ID/冷启动/v5升级、直接新增和撤销冲突、身份切换、丢失响应后的同ID恢复，以及两主题320/820/1280宽、1.5倍文字/键盘和跨画布草稿保留。宿主布局图在`client/flutter_app/build/qa/assistant/`；本机QA字体仅供检查，不进入应用资产。

Windows构建成功。Android首次常规构建遇到C盘Pub缓存与F盘工程的Kotlin增量缓存跨根错误；恢复方式是在`client/flutter_app/android`执行以下一次性构建参数，不改项目发布设置：

```powershell
.\gradlew.bat assembleDebug '-Pkotlin.incremental=false' '-Pkotlin.compiler.execution.strategy=in-process' '-Pdart-defines=SU5OT0NFTkNFX09GRkxJTkVfT05MWT10cnVl'
```

最后一个参数是`INNOCENCE_OFFLINE_ONLY=true`的Base64表示。Debug开发包仍包含Flutter调试用INTERNET声明，应用的offlineOnly网络保护有效；它不能替代无INTERNET且沿用正式证书的已发布v1.2.2离线包。本轮没有替换正式资产或扩大正式联网范围。

尚待证据：真实供应商生成质量/费用与拒绝路径、带真实登录会话的完整六端点HTTP链路、跨端同步/长期恢复、Windows全DPI视觉矩阵和Android实体设备/OEM/Vulkan。B2月历存档/重排、B3独立年度拆解未实施；P01/G01和Android A0–A5保持各自待验状态。
