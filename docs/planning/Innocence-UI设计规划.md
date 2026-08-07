---
schema_version: 1
document_type: ui_design_plan
project_name: "Innocence"
created_at: "2026-08-07"
themes:
  - id: theme-01
    name: "侘寂禅意"
    family: "wabiSabi 家族"
    status: archived_and_reference_revised_v2
    prompt_source: "用户提供"
  - id: theme-02
    name: "极简主义"
    family: "Minimalism"
    status: archived_and_reference_implemented
    prompt_source: "用户提供"
  - id: theme-03
    name: "待定"
    family: "待定"
    status: pending_user_prompt
---

# Innocence UI 设计规划

## 1. 文档职责

- 承接全部 UI 全面重写规划（信息架构 / 双端布局 / 视觉令牌 / 主题 / 组件）
- **主题提示词原文存档区**：用户提供的提示词必须原文存档于本文档，后续所有主题生成均以存档为准（规则来源：`docs/08-project-profile.md` RULE-004、`AGENTS.md` THEME-PROMPTS-ARCHIVED）
- 每个主题沉淀为独立章节：提示词原文 + 提炼的设计令牌 + 参考实现

## 2. 主题存档区

---

### 主题一：侘寂禅意（wabiSabi 家族）

- 存档时间：2026-08-07
- 状态：提示词已存档，参考实现已完成（`docs/design/templates/wabisabi-zen.html`）

#### 2.1 提示词原文（存档）

