---
schema_version: 1
document_type: development_notes
project_name: Innocence
updated_at: "2026-10-04"
decision: "DEC-0051 / 0092；DEC-0052 / 0093"
status: byok_chat_discovery_implemented_fixture_verified_live_provider_and_device_pending
scope: "本机聊天助手开发构建；未发布新版本"
---

# AI对话助手配置与验收

用户要求类似Codex Chat的内置对话框，自行接入API Key，用自然语言规划并操作Innocence。当前主入口已经改为多轮聊天，原三候选页面从“本地排程”进入。模型连接由客户端直接发往用户指定的服务；本机资料和登录账号各自保存配置及聊天记录。

## 使用步骤

1. 打开新版Windows窗口，进入本机资料或登录账号，在工具区点击“智能助手”；首页和计划页的助手入口也会打开聊天页。
2. 点击右上角“模型设置”，填写**服务地址**和自己的**API Key**。DeepSeek官方服务可直接填`https://api.deepseek.com`；OpenAI可填`https://api.openai.com`或`https://api.openai.com/v1`。密钥默认隐藏，不要把密钥发送到聊天或保存进代码。
3. 点击“获取可用模型”，软件向该服务查询模型列表，显示服务实际返回的模型名称和标识；从下拉框选择。只有一个模型时自动选择，多个时由用户选择；不需要记模型名。可刷新列表。
4. 点击“保存并连接”。软件用一次简短、不带软件工具或业务资料的请求验证所选模型与协议；协议不兼容时会有限回退。成功后才按当前身份加密保存最终配置；失败保留原连接，输入仍在对话框中。再次打开时密钥留空可复用同一服务域名的已存密钥；换域名须重新填写。“移除已保存连接”删除当前身份配置。
5. 选择“聊天”进行普通多轮对话，或选择“操控软件”让模型按需读取当前资料并调用已接入的工具。软件变更会展示具体任务/内容及确认按钮，点击确认后才执行。

地址必须使用HTTPS；本机模型可使用localhost、127.0.0.1或::1的HTTP地址。支持根地址、`/v1`、自定义API前缀，以及旧配置中的完整`/chat/completions`、`/responses`或`/models`路径；查询模型时只在同一服务origin尝试有限路径，不跟随重定向。

若服务没有兼容的`/models`接口，可展开“高级设置”，按服务商说明手动填写模型名并选择自动/Chat Completions/Responses，再点击“保存并连接”。列表出现某个模型只代表服务返回了该标识，不能保证密钥有调用权限或模型支持软件工具；余额、限额和工具能力仍须核对。当前不支持Claude Messages、Gemini原生协议或自定义鉴权头。

