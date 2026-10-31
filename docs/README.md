# 文档目录

当前状态只以[恢复入口](../progress/0000__AI-RESUME.md)为准，再按[检查点索引](../progress/INDEX.md)查证据。不要将旧发布日志、初始审计或历史“待确认”当成当前状态。

## 当前工作入口

| 任务 | 文档 |
|---|---|
| 鸿蒙实况窗审核、预计日期与结果入口 | [权益接入](development/鸿蒙专注提醒权益接入.md) |
| 鸿蒙全屏PC范围与H0-H5待验 | [平板实施规划](planning/Innocence-鸿蒙平板版本实施规划.md) |
| Android通知剩余时间与当前安装包 | [v1.3.2发行说明](releases/v1.3.2.md)、[Android规划](planning/Innocence-Android版本实施规划.md) |
| Windows／鸿蒙当前联网基线 | [三端v1.3.0](releases/v1.3.0.md)、[鸿蒙v1.3.0](releases/v1.3.0-harmonyos.1.md) |
| 后台注册、用户删除与团队问题 | [后台接入与验收](development/后台注册控制与用户删除.md) |
| BYOK助手配置与未完能力 | [配置验收](development/AI对话助手配置与验收.md)、[B方案契约](planning/Innocence-AI智能助手B方案实施与契约.md) |
| 主题原始提示词与当前设计 | [UI设计规划](planning/Innocence-UI设计规划.md)；保留原文，不随状态压缩删除 |
| 桌面布局与组件 | [自适应体验](planning/Innocence-Windows自适应桌面体验.md)、[信息架构](planning/Innocence-Windows信息架构与组件体系.md) |

## 规则与契约

读取顺序为[AGENTS](../AGENTS.md)要求的L0恢复入口 → L1检查点索引 → 按任务读L2；不默认全量阅读规划和历史。

| 文档 | 定位 |
|---|---|
| [00 初始现状审计](00-current-state-audit.md) | 2026-08-07基线快照，不是当前状态 |
| [01 产品范围](01-product-scope.md) | 产品范围与规划指针 |
| [02 契约与兼容](02-contract-and-compatibility-rules.md) | 身份/会话/业务语义约束 |
| [03 执行计划](03-execution-plan.md) | P01/G01等阶段与分支门禁 |
| [04 远期扩展](04-future-integration.md) | 尚未纳入当前交付的范围 |
| [05 版本控制](05-git-version-control-policy.md) | 提交、分支与远端授权 |
| [06 契约清单](06-contract-inventory.md) | 接口核验与验收点 |
| [07 数据流和模块](07-dataflow-and-module-map.md) | 模块、设备与数据边界 |
| [08 项目规则](08-project-profile.md) | 项目特有不变量；旧日期记录按历史理解 |

`planning/`保留需求/设计/契约，`development/`保留当前操作与能力边界，`releases/`按版本保留分发事实，`troubleshooting/`保留排查方法，`archive/`保存被精简文档的完整原文。

## 压缩与追溯

2026-11-01压缩将恢复入口、鸿蒙规划和权益接入的历史流水移出当前阅读层；74份旧检查点原名归档，INDEX逐项保留。最新操作文档直接写当前事实/下一步，避免每次追加完整旧日志。原始快照、逐文件摘要与旧待办归并映射见[归档清单](archive/documentation-compression-20261101.json)。检查点不可变，状态纠正通过新检查点；不删除主题提示词、契约、源码、构建证据或用户资料。