> 请使用 TailwindCSS 创建模板「侘寂禅意」，延续 wabiSabi 家族风格，打造安静、克制、带有时间痕迹的沉浸式单页。整体强调留白、不完美之美、自然材质与慢节奏互动，避免任何高饱和、强对比、炫技动效。内容涵盖：禅意 Hero、愿景/故事段落、手作感卡片或图文区、体验流程、静态见证/引语，以及收尾 CTA。
>
> **场景设定与体验目标**
> - 面向冥想应用、茶室/香薰品牌、文化工艺课程、静心写作或疗愈类服务。
> - 让用户感到「时间放慢、呼吸顺畅、可以停留」，避免促销感与硬性驱动。
> - 文案语气：短句、陈述、留白。允许简短日语或汉字印章点缀，但保持可访问性。
>
> **信息架构与版式**
> - Hero：大幅留白，顶部或左侧放置 1–2 行标题（字距略大），副标题 1 行，单一 CTA（如「预约体验」），可附一句极短的品牌箴言。背景为柔和米白或浅灰褐，角落可有极淡墨迹/水彩晕染。
> - 故事段落：两栏布局，左侧文字讲述理念（无序列表或短段落），右侧为质感图片或手绘插图。图像需加纸纤维或亚麻纹理遮罩，透明度极低。
> - 卡片/图文区：2–3 列自适应卡片，内容为课程/空间/器物介绍；卡片边缘轻微不规则或 2–4px 圆角，描边 1px 半透明，内阴影极弱，背景使用米白/灰褐渐层。
> - 体验流程：以 3–5 步静态流程呈现，每步使用小圆点或印章式编号；文本保持简短；可用竖向分隔线或淡色网格对齐。
> - 引语/见证：单列或双列引语，字号 18–20px，行高 1.7；配小印章或签名式落款；不使用头像框。
> - 收尾 CTA：简洁区块，仅一句行动号召和一枚按钮；背景可加轻微纸纹或淡色渐变。
>
> **色彩与材质**
> - 主背景：米白/灰褐/浅麻布色（如 #F5F3EF, #E8E5DF）；深色文本用炭灰/深褐（#3A3731）；辅助文本用中灰褐（#7A7772）。
> - 强调色仅限一到两种自然色：苔绿（低饱和灰绿）、泥土褐、靛青墨；饱和度低于 30%。强调色用于小印章、分隔线或按钮描边，不大面积铺色。
> - 纹理：纸纤维、亚麻编织、轻微刷痕、石纹裂纹，透明度 3–8%；避免重复平铺，可用多层低透明线性/径向渐变混合。
> - 阴影与高光：几乎无阴影，或使用极轻的大面积柔光；不使用强烈光斑、玻璃态或霓虹。
>
> **排版与文字**
> - 标题：衬线或优雅无衬线（Crimson Text、Noto Serif、Inter），字重 500–700，字距略增，允许小写与大写混排；尽量不超过两行。
> - 正文：15–16px，行高 1.65–1.8；段落短、留白多；避免长列表堆叠。
> - 标签/徽章：可使用等宽或手写风格小字，配印章/水印效果；保持高对比度以可读。
> - 避免全屏大段文字；每个区块保持 3–6 行即可，配足够内边距。
>
> **组件与交互**
> - 按钮：扁平或极浅浮起，半透明描边 + 内填充低饱和色；Hover 仅亮度/描边轻微变化，Active 向下 1–2px 或阴影减弱；Focus 提供 2–3px 清晰描边（自然色或炭灰）。
> - 卡片：1px 描边 + 12–20px 内距，背景米白渐层，附轻微纸纹；Hover 可微升 2px 或轻微色温变化；移动端保持静态。
> - 分隔：使用极细线、虚线、或淡淡网格；可在区块间用不规则撕边/手绘线条，但必须保留可访问的布局。
> - 图像：加轻微噪点/纸纹遮罩；控制对比度；必要时用实色覆层提高文字可读性。
> - 动效：淡入/渐变 200–320ms；不要弹跳/旋转；尊重 `prefers-reduced-motion`，在低运动模式下关闭抖动/浮动。
>
> **可访问性与性能**
> - 文本对比度保持 AA 以上；按钮和链接提供可见的 Focus 状态，切勿仅靠颜色区分。
> - 图像应提供 alt 文本；装饰性图像标记为呈现用。避免大体积视频/重滤镜，移动端减少背景纹理层数。
> - 布局在移动端改为单列，留白不压缩过度；分段清晰，CTA 保持触控安全区。
>
> **文案语气示例**
> - 主标语：静、慢、留白；副标语：让时间落下尘埃。
> - 卡片：一器·一茶；一室·一念；一火·一香；短句对仗即可。
> - CTA：预约安静时刻 / 进入冥想 / 预定体验。
>
> **Tailwind 实现提示（仅供参考，不必全部使用）**
> - 容器：`max-w-5xl mx-auto px-6 lg:px-10 py-16 lg:py-24`
> - 背景与纹理可通过 `bg-[radial-gradient(...)]` 叠加；卡片 `rounded-[12px] border border-black/5 shadow-none bg-white/80 backdrop-blur-[1px]`
> - 按钮：`inline-flex items-center gap-2 px-5 py-3 rounded-md border border-neutral-300/60 bg-white/70 text-neutral-800 hover:bg-white/90 active:translate-y-[1px] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-neutral-500/60`
> - 文本：`tracking-[0.08em]` 用于标题，正文 `leading-relaxed text-[15px] text-neutral-700`

#### 2.2 提炼的设计令牌（供 Innocence 后续主题落地参考）

| 令牌 | 值 | 用途 |
|---|---|---|
| `bg-paper` | `#F5F3EF` | 主背景（米白） |
| `bg-linen` | `#E8E5DF` | 次级背景（浅灰褐/麻布） |
| `text-ink` | `#3A3731` | 主文本（炭灰/深褐） |
| `text-stone` | `#7A7772` | 辅助文本（中灰褐） |
| `accent-moss` | `hsl(90, 12%, 44%)` 类低饱和苔绿 | 印章/分隔线/按钮描边，面积小 |
| `accent-ink-indigo` | `#43484F` 类靛青墨 | 印章/落款 |
| 饱和度约束 | 强调色饱和度 < 30% | 全局 |
| 纹理透明度 | 3–8% | 纸纤维/噪点，多层渐变混合，不重复平铺 |
| 阴影 | 无或极轻大面积柔光 | 禁用光斑/玻璃态/霓虹 |
| 标题字体 | Noto Serif SC / Crimson Text，字重 500–700，字距略增（0.08em+） | 尽量不超两行 |
| 正文字号/行高 | 15–16px / 1.65–1.8 | 段落短、留白多 |
| 卡片圆角 | 2–4px 或 12px（轻微不规则亦可） | 1px 半透明描边，极弱内阴影 |
| 按钮交互 | hover 仅亮度/描边微变；active 下移 1–2px；focus-visible 2–3px 清晰描边 | 不可仅靠颜色区分 |
| 动效 | 淡入/渐变 200–320ms；禁用弹跳/旋转；尊重 `prefers-reduced-motion` | — |

