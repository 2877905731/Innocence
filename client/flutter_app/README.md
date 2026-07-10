# flutter_app

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

### 构建 Windows 发布版

当前项目经常需要验证 Windows 桌面可执行程序，最终产物通常位于：

- `build/windows/x64/runner/Release/innocence_flutter.exe`

同时要注意：

- Flutter 逻辑代码真正打包进的是 `build/windows/x64/runner/Release/data/app.so`
- 有时 `exe` 时间戳变化不明显，但 `app.so` 已更新

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
