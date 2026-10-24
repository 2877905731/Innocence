# GitHub 下载的鸿蒙 HAP 如何安装

适用当前公开的 `v1.2.5-harmonyos.1` 平板本机版。GitHub 的
`Innocence-v1.2.5-harmonyos-arm64-release-unsigned.hap` 是 **ARM64 未签名开发分发包**，
不能在平板文件管理器里直接点击安装。`Release/AOT` 表示编译方式，不代表已经签名或上架。

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
