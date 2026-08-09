# 文档目录

这里存放 `Innocence` 项目的治理、规划、实现约束、排查经验与开发过程文档。

## 当前目录结构

```text
00~08-*.md                  治理层文档（AI 多会话工作框架，2026-08-07 落地）
planning/                    产品规划与设计详稿
troubleshooting/             问题排查与经验沉淀
README.md                    当前索引
../AGENTS.md                 项目规则（恢复流程/约束/进度协议）
../progress/                 恢复入口与检查点体系
```

## 治理层文档（docs/ 根目录）

由 `ai-project-template v4` 框架生成，供任意 AI 会话按分层恢复接手项目：

| 文档 | 内容 |
|---|---|
| `00-current-state-audit.md` | 项目现状审计（基线盘点） |
| `01-product-scope.md` | 产品范围指针 |
| `02-contract-and-compatibility-rules.md` | 契约与兼容性硬性约定 |
| `03-execution-plan.md` | 阶段门禁执行计划（P00~P06） |
| `04-future-integration.md` | 远期扩展位 |
| `05-git-version-control-policy.md` | Git 版本控制策略 |
| `06-contract-inventory.md` | 契约清单索引与核验点 |
| `07-dataflow-and-module-map.md` | 数据流与模块地图 |
| `08-project-profile.md` | 项目特有规则（权威来源） |

接手顺序：`progress/0000__AI-RESUME.md` → `progress/INDEX.md` → 按需读取以上文档。

## 产品层文档（planning/）

- `Innocence-项目计划书.md` —— 15 模块全部封板的产品规划
- `Innocence-MVP第一版功能范围.md` —— 第一版范围边界与完成标准
- `Innocence-接口清单草案.md` —— 前后端接口契约草案
- `Innocence-数据库表结构草案.md` —— 数据库表结构草案
- `Innocence-UI设计规划.md` —— UI 全面重写规划 + 四个主题提示词与参考实现存档（P00.5）

## 排查文档（troubleshooting/）

- `Innocence-前端修改未生效排查.md`

## 推荐阅读顺序

1. `progress/0000__AI-RESUME.md` —— 当前状态与下一步
2. `docs/03-execution-plan.md` —— 阶段门禁
3. `planning/Innocence-项目计划书.md`
4. `planning/Innocence-MVP第一版功能范围.md`
5. `planning/Innocence-接口清单草案.md`
6. `planning/Innocence-数据库表结构草案.md`
7. `troubleshooting/Innocence-前端修改未生效排查.md`
