---
schema_version: 1
document_type: checkpoint
sequence: "0084"
created_at: "2026-10-02T20:54:00+08:00"
phase: P01
type: CORRECTION
status: complete
title: "Android玻璃纹理方向、圆盘手柄误滚动与双端每日标语纠正"
objective: "修正用户手机截图中的玻璃采样错位、扩大短计划首尾手柄命中并避免纵向滚动竞争，补齐双端每日标语；记录用户取消歌词收录。"
completed:
  - fact: "修正Flutter3.44.4 Impeller GLES的Picture.toImageSync纹理纵向反转；Canvas已经补偿，而原texture()直采样未补偿。以编译宏保护旧GLES翻转，3.47+与Skia/Vulkan/Metal保留原采样方向。"
    evidence: "glass_refraction.frag；Flutter官方迁移文档；API36真实GLES后端像素探针green=[30,70,100]，与三行预期完全一致。"
  - fact: "圆盘手柄命中半径36dp，与绘制命中一致；仅手柄按下立即接管拖动，非手柄起点保持父级可滚动。视觉圆点略增大且加淡晕，保留半小时/防重叠/最短时长/当天午夜钳制。"
    evidence: "新增3项手势回归：原环带外命中、距手柄32dp短拖不滚动、非手柄仍可滚动；原午夜/邻接/输入/窄屏用例全部通过。"
  - fact: "Android首页新增主题化每日标语，Windows标明每日标语且在专注中保留；共用现有按日期/主题/语言稳定选择的原创文案池，双端恢复前台重新刷新并重排午夜计时。"
    evidence: "Android两主题/双语/320dp专注状态用例；Windows四主题/双语/460x700与1360x900专注状态用例；签名APK两主题首页截图。"
  - fact: "DEC-0047用户要求、图片引用与后续‘没版权的话就算了’原文已存档；本轮没有收录歌词或改为伪造歌词归属。"
    evidence: "UI设计规划2026-10-02章节；原文UTF-8字符串核对。"
  - fact: "生成独立本地Windows便携包与沿用正式签名的Android本机离线APK，版本仍1.2.0+5；未覆盖build/releases/v1.2.0历史发布文件或修改远端Git/Release。"
    evidence: "build/verification/20261002-fixes；签名证书摘要与0083相同；SHA256SUMS.txt。"
  - fact: "独立API36模拟器签名Release安装、两主题首页、外缘垂直短拖06:00→05:30且外层几何不变、保存05:30–09:00/210分钟、覆盖安装与冷启动恢复核对。"
    evidence: "新userdata路径F:/AndroidSdk-Innocence/captures/20261002-fixes/userdata.img；原AVD用户数据未写入；clock-short-drag.png、restored-plan.xml。"
changed_files:
  - path: "client/flutter_app/shaders/glass_refraction.frag"
    change: "GLES离屏纹理方向补偿与版本迁移宏保护。"
  - path: "client/flutter_app/lib/features/plans/presentation/widgets/plan_clock_range_picker.dart"
    change: "72dp手柄目标、选择性立即接管的手势识别器、环带外命中与可见圆点反馈。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/android_home_shell.dart"
    change: "每日标语卡片、午夜计时及生命周期恢复刷新。"
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "每日标语在专注中保持显示，恢复前台刷新。"
  - path: "client/flutter_app/test/core/widgets/glass_refraction_test.dart"
    change: "离屏同步纹理及纵轴位置/位移像素断言。"
  - path: "client/flutter_app/test/support/glass_backend_probe.dart"
    change: "独立设备入口检验真实GLES采样方向；不进入生产main入口。"
  - path: "client/flutter_app/test/features/plans/android_plan_clock_test.dart"
    change: "3项手柄/滚动竞争回归。"
  - path: "client/flutter_app/test/features/home/android_home_shell_test.dart"
    change: "两主题/双语/窄屏与专注状态标语回归。"
  - path: "client/flutter_app/test/features/home/desktop_daily_slogan_test.dart"
    change: "四主题/双语/大小画布在专注时仍显示同日标语。"
  - path: "docs/planning/Innocence-UI设计规划.md、Innocence-Android版本实施规划.md、Innocence-离线模式主题标语与年月计划实施规划.md"
    change: "存档本轮要求/取消歌词决定与现行材质、触控、标语规则，覆盖旧专注替换标语规则。"
  - path: "progress/0000__AI-RESUME.md、progress/INDEX.md"
    change: "记录0084本地成果与待实体设备/Windows运行验收边界。"
