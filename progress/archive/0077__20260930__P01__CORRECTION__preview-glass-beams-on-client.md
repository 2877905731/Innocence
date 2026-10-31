---
schema_version: 1
document_type: checkpoint
sequence: "0077"
created_at: "2026-09-30T13:21:32+08:00"
phase: P01
type: CORRECTION
status: complete
title: "液态玻璃客户端光束按网页预览重建"
objective: "纠正 Flutter 宽幅线性光带与用户认可的网页预览效果不一致，并核对 Windows/Android 实际画面"
completed:
  - fact: "以预览 CSS 的两条椭圆光束和电蓝光晕替换 Flutter 原三条宽幅线性光带；逐层对应尺寸、色标、40/22/36px 模糊、28/24/32 秒 ease-in-out 往返轨迹"
    evidence: "docs/design/templates/ui-redesign-preview.css:27-33；client/flutter_app/lib/core/widgets/glass_motion_backdrop.dart"
  - fact: "Windows Debug 认证与离线首页实际画面可见独立光束漂移及中性卡片内透光变化；Android API36 Pixel 7 模拟器两个时间点截图可见紫/蓝穿透变化，未见此前的径向圆边伪影"
    evidence: "computer-use sky 窗口截图；F:/AndroidSdk-Innocence/captures/innocence-glass-beam.png 与 innocence-glass-beam-later.png"
  - fact: "白色主题、面板本身的颜色/模糊和业务数据逻辑未改变；减少动画时停留首帧，退到后台时停止计时"
    evidence: "本次代码差异仅在 glass_motion_backdrop.dart 的背景绘制及相应规划/记录"
changed_files:
  - path: "client/flutter_app/lib/core/widgets/glass_motion_backdrop.dart"
    change: "按网页 CSS 重建三层椭圆光源、背景径向微光与独立往返动画"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "存档用户光束修正指令与参数基准"
  - path: "docs/design/templates/UI-REDESIGN-20260929.md"
    change: "记录客户端与预览光束对齐及双端目视证据"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新当前基线和后续验收边界"
  - path: "progress/INDEX.md"
    change: "追加本检查点"
evidence:
  - command: "dart format lib/core/widgets/glass_motion_backdrop.dart；flutter analyze --no-pub"
    result: "退出码0；No issues found"
  - command: "flutter test --no-pub"
    result: "退出码0；74 tests passed"
  - command: "flutter build windows --debug --no-pub；flutter build windows --release --no-pub"
    result: "均退出码0；Debug/Release 构建目录生成"
  - command: "GRADLE_OPTS=-Dorg.gradle.project.kotlin.incremental=false；flutter build apk --debug --no-pub"
    result: "退出码0；app-debug.apk 180087341 bytes，SHA-256 13980A54EBF172B1C0B3D004C5897713F5D267B7DE3560DCEB6FAEFAD30F6676"
  - command: "adb install -r；am force-stop；am start -W；pidof；screencap；logcat -d -t 400 筛选致命错误"
    result: "安装 Success，冷启动 Status: ok / LaunchState: COLD / PID 3051；两个时间点截图已目视，最近 400 行无匹配 FATAL EXCEPTION / E/flutter"
  - command: "computer-use sky.launch_app / get_window_state / click"
    result: "Windows Debug 认证页与离线首页可见，光束和面板透光随时间变化"
  - command: "git diff --check -- 本轮跟踪文件"
    result: "退出码0；仅有工作副本 LF/CRLF 提示"
compatibility_and_security:
  contract_impact: "none；未改接口、主题存储值和业务字段"
  tenant_impact: "none；背景仅视觉绘制，原登录/离线 ownerScope 逻辑不变"
  sensitive_data: "none；未复制真实凭据或第三方原图，未执行远端 Git 动作"
risks_or_blockers:
  - "Flutter 与浏览器的渐变光栅化不同，参数逐项对应 CSS 但不声称像素逐点一致"
  - "实体 Android、Windows 多 DPI 与长时间帧率/耗电未验收"
  - "认证失败、租户不匹配、权限拒绝、缺字段及生成失败的业务负向路径不在本次纯背景修改范围；沿用已有逻辑，本轮未回放"
next_actions:
  - id: NEXT-GLASS-VISUAL-MATRIX
    action: "在实体 Android 与 Windows 多 DPI/长时间运行中核对光束流畅度、面板透光和文字对比度"
    inputs: ["client/flutter_app/lib/core/widgets/glass_motion_backdrop.dart", "docs/design/templates/liquid-glass-preview.html"]
  - id: NEXT-TWO-THEME-DETAILS
    action: "继续两主题业务详情页的旧静态样式清理与实际页面回归"
    inputs: ["progress/0000__AI-RESUME.md"]
---
