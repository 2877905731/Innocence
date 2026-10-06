# Innocence 鸿蒙平板开发工程

2026-10-07：v1.2.3+8 仅同步鸿蒙源码版本并随仓库推送；0104 运行证据对应先前 1.2.2+7 Debug HAP。此次正式下载资产只有 Windows 与 Android，不发布未签名 HAP，原输入法/业务恢复/真机签名待办继续保留。

用户于 2026-10-05 要求开始制作。平板复用 PC 工作台和四主题；当前原生宿主按横屏/反向横屏、沉浸式全屏配置，关闭 Windows 窗口控制、拖边、托盘和 Focus Orb。首轮构建强制本机模式，账号接口和 BYOK 请求不启用，等待设备槽位契约及原生密钥保险库接入。

当前已完成共享 Dart、ArkTS 与原生插件编译，生成 **ARM64 与 x64 未签名 Debug HAP**，启动图标已复用项目正式 Innocence 母版。0104已在官方API26/x64平板模拟器安装启动，PC全屏与四主题原生画面有证据；真实平板调试签名、业务保存恢复及完整平台验收仍待，整体H0-H5/G01未封板。原生示例测试不覆盖本产品业务，当前构建移除了其默认测试 target 和 hypium 依赖，保留示例源码作参考。

## 工具和依赖

- Flutter OH：`3.41.10-ohos-1.0.1`，commit `adaf911c35c9136a7d18fc424d714c9ec7724e60`，配套 Dart `3.11.5`。
- 鸿蒙引擎：`3fb08d34b6f96a15fbb219b903c9d0ab37b6c2e0`。
- 官方工具：用户提供 `F:/devecostudio-windows-26.0.0.851.zip`，已解压 DevEco Studio `26.0.0.851`；SDK `26.0.0.105` / API 26，Node `24.14.1`、ohpm `26.0.0.630`、Hvigor `6.26.8`、JBR 21。
- 兼容 API 下限沿维护者模板 `5.1.0(18)`，target 使用 DevEco 26 接受的 `26.0.0`，compile 由 SDK 工具选择。当前产物元数据为 compatible API 18 / target API 26；最低设备版本的运行兼容性仍待验证。
- Preferences、路径、文件选择及 SQLite 使用维护仓库适配，见本目录 `pubspec_overrides.yaml` 的固定 commit。FFI `2.4.0+3` 和 sqlite3 `3.1.6` 用于满足 OH Dart 版本约束；本机 SQLite 在鸿蒙上使用 `sqflite_ohos`，不采用桌面 FFI 工厂。