DeepSeek名称以获取到的列表为准，截图中填写的`deepseek`并非已验证的模型标识。关闭代理时无法连接、开启后HTTP400说明错误从网络层变成了服务请求层；模型发现可以减少模型名/路径填写错误，但不能替代有效网络、密钥权限或余额。依据：[DeepSeek模型列表](https://api-docs.deepseek.com/api/list-models/)、[OpenAI API认证与模型列表](https://developers.openai.com/api/reference/overview)。本轮没有读取或调用用户的真实密钥。

函数调用在Chat Completions和Responses中的字段与结果回传不同，适配器分别处理。Responses使用`store:false`，在当前会话中保留完整output项（包括推理项、消息与函数调用），并按call_id回传函数结果；恢复聊天时只加载可见对话及操作记录，不自动重放旧函数。协议依据：[OpenAI函数调用文档](https://developers.openai.com/api/docs/guides/function-calling)、[推理模型无状态上下文说明](https://developers.openai.com/api/docs/guides/reasoning)。使用哪个协议和模型，以服务商对该模型的支持为准。

DeepSeek Chat工具对话所需的`reasoning_content`只在当前模型上下文内回传，不显示或存进聊天历史；恢复的可见历史缺少该字段时，对DeepSeek官方Chat工具请求显式关闭思考模式，避免缺字段400。实际供应商行为仍待核验；依据：[DeepSeek思考模式](https://api-docs.deepseek.com/guides/thinking_mode/)。

可直接输入这样的请求：

- “查看明天已有安排，帮我加一小时英语和一小时数学，保留原任务，先展示具体时间。”
- “把这次计划讨论的结论保存成一条备忘录。”
- “新建今年10到12月的英语年度目标，分成阅读和听力两个子任务。”
- “开始25分钟专注，任务叫英语阅读。”
- “切换成液态玻璃主题。”
- “打开月计划所在的计划页。”

日任务仍使用30分钟网格。45分钟或跨午夜等不符合现有日计划语义的请求需要先说明并澄清，不能静默舍入；工具不会自动推断任务完成、修改年度进度或代签到。

## 当前软件工具

| 工具 | 实际接入 | 执行方式 |
|---|---|---|
| read_software | 日/月/年计划、任务存档、备忘录、专注、统计、设置摘要；通知和陪伴只返回数量/状态摘要 | 当前身份按需读取 |
| add_day_tasks | 明确日期的稳定新增；保留原任务ID、完成状态及实际时长 | 展示任务及执行ID，确认后走原校验/事务/幂等链路 |
| query_plan_execution | 按原执行ID查真实提交/拒绝/撤销结果 | 只查询，结果不明时不重新新增 |
| undo_plan_execution | 撤销指定助手新增 | 先确认；修订或专注已变化时拒绝 |
| save_task_archive | 将指定日计划保存为存档 | 先确认，再核对当前日修订 |
| create_memo | 新增本人备忘录 | 先确认，核对实际保存结果 |
| update_memo | 修改本人备忘录标题和正文，保留检查项 | 先确认，核对原内容未变化 |
| delete_memo | 删除指定本人备忘录 | 先确认，核对原内容未变化 |
| save_annual_task | 新增或修改年度任务；新任务可含独立子任务 | 先确认，保留现有进度；读取失败或修订变化则拒绝 |
| delete_annual_task | 删除指定年度任务 | 先确认并核对当前修订 |
| control_focus | 开始、暂停/继续、结束专注 | 先确认并核对实际专注状态 |
| open_page | 首页/计划/专注/陪伴/收件箱/统计/备忘录/设置 | 切到目标页面，对话留在当前身份中，可再次进入 |
| change_theme | Windows四主题；Android简约白色/液态玻璃 | 先确认，调用现有主题控制器 |
| change_language | 中文或英文 | 先确认，调用现有语言控制器 |

当前工具覆盖常用计划和学习操作。原日任务编辑/删除/重排、存档批量套用、已有年度任务的子任务编辑尚未接入聊天；这些操作继续通过原页面完成。账号安全、隐私、管理员操作、好友/团队消息发送、自动签到和任意电脑命令没有开放给模型。第16模块的全部批次及原项目门禁尚未验收通过。

## 本机配置与执行边界

- Windows使用当前系统用户的DPAPI；Android使用Keystore中的AES-GCM密钥和随机IV。完整连接配置先经原生通道加密再存入SharedPreferences，原生加密不可用时拒绝保存，没有明文兜底。密钥不进入Innocence业务API、数据库、同步、Git、日志或聊天；请求模型时只作为Authorization头。
- 聊天记录按当前账号/本机owner分区，保存最近120条可见记录，**聊天正文未加密**。切换身份会清空当前内存、停止请求和取消待确认动作，重新进入时读取该身份自己的历史。配置和历史不参与同步；注销账号会清除该身份的助手配置及历史。
- “操控软件”模式会向用户指定的模型服务发送对话和工具按需读取的当前资料；“聊天”模式不提供软件工具。工具不接受owner字段、任意路由、SQL、文件路径或Shell命令，模型输出须通过严格字段及业务规则校验。
- 当前采用整段回复，不是流式逐字显示。连接超时10秒、单次请求总时限60秒、响应上限2MB、每次用户消息最多8轮模型/工具交互；不跟随重定向或自动重试写入。停止会取消尚未开始的动作，已提交变更仍以操作记录和业务结果为准。
- 获取模型总时限25秒、上限1000个模型；地址/密钥改变立即使旧列表失效。取消或身份变化会丢弃旧结果，不在新身份中保存连接。401/403/402/429及网络错误立即停止，不猜模型或改换供应商。
- 单轮中重复的相同写工具载荷复用原结果，避免再次确认和重复写入。确认后、执行前先保存“执行结果待核对”记录；日计划记录包含固定执行ID，超时或中止后使用该ID查询，不能把未知结果报成成功。
- 已发布v1.2.2+7 Android APK仍是无INTERNET的本机离线包。本轮Android仅编译`INNOCENCE_OFFLINE_ONLY=false`的Debug联网开发包，未安装、替换发行签名或发布。Windows新版为本机开发构建，未生成新版安装器/便携发行包或上传远端。

## 0093模型发现与简化配置验收证据

| 命令/检查 | 实际结果 | 证据与限制 |
|---|---|---|
| flutter analyze --no-pub | exit 0，No issues found，5.4秒 | `client/flutter_app/build/discovery-analyze.log` |
| flutter test --no-pub | exit 0，168项通过，18秒 | `build/discovery-full-test.log`；前153项+15项模型发现/配置/安全回归 |
| flutter build windows --release --no-pub | exit 0，30.8秒 | `build/discovery-windows-build.log`；最终Dart改动已编入 |
| Gradle assembleDebug，非增量/in-process，offlineOnly=false | BUILD SUCCESSFUL，12秒 | `build/discovery-android-build.log`；联网Debug仅编译，未安装 |
| 玻璃320/白色1280、字体1.5、键盘280设置页 | 两项布局及模型选择回归通过 | `build/qa/discovery/`宿主PNG目视核对，无布局异常；不替代原生设备验收 |
| 按绝对exe路径替换开发窗口，Start-Process并复核 | PID12676，2026-10-04T22:13:14+08:00，Innocence窗口有响应 | `build/discovery-runtime-launch.json`及`discovery-runtime-review.json`；不证明实际供应商或页面操作已验收 |

模型发现使用真实loopback GET与POST：根路径404→同origin/v1、Bearer头与无请求体、真实id顺序/去重、空列表与缺id立即拒绝、Chat协议400→Responses成功、手动协议保持、401/403/402/429/重定向/500无错误回退、取消与切身份不保存、连接失败保留旧配置、离线发行在联网前拒绝。普通聊天收到未提供的工具调用也会拒绝执行。更换地址/密钥后旧模型选择失效，换域名不复用原密钥。

五类负向路径：authentication_failure（401/403）、tenant_mismatch（延迟发现时换身份）、permission_denied（离线版本及普通聊天工具拒绝）、missing_field（模型缺id）、generation_failure（无效/空列表或连接失败）。所有供应商请求用合成Key及loopback；未访问真实模型服务。此轮后端与原生加密代码没有改变，沿用0092对应证据，不重复宣布新的后端或设备验收。

开发产物SHA256：Windows runner `e97f66d4a8f46295510119f1383b64edd69f9df67993510160b4569d5c485120`，Dart `data/app.so` `5c21d85e5dca2dd729f27ab71e6c5d00c370c4a822f6561baf295dc051a845d2`，Android Debug `c6f0baa2d18381ed1ffdde516b3dc3d2d0a1211fa72ce7ee7dc9ff1303c0193f`。Debug APK package仍为1.2.2/code7、min24/target36、三ABI，具有INTERNET权限；它与已正式发布的无INTERNET签名APK不同，不作为新的发行资产。

## 0092聊天与工具实现的既有证据

| 命令/检查 | 实际结果 | 证据与限制 |
|---|---|---|
| flutter analyze --no-pub | exit 0，No issues found，6.2秒 | `client/flutter_app/build/chat-analyze.log` |
| flutter test --no-pub | exit 0，153项通过 | `client/flutter_app/build/chat-full-test.log`；原131项+22项聊天/工具/布局回归 |
| Maven test（Java21、本机MySQL合成事务） | exit 0，17套/73项，failure=0、error=0 | `server/innocence-server/target/surefire-reports/`；原69项+4项客户端提案/边界回归 |
| Maven -DskipTests package | exit 0 | `target/chat-package.log`；没有启动或部署后端 |
| MSVC编译并运行assistant_crypto_test.cpp | 4项通过 | 共享生产DPAPI函数的实际原生往返/密文不同/篡改拒绝/空输入拒绝；Android加密仍仅编译 |
| flutter build windows --release --no-pub | exit 0，32.7秒 | `build/chat-windows-build.log`；最终改动已编入Dart产物 |
| Gradle assembleDebug，非增量/in-process，offlineOnly=false | BUILD SUCCESSFUL，12秒 | `build/chat-android-build.log`；未做设备安装或Keystore运行验收 |
| 两主题×320/820/1280、大字体1.5、键盘280布局 | 6项布局回归通过 | `build/qa/chat/`六张合成对话PNG；白色1280和玻璃320目视核对，宿主图片不替代原生设备验收 |

五类负向路径已分别覆盖：无有效凭据/模型权限（401/403）、身份切换及跨owner访问、未开放工具与越权参数、缺字段/类型错误、无效或未完成模型响应。还覆盖停止待确认/停用已准备动作、重复写抑制、确认期间日修订变化、年度读取失败拒绝旧缓存。协议测试使用真实loopback HTTP；业务测试使用隔离SQLite及本机MySQL合成数据，没有向真实账号写入验收任务。

0092曾按用户“编译好后启动新版，替换旧窗口”授权启动PID19476（`build/chat-runtime-launch.json`），现已由0093的PID12676替换。进程与窗口证据只证明启动子集，不证明真实模型、原生聊天页面或全部软件动作已验收。

仍待用户配置真实服务后核对：连接/生成质量、所选模型函数调用、实际费用与限额、完整登录HTTP/同步、Android Keystore设备往返、实体手机与Windows多DPI/四主题运行矩阵。本轮不将这些待验项目写成完成。

实现入口：`lib/features/assistant/presentation/assistant_chat_page.dart`、`application/chat_controller.dart`、`application/assistant_app_tools.dart`、`data/chat_provider.dart`、`data/chat_discovery.dart`、`data/chat_repository.dart`。模型发现见B专档第13节；线上客户端提案契约UAI-07与后端实现见第12节、`AssistantModels.ClientProposalRequest`、`AssistantService.clientProposal`、`AssistantController`；原日计划事务/撤销链路继续沿用0091。
