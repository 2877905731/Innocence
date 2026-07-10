# 客户端目录

这里存放 `Innocence` 的客户端代码。当前仓库中实际使用的主客户端工程是 `flutter_app`。

## 目录说明

```text
flutter_app/                 Flutter 主工程
README.md                    当前目录说明
```

## 当前实现重点

- Android 与 Windows 是当前第一阶段主平台
- 主页面已经接入计划、专注、签到、统计、通知、好友、备忘录、团队、设置等入口
- 二级页面已逐步统一为同一套浅色桌面风格
- 桌面端包含挂件视图、窗口控制、圆角毛玻璃面板与位置/尺寸记忆能力

## 当前建议工作流

### 日常开发

进入 `client/flutter_app` 后运行 Flutter 调试。

### Windows 验证

如果你验证的是桌面发布版，建议使用：

- `client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe`

注意：

- 仅修改 Dart 代码并不会自动更新已生成的 `Release` 可执行目录
- 每次桌面逻辑改完后，都要重新构建 Windows 发布包

## 你通常会在这里改什么

- `flutter_app/lib/app`：应用入口、状态控制、语言控制
- `flutter_app/lib/core`：主题、基础组件、平台桥接
- `flutter_app/lib/features`：按业务模块拆分的页面与数据模型
- `flutter_app/windows`：Windows 桌面壳工程

## 关联文档

- Flutter 主工程说明：[client/flutter_app/README.md](/F:/springmvc1/Innocence/client/flutter_app/README.md)
- 前端构建未生效排查：[docs/troubleshooting/Innocence-前端修改未生效排查.md](/F:/springmvc1/Innocence/docs/troubleshooting/Innocence-前端修改未生效排查.md)
