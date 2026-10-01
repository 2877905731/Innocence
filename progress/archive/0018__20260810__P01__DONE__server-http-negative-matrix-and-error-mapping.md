---
schema_version: 1
document_type: checkpoint
sequence: "0018"
created_at: "2026-08-10T12:16:19+08:00"
phase: P01
type: DONE
status: complete
title: "会话、黑名单与头像上传真实 HTTP 负向矩阵"
objective: "解除数据库集成环境阻塞，回放 U09-U13 服务端正常与负向路径并修复发现的契约偏差"
completed:
  - fact: "在隔离 MySQL 8 与 Redis 7 环境完成 1 手机 + 1 电脑并存、同槽桌面替换、旧会话拒绝和新会话保持回放"
    evidence: "真实 HTTP 返回：初始手机/桌面与替换后手机/新桌面均 HTTP 200；旧桌面会话 HTTP 401 + code=2000"
  - fact: "完成黑名单空/非空、新增、重复、本人、所属用户解除和跨租户身份不匹配回放"
    evidence: "U09-U12 正常路径 HTTP 200；本人/重复拉黑 HTTP 400 + code=1000；租户不匹配 HTTP 401 + code=2000"
  - fact: "完成头像缺失、超限、伪图片、失效会话、跨租户、正常上传、资料回写与静态资源精确字节回放"
    evidence: "U13 正常路径 HTTP 200；业务输入失败 HTTP 400 + code=1000；会话/租户失败 HTTP 401 + code=2000；下载字节与上传 PNG 完全一致"
  - fact: "存储失败回放发现 code=9000 被错误映射为 HTTP 400，修复后复验为 HTTP 500 + code=9000"
    evidence: "GlobalExceptionHandler 新增 INTERNAL_ERROR → INTERNAL_SERVER_ERROR 映射及两项回归测试"
  - fact: "完整 Spring 上下文和全部后端测试在隔离数据库环境通过"
    evidence: "Surefire 汇总 6 suites / 16 tests / 0 failures / 0 errors / 0 skipped"
changed_files:
  - path: "server/innocence-server/src/main/java/com/innocence/server/common/web/GlobalExceptionHandler.java"
    change: "将内部业务错误 code=9000 映射为 HTTP 500"
  - path: "server/innocence-server/src/test/java/com/innocence/server/common/web/GlobalExceptionHandlerTest.java"
    change: "新增内部错误 HTTP 500 与普通业务错误 HTTP 400 回归测试"
  - path: "docs/06-contract-inventory.md"
    change: "将 U09-U12 更新为 HTTP 已验证，将 U13 更新为服务端 HTTP 已验证、客户端工具链待补"
  - path: "docs/03-execution-plan.md"
    change: "同步 G01 会话策略与负向路径真实 HTTP 验收状态"
  - path: "progress/0000__AI-RESUME.md"
    change: "移除数据库集成环境待办，接续目标收敛到 Flutter/Windows 工具链"
  - path: "progress/INDEX.md"
    change: "追加 0018 检查点索引"
evidence:
  - command: "Python 标准库向 127.0.0.1:18080 回放 U09-U13 会话、黑名单和头像 multipart 矩阵"
    result: "21 项 HTTP 状态/业务码断言及 1 项头像静态资源精确字节断言全部通过"
  - command: "以普通文件作为 avatar storage-dir 启动 18081 实例并回放有效 PNG"
    result: "修复前 HTTP 400 + code=9000；修复后 HTTP 500 + code=9000"
  - command: "mvn -q '-Dspring.datasource.url=jdbc:mysql://127.0.0.1:3307/innocence' '-Dspring.data.redis.port=6380' test"
    result: "通过；6 个测试套件共 16 项，0 failure、0 error、0 skipped，包含 contextLoads"
  - command: "mvn -q -DskipTests package"
    result: "通过；修复后的 Spring Boot JAR 打包成功"
compatibility_and_security:
  contract_impact: "修正 U13 已登记的 HTTP 500/code=9000 语义；不改字段或成功响应"
  tenant_impact: "真实 HTTP 回放确认 session token 与 user/device slot 绑定，跨用户身份头与 token 不匹配时拒绝"
  sensitive_data: "仅使用 example.invalid 合成账号、合成口令、临时 token 和 1×1 PNG；未输出 token，未使用真实邮箱、密码或个人身份"
risks_or_blockers:
  - "本机仍未安装 Flutter/Dart SDK，尚不能执行 pub get、analyze、Flutter 测试、Windows 构建与 DPI 实机验收"
next_actions:
  - id: NEXT-001
    action: "Flutter SDK 可用后执行 pub get、锁文件核对、analyze、test 和 Windows 构建"
    inputs: ["Flutter SDK", "Dart SDK"]
  - id: NEXT-002
    action: "Windows 构建成功后完成三档画布在 100%/125%/150% DPI 的头像选择与页面验收"
    inputs: ["Flutter Windows 构建", "Windows DPI 环境"]
---

# 检查点说明

本检查点只声明服务端集成 HTTP 矩阵完成；Flutter 客户端与 Windows 实机验收仍按 TRUTHFUL-SCOPE 保持未完成。
