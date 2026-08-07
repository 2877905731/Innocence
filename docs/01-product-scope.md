---
schema_version: 1
document_type: product_scope
project_name: "Innocence"
goal: "为有学习、自律、备考、长期坚持需求的用户，提供手机端 + 桌面端的熟人圈轻社交陪伴工具：完成「计划 - 学习 - 记录 - 签到 - 统计」个人闭环，以及 1~5 人小团队互看进度、互相提醒的陪伴闭环"
in_scope:
  - id: SCOPE-001
    capability: "账户与登录（邮箱注册/密码/验证码登录、找回、资料、黑名单、隐私、注销）"
    done_when: "MVP 完成标准第 1、2、9 条验收通过"
  - id: SCOPE-002
    capability: "设备与同步（1 台手机 + 1 台电脑同时在线、学习状态/计划/通知红点同步、桌面离线补传）"
    done_when: "MVP 完成标准第 2 条验收通过"
  - id: SCOPE-003
    capability: "学习主闭环（短/长/超长计划、定时与番茄、签到、备忘录、首页聚合）"
    done_when: "MVP 完成标准第 3、4、7 条验收通过"
  - id: SCOPE-004
    capability: "社交骨架（好友、团队、私信、团队群聊、提醒、队友进度可见）"
    done_when: "MVP 完成标准第 5、6 条验收通过"
  - id: SCOPE-005
    capability: "统计中心（番茄/时长/签到/完成率/趋势图/失败摘要/队友摘要）"
    done_when: "MVP 完成标准第 4 条验收通过"
  - id: SCOPE-006
    capability: "系统通知（好友申请/团队邀请/提醒/完成/签到结果/公告，站内+手机推送+桌面通知，30 天保留）"
    done_when: "MVP 完成标准第 6、8 条验收通过"
  - id: SCOPE-007
    capability: "后台管理（用户/团队/通知/举报/敏感词/公告，审计留痕）"
    done_when: "MVP 完成标准第 8 条验收通过"
  - id: SCOPE-008
    capability: "UI 设计体系（信息架构、双端布局、视觉令牌、三个并存可切换主题、组件体系）"
    done_when: "三主题切换生效、双端观感一致、登录到二级页全部按新设计落地"
out_of_scope:
  - id: OUT-001
    item: "陌生人私信、陌生人社交广场、推荐好友/团队"
  - id: OUT-002
    item: "图片/语音/文件聊天、团队留言板、好友留言板"
  - id: OUT-003
    item: "自定义签到任务、补签、备忘录提醒、备忘录回收站"
  - id: OUT-004
    item: "多手机/多电脑并发、复杂同步冲突合并、复杂排行榜、勋章成就体系"
  - id: OUT-005
    item: "AI 内容审核、多层级管理员权限体系"
definition_of_done:
  - scope_id: SCOPE-001
    evidence: "MVP 完成标准 9 条逐条验收记录（P06 阶段门禁）"
  - scope_id: SCOPE-008
    evidence: "三主题在设置中可切换；页面按新设计重建完成（P00.5 门禁）"
decision_entrypoint:
  checkpoint_type: DECISION
  source: progress/
---

# 产品范围说明

本文为治理层范围指针，详细产品规格见：

- 产品规划与模块结论：`docs/planning/Innocence-项目计划书.md`（15 模块全部封板）
- 第一版范围边界：`docs/planning/Innocence-MVP第一版功能范围.md`
- UI 规划与主题存档：`docs/planning/Innocence-UI设计规划.md`（待创建，P00.5 先行产出）

范围变更须通过 DECISION 检查点记录。
