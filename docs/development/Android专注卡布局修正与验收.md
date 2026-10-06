# Android专注卡布局修正与验收

2026-10-04用户提供Android首页截图并要求“专注的布局不太合理，你修改一下”；实现及实际核对完成于2026-10-05（0097）。原通用卡片把状态、靠右表盘、右下按钮依次垂直排列，形成大片空白。Android首页和专注详情改为独立卡片：数字计时/状态/任务与表盘同组，底部48dp以上通栏主动作；原FocusSession、ticker、主题材质、导航与业务回调保持。

窄屏/大字体按实际时长文字测量重排到上下居中；超过一小时的时长保持单行，必要时仅限制数字基准字号，正文保持用户字体设置。首页长任务最多两行，详情显示完整任务。详情暂停/继续和结束在普通宽度并列，窄屏大字体竖排；isBusy仍禁用原动作。

## 实际命令与结果

在 `client/flutter_app` 执行：

```powershell
& D:/soft/flutter/bin/flutter.bat test test/features/home/android_focus_layout_test.dart test/features/home/android_home_shell_test.dart test/features/home/white_home_refinement_test.dart --no-pub --reporter expanded
& D:/soft/flutter/bin/flutter.bat analyze --no-pub
```

| 检查 | 最终结果 |
|---|---|
| 三份相关用例 | exit0，24项通过，12秒；新增13、原首页5、表盘/尺寸6 |
| 新布局矩阵 | 四主题×双语×空闲/进行中/暂停×411普通字体/320字体1.5/600横向字体1.5，共72组合；单行时长、长任务、同一session、通栏48dp、导航及原动作回调；忙状态另验 |
| Flutter analyze --no-pub | exit0，No issues found，37.1秒 |
| Gradle assembleDebug | BUILD SUCCESSFUL，19秒；207 tasks/22执行/185复用 |
| API36覆盖安装 | install -r Success，本机资料与用户原复古主题恢复 |
| 最终冷启动 | Status ok/COLD，TotalTime3381ms/WaitTime3384ms，PID3451 |
| 00:10:02运行复核 | MainActivity前台；FATAL、Flutter未处理异常及RenderFlex overflow三个筛选计数均0 |

Gradle在 `client/flutter_app/android` 执行：

```powershell
& ./gradlew.bat 'assembleDebug' '-Pkotlin.incremental=false' '-Pkotlin.compiler.execution.strategy=in-process' '-Pdart-defines=SU5OT0NFTkNFX09GRkxJTkVfT05MWT1mYWxzZQ=='
```

APK `build/app/outputs/flutter-apk/app-debug.apk`：180731995 bytes，SHA256 `53468169747a90c1901cd4c61d04983568d4f3e73edecc86d47e4392f1727756`。这是现有联网Debug开发构建；正式离线v1.2.2+7资产未改。

最终日志 `build/android-focus-layout-{test,analyze,build}.log`。首轮24中忙状态用例使用pumpAndSettle遇循环加载动画超时，第二轮点击前未等待滚动布局帧；已按真实滚动流程增加pump、对忙状态使用有界pump。首轮图片还发现长时长换行，修正后新增单行文字盒断言；前两轮日志保留为 `*-test-{initial,second}.log`，未跳过用例。

## 原生画面与窗口恢复

模拟器安装前已经关闭，首次ADB返回device not found。重开原 `Innocence_API36_Pixel7`，install -r成功，原生首页新卡片可见；重开的窗口自动尺寸落屏外，sky截图只能看到一部分。SDK帮助确认 `-scale` 命令行选项已废弃，不使用它；窗口菜单尝试没有恢复位置。通过SDK的 `adb emu kill` 正常关该模拟器，先备份 `emulator-user.ini` 到忽略构建目录，仅改window.x=600、window.y=35、window.scale=0.32，再重开同一AVD，不改userdata。

通过computer-use的sky观察完整窗口并拖标题栏居中：主图348×799，物理原点979,85；工具栏54×508，原点1499,130。2560×1440/150%桌面工作区高1368，整体中心约1279.5,684.25，误差约1px。窗口保持打开，当前展示专注详情。

ADB截图和uiautomator读取的“进入专注”bounds `[105,1794][975,1920]` 相符，点击540,1857正常进入详情；只做导航，没有开始/暂停/结束实际时段，也未保存任务或签到。`build/qa/android-focus-layout/runtime/focus-home.png`、`focus-detail.png` 为当前实际设备画面；`apk.json`、`final-start.log`、`runtime-check.json`、`window-position.json` 记录摘要。只保存指定进程错误计数，不保存全量个人logcat。

8张宿主PNG在 `build/qa/android-focus-layout/`，复古/白色空闲、玻璃运行、白色320大字体暂停各一组首页/详情，纯合成数据不落用户数据库，已逐组核对。原生证据为API36待开始首页及详情导航子集，模拟器运行/暂停/结束全状态、实体设备/输入法/OEM/Vulkan、Windows多DPI和长时间性能继续待验。

本轮无身份、owner、权限、字段或模型生成语义变更。认证失败、租户不匹配、权限拒绝、字段缺失、生成失败沿既有fixture/后端证据维护；真实供应商/HTTP/同步未回放，不把本轮布局当这些门禁完成。源码仅Android Shell与其fixture/布局用例；未重建Windows、未改正式版本、未推送或发布。
