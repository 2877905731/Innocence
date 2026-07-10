# Innocence 前端修改未生效排查

## 1. 适用场景

当出现以下现象时，优先查看本文：

- 已经修改了 Flutter 前端代码，但启动桌面程序后界面还是旧样式
- 主页面按钮点击后进入的还是旧页面，或者看起来“完全没变化”
- 汉化、二级页面样式、按钮点击逻辑已经改过，但用户运行程序后仍反馈“没有生效”
- 开发者继续反复修改页面代码，但程序表现始终和源码不一致

## 2. 本次问题的真实根因

这次问题不是“页面代码没有改到位”，而是“用户运行的程序和当前源码不是同一个版本”。

本次实际根因有两层：

1. 用户运行的是旧的 `Release` 成品。
2. 项目当时又刚好无法重新生成新的 `Release` 成品，导致最新源码根本没有进入可执行程序。

具体表现：

- 源码已经修改为新的通知页、统一二级页面外壳、更新后的按钮跳转逻辑
- 但用户启动的仍然是旧的 `build/windows/x64/runner/Release/innocence_flutter.exe`
- 旧程序中保留了旧版英文深色通知页，因此看起来像“代码完全没生效”
- 同时，项目重新打包时出现依赖解析问题，新的 `Release` 一开始无法构建成功

## 3. 这次排查得到的关键信号

### 3.1 不要先假设页面没改对

如果截图里的文案、颜色、布局明显还是旧版，而源码里已经不是这个样子，优先怀疑以下两件事：

- 用户打开的是旧的 `exe`
- 新的 `Release` 实际上没有成功编译出来

### 3.2 先对照三个位置

#### 源码入口

- 前端逻辑入口：`client/flutter_app/lib/main.dart`
- Windows 桌面壳入口：`client/flutter_app/windows/runner/main.cpp`

#### 最终运行成品

- Windows `Release` 程序：`client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe`
- Flutter 逻辑产物：`client/flutter_app/build/windows/x64/runner/Release/data/app.so`

#### 页面实际跳转链路

如果用户说“主页面点通知进去还是旧页面”，先确认主页面是否真的已经跳到目标页面。例如本次链路是：

- `client/flutter_app/lib/features/home/presentation/pages/home_page.dart`
- 跳转到 `client/flutter_app/lib/features/notifications/presentation/pages/notification_page.dart`

如果源码里的跳转链路已经接通，但程序里仍显示旧页面，通常不是路由问题，而是构建产物过旧。

## 4. 标准排查顺序

建议严格按照下面顺序排查，不要一上来继续改页面代码。

### 第一步：确认用户当前运行的是哪一个程序

确认运行中的 `innocence_flutter.exe` 路径。

重点确认是不是下面这个路径：

- `client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe`

如果用户运行的是桌面快捷方式、复制出去的独立程序、旧目录下的可执行文件，就可能看到旧版本界面。

### 第二步：比较源码修改时间和 `Release` 成品时间

重点比较以下文件时间：

- 最近改过的页面源码文件
- `build/windows/x64/runner/Release/innocence_flutter.exe`
- `build/windows/x64/runner/Release/data/app.so`

判断原则：

- 如果源码时间明显更新，但 `exe` 和 `app.so` 还是旧时间，说明新改动没有被打进程序
- `app.so` 的时间尤其重要，因为它承载 Flutter 逻辑

### 第三步：直接用可见文案反查源码

当截图里还有旧英文文案时，直接在项目中搜索这些可见文本。

例如：

- `Notification center`
- `Recent 30 days only`
- `Nothing here yet`
- `All caught up`

如果源码里相关页面已经改成了另一套文案或另一套容器结构，但运行程序仍显示旧文本，说明问题不在页面代码本身，而在运行产物。

### 第四步：确认新 `Release` 是否能正常构建

如果 `Release` 不能正常构建，就算代码已经改好，用户也不可能看到新结果。

本次遇到的实际构建问题是：

- `flutter_localizations` 无法解析
- `intl` 依赖未进入当前构建环境

这会直接导致新的桌面程序无法产出。

## 5. 本次问题的修复方法

### 5.1 先刷新依赖

在 `client/flutter_app` 目录执行：

```powershell
flutter pub get --offline
```

说明：

- `flutter pub get --offline` 可以在本地缓存齐全时刷新依赖配置
- 本次就是通过它把 `flutter_localizations` 和 `intl` 正确写回当前依赖配置

### 5.2 再重新构建 Windows Release

```powershell
flutter build windows --release --no-pub
```

说明：

- `--no-pub` 表示直接使用刚刚已经刷新好的依赖配置进行构建
- 本次修复后，新的 `Release` 已成功生成

### 5.3 注意一个容易误用的命令

下面这个命令不可用：

```powershell
flutter build windows --release --offline
```

原因：

- `flutter build windows` 没有 `--offline` 这个选项
- 离线刷新依赖要放在 `flutter pub get --offline`

### 5.4 构建完成后必须再次核对时间

构建成功后，立即检查：

- `build/windows/x64/runner/Release/innocence_flutter.exe`
- `build/windows/x64/runner/Release/data/app.so`

如果这两个文件的时间没有更新，就不要默认认为“程序已经是最新的”。

### 5.5 重新启动的必须是最新 Release 程序

只启动下面这份：

- `client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe`

不要继续复用未知来源的快捷方式或旧目录里的复制品。

## 6. 下次再遇到时的快速判断模板

如果出现“我已经改了很多次，但用户还是看到旧页面”，优先按下面顺序判断：

1. 先看运行中的 `innocence_flutter.exe` 路径是不是当前项目的 `Release`
2. 再看 `Release` 的 `exe` 和 `app.so` 时间是不是晚于最近源码修改时间
3. 再看当前截图里的旧文案是否已经不在源码对应页面中
4. 再检查 `flutter pub get` 和 `flutter build windows --release` 是否真的成功
5. 只有当前四项都正常后，才继续怀疑页面代码或页面路由本身

## 7. 开发过程中的预防措施

为避免再次出现“代码改了但程序里没变化”，建议固定执行以下规则：

### 规则 1：凡是用户运行 `Release`，前端改动后就必须重新生成 `Release`

如果用户不是直接用开发模式运行，而是双击 `Release/innocence_flutter.exe`，那就不能只改源码不重打包。

### 规则 2：每次改完 UI，不要只看源码，要看产物时间

至少核对：

- 页面源码文件时间
- `Release` 下 `exe` 时间
- `Release` 下 `app.so` 时间

### 规则 3：用户提供截图时，优先用截图文案反查是不是旧版本界面

这一步可以非常快地判断“用户看到的是不是最新代码对应的页面”。

### 规则 4：如果页面链路已经接通，不要重复修改同一页面直到确认构建产物是新的

否则会陷入“页面已经修好了，但因为程序没更新，看起来像完全没修”的假象，浪费大量时间。

## 8. 本次问题结论

本次问题的核心不是前端页面没有修改，而是：

- 用户运行的是旧版 `Release` 程序
- 同时项目在该时点无法重新生成新的 `Release`

因此后续遇到类似反馈时，应先排查“运行产物是否最新”和“构建链是否正常”，再继续修改业务页面代码。
