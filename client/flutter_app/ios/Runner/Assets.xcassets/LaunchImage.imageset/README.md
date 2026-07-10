# iOS LaunchImage 资源说明

这里是 Flutter iOS 工程启动图资源目录。

## 作用

当 iOS 应用刚启动、Flutter 首帧还没有绘制出来时，系统会先展示这里配置的启动图资源。

## 你可以在这里做什么

- 替换默认启动图
- 调整不同分辨率下的启动资源
- 配合 Xcode 资源管理器维护 `Assets.xcassets`

## 当前项目状态

当前项目的主要开发重点不是 iOS，而是：

- Windows 桌面端
- Android

所以这个目录目前主要保留 Flutter 默认结构，便于未来需要 iOS 支持时继续扩展。

## 修改方式

有两种常见方式：

1. 直接替换本目录中的图片资源。
2. 用 Xcode 打开 `ios/Runner.xcworkspace` 后，在 `Runner/Assets.xcassets` 中可视化维护。

## 注意

- 如果你当前并不打算维护 iOS 版本，可以先保持这里不动
- 不建议在未明确适配需求前单独改动此目录，以免与后续 Flutter 资源生成流程冲突
