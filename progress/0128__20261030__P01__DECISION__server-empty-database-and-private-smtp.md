---
schema_version: 1
document_type: checkpoint
sequence: "0128"
created_at: "2026-10-30T19:05:00+08:00"
phase: P01
type: DECISION
status: complete
title: "用户选择服务器空库及自填SMTP，正常邮箱注册辅助就绪"
objective: "固化服务器初始化与凭据范围，准备新空库通过现有邮箱验证码流程注册管理员账号的本机辅助"
completed:
  - fact: "用户选择从空库开始，不迁移本地数据。"
    evidence: "当前会话异步问题回复原文：从空库开始，不迁移本地数据。"
  - fact: "用户已有SMTP，由用户直接在服务器填写配置。"
    evidence: "当前会话回复原文：已有 SMTP，可在服务器填写配置。未提供或读取SMTP授权码。"
  - fact: "本机register-admin.ps1通过回环SSH入口请求验证码、注册并尝试退出临时Windows会话；密码/验证码隐藏输入，不输出响应正文或令牌，拒绝非回环URL及重定向。"
    evidence: "PowerShell语法通过；PowerShell7和WindowsPowerShell5.1各7个合成HTTP场景通过，精确UTF8密码/业务字段及会话身份核对。未请求真实服务器或发送真实邮件。"
changed_files:
  - path: "infra/deploy/register-admin.ps1"
    change: "新增在用户电脑执行的正常邮箱注册辅助；不修改数据库直接创建账号。"
  - path: "infra/deploy/README.zh-CN.md"
    change: "说明空库注册入口与本机执行方式，明确0127原包不重建或修改。"
  - path: "progress/0000__AI-RESUME.md"
    change: "更新空库/SMTP选择及服务器配置、启动、真实注册的下一步。"
  - path: "progress/INDEX.md"
    change: "升序追加0128。"
  - path: "progress/0128__20261030__P01__DECISION__server-empty-database-and-private-smtp.md"
    change: "固化本轮用户决定与本机证据。"
evidence:
  - command: "PowerShell Language.Parser.ParseFile(register-admin.ps1)"
    result: "语法错误0。"
  - command: "Python3.12 build/deployment/tools/verify-registration-helper.py；分别使用PowerShell7与WindowsPowerShell5.1执行本机HTTP fixture"
    result: "两种宿主各7项通过：正常注册、SMTP503、验证码400、退出500、缺令牌、302重定向、非回环目标拒绝；精确UTF8/身份字段及令牌不输出核对通过。5.1首次fixture使用不兼容的模块自动加载失败，改用直接构造合成SecureString后7项通过，产品脚本无需该模块。"
compatibility_and_security:
  contract_impact: "调用已有send-register-code/email-register/logout，沿用6到32位密码/6位验证码/windows会话；admin_web权限仍由白名单及服务端核对。"
  tenant_impact: "明确不迁移本地资料；新账号使用正常注册，未设置X-User-Id或绕过邮箱验证。"
  sensitive_data: "没有真实SMTP/账号/密码/验证码/令牌输入或落盘，验证仅用本机fixture和保留域地址；脚本不显示请求/响应正文。"
risks_or_blockers:
  - "用户是否已经上传/解包0127包尚无执行回执；不据本次选择声称初始化完成。"
  - "服务器真实启动、SMTP投递、账号创建及管理员登录/拒绝路径、内存及恢复仍待；0127部署包和SHA不变。"
  - "真实注册成功但退出失败时脚本准确保留账号已创建提示，不要求重建账号；后续管理登录使用独立槽位。"
next_actions:
  - id: NEXT-001
    action: "用户完成0127上传/解包/prepare后直接在服务器填写.env的白名单与SMTP，保留生成密码；按已授权空库方式启动。"
    inputs: ["infra/deploy/.env.example", "infra/deploy/start.sh"]
  - id: NEXT-002
    action: "真实健康通过后通过SSH隧道运行本机注册辅助，接收真实邮件并在后台登录；不向聊天发送.env、验证码或授权码。"
    inputs: ["infra/deploy/register-admin.ps1", "infra/deploy/README.zh-CN.md"]
---
