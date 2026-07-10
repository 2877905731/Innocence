# 文档目录

这里存放 `Innocence` 项目的产品、实现约束、排查经验与开发过程文档。

## 当前目录结构

```text
planning/                    规划与设计文档
troubleshooting/             问题排查与经验沉淀
README.md                    当前索引
```

## 已归档文档

### planning

- `Innocence-项目计划书.md`
- `Innocence-数据库表结构草案.md`
- `Innocence-接口清单草案.md`
- `Innocence-MVP第一版功能范围.md`
- `Innocence-桌面端UI实现约束.md`

### troubleshooting

- `Innocence-前端修改未生效排查.md`

## 推荐阅读顺序

如果你刚接手这个项目，建议按下面顺序阅读：

1. `planning/Innocence-项目计划书.md`
2. `planning/Innocence-MVP第一版功能范围.md`
3. `planning/Innocence-接口清单草案.md`
4. `planning/Innocence-数据库表结构草案.md`
5. `planning/Innocence-桌面端UI实现约束.md`
6. `troubleshooting/Innocence-前端修改未生效排查.md`

## 这份目录适合放什么

- 需求范围变更记录
- 页面与接口映射关系
- 联调注意事项
- 构建与发布排查
- 桌面端 UI 规范
- 上线或本地部署说明

## 当前最重要的排查文档

如果你刚修改完 Flutter 界面，但打开程序看不到效果，优先看：

- [Innocence-前端修改未生效排查.md](/F:/springmvc1/Innocence/docs/troubleshooting/Innocence-前端修改未生效排查.md)

这份文档已经记录了本项目最常见的桌面端误区：代码已改，但实际运行的还是旧的 Windows 发布包。
