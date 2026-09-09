# Innocence Logo 资产记录

## 用户选定源图 V1

状态：作为未处理备份保留，不直接用于 Windows 图标。

- 文件：[innocence-logo-v1-selected.png](./innocence-logo-v1-selected.png)
- 画布：`1254×1254`
- 背景：保留原始白色圆角底板、外围画布与阴影
- 完整性：归档文件与用户原图 SHA-256 一致，没有重绘、调色、裁切或透明化
- 保留元素：银灰字母 `I`、右上圆点、环线、`INNOCENCE` 字标与下方短横

## 正式抠图母版 V1

状态：已完成，可作为多尺寸 Windows ICO 与托盘图标的正式视觉源。

- 文件：[innocence-logo-v1-cutout.png](./innocence-logo-v1-cutout.png)
- 画布：`1254×1254`、`Format32bppArgb`
- 构成：完整保留白色圆角底板及其内部全部品牌内容，只删除底板之外的外围画布
- 透明度：四角 `alpha=0`，底板中心 `alpha=255`，圆角边缘保留多级 Alpha 抗锯齿
- 保真：不透明区域抽样 RGB 与源图一致；没有重绘字母、字标、环线或渐变
- SHA-256：`F5BE185D83A8738EF7FB03FD95D144D8CEC8CBA98310D1D396EFE40E80126A7F`

提取使用确定性的圆角蒙版。OpenAI ImageGen 的背景提取尝试因输出为不透明棋盘格而未采用，也未写入项目。制作桌面/任务栏/托盘资源时，只允许按目标尺寸进行构图适配和清晰度优化，不得更换字形或改变品牌配色。

## 历史候选稿

状态：已被用户选定稿替代，仅留作设计过程记录，不再用于正式资源。

### 视觉语义

- 白色折页同时表达摊开的书页与向前的箭头，兼顾学习时的安静和行动时的冲力。
- 不对称斜切与深靛蓝结构线提供先锋、现代的编辑感。
- 小面积钴蓝圆点代表注意力焦点；白色约占可见图形的 70%–80%。
- 图形保持单一轮廓和宽阔留白，目标是在 `16×16`、`32×32` 托盘尺寸下仍可辨认。

### 生成信息

- 工具：OpenAI ImageGen
- 输出：[innocence-logo-v1-candidate.png](./innocence-logo-v1-candidate.png)
- 背景：透明
- 画布：正方形

### 原始提示词

```text
Use case: logo-brand
Asset type: Windows desktop application icon and system tray icon for the productivity and study app Innocence
Primary request: Create exactly one original minimalist, modern, avant-garde icon mark. The central idea is a folded white study page that simultaneously reads as an open book and a sharp forward-moving arrow. It should balance quiet concentration with an unmistakable impulse to move forward.
Subject: One bold asymmetric white folded-paper shape; a strong diagonal cut or negative-space slash leaning forward; a restrained deep-indigo structural edge; one tiny vivid cobalt-blue focus dot. The silhouette should feel editorial and art-directed, not like a generic education app.
Style/medium: flat vector-like modernist identity, Swiss editorial discipline mixed with contemporary avant-garde geometry, minimal but daring
Composition/framing: exactly one centered symbol, square 1:1 canvas, generous clean padding, slightly forward-leaning visual weight, simple broad geometry
Color palette: white occupies roughly 70–80% of the visible mark, deep indigo or near-black only for essential outline/contrast, one small vivid cobalt accent
Background: genuinely transparent with clean alpha edges
Constraints: instantly legible at 16x16 and 32x32; the white form must remain visible on both light and dark Windows taskbars through a crisp minimal dark edge or shadowless backing shape; no text, no wordmark, no letters, no enclosing rounded-square tile, no mockup, no extra variants, no watermark
Avoid: circles as the main container, gradients, gloss, 3D, drop shadows, soft decorative flourishes, literal pencils, graduation caps, generic checkmarks, overly detailed book pages
```
