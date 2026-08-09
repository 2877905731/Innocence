---
schema_version: 1
document_type: ai_resume
project_name: "Innocence"
updated_at: "2026-08-10"
latest_checkpoint: "0010"
current_phase: P00.5
current_gate: G00.5
state: windows_adaptive_desktop_canvas_direction_approved
next_sequence: "0011"
current_goal: "P00.5 UI 设计体系进行中：四主题方向与 Windows 自适应桌面画布已确认；下一步推进页面信息架构、Large/Medium/Small 组件密度接口和主题映射"
recent_baseline:
  - checkpoint: null
    result: "P00 治理基线初始化完成；暂无历史检查点"
user_decisions:
  - id: DEC-0001
    decision: "模板治理框架全量 9 文档落地；planning 文档并存引用"
  - id: DEC-0002
    decision: "阶段门禁按 MVP 5 阶段映射，已实现部分折入对应阶段基线"
  - id: DEC-0003
    decision: "进度协议启用（检查点 + RESUME + INDEX）"
  - id: DEC-0004
    decision: "前端 UI 全面推翻重建；功能逻辑与数据层保留"
  - id: DEC-0005
    decision: "主题集合并存可切换，主题提示词由用户提供并必须存档；主题数量后由 DEC-0012 更新为四个"
  - id: DEC-0006
    decision: "主题一采用大胆艺术字与大尺寸排版；面板统一直角；组件与背景使用同系冷色轻微对比；禁止色彩渐变、玻璃态、强阴影与大圆角"
  - id: DEC-0007
    decision: "UI 当前优先设计 Windows 桌面端；移动端仅同步主题风格，布局、导航、信息密度与组件规格后续单独设计"
  - id: DEC-0008
    decision: "主题一采用参考图的暖灰米色色调；同组面板彼此留白、去除外框与分隔边框，仅用独立纯色背景形成层级"
  - id: DEC-0009
    decision: "主题二为极简主义（Minimalism）：纯白背景、黑灰层级、12 列精确网格、大量留白、排版主导与克制交互"
  - id: DEC-0010
    decision: "主题三为玻璃态（Glassmorphism）：深色渐变背景、10/20/40px 背景模糊、0.05-0.2 透明度层级、半透明描边、柔和阴影与 12-24px 圆角；Windows 优先"
  - id: DEC-0011
    decision: "主题三改为中世纪现代主义（Mid-Century Modern），采用 1950-60 年代有机几何、暖米色与木质色、星爆图案、几何无衬线排版和现代非对称网格；本决策替代 DEC-0010"
  - id: DEC-0012
    decision: "玻璃态恢复为第四个可选主题；中世纪现代主义与玻璃态分别使用独立临时 HTML。生成 Flutter 前端时优先参考 HTML 的构图与视觉令牌；若 AI 参考不便或转换效率较低，可忽略 HTML 代码并依据提示词、令牌和页面结构实现"
  - id: DEC-0013
    decision: "Windows 端不再以固定桌面挂件为中心，采用 Large/Medium/Small 三档自适应画布 + 用户主动 Focus Orb；首次登录默认 Medium 920×760，跨尺寸只重排 shell 与组件密度并保留业务状态；设计执行权交由 AI，可在提升舒适度与效率时突破旧挂件约束"
unfinished:
  - id: TODO-002
    priority: P0
    item: "完成页面清单、导航地图与 Large/Medium/Small 跨尺寸内容优先级"
    gate: G00.5
  - id: TODO-003
    priority: P1
    item: "定义 Flutter DesktopPresentationTier、组件 full/comfortable/compact/glance 密度接口与主题映射"
    gate: G00.5
next_actions:
  - id: NEXT-001
    action: "依据 Windows 自适应桌面体验规范推进 P00.5 信息架构和组件体系；移动端布局仍单独设计"
    inputs: []
required_reads:
  - AGENTS.md
  - docs/08-project-profile.md
  - docs/03-execution-plan.md
  - docs/07-dataflow-and-module-map.md
  - docs/06-contract-inventory.md
  - docs/planning/Innocence-Windows自适应桌面体验.md
  - progress/INDEX.md