#### 2.3 参考实现

- 文件：`docs/design/templates/wabisabi-zen.html`（Tailwind 单页模板，全区块：Hero / 故事 / 卡片 / 流程 / 引语 / CTA）
- 用途：作为「侘寂禅意」主题的视觉基准，后续在 Flutter 中落地该主题时对照此实现提炼组件样式

#### 2.4 用户视觉校正（2026-08-07，优先级高于 2.2 提炼结果）

- 参考来源：用户截图 + `https://www.uiprompt.site/zh/styles/preview/visual-wabiSabi`
- Logo / 品牌字：允许更大胆的艺术字构图，不局限于普通导航字号；通过大尺寸衬线、细字重、斜体错位和字距关系形成品牌记忆。
- 首屏标题：桌面端使用约 `72px` 起步的大尺寸标题，允许继续放大到视口级尺度；以排版本身作为主视觉。
- 面板与卡片：统一使用直角（`border-radius: 0`），以细描边、留白、网格和纯色色块建立层级。
- 色彩：组件与页面背景属于同一冷灰 / 冷灰绿色系，仅通过轻微明度差形成对比。
- 禁止项：主题界面不得使用色彩渐变、玻璃态、高光、强阴影或大圆角；纹理只能作为极低透明度材质噪点存在。
- 参考站的渐变只作为反例观察，不进入 Innocence 主题令牌。
- 修订实现：`docs/design/templates/wabisabi-zen.html` 已按以上规则重做为 v2。

#### 2.5 平台实施顺序（2026-08-07）

- 当前优先目标：Windows 桌面端，主题一 v2 参考实现按桌面窗口与桌面交互密度设计。
- 移动端不复用 Windows 页面布局，不在本轮做响应式收缩或移动端组件定稿。
- 后续移动端仅同步主题语言（色彩、字体气质、材质、直角规则），导航、信息密度、组件尺寸与交互结构另行设计。

#### 2.6 色调与面板关系校正（2026-08-07，优先级高于 2.4 的冷色描述）

- 色调以用户提供的两张 Wabi-Sabi 参考图为准：纸白、亚麻灰、浅陶土灰、炭褐文字，整体偏暖且低饱和。
- 推荐基础色：页面 `#F5F3EF`、浅面板 `#EAE6DF`、陶土面板 `#D9D0C6`、沙灰面板 `#E2DDD5`、正文 `#3A3731`、辅助文字 `#7A756F`。
- 同组面板必须是彼此独立的纯色色块，使用明显留白分隔，不共用外框，不使用卡片分隔边框。
- 面板层级仅依赖同色系明度与色温差，不使用阴影或渐变补强。
- 编号、标签等内部装饰尽量去框化，避免重新形成“表格单元格”的观感。

---

### 主题二：极简主义（Minimalism）

- 存档时间：2026-08-07
- 状态：提示词已存档，Windows 参考实现已完成（`docs/design/templates/minimalism.html`）
- 参考网站：`https://www.uiprompt.site/zh/styles/preview/core-minimalism`

#### 2.7 提示词原文（存档）

