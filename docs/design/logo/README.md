# Innocence Logo 资产记录

## 用户选定稿 V1

状态：已从用户提供的原图无损提取并归档；等待用户确认提取结果后，再制作多尺寸 Windows ICO 并替换正式安装包资源。

- 文件：[innocence-logo-v1-selected.png](./innocence-logo-v1-selected.png)
- 画布：`1254×1254`
- 背景：保留原始白色圆角底板、外围留白与阴影
- 完整性：归档文件与用户原图 SHA-256 一致，没有重绘、调色、裁切或透明化
- 保留元素：银灰字母 `I`、右上圆点、环线、`INNOCENCE` 字标与下方短横

本文件是后续图标适配的唯一视觉源。制作桌面/任务栏/托盘资源时，只允许按目标尺寸进行构图适配和清晰度优化，不得更换字形或改变品牌配色。

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
