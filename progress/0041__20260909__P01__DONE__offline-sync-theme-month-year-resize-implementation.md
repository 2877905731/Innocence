---
schema_version: 1
document_type: checkpoint
sequence: "0041"
created_at: "2026-09-09T00:12:32+08:00"
phase: P01
type: DONE
status: complete
title: "离线同步、每日主题标语、年月计划与原生缩放代码落地"
objective: "执行 0040 决策与详细规划，完成离线身份/同步、四主题标语、短/月/年计划和 Windows 八方向 sizing loop 的代码与自动化验证"
completed:
  - fact: "认证页可无需登录进入独立 local profile；计划、专注、备忘录、签到意图、日模板、年度区间及派生统计写入 SQLite，并以 local:<uuid> 隔离。"
    evidence: "client/flutter_app/lib/core/local/offline_store.dart；离线仓储 9 项测试通过"
  - fact: "登录后先上传 metadata-only manifest 取得目标账号/冲突预览；用户明确选择保留云端或本地覆盖后，才按依赖顺序逐项幂等导入。"
    evidence: "sync/import-preview、sync/import 客户端与服务端实现；错账号负向单测通过；只有 accepted 在本机标记 synced"
  - fact: "会话恢复只在 HTTP 401/code=2000 时清除登录凭据，网络或初始化故障不再静默注销。"
    evidence: "client/flutter_app/lib/app/session_controller.dart 的 _isAuthenticationFailure 分支"
  - fact: "首页四主题各 7 条标语按本地日期稳定轮换，主题艺术字、跨午夜更新、专注态优先和无障碍语义已接入。"
    evidence: "client/flutter_app/lib/features/home/domain/theme_daily_slogan.dart；对应 3 项测试通过"
  - fact: "短计划保存后继续编辑；长计划展示完整月历并支持横向切月/日模板冲突策略；超长计划展示 12 月、月区间拖动/编辑/删除及主题季节图案。"
    evidence: "Flutter 计划页面与 Java 月/年/日模板/年度区间契约；闰月、12 月结构、跨租户模板和 revision 冲突测试通过"
  - fact: "Flutter 八方向边缘命中触发 Windows 原生 sizing loop，并保留 DPI 命中、移动/缩放持久化和顶层备用命中。"
    evidence: "desktop_resize_frame.dart、desktop_widget_bridge.dart、flutter_window.cpp、win32_window.cpp；Windows Release 编译通过"
  - fact: "Windows Release 已启动且进程响应。"
    evidence: "PID 25640，ProcessName=innocence_flutter，Responding=True，MainWindowTitle=Innocence"
changed_files:
  - path: "client/flutter_app/lib/core/local/offline_store.dart"
    change: "新增本地身份、业务表、outbox、同步结果回写与离线统计"
  - path: "client/flutter_app/lib/core/local/offline_sync_models.dart"
    change: "新增导入 manifest、预览、操作、冲突策略和结果模型"
  - path: "client/flutter_app/lib/features/sync/data/offline_sync_api.dart"
    change: "新增登录后导入预检与确认导入 API adapter"
  - path: "client/flutter_app/lib/app/session_controller.dart"
    change: "接入离线状态、功能路由、非 401 会话保留和确认导入流程"
  - path: "client/flutter_app/lib/app/app.dart"
    change: "接入登录后的目标账号与冲突确认遮罩"
  - path: "client/flutter_app/lib/features/home/presentation/pages/adaptive_desktop_home.dart"
    change: "接入主题标语、月历、年历、季节图案与离线状态"
  - path: "client/flutter_app/lib/features/plans/presentation/widgets/today_plan_editor_dialog.dart"
    change: "保存当天计划后保持可编辑并增加未保存保护"
  - path: "client/flutter_app/lib/core/widgets/desktop_resize_frame.dart"
    change: "新增八方向 Flutter 命中与鼠标拖边桥接"
  - path: "client/flutter_app/windows/runner/win32_window.cpp"
    change: "新增 DPI 命中、原生 sizing loop 与窗口尺寸位置持久化"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/sync/service/SyncImportService.java"
    change: "新增当前用户限定、目标账号确认、依赖排序、逐项事务、幂等与冲突处理"
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/plan/service/StudyPlanService.java"
    change: "新增月/年概览、日模板批量套用与年度区间业务逻辑"
  - path: "server/innocence-server/src/main/resources/schema.sql"
    change: "新增年度计划区间和同步导入操作表"
  - path: "docs/06-contract-inventory.md"
    change: "将同步与年月计划契约更新为实际路径和当前证据状态"
evidence:
  - command: "cd client/flutter_app && flutter analyze"
    result: "No issues found"
  - command: "cd client/flutter_app && flutter test"
    result: "49 项通过，0 失败"
  - command: "cd server/innocence-server && mvn test"
    result: "36 项通过，0 失败，BUILD SUCCESS；Spring local 上下文与 schema 初始化成功"
  - command: "cd client/flutter_app && flutter build windows --release"
    result: "成功生成 build/windows/x64/runner/Release/innocence_flutter.exe"
  - command: "Start-Process Release/innocence_flutter.exe 后查询进程"
    result: "PID 25640 存活、Responding=True、窗口标题 Innocence"
  - command: "git diff --check"
    result: "退出码 0；仅现有 LF→CRLF 提示，无空白错误"
compatibility_and_security:
  contract_impact: "新增 /api/app/v1/sync/import-preview、/sync/import 与 /plans 下月/年/日模板/年度区间路由；旧 week/weekly-templates 保留兼容"
  tenant_impact: "服务端身份只取 Bearer session 对应 RequestUserContext；确认 targetUserNo 不匹配返回 403；模板和年度区间查询均带当前 userId"
  sensitive_data: "manifest 不含业务正文；测试与日志未写入真实邮箱、密码、验证码或完整用户请求"
risks_or_blockers:
  - "当前 Windows UI 自动化附件不可用，未执行 Release 的八方向真实鼠标拖动及 100%/125%/150% DPI 矩阵；不得将人工拖边验收标记完成。"
  - "同步接口已通过单元、全量上下文和客户端仓储验证，但真实登录会话 HTTP 幂等/断线续传回放仍待执行。"
next_actions:
  - id: NEXT-001
    action: "人工拖动当前已启动 Release 的八个方向，并在 100%/125%/150% DPI 记录拖动前后 RECT。"
    inputs: ["PID 25640", "Windows 显示缩放设置"]
  - id: NEXT-002
    action: "启动本地服务并用合成账号回放 import-preview/import，覆盖 keep_server、overwrite、重复 operationId 与错 targetUserNo。"
    inputs: ["docs/06-contract-inventory.md", "server local profile"]
---
