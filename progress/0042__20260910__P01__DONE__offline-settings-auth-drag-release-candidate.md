---
schema_version: 1
document_type: checkpoint
sequence: "0042"
created_at: "2026-09-10T00:16:39+08:00"
phase: P01
type: DONE
status: complete
title: "离线设置分级开放与认证页拖窗发布候选"
objective: "按用户验收反馈开放离线可用设置、隐藏联网设置，并修复认证页顶部无法拖动 Windows 窗口的问题"
completed:
  - fact: "用户确认普通 Canvas 边框拖动与离线模式已经可用；该结论只覆盖用户实际反馈，不扩展为完整 DPI/八方向矩阵。"
    evidence: "2026-09-09 用户反馈：拖动边框已经可以使用，离线模式也可以用"
  - fact: "离线模式可进入系统设置，只展示语言、本机资料、桌面体验、外观和本机操作；隐私、通知、设备会话、后台管理和账号注销不出现在离线导航。"
    evidence: "SettingsPage.isOfflineMode 能力矩阵；offline_settings_page_test.dart 通过"
  - fact: "离线 Canvas/Focus Orb 桌面偏好写入 local_widget_setting，数据库从版本 1 平滑升级到版本 2，偏好不进入云端业务 outbox。"
    evidence: "OfflineStore.loadLocalWidgetSetting/saveLocalWidgetSetting；持久化与 outbox=0 测试通过"
  - fact: "认证页顶部拖动命中层移到滚动内容之上，范围避开 10px 缩放边缘与右上窗口按钮；无按钮的品牌展示区也可拖动。"
    evidence: "auth_experience.dart；widget_test.dart 验证拖动手势实际发送 startWindowDrag"
  - fact: "Windows Release 重新构建并启动，主进程可响应。"
    evidence: "PID 8228，ProcessName=innocence_flutter，Responding=True，MainWindowTitle=Innocence"
changed_files:
  - path: "client/flutter_app/lib/features/auth/presentation/widgets/auth_experience.dart"
    change: "重排认证页拖动命中层并增加品牌区拖动"
  - path: "client/flutter_app/lib/features/home/presentation/pages/home_page.dart"
    change: "离线模式不再拦截设置入口，也不触发云端设置刷新"
  - path: "client/flutter_app/lib/features/settings/presentation/pages/settings_page.dart"
    change: "增加离线能力矩阵、提示、联网分区过滤与主题化 Material 命中表面"
  - path: "client/flutter_app/lib/core/local/offline_store.dart"
    change: "新增本机桌面偏好表、读写方法与 schema v2 升级"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "进入离线模式时恢复桌面偏好，并允许离线本地更新"
  - path: "client/flutter_app/test/widget_test.dart"
    change: "验证认证页拖动区域存在并发送原生拖窗方法"
  - path: "client/flutter_app/test/features/settings/offline_settings_page_test.dart"
    change: "验证离线设置分区和本机桌面开关可操作"
  - path: "client/flutter_app/test/core/local/offline_store_test.dart"
    change: "验证桌面偏好持久化且不产生同步 outbox"
  - path: "docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md"
    change: "覆盖离线设置和认证页拖窗的相悖旧计划"
evidence:
  - command: "cd client/flutter_app && flutter analyze"
    result: "No issues found"
  - command: "cd client/flutter_app && flutter test"
    result: "51 项通过，0 失败"
  - command: "cd server/innocence-server && mvn test"
    result: "36 项通过，0 失败，BUILD SUCCESS"
  - command: "cd client/flutter_app && flutter build windows --release"
    result: "成功生成 build/windows/x64/runner/Release/innocence_flutter.exe"
  - command: "Start-Process Release/innocence_flutter.exe 后查询进程"
    result: "PID 8228 存活、Responding=True、窗口标题 Innocence"
  - command: "git diff --check"
    result: "退出码 0；仅 LF→CRLF 提示，无空白错误"
compatibility_and_security:
  contract_impact: "服务端 API 契约无新增；本地 SQLite schema 从 v1 升级到 v2"
  tenant_impact: "本机桌面偏好继续按 local ownerScope 隔离；离线设置不调用需要 Bearer token 的接口"
  sensitive_data: "none；未记录邮箱、密码、验证码、token 或本地业务正文"
risks_or_blockers:
  - "computer-use 运行时未实际暴露 getApp/listApps，无法自动执行纠正后的认证页鼠标拖动；当前只有方法通道回归与 Release 启动证据。"
  - "完整 100%/125%/150% DPI 八方向矩阵和真实登录会话同步 HTTP 回放仍属后续验收，不作为本发布候选已完成人工验证。"
next_actions:
  - id: NEXT-001
    action: "提交并推送当前实现，创建 Windows 预览 Release 并上传完整 x64 运行目录压缩包。"
    inputs: ["origin/main", "pubspec version 0.0.1+1"]
  - id: NEXT-002
    action: "用户在已启动 PID 8228 的登录页顶部空白条和左侧品牌区各拖动一次，确认纠正后的真实窗口移动。"
    inputs: ["Windows Release"]
---