> 你现在是一名资深 UI 设计师兼前端工程师，请生成一个与当前「极简主义（Minimalism）」核心样式卡展示界面风格高度接近的极简风格 UI。
> 请使用 TailwindCSS 创建一个极简主义（Minimalism）风格的界面，通过大量留白、精确网格和中性色彩创造优雅、纯粹的视觉体验。
>
> **核心设计要求**
>
> 1. **大量留白（Whitespace）**
>    - 主要内容区留白: padding: 48px 或 64px;
>    - 段落间距: margin-bottom: 32px 或 48px;
>    - 行高: line-height: 1.8（阅读舒适性）
>    - 字母间距: letter-spacing: 0.02em 或 0.03em;
>    - 负空间比例: 内容区域占页面 40-50%，留白占 50-60%
>
> 2. **精确网格系统**
>    - 12 列网格: grid-template-columns: repeat(12, 1fr);
>    - 栏间距: gap: 24px 或 32px;
>    - 模块化间距: 使用 8px 基础单位（8, 16, 24, 32, 48, 64, 96px）
>    - 对齐精确: 所有元素遵循网格对齐，避免像素偏移
>    - 垂直韵律: 使用 baseline grid 创造垂直节奏感
>
> 3. **中性色彩为主**
>    - 纯黑: #000000（标题）
>    - 纯白: #ffffff（背景）
>    - 深灰: #1a1a1a, #2d2d2d, #404040（文字层级）
>    - 中灰: #666666, #808080, #999999（次要信息）
>    - 浅灰: #cccccc, #e5e5e5, #f5f5f5（边框、分隔线）
>    - 点缀色（极少使用）: #0066ff（链接）, #ff0000（强调）
>
> 4. **排版即视觉**
>    - 标题: font-size: 48px - 72px; font-weight: 300 或 700; letter-spacing: -0.02em;
>    - 副标题: font-size: 24px - 36px; font-weight: 400; letter-spacing: 0.01em;
>    - 正文: font-size: 16px - 18px; font-weight: 400; line-height: 1.8;
>    - 辅助文字: font-size: 12px - 14px; font-weight: 300; color: #999999;
>    - 字体选择: Helvetica Neue, Inter, SF Pro Display（无衬线，干净）
>
> 5. **减法设计哲学**
>    - 移除所有装饰: box-shadow: none; border: none;
>    - 仅保留必要元素: 只显示核心内容和功能
>    - 简化交互: 悬停仅改变透明度（opacity: 0.7）或颜色
>    - 隐藏复杂性: 使用渐进式披露，避免一次性展示过多信息
>    - 极简图标: 使用简单线性图标，stroke-width: 1px 或 1.5px;
>
> **配色方案（中性色为主）**
>
> 主要中性色:
> - 纯黑: #000000
> - 纯白: #ffffff
> - 深灰: #1a1a1a, #2d2d2d, #404040
> - 中灰: #666666, #808080, #999999
> - 浅灰: #cccccc, #e5e5e5, #f5f5f5
>
> 点缀色（极少使用）:
> - 蓝色: #0066ff（链接、主要操作）
> - 黑色: #000000（强调）
> - 红色: #ff0000（警告、删除）
>
> **关键 CSS 类示例**
>
> ```css
> /* 极简主义容器 */
> .minimal-container {
>   max-width: 800px; /* 限制阅读宽度 */
>   margin: 0 auto;
>   padding: 64px 32px;
>   background: #ffffff;
> }
>
> /* 极简主义标题 */
> .minimal-heading {
>   font-size: 48px;
>   font-weight: 300;
>   letter-spacing: -0.02em;
>   line-height: 1.2;
>   color: #000000;
>   margin-bottom: 48px;
> }
>
> /* 极简主义正文 */
> .minimal-text {
>   font-size: 18px;
>   font-weight: 400;
>   line-height: 1.8;
>   letter-spacing: 0.02em;
>   color: #404040;
>   margin-bottom: 32px;
> }
>
> /* 极简主义按钮 */
> .minimal-button {
>   padding: 16px 32px;
>   font-size: 16px;
>   font-weight: 400;
>   letter-spacing: 0.02em;
>   color: #000000;
>   background: #ffffff;
>   border: 1px solid #000000;
>   cursor: pointer;
>   transition: all 0.3s ease;
> }
>
> .minimal-button:hover {
>   background: #000000;
>   color: #ffffff;
> }
>
> /* 极简主义分隔线 */
> .minimal-divider {
>   width: 100%;
>   height: 1px;
>   background: #e5e5e5;
>   margin: 64px 0;
>   border: none;
> }
>
> /* 极简主义网格 */
> .minimal-grid {
>   display: grid;
>   grid-template-columns: repeat(12, 1fr);
>   gap: 32px;
>   margin-bottom: 64px;
> }
>
> /* 极简主义卡片 */
> .minimal-card {
>   background: #ffffff;
>   padding: 32px;
>   border: 1px solid #e5e5e5;
>   transition: border-color 0.3s ease;
> }
>
> .minimal-card:hover {
>   border-color: #000000;
> }
> ```
>
> **间距系统（8px 基础单位）**
> - xs: 8px（紧密元素）
> - sm: 16px（相关元素）
> - md: 24px（组件间距）
> - lg: 32px（节间距）
> - xl: 48px（区块间距）
> - 2xl: 64px（主要区域）
> - 3xl: 96px（页面级间距）
>
> **微型交互细节**
> - 悬停过渡: transition: all 0.3s ease;
> - 透明度变化: opacity: 1 → opacity: 0.7;
> - 颜色渐变: color: #000000 → color: #666666;
> - 边框变化: border-color: #e5e5e5 → border-color: #000000;
> - 避免复杂动画: 不使用 transform: scale() 或 translateY()
>
> **重要提示**
> - 留白是设计的一部分，不是浪费空间
> - 每个元素必须有存在的理由，否则移除
> - 使用网格对齐所有元素，保持精确的视觉秩序
> - 色彩极度克制，黑白灰为主，点缀色仅用于强调
> - 排版是极简主义的灵魂，通过字体大小、粗细、间距创造层次
> - 交互细腻但不夸张，保持优雅和克制
>   提示词预览网站：https://www.uiprompt.site/zh/styles/preview/core-minimalism

