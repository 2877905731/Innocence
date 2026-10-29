# GitHub 下载的鸿蒙 HAP 如何安装

适用当前公开的 `v1.2.5-harmonyos.1` 平板本机版。GitHub 的
`Innocence-v1.2.5-harmonyos-arm64-release-unsigned.hap` 是 **ARM64 未签名开发分发包**，
不能在平板文件管理器里直接点击安装。`Release/AOT` 表示编译方式，不代表已经签名或上架。

## 已确认目标：仅给自己平板使用（2026-10-24）

用户确认“我想只给自己用”。本轮继续以自己平板上的安装和后续更新为目标，不安排正式公开上架，也不上传个人签名 HAP、Profile 或私钥到 GitHub；已有公开未签名资产保持原样。

账号状态：用户此前确认“已注册，实名认证还没完成”。2026-10-24 在用户准备的[华为开发者中心](https://developer.huawei.com/consumer/cn/)创建下述应用；2026-10-29 控制台主账号已显示“已认证”。没有代填或提交身份资料，也没有读取实名认证主体信息。

### 2026-10-24 控制台实际准备结果（0120）

| 字段 | 已核对值 |
| --- | --- |
| 应用名称／项目 | Innocence／Innocence |
| APP ID | `6917619921714239020` |
| 包名 | `com.innocence.tablet.innocence_flutter` |
| 类型／设备／语言 | HarmonyOS 应用／平板／简体中文 |
| 应用版本状态 | 准备提交 |

应用登记后仍未公开上架。0120 当时只核对到“指定设备发布”选项；后续证书及 Profile 已在用户具体确认后实际签发，见下方 0121。

0120 时仅有已过期调试证书，并准备了 `Innocence-self-use-release` 发布证书草稿。复用的 510 字节 CSR 自签名验证通过，公钥与原证书链中的签名证书一致，未创建或导出私钥。该 CSR 后续已获用户确认上传并用于实际签发；申请草稿不再是当前状态。

### 发布证书和指定设备 Profile 已签发（2026-10-29，0121）

- `Innocence-self-use-release` 发布证书已生效，有效至 `2029-10-24`。用户手动下载后提供 `.cer` 文件；保留原件并按字节复制到 F 盘私有目录。2910 字节证书文件含 3 张链证书，其中签名证书公钥与原 CSR、旧调试 Profile 的公钥一致。
- 用户确认“确认创建这份单设备 Profile”后，实际提交 `Innocence-self-use-tablet-release`；控制台显示“生效／指定设备发布”，有效至 `2027-04-29`，证书指纹已自动关联到当前应用。
- 用户手动下载 `.p7b` 后，4164 字节文件已复制到 F 盘 `build/harmonyos-h0/self-use/20261029/`。官方 `hap-sign-tool.jar verify-profile` 返回成功，结果中的 `verifiedPassed=true`。
- 完整设备 ID 集合在内存中与旧调试 Profile 精确比对，均为同一台设备。控制台将类型显示为“手机”；该显示不替代实际设备 ID 核对。没有输出或在仓库记录真实 UDID。
- 新 Profile 内嵌证书与下载证书链中的签名证书逐字节一致，包名、开发者标识、公钥及设备集合匹配旧配置；但 `app-identifier` 已变为当前登记的 APP ID，与旧调试 Profile 不同。该差异已明确保留，未篡改签名 Profile 来掩盖差异。

0121 完成发布签名材料准备，后续 0122 已完成本机签名构建和官方 HAP 验签；安装描述、HTTPS 入口及真实安装／覆盖验证仍待。旧调试版与 Release 的 `debug` 状态和应用标识须另外核对；官方文档指出 `app.json` 的 `debug` 不一致会导致 `9568336`，参见[安装时 debug 类型不一致](https://developer.huawei.com/consumer/cn/doc/harmonyos-faqs-V5/faqs-app-debugging-32-V5)。不通过卸载旧版来试错，也不把公钥相同当成资料保留已验证。

证书、Profile、含设备内容的 SDK 验证结果及后续个人签名包只保存在 F 盘忽略目录；未上传到 GitHub。私钥沿用本机原材料，未复制或导出新私钥。TIMER 实况窗与后台代理提醒权益尚未申请，签名成功不代表这些权益已开通。

### 本机单设备签名 HAP 已完成（2026-10-30，0122）

已用原密钥、新发布证书和上述单设备 Profile 完成 ARM64 Release/AOT 签名构建；Hvigor `assembleHap` 为 167.3 秒，包含依赖解析的本次成功包装流程为 222.4 秒。产物仅放在 F 盘：

```text
client/flutter_app/build/harmonyos-h0/self-use/20261029/Innocence-v1.2.5-harmonyos-arm64-self-use-signed.hap
字节数：53297721
SHA256：059af0066d95618d3c6cdf633c69555dccf4edf114b224771ce6b431078e93a1
```

官方 `verify-app`、三份 ARM64 ELF 的代码签名、摘要、权限签名和 ZIP CRC 均通过。包内 Profile 与已验证的 `.p7b` 逐字节相同，证书链公钥匹配；版本为 `1.2.5+10`、平板、`debug=false`，只有 `PUBLISH_AGENT_REMINDER`，没有 `INTERNET` 权限。全部 5 份字体／许可资产及 119 个暂存 Dart 文件与当前工程逐字节一致；仓库签名配置仍为空。

保留兼容性门禁：本机 0111 旧候选为 `debug=true`，本次为 `false`，且前述 `app-identifier` 不同。未连接观察当前安装状态，也未覆盖或卸载真实平板应用；资料保留和实际安装不可记为通过。

用户在 2026-10-30 选择“没有，准备临时入口”。当前仅授权准备临时 HTTPS 入口，尚未对外开放含设备 Profile 的安装包。按[华为 Deeplink 分发规范](https://developer.huawei.com/consumer/cn/doc/doccenter-submission/agc-help-internal-test-release-app-0000002260691994)，已准备同域名的 HTTPS 包／图标／签名描述文件、HEAD 文件大小、Range 分片响应，以及华为浏览器中的用户点击入口；实际开放与实体安装继续分别验证。

### 临时网页入口准备完成（2026-10-30，0123）

固定官方链接仓库 `c71aa1afd261b8921a2062e478ba86641c0e646c` 中的 manifest 工具 1.0.0，在本机使用原密钥签名，官方验签和新发布证书公钥交叉验证通过；修改版本号后的描述文件被拒绝。工具按其类型 DTO 签名，覆盖应用／版本／模块摘要等字段，不覆盖 `deployDomain`、图标 URL 和 `packageUrl`；这些路由字段已逐值检查，下载服务另按整份文件 SHA256 固定，不能把它描述为所有字段都受工具签名保护。

安装页、`manifest.json5`、图标和 53297721 字节 HAP 共 4 个文件均在 F 盘忽略目录。便携 Cloudflare Quick Tunnel 2026.10.6 已核对官方资产 SHA256 和有效 Authenticode，未安装服务或更改防火墙；当前隧道只转发需要明确开放标记的本机端口。公网 `/health` 返回可达且 `files_published=false`，真实安装文件仍为 404。本机预览可显示安装页，未在电脑点击安装 Deeplink。

30 项 HTTP／访问检查通过：HEAD 精确长度且无正文、前缀和后缀 Range 206／字节一致、非法范围 416、目录／非名单文件／路径穿越 404、POST 405，以及未确认公网关闭。另一个仅回环地址的隔离夹具验证了有效标记、过期／超 30 分钟／旧运行 ID／来源及摘要不匹配拒绝、描述文件改动拒绝；隔离标记没有开放真实公网服务。

用户确认具体链接和范围后才生成真实开放标记，最长 30 分钟，届时仍需核对外部 HTTPS 的 HEAD／Range 和华为浏览器安装。链接持有者可下载包含设备 Profile 和证书信息的 HAP，只有登记设备能按该 Profile 安装；私钥、密码和独立 Profile 文件不进入下载白名单。完整临时域名和随机路径只留私有运行记录与用户交付，不提交仓库。电脑在线、进程存活和临时地址有效均是必要条件，不能当成永久下载空间。[Cloudflare Quick Tunnel 文档](https://developers.cloudflare.com/tunnel/get-started/quick-tunnels/)

另需保留资格边界：[官方测试流程](https://developer.huawei.com/consumer/cn/doc/doccenter-submission/agc-help-internal-test-guide-0000002295325149)当前注明指定设备发布仅支持企业开发者。当前账号已实际取得 Profile，但账号类型未读取、网页实机安装未验证；不由签发成功推断完整网页分发资格。任何临时对外共享均须先展示实际链接、文件和有效范围，再按用户具体确认开放；私钥与密码只在本机使用。

### 本次临时入口已按确认开放（2026-10-30，0124）

用户明确回复“确认开放30分钟”后，仅按此前展示的同一 Cloudflare 域名、随机路径和 4 个文件开放。北京时间从 `2026-10-30 03:31:50` 至 `04:01:50`，有效窗口精确为 1800 秒；真实开放标记绑定当前运行 ID、origin、HAP 摘要及全部文件摘要，未自动续期。下载服务在到期时拒绝文件请求并停止，隧道包装进程随服务停止而退出；进程提前退出也会使入口失效。

外部 HTTPS 的 7 项校验通过：健康状态显示已开放，安装页／描述／图标的完整字节摘要与本机一致，HAP HEAD 为 53297721 字节且无正文，前 32 字节和末 16 字节的 Range 206 及 Content-Range／实际字节一致。内置浏览器已读取公网安装页和正确 Deeplink；公网截图接口两次失败，本轮未取得新的公网截图，不以旧本机预览截图替代这一证据。

在登记平板的华为浏览器打开交付链接，再点击“在平板上安装”；电脑须保持在线。当前完成的是临时文件分发及下载校验，系统安装、企业资格、旧版覆盖和资料恢复仍待平板反馈，不能据此标记安装成功。若拒绝覆盖，先保留旧应用及资料并反馈完整提示；不卸载试错。含设备 Profile 的 HAP 仅在授权窗口提供，私钥／密码及独立 Profile 不共享，不上传 GitHub。

希望在平板浏览器中点安装链接，需要先确认开发者账号可申请“指定设备发布”Profile，并准备：

1. 与应用匹配的发布证书、密钥和指定设备发布 Profile；Profile 仅加入自己的平板。
2. 使用该签名配置生成的 Release HAP。
3. 对应并已签名的 `manifest.json5` 安装描述文件，以及设备可访问的 HTTPS 安装入口。

该路线允许登记过的设备通过安装入口操作，不等于把文件管理器里的任意 HAP 直接点开。当前账号已实际取得上述单设备发布 Profile；这只证明本次申请成功，仍需完整的签名包、安装描述、可访问入口和实体安装证据，才能把浏览器安装计为完成。

2026-10-24 本机仅读签名元数据：`app` 工程有一份 **Debug** Profile，已于北京时间 `2026-10-21 13:17:09` 过期；`app-release` 没有配置 Profile。没有导出真实设备标识、主体、密钥或密码。旧调试材料不能直接当成指定设备发布材料使用。

切换调试／发布签名之前，须核对应用身份和覆盖兼容性；同包名本身不足以保证保留现有资料。未取得兼容覆盖证据时不卸载旧版，不承诺已有本机资料已经迁移。

参考：[华为指定设备发布 Profile](https://developer.huawei.com/consumer/cn/doc/app/agc-help-internaltest-profile-0000002283260129)、[华为内部测试分发](https://developer.huawei.com/consumer/cn/doc/app/agc-help-internal-test-release-app-0000002260691994)、[内测平台对证书、Profile 与浏览器安装的要求](https://api.pgyer.com/doc/view/harmonyos)。

## 当前可用方式：设备签名 + 电脑安装

1. 电脑安装华为官方 DevEco Studio 及 HarmonyOS SDK。平板开启开发者模式和 USB 调试，
   用 USB 连接电脑，并在平板上确认调试授权。
2. 在 DevEco 项目的签名配置中登录自己的华为开发者账号，生成或更新包含这台平板的
   **调试 Profile、证书和密钥**。Profile 必须有效，设备与包名必须匹配。
   本项目包名为 `com.innocence.tablet.innocence_flutter`。
3. 使用官方签名工具给下载的 HAP 签名；或者按下方源码流程生成签名 HAP。
   本地开发者资料只保存在自己的电脑，不能把 `.p12`、密码或设备 Profile 发到公开仓库。
4. 用 SDK 的 `hdc` 安装 **已经签名** 的 HAP。打开 PowerShell：

```powershell
# 将工具路径和 HAP 路径换成自己电脑上的实际位置。
$hdcPath = 'F:\DevEcoStudio\sdk\default\openharmony\toolchains\hdc.exe'
& $hdcPath list targets
& $hdcPath install -r 'F:\Innocence\Innocence-device-signed.hap'
& $hdcPath shell aa start -b com.innocence.tablet.innocence_flutter -a EntryAbility
```

如果连接了多个设备，用 `hdc -t <目标设备> ...` 明确指定要安装的平板。
`install -r` 请求覆盖安装；它不能绕过签名和 Profile 校验。

## 本项目源码的签名构建

在 `client/flutter_app` 运行以下命令，默认工具和所有暂存文件均放在 F 盘：

```powershell
# 同步生成独立 Release 工程。
.\tool\harmonyos.ps1 -Action prepare -BuildMode release
```

用 DevEco 打开 `build/harmonyos-h0/app-release/ohos`，完成此工程的签名配置。
然后回到 PowerShell：

```powershell
# 不加 -Unsigned；缺少有效签名时应失败。
.\tool\harmonyos.ps1 -Action build -BuildMode release
```

从 `build/harmonyos-h0/app-release/build/ohos/hap/` 选用 `*-signed.hap`，再执行上述 `hdc install -r`。
`app`（Debug）和 `app-release` 是独立暂存工程，前者的签名配置不会自动变成后者的配置。
更多工具与构建限制见 [README](README.md)。

## 已经装过旧版

升级应继续使用与旧版一致的应用签名身份，保留本机资料。换证书或 Profile 的应用身份不一致，
可能被拒绝覆盖；先核对签名和设备 Profile，不要用卸载解决，因为离线资料会有丢失风险。
仅有旧的设备签名 HAP、没有原证书与密钥，不能用它直接给新包签名。

## 希望其他人下载后直接安装

需要完成正式应用签名及对应发行流程，例如华为应用市场或 AppGallery Connect 提供的测试分发。
当前 GitHub 包不具备这项分发条件；重新命名为 `.apk`、压缩包或仅换扩展名不能解决。
鸿蒙原生 HAP 与兼容 Android 的 APK 是不同安装路径，系统版本及设备支持也必须匹配。

官方参考：[应用签名](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-signing)、
[HDC 工具](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/hdc)。
