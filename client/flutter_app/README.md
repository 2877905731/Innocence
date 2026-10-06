# Innocence Flutter Client

这里是 `Innocence` 的 Flutter 主工程，也是当前移动端与 Windows 桌面端联动开发的核心目录。

## 当前能力

- 登录、注册与语言选择
- 主页面与桌面挂件视图
- 今日计划与周计划模板
- 专注计时
- 签到与失败记录
- 统计中心
- 通知中心
- 好友中心
- 备忘录中心
- 设置中心
- 团队与团队聊天
- 后台管理入口

## 目录结构

```text
lib/
  app/                       应用入口、会话控制、语言控制
  core/                      通用主题、组件、工具、平台桥接
  features/                  按功能拆分的业务模块
android/                     Android 平台工程
windows/                     Windows 平台工程
linux/                       Linux 平台工程
macos/                       macOS 平台工程
ios/                         iOS 平台工程
pubspec.yaml                 Flutter 依赖配置
```

## 运行要求

- Flutter SDK `>=3.4.0 <4.0.0`
- Dart SDK 与 Flutter 版本匹配

当前依赖比较轻量，核心三方依赖包括：

- `flutter_localizations`
- `shared_preferences`

## 常用运行方式

### 调试运行

在当前目录下直接运行 Flutter 调试命令即可。

### 构建 Windows Release

当前项目经常需要验证 Windows 桌面可执行程序，最终产物通常位于：

- `build/windows/x64/runner/Release/innocence_flutter.exe`

同时要注意：

- Flutter 逻辑代码真正打包进的是 `build/windows/x64/runner/Release/data/app.so`
- 有时 `exe` 时间戳变化不明显，但 `app.so` 已更新

正式发布时使用仓库内的打包脚本：

```powershell
pwsh -File windows/package_release.ps1
```

脚本会依次执行依赖解析、静态分析、完整 Flutter 测试和 Windows Release 构建，然后在
`build/releases/v<version>/` 生成：

- `Innocence-v<version>-windows-x64-setup.exe`：每用户安装器，支持开始菜单、可选桌面快捷方式和卸载
- `Innocence-v<version>-windows-x64-portable.zip`：免安装便携包
- `SHA256SUMS.txt`：当前目录内 Windows 与 Android 发布资产的 SHA256 校验值；两个打包脚本不会删除另一平台产物

安装器由 `windows/installer.iss` 定义，需要本机安装 Inno Setup 6。正式公开发布前还应使用可信代码签名证书签名；没有证书时必须在发布说明中明确安装器未签名。

### 构建 Android 本机离线 Release

v1.2.0 首次发行 Android 本机离线版。`INNOCENCE_OFFLINE_ONLY=true` 同时控制专用离线入口、禁止恢复在线会话、请求层拦截和 Manifest 移除 `INTERNET` 权限。普通开发及 Windows 构建保留现有联网路径。

v1.2.3+8 延续本机离线范围与正式发行签名，改进简约白及专注布局；可覆盖 v1.2.2 保留本机资料。Windows 开放自带 Key 的聊天助手，Android 离线包仍关闭模型联网调用。鸿蒙源码版本同步，但未提供正式签名 HAP。

```powershell
flutter pub get
pwsh -File android/package_release.ps1
```

脚本执行 analyze、全部 Flutter 用例、离线编译开关专项及 Release APK 构建；随后用 `apksigner` 和 `aapt` 核对签名、版本、非调试状态和无联网权限，输出 `build/releases/v<version>/Innocence-v<version>-android-offline.apk`。双端验证在同一源码下已完成时可用 `-SkipVerification` 跳过重复检查，构建与产物校验仍执行。

正式签名需要四个进程环境变量：`INNOCENCE_ANDROID_KEYSTORE`、`INNOCENCE_ANDROID_STORE_PASSWORD`、`INNOCENCE_ANDROID_KEY_ALIAS`、`INNOCENCE_ANDROID_KEY_PASSWORD`。不将密码写进命令行、仓库或日志。未提供变量时，脚本从当前 Windows 用户的 `%LOCALAPPDATA%/Innocence/release-signing/` 读取 `innocence-android-release.p12` 与 DPAPI 加密的 `signing-credentials.clixml`；可用 `-SigningDirectory` 指定受限目录。Gradle 缺少正式签名会拒绝 Release 构建，不回退到 Debug 密钥。

同一 applicationId `com.innocence.app.innocence_flutter` 的后续升级必须沿用首次发行密钥，并递增 versionCode。签名材料应由项目所有者另行安全备份；DPAPI 文件只能由对应 Windows 用户解密，迁移构建机时须通过安全方式提供上述变量。开发版 Debug 签名不同，无法覆盖正式版；本机数据不能因验收而静默清除。

本次 Android 仅开放本机能力；登录、陪伴、收件箱、云同步与推送后续接入。月／年计划独立手机页已有离线实现；实体手机/OEM/Vulkan、其他详情页和长期运行验收仍有待办。

## 前端协作注意事项

- 主页面与二级页面正在统一为同一套桌面视觉语言
- 很多用户反馈来自“修改后未重新构建 Release”，这一点在桌面验证时尤其重要
- 如果界面看起来还是旧版本，优先检查是否重新构建了 Windows 发布包

## 排查文档

- 前端修改未生效排查：[docs/troubleshooting/Innocence-前端修改未生效排查.md](/F:/springmvc1/Innocence/docs/troubleshooting/Innocence-前端修改未生效排查.md)

## 当前开发优先级

- 优先保证 Windows 桌面端体验可用
- 再逐步补齐 Android 端适配
- 在界面统一基础上继续推进真实功能联调

## 鸿蒙平板开发预览

[v1.2.3 开发预览 1](https://github.com/2877905731/Innocence/releases/tag/v1.2.3-harmonyos-preview.1) 提供 ARM64 平板和 x64 模拟器的未签名 Debug HAP。实体平板需设备 Profile 和签名，不能直接安装下载包；PC 全屏页面与四主题共用共享源码，原生工具链与流程见 [鸿蒙 README](harmonyos/README.md)。真机、输入法和业务恢复仍待验收。
