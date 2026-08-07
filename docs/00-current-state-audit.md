---
schema_version: 1
document_type: current_state_audit
project_name: "Innocence"
audit_date: "2026-08-07"
source:
  summary: "Innocence 为自有立项产品（非迁移/非集成项目），产品规划已完成，代码已部分落地"
  evidence:
    - file_count: "约 300+（前后端工程含模板生成物）"
    - commit_or_hash: "46e9ddf（origin/main 最新）"
baseline:
  tech_stack: "Flutter（Android/Windows）+ Java 21 + Spring Boot 3.3.2 + MyBatis + MySQL 8 + Redis + Spring Mail + Spring WebSocket + Docker Compose"
  implemented_capabilities:
    - "账号认证链路：邮箱注册、邮箱+密码登录、邮箱+验证码登录、验证码发送、会话恢复"
    - "双端在线策略：1 台手机 + 1 台电脑，按规则处理会话替换"
    - "今日计划与短计划：48 个半小时单元时间轴编辑器、时间块创建/命名/完成状态/时长汇总、重叠与时间校验"
    - "周模板：保存当天短计划为模板、模板列表、套用到指定日期"
    - "周计划总览：周一到周日概览、周切换、点日期进编辑"
    - "定时系统最小闭环：开始学习时段/当前状态/手动结束"
    - "首页学习状态卡：发起学习、绑定自定义番茄循环、倒计时、预计结束时间"
    - "签到系统：今日签到状态查询/手动提交、按当天计划完成校验、失败记录（保留时长不计成功）"
    - "统计中心简版：近 7/30 天聚合学习时长、番茄数、签到、失败次数、完成率；趋势图四类指标切换"
    - "统计中心独立页：核心指标区、趋势详情区、每日拆解区、失败记录区（含删除）"
  automated_tests:
    count: null
    command: "未建立自动化测试基线"
    result: "未执行"
  runtime_evidence:
    - "项目 README 记录本地 MySQL:3306 / Redis:6379，application-local.yml 指向 127.0.0.1"
  incomplete_items:
    - "好友/团队/私信/群聊/提醒/通知中心：接口草案已定，开发未完成（后端 friend/team/report/notification 模块与前端 features 已有骨架）"
    - "后台管理：仅骨架"
    - "桌面挂件：未落地"
    - "UI：2026-08-07 决定全面推翻重写，旧视觉约束文档已删除"
    - "自动化测试：无"
gaps:
  - id: GAP-001
    description: "治理基线缺失：无 AGENTS、无 progress、无阶段门禁——本文件与 docs 0~8 即为此缺口补齐"
    gate: G00
  - id: GAP-002
    description: "UI 设计体系缺失：三主题未定（待用户提示词），页面布局将全部重建"
    gate: G00.5
  - id: GAP-003
    description: "社交骨架（P03）为最大未开发模块，依赖新 UI 设计先行"
    gate: G03
evidence:
  - command: "git log --oneline"
    result: "7bac3a2..46e9ddf 共 6 次提交，最新 docs: 移除桌面端毛玻璃强制约束，UI 视觉方向全面重写"