#### 2.8 提炼的设计令牌（Windows）

| 令牌 | 值 | 用途 |
|---|---|---|
| `minimal-bg` | `#FFFFFF` | 页面与主工作区背景 |
| `minimal-ink` | `#000000` | 主标题与关键操作 |
| `minimal-carbon` | `#1A1A1A` | 一级正文 |
| `minimal-graphite` | `#404040` | 普通正文 |
| `minimal-neutral` | `#666666` | 次级信息 |
| `minimal-quiet` | `#999999` | 辅助标签与元数据 |
| `minimal-line` | `#E5E5E5` | 必要的 1px 分隔线 |
| `minimal-wash` | `#F5F5F5` | 次级区块纯色背景 |
| `minimal-signal` | `#0066FF` | 极少量链接与主操作 |
| 网格 | 12 列 / 32px gap | Windows 主画布 |
| 间距 | 8px 基础单位 | 8 / 16 / 24 / 32 / 48 / 64 / 96 / 128 |
| 首屏标题 | 96–144px / 300 与 700 对比 | 排版作为主视觉 |
| 正文 | 16–18px / 1.8 | 最大阅读宽度约 760px |
| 形状 | 直角 | 禁用大圆角、阴影、渐变与装饰纹理 |
| 动效 | 300ms opacity / color / underline | 禁用位移与缩放 |

#### 2.9 参考实现

- 文件：`docs/design/templates/minimalism.html`
- 平台：Windows 桌面端（最小画布宽度 1024px；移动端另行设计）
- 参考页实测：首屏标题约 `128px / 300`，区块左右留白约 `96px`，区块上下留白约 `128px`
- 内容映射：Innocence 导航 / 极简 Hero / 设计系统 / 今日专注工作区 / 减法原则 / 黑底 CTA

### 主题三：待定

- 状态：等待用户提供提示词

## 3. 后续规划占位

- 信息架构（页面清单 + 导航地图）：三个主题提示词收集完成后推进
- 双端布局规范、视觉令牌结构、组件体系：同上
- 页面重建实施顺序：登录 → 主框架 → 首页 → 二级页
