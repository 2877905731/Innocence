# GitHub 下载的鸿蒙 HAP 如何安装

适用当前公开的 `v1.2.5-harmonyos.1` 平板本机版。GitHub 的
`Innocence-v1.2.5-harmonyos-arm64-release-unsigned.hap` 是 **ARM64 未签名开发分发包**，
不能在平板文件管理器里直接点击安装。`Release/AOT` 表示编译方式，不代表已经签名或上架。

## 已确认目标：仅给自己平板使用（2026-10-24）

用户确认“我想只给自己用”。本轮继续以自己平板上的安装和后续更新为目标，不安排正式公开上架，也不上传个人签名 HAP、Profile 或私钥到 GitHub；已有公开未签名资产保持原样。

账号状态：用户此前确认“已注册，实名认证还没完成”。2026-10-24 后续已在用户准备的[华为开发者中心](https://developer.huawei.com/consumer/cn/)创建下述应用，但本轮未读取实名认证结果，也未代填或提交身份资料；不能仅凭应用创建成功就记为实名通过。

### 2026-10-24 控制台实际准备结果（0120）

| 字段 | 已核对值 |
| --- | --- |
| 应用名称／项目 | Innocence／Innocence |
| APP ID | `6917619921714239020` |
| 包名 | `com.innocence.tablet.innocence_flutter` |
| 类型／设备／语言 | HarmonyOS 应用／平板／简体中文 |
| 应用版本状态 | 准备提交 |

创建成功只代表应用登记完成，尚未上架。控制台“添加 Profile”表单当前提供可选的“指定设备发布”，选择后显示设备字段；尚未提交该 Profile，也未证明最终申请已获准。

证书页面只有一张已过期的调试证书。已准备名称为 `Innocence-self-use-release`、类型为“发布证书”的申请草稿，CSR 尚未上传或提交。F 盘忽略目录 `build/harmonyos-h0/self-use/20261024/` 内已准备复用的 510 字节 CSR：自签名验证通过，公钥与原证书链中的签名证书一致，没有创建或导出私钥。详情和摘要仅保存在本机 `csr-readiness.json`。平台是否接受该 CSR、发布证书签发及后续私钥签名配置仍待实际核对。

下一步需在具体确认上传这份 CSR 至华为开发者中心并申请发布证书后，再办理指定设备发布 Profile；仅加入自己的平板。新增签名凭据按浏览器操作规则在提交前确认。发布证书与设备 Profile 取得后，仍须核对旧应用身份、签名 HAP、签名安装描述、HTTPS 入口和实际覆盖安装，不能把申请草稿当成可安装包。

希望在平板浏览器中点安装链接，需要先确认开发者账号可申请“指定设备发布”Profile，并准备：

1. 与应用匹配的发布证书、密钥和指定设备发布 Profile；Profile 仅加入自己的平板。
2. 使用该签名配置生成的 Release HAP。
3. 对应并已签名的 `manifest.json5` 安装描述文件，以及设备可访问的 HTTPS 安装入口。

该路线允许登记过的设备通过安装入口操作，不等于把文件管理器里的任意 HAP 直接点开。当前控制台可选择指定设备发布，但实名认证结果、账号完整资格和最终 Profile 签发仍未核实，不能仅因“自用”或选项可见就承诺申请必然成功。若此能力不可用，现有调试签名加电脑安装仍是另一条可行路径，但它不能替代用户希望的浏览器安装目标。

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
