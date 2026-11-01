---
schema_version: 1
document_type: checkpoint
sequence: "0147"
created_at: "2026-11-01T18:54:57+08:00"
phase: P01
type: DECISION
status: complete
title: "按用户要求在发送登录验证码前拦截未注册邮箱，已部署并保留关闭注册状态"
objective: "修正关闭注册后仍向未注册邮箱发送登录验证码的问题，在发送前返回没有该账号"
source_commit: "305c37579e68d2aa8691ec9d342b80a7a159fc6a"
completed:
  - fact: "用户明确要求：发送验证码前拦截未注册账号，显示没有该账号。登录账号存在性检查不依赖注册开关，开放注册时同样生效。"
    evidence: "本轮用户原文；契约专档新增登录验证码账号校验，HTTP 404/code4004/message精确为没有该账号。"
  - fact: "发送服务先复用登录使用的findAuthByEmail，不存在就拒绝，不调用SMTP或Redis；现有账号保持原发送和验证码登录流程。"
    evidence: "EmailCodeService唯一后端业务代码差异；未知/已删除账号、数据库失败、邮件失败和请求校验负向覆盖。"
  - fact: "全量后端104项回归及隔离真实HTTP通过。"
    evidence: "0失败/0错误/0跳过；独立MySQL8.4/Redis7.2/qa profile与受控SMTP，未使用生产资料或真实邮箱。"
  - fact: "服务器部署完成，生产可信HTTPS未知账号立即404，当前注册关闭状态保留，服务健康UP。"
    evidence: "备份pre-online-20261101105418；候选/运行JAR SHA256相等；生产未知邮箱无验证码/冷却键，缺字段400/管理公网404/manifest及SHA256SUMS通过。"
changed_files:
  - path: "server/innocence-server/src/main/java/com/innocence/server/modules/account/service/EmailCodeService.java"
    change: "注入UserMapper，登录验证码发送前校验邮箱认证记录并返回明确错误。"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/account/service/EmailCodeServiceTest.java"
    change: "新增11项服务/MockMvc用例，覆盖开关两态、准确提示、零邮件/Redis副作用、已注册发送、冷却、数据库/邮件失败和字段校验。"
  - path: "server/innocence-server/src/test/java/com/innocence/server/modules/account/service/AdminAccountControlsTest.java"
    change: "适配新增依赖，保留关闭注册零副作用校验。"
  - path: "docs/development/后台注册控制与用户删除.md"
    change: "记录用户决策、发送前账号预检契约和本轮隔离/部署证据。"
  - path: "docs/06-contract-inventory.md"
    change: "登记登录验证码接口的请求、响应、错误与核验状态。"
  - path: "progress/0000__AI-RESUME.md"
    change: "恢复时间、最新检查点和后台实际反馈状态更新，保留原鸿蒙审核待办。"
  - path: "progress/INDEX.md"
    change: "升序追加0147。"
  - path: "progress/0147__20261101__P01__DECISION__login-code-account-check-deployed.md"
    change: "记录本轮行为决策、实际命令与上线边界。"
evidence:
  - command: "mvn -q verify；汇总target/surefire-reports/TEST-*.xml"
    result: "104项，failures=0/errors=0/skipped=0；新增EmailCodeServiceTest为11项。"
  - command: "git diff --stat 7d5452c HEAD -- server/innocence-server/src/main；prepare.py JAR CRC/条目与内容逐字节校验"
    result: "后端业务源码仅EmailCodeService变更；剔除application-local.yml，其余JAR条目字节一致；干净跟踪源码305c375；构建产物不入Git。"
  - command: "严格主机密钥校验SSH；docker build -t innocence-server:login-code-20261101；python3 verify_http.py"
    result: "注册关闭/开放两态：未知账号404且无SMTP/Redis，已有账号发送200/登录200/资料owner正确、错误验证码400/冷却429；注册关闭仍403；缺失/非法邮箱400；删除认证记录后带旧验证码及冷却仍404；SMTP失败500且无新增码/冷却。SMTP仅受控接收3封合成邮件，消息正文不留存；finally清理隔离容器及卷。"
  - command: "python3 /opt/innocence/login-code-20261101/deploy_backend.py"
    result: "先私有备份DB/头像/旧JAR/镜像/manifest与校验清单，再仅更新后端，无SQL迁移；healthy/HTTPS UP；注册enabled=0保持；未知账号404/4004/UTF-8精确提示没有该账号，验证码及冷却键均不存在；缺字段400/1001、管理公网404；所有部署文件散列通过。未触发部署回退。"
  - command: "候选镜像与运行容器sha256sum /app/server.jar；生产及QA回执取回F盘忽略目录"
    result: "两者均47576e8e3ffba3aef9d398facb11321f1253f2ce18e2c5bbdeb158143ef49eb3；回执位于build/deployment/login-code-20261101/qa-result.json与production-result.json。"
compatibility_and_security:
  contract_impact: "登录验证码新增404/4004/没有该账号前置错误，注册开关不阻断已有账号；三端现有认证页展示API错误且失败不开始倒计时，无需更新客户端。密码找回及独立注册流程未变。"
  tenant_impact: "只查询输入邮箱是否存在认证记录，不返回身份或业务资料；合成HTTP登录读取其自身userId验证；未修改真实账号或会话资料，不改变租户授权。"
  sensitive_data: "真实配置/SSH身份仅既有私有位置；生产仅验证确定不存在的合成邮箱，不触发真实SMTP；无邮箱/验证码/令牌正文日志或Git产物。未执行Git远端操作。"
risks_or_blockers:
  - "真实SMTP投递未在本轮验证；正向发送通过受控SMTP及验证码登录HTTP验证。部署回退分支本轮未触发。"
  - "本轮为后台反馈修复，不改变Harmony TIMER审核中状态，不标记P01/G01整体完成。"
next_actions:
  - id: NEXT-001
    action: "用户可直接用现有客户端重试未注册邮箱，预期立即显示没有该账号；继续按真实使用反馈处理。保持当前注册关闭设置。"
    inputs: [docs/development/后台注册控制与用户删除.md]
---