evidence:
  - command: "dart format（本轮Dart文件）；flutter analyze --no-pub"
    result: "最终退出码0，No issues found!（25.5秒）；首次闭包级联编译错误已改为明确回调赋值。"
  - command: "flutter test --no-pub test/features/plans/android_plan_clock_test.dart test/core/widgets/glass_refraction_test.dart"
    result: "退出码0，17项通过；首次新增手势用例按点在组件边界外而失败，修正为组件内原环带外位置后通过，另增加32dp目标用例。"
  - command: "flutter test --no-pub test/features/home/android_home_shell_test.dart test/features/home/desktop_daily_slogan_test.dart"
    result: "退出码0，7项通过，包括Android4组合、Windows16组合标语显示检查。"
  - command: "flutter test --no-pub --reporter expanded"
    result: "退出码0，00:24 +99: All tests passed!。"
  - command: "flutter test --no-pub --dart-define=INNOCENCE_OFFLINE_ONLY=true test/app/offline_release_test.dart test/app/session_controller_offline_restore_test.dart --reporter expanded"
    result: "退出码0，8项通过；离线传输403及旧在线身份阻断/显式选择/缺本机资料恢复负向路径保留。"
  - command: "flutter run --debug --no-pub -d emulator-5562 -t test/support/glass_backend_probe.dart --no-resident（临时禁Kotlin增量）"
    result: "Debug构建66.5秒、安装成功；DDS服务连接报拒绝，未据此声称完整调试会话可用。随后adb logcat单独确认真实Impeller OpenGLES与GLASS_BACKEND_PROBE PASS: green=[30,70,100] expected=[30,70,100]；探针截图目视见同位置光束。"
  - command: "flutter build windows --release --no-pub"
    result: "退出码0，57.2秒；完整运行目录压缩为独立本地便携ZIP。Windows实际窗口与多DPI本轮未操作。"
  - command: "临时加载既有DPAPI保护签名到进程环境；flutter build apk --release --no-pub --dart-define=INNOCENCE_OFFLINE_ONLY=true；最后恢复环境"
    result: "退出码0，47.7秒；APK62476948字节；未更换密钥或将密码写仓库/输出。"
  - command: "apksigner verify --verbose --print-certs；aapt dump badging/permissions"
    result: "v2签名有效，证书SHA256=c39218092db96b3c4085b0853bb781399b7d4fe1747a9d1032844b8154c05837；versionName1.2.0/versionCode5，minSdk24/targetSdk36；最终Manifest无INTERNET。"
  - command: "独立userdata启动emulator-5562；adb安装/启动、uiautomator dump、screencap；input swipe 986 1087 986 1024 180；保存与install -r后冷启动"
    result: "安装/覆盖均Success，冷启动Status ok；两主题标语可见；外缘垂直短拖06:00–09:00变为05:30–09:00（210分钟），圆盘语义区域仍[74,496][1006,1913]，无外层滚动；恢复后任务05:30–09:00与玻璃主题保留。最终应用PID致命错误筛选0。"
  - command: "Get-FileHash -Algorithm SHA256；Compress-Archive"
    result: "Android SHA256=dd1dfe7485209873304f23d7f3a52bd7a80e6322b873977d3b62dca98f06368c；Windows ZIP14920651字节/SHA256=8affddab2abe1deb795b98aa0d9b570dd679d68d14cb00d4eb790d9ae67abb4b。"
  - command: "git diff --check；UI存档原文Contains核对"
    result: "空白检查退出码0，仅LF/CRLF提示；原文两句和取消歌词答复保存为UTF-8。"
compatibility_and_security:
  contract_impact: "none；半小时当天槽/接口/数据模型/主题存储值保持；专注与每日标语呈现优先级有明确用户决策记录。"
  tenant_impact: "none；探针只用人工光场，Release触控验证只写独立新userdata的合成计划，不接管既有用户草稿或真实账号数据。"
  sensitive_data: "签名材料仅受限目录/进程环境；截图与userdata及构建产物均仓库外或Git忽略目录，真实凭据未输出。"
risks_or_blockers:
  - "实体Android手机、Vulkan设备、完整键盘/大字体/多DPI/长时间性能未验收；本轮不会自动通过G01或Android A0–A5。"
  - "Windows只有源码布局回归与Release构建证据；本轮未接管用户窗口，运行画面/多DPI另验。"
  - "本地文件仍为1.2.0+5修正版，未发布到GitHub；后续正式发布需另行版本递增与远端授权。正式签名包不可直接覆盖不同签名Debug安装。"
  - "真实认证失败、跨租户与在线权限拒绝回放本轮视觉触控范围未执行；缺字段/离线拒绝路径随全量和专项执行，无场景降级保持可读/可交互，着色器加载失败未在设备主动注入。"
next_actions:
  - id: NEXT-0084-PHYSICAL-DEVICE
    action: "用户实体手机安装同签名本地修正版，核对玻璃光场位置/滚动与圆盘外缘垂直短拖；补Vulkan与Windows多DPI实际画面。"
    inputs: ["client/flutter_app/build/verification/20261002-fixes/", "F:/AndroidSdk-Innocence/captures/20261002-fixes/"]
---

本轮专属产物不覆盖0083的公开资产。未执行push、tag或发布Release。原图只作为用户问题证据，不作为客户端背景或素材。
