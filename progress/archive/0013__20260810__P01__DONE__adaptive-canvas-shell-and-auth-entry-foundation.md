---
schema_version: 1
document_type: checkpoint
sequence: "0013"
created_at: "2026-08-10T09:59:05+08:00"
phase: P01
type: DONE
status: complete
title: "Windows 自适应画布、Focus Orb 与认证入口首批实现"
objective: "完成 P01 第一段源码实现：DesktopPresentationTier、自适应 6+2 主 Shell、Focus Orb、认证入口与重置密码真实调用"
completed:
  - fact: "Large/Medium/Small 由宽高共同解析，使用 32px 回滞；三档分别映射 full/comfortable/compact 与 rail/compactRail/bottomBar"
    evidence: "client/flutter_app/lib/core/layout/desktop_presentation.dart"
  - fact: "Windows 登录后主框架接入 6 个主工作区与备忘录、设置 2 个工具入口；首页、计划、专注、陪伴、收件箱、统计均绑定现有真实模型和回调"
    evidence: "client/flutter_app/lib/core/widgets/adaptive_canvas_shell.dart；client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
  - fact: "Focus Orb 作为独立 glance 表面由用户主动进入，使用真实专注倒计时，可恢复 Canvas、开始或结束专注；原生窗口按 DPI 执行 88×88 与 Canvas 最小尺寸"
    evidence: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart；client/flutter_app/windows/runner/win32_window.cpp"
  - fact: "认证页完成暖米色直角视觉重建，并接入登录、验证码登录、注册、发送重置验证码和重置密码"
    evidence: "client/flutter_app/lib/features/auth/presentation/pages/auth_page.dart；client/flutter_app/lib/features/auth/data/auth_api.dart；client/flutter_app/lib/app/session_controller.dart"
  - fact: "新增尺寸策略测试、Focus Orb 契约测试，以及找回密码入口和缺失邮箱负向 UI 测试源码"
    evidence: "client/flutter_app/test/core/layout/desktop_presentation_test.dart；client/flutter_app/test/widget_test.dart"
changed_files:
  - path: "client/flutter_app/lib/core/layout/desktop_presentation.dart"
    change: "新增窗口表面、三档呈现、组件密度、导航策略、断点与回滞解析"
  - path: "client/flutter_app/lib/core/widgets/adaptive_canvas_shell.dart"
    change: "新增 Large/Medium rail、Small 四项底栏、工具溢出、命令栏和 Orb 入口"
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "新增真实数据驱动的 6 个主工作区和 88×88 Focus Orb"
  - path: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
    change: "Windows 分支切换到 AdaptiveDesktopHome，保留既有业务回调"
  - path: "client/flutter_app/lib/features/auth/presentation/pages/auth_page.dart"
    change: "重建认证布局并加入找回/重置密码模式与缺失字段校验"
  - path: "client/flutter_app/lib/features/auth/data/auth_api.dart"
    change: "加入发送重置验证码和重置密码 API"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "加入重置密码控制流程和双语结果横幅"
  - path: "client/flutter_app/lib/core/platform/desktop_widget_bridge.dart"
    change: "统一 canvas/orb 语义并兼容原生 page/mini 模式"
  - path: "client/flutter_app/lib/app/app.dart"
    change: "认证后窗口进入 canvas 模式"
  - path: "client/flutter_app/windows/runner/win32_window.cpp"
    change: "调整默认/最小尺寸、最大化、DPI 缩放、Orb 尺寸和托盘恢复行为"
  - path: "client/flutter_app/windows/runner/win32_window.h"
    change: "同步自适应 Canvas 说明与默认尺寸"
  - path: "client/flutter_app/test/core/layout/desktop_presentation_test.dart"
    change: "新增断点、回滞、密度、导航和 Orb 契约测试源码"
  - path: "client/flutter_app/test/widget_test.dart"
    change: "修正启动测试构造参数，并覆盖重置入口和缺失邮箱提示"
  - path: "docs/06-contract-inventory.md"
    change: "登记重置密码与发送重置验证码契约核验点 U07/U08"
  - path: "docs/07-dataflow-and-module-map.md"
    change: "登记 layout/widgets 代码位置并扩展契约范围到 U08"
evidence:
  - command: "PowerShell 扫描页面 ID、关键类型、服务端路由及 Dart/C++ 分隔符"
    result: "47 个语义页面 ID 全部唯一；8 个关键实现令牌存在；2 个重置路由与服务端匹配；10 个 Dart 文件和 1 个 C++ 文件分隔符计数平衡"
  - command: "PowerShell 扫描变更文档引用、全部变更文件尾随空格与禁用标记；git diff --check"
    result: "33 个唯一文档引用均存在；27 个变更文件无尾随空格；无非法 FontWeight、TODO、mock-only 或 placeholder 标记；git diff --check 通过（仅行尾转换提示）"
  - command: "Get-Command flutter；Get-Command dart"
    result: "Flutter 和 Dart 均不可用，因此未执行 flutter analyze、flutter test 或 Windows 构建，不声明测试通过"
compatibility_and_security:
  contract_impact: "新增客户端调用既有 /auth/password/send-reset-code 与 /auth/password/reset；已与 AuthController 和接口草案路径核对，脱敏回放样本仍待收集"
  tenant_impact: "主 Shell 只消费 SessionController 当前登录用户模型；未新增跨用户读取或绕过权限的调用"
  sensitive_data: "未写入真实邮箱、密码、验证码、token 或请求日志"
risks_or_blockers:
  - "Flutter/Dart SDK 不在当前环境，静态分析、测试执行与 Windows 构建尚未完成"
  - "G01 尚未通过：资料、隐私、设置页面重建，以及会话冲突、拉黑、租户不匹配和权限拒绝负向验收仍待完成"
next_actions:
  - id: NEXT-001
    action: "继续按新 UI 重建资料、隐私与设置页面"
    inputs: []
  - id: NEXT-002
    action: "工具链可用后执行 flutter analyze/test 与 Windows 三档尺寸、三档 DPI、Canvas/Orb 实机验收"
    inputs: []
---