[维护仓库和稳定版本说明](https://atomgit.com/CPF-Flutter/flutter_flutter)、[原生插件适配列表](https://atomgit.com/CPF-Flutter/flutter_packages)、[华为官方工具下载](https://developer.huawei.com/consumer/cn/download/command-line-tools-for-hmos)。旧 Gitee Flutter 分支不再作为本工程工具来源。

## 开发命令

在 `client/flutter_app` 下运行，工具只设置本次进程环境。默认 SDK、缓存和暂存工程在忽略目录 `build/harmonyos-h0`；Windows/Android 使用原有项目和锁文件。

2026-10-05 用户指定鸿蒙相关文件全部存放在 F 盘。统一根目录为 `F:\springmvc1\Innocence\client\flutter_app\build\harmonyos-h0`：官方解压工具放 `tools/DevEcoStudio26`，Flutter OH 放 `flutter-oh`，Dart 依赖放 `pub-cache`，npm/ohpm/Hvigor 缓存分别放 `npm-cache`、`ohpm-cache`、`hvigor-home`，临时文件放 `temp`，暂存工程及 HAP 输出位于 `app`。DevEco 设置、索引、插件和日志配置到 `ide-profile`，工具用户目录为 `task-home`。脚本校验 Flutter/DevEco 路径属于 F 盘，只修改本次进程环境并在退出后恢复；15 项环境值恢复核对通过。0103已在F盘下载API26/SP8镜像并创建平板实例。0104已解决独立CLI许可目录例外：仅C盘`AppData/Local/Huawei/Emulator26.0`专用目录指向F盘同版本官方工具的既有配置，原47字节状态保留`archive/0103/windows-cli-license-cache`。C盘只留目录链接，许可、镜像和实例内容均在F盘；没有复制或修改用户的许可选择。

```powershell
# 自动识别 tools/DevEcoStudio26。
./tool/harmonyos.ps1 -Action doctor
./tool/harmonyos.ps1 -Action build -Unsigned
# Windows 本地模拟器：x64 工程和输出单独位于 app-x64。
./tool/harmonyos.ps1 -Action build -Unsigned -Architecture x64
# 打开暂存的 ohos 工程，在 IDE 完成调试签名。
./tool/harmonyos.ps1 -Action ide
# 签名配置就绪后，构建带签名调试包。
./tool/harmonyos.ps1 -Action build
```

Flutter OH 可用 `-FlutterSdk` 指定，官方工具可用 `-DevEcoHome` 指定；`-DirectGit` 仅用于本机失效代理及旧仓库地址迁移，额外在该进程启用 Git 长路径；`-GitHelperPath` 可指定完整 Git 的辅助程序目录，不修改全局 Git 配置。`-Architecture` 默认为 `arm64`，使用 `x64` 时暂存工程为 `app-x64`、kernel 为 `kernel-check-x64`；`ide` 也按该参数打开对应工程。

`prepare` 将 `lib`、shader 与原生工程复制到 `build/harmonyos-h0/app`，只在该暂存工程使用鸿蒙依赖覆盖及锁文件。`GeneratedPluginRegistrant` 已生成 Preferences、路径、文件选择和 SQLite 四个插件的注册，并通过原生编译。调试签名在暂存工程完成；脚本发现其非空签名配置时保留该配置，不复制回仓库。账号登录与设备授权由用户在官方界面操作，签名材料不能纳入 Git。

`-Unsigned` 显式传递 `--no-codesign`，用于原生编译核验。默认 `build` 仍要求签名包，缺少签名时不会将未签名包当作构建成功。

依赖解析完成后，可用以下命令独立核对 Dart kernel；它不生成 HAP，也不证明 ArkTS/SQLite/文件选择已经能在设备运行：

```powershell
./tool/harmonyos.ps1 -Action kernel
```

宿主平板回归命令：

```powershell
flutter test --no-pub --dart-define=INNOCENCE_TARGET_PLATFORM=harmonyos `
  test/core/layout/harmony_tablet_presentation_test.dart `
  test/features/settings/offline_settings_page_test.dart `
  test/app/offline_release_test.dart
```

`INNOCENCE_TARGET_PLATFORM` 也用于宿主验证平板页面；实际鸿蒙通过 `Platform.operatingSystem == 'ohos'` 识别。布局使用 PC 呈现，但设备身份为 `harmonyos`，不会报告 Windows。软键盘仅减少可见高度，侧栏和工作台保留，内容由既有滚动容器处理。

## 当前证据与下一步

2026-10-05：标准 Dart 与配套 OH Dart 对共享源码分析均输出 `No issues found!`；Windows/Android 相关 25 项、平板及本机门禁 10 项通过；ARM64 目标 `kernel_snapshot_program` exit 0。八张宿主合成图位于 `build/qa/harmony-tablet`，使用 CJK QA 字体，不代表鸿蒙字体或原生设备效果。

0102记录的2026-10-05完整原生构建已通过，2026-10-06继续时重新核对产物摘要一致。该次 `build -Unsigned` exit 0，Hvigor 耗时 18.7 秒；`doctor` 的 HarmonyOS 项通过，隔离工具用户目录下未配置 Android 不影响原有双端 SDK。旧 HAP 现保留在 `build/harmonyos-h0/archive/0102/arm64-unsigned.hap`，115144159 字节，SHA-256 `f10e480b990245d5e3ae8461941cdf108a4e7bb65c902d0c99a96ee10d3998d7`，ZIP CRC 核对通过。元数据为 `com.innocence.tablet.innocence_flutter` / `1.2.2+7`、tablet、横屏及 ARM64；原生 Flutter/SQLite 库为 ARM64 ELF。113 个共享 Dart 文件与暂存工程逐字节一致。

当前 Debug HAP 仍声明模板的 `ohos.permission.INTERNET` 权限，客户端通过构建参数强制本机模式；这不是无网络权限的正式离线发行包。原生 SQLite 持久化、文件选择、主题着色器及全屏实际效果须在鸿蒙环境验证。

0102记录的2026-10-06首次x64模拟器包 `build -Unsigned -Architecture x64` exit 0/Hvigor156.6秒，现保留在 `build/harmonyos-h0/archive/0102/x64-unsigned.hap`，116763248 字节，SHA-256 `23bb2b3b6af57f23ce72da76014ec14f6bd5d66c4c04b8cff1527312a811b928`。ZIP CRC 与两份 x86_64 ELF 核对通过，ARM64 包单独保留。此结果仍是编译证据，不证明模拟器启动成功。

2026-10-06随后补正式启动图标：源资源逐字节复用 `docs/design/logo/innocence-logo-v1-cutout.png`，DevEco生成512×512包内PNG，四份图标（两架构各app/entry）一致并已目视核对。两架构重建exit0：ARM64/Hvigor28.4秒/115600935字节/SHA-256 `6d686fccced019542e78a46f1732b0c90666ea6f14d579c9b9514ec701a4387e`；x64/Hvigor23.0秒/117220024字节/SHA-256 `06ff364610cae8b66ec8e9f2cf428af1d71c4e2c60225d60bd96f2573df17fdc`。最新输出仍为各自 `app` / `app-x64` 下的 `build/ohos/hap/entry-default-unsigned.hap`，清单文件更新，CRC/两架构原生库/各113共享Dart一致性通过；旧0102包及清单保留。

用户已完成 DevEco 登录。自动签名提示缺少设备 Profile；模拟器可跳过签名，真机需连接后生成调试 Profile。0103已核对下载好的HarmonyOS7.0.0.107/SP8/API26镜像，并创建官方MatePad Air12预设（2800×1840/360dpi/x64/4GB RAM/6GB ROM）；此预设不代表已确认用户真实平板型号。镜像位置为F盘`task-home/AppData/Local/Huawei/Sdk`，设备实例为`task-home/AppData/Local/Huawei/Emulator/deployed/MatePad Air 12`。

下一步：用户处理当前小艺输入法首次协议/隐私页后，保存已有QA_NATIVE/QA_TASK草稿并验证SQLite业务写入/进程冷启动；复验玻璃编辑黑屏/输入法服务错误，再连接用户平板完成Profile与签名。后续完成触控矩阵、HUKS、设备槽位及联网契约。发行需经过 H5，当前没有发布授权。

0103启动诊断：设备管理器及直接GUI启动只有后台进程，没有可操作窗口；`hdc list targets` exit0/目标0，尚未执行HAP安装。官方`Emulator -start ... -bootMode coldboot` exit1并提示独立服务协议，`-logZip`提示日志收集失败；`HypervisorPresent=True`不能代替完整模拟器环境核验。computer-use桌面启动也未返回窗口，已请求用户手动点击设备管理器启动并提供状态或错误文字。当前原因未确定，不记H0运行通过。镜像与设备配置核验清单位于`build/harmonyos-h0/tablet-emulator-manifest.json`；两架构现有HAP的CRC/摘要/原生库和113共享Dart再次核对PASS。

0104解决0103启动等待：IDE日志明确原生工具等`y/N`；原生工具默认读Windows用户许可目录，IDE已确认的同版本配置在F盘。检查C盘目录仅有本轮诊断生成的47字节状态后，保留旧目录并建立指向F盘的Junction，没有修改既有许可或隐私选择。模拟器随后启动并连接，`param get const.ohos.apiversion`为26、`uname -m`为x86_64；最新版x64 HAP安装成功，`aa start -b com.innocence.tablet.innocence_flutter -a EntryAbility`返回启动成功。原生App root为2800×1840全显示区域，首页、计划、设置及四主题有画面，液态玻璃经`aa force-stop/start`恢复。

原生SQLite初始文件通过只读核对：user_version6、17表、integrity_check=ok，计划与任务行均为0，不能据此记为业务保存恢复完成。简约白通过鸿蒙`uitest uiInput inputText`输入QA_NATIVE/QA_TASK并添加灵活任务；草稿尚未保存，小艺输入法首次协议/隐私页已打开，待用户亲自选择。先前玻璃编辑出现黑屏与Flutter输入法12800008/12800009错误，需在输入法初始化完成后复验。原生画面在`build/qa/harmony-native`；运行清单`build/harmonyos-h0/harmony-runtime-manifest.json`明确业务恢复与真机签名为false。
