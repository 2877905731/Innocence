---
schema_version: 1
document_type: ai_resume
project_name: "Innocence"
updated_at: "2026-09-23"
latest_checkpoint: "0057"
current_phase: P01
current_gate: G01
state: annual_charge_progress_unified_build_verified_visual_qa_pending
next_sequence: "0058"
current_goal: "年度任务唯一充能框已合并月份跨度和任务进度，空框起步、随进度平滑增减，+10/−10、+5/−5、+1/−1 和直接完成已接入现有持久化；年度定向测试、Flutter 全套 63 项、静态分析与 Windows Release 构建通过。下一步在 Large/Medium/Small 与多 DPI 下人工确认实际视觉和动效"
recent_baseline:
  - checkpoint: "0015"
    result: "设置页完成 Large/Medium/Small 三档独立编排与黑名单新增入口；新增会话、认证、拉黑和跨租户权限负向测试，定向 Maven 7 项通过；Flutter/Dart SDK、数据库集成环境和头像上传后端路由仍不可用"
  - checkpoint: "0016"
    result: "固化 U13 头像上传契约并完成 Spring multipart 路由、本地存储、JPEG/PNG 内容校验、当前用户资料回写和失败清理；定向 Maven 头像与既有安全测试通过；完整 contextLoads 仍因本机 MySQL 认证失败"
  - checkpoint: "0017"
    result: "资料页完成 JPEG/PNG 文件选择、5 MiB 前置校验、multipart 调用和资料刷新源码；file_selector 依赖按官方元数据锁定；Flutter/Dart SDK 不可用，尚未执行 pub get/analyze/test"
  - checkpoint: "0018"
    result: "隔离 MySQL/Redis 环境完成 U09-U13 真实 HTTP 矩阵；发现并修复 code=9000 被错误映射为 HTTP 400 的缺陷，完整 Maven 16 项通过；Flutter/Dart SDK 仍不可用"
  - checkpoint: "0019"
    result: "Flutter 3.44.9 Stable / Dart 3.12.2 与中国镜像配置完成；pub get、analyze、Flutter 16 项测试和 Windows Release 构建通过，file_selector 原生插件注册生成；实机 DPI 与真实文件选择待验收"
  - checkpoint: "0020"
    result: "后端鉴权不再信任客户端 X-User-Id，改由 Bearer session token + 设备槽位反查活动会话；当前会话响应不再暴露 sessionToken；隔离 MySQL/Redis 完整 Spring 上下文与全部测试通过"
  - checkpoint: "0021"
    result: "补齐 POST /api/app/v1/auth/logout；按 Bearer token 撤销当前设备活动会话并写入 logout_time；隔离 MySQL/Redis 完整上下文与全部 20 项后端测试通过"
  - checkpoint: "0022"
    result: "补齐 GET /api/app/v1/stats/trend；支持 7d/30d 并返回 xAxis + series；隔离 MySQL/Redis 完整上下文与全部 23 项后端测试通过"
  - checkpoint: "0023"
    result: "侘寂主题按用户决策收敛为暖灰米纸、胡桃棕与深米色；认证页和 Windows 自适应主页接入纸纤维、亚麻编织、轻刷痕与信封折线；flutter analyze、19 项测试、定向色板测试及 Windows Release 构建通过，人工视觉/DPI 仍待验收"
  - checkpoint: "0024"
    result: "设置页与 Focus Orb 已全面绑定当前视觉主题，桌面特效全链路删除，Orb 纠偏为 72×72 圆形进度环；flutter analyze、21 项 Flutter 测试、25 项 Maven 测试与 Windows Release 构建通过，已启动 PID 27304"
  - checkpoint: "0025"
    result: "Orb 移除 Tooltip 与透明外圈；HomePage 改从全局主题标记解析当前主题；Canvas 跨启动固定回到居中 920×760；flutter analyze、22 项测试与 Windows Release 构建通过，DPI 144 实测窗口 920×760"
  - checkpoint: "0031"
    result: "共享 GlassPanel、导航、设置面板、主页卡片和空状态全部改为主题感知表面；玻璃态移除固定白卡与近黑条带，备忘录内部组件改用 ColorScheme；flutter analyze、25 项测试、git diff --check 与 Windows Release 构建通过"
  - checkpoint: "0032"
    result: "备忘录新建/编辑弹窗改为响应式桌面大面板：Large 窗口最大约 820px 宽、76% 高，正文和清单保持滚动；flutter analyze、25 项测试与 Windows Release 构建通过，待推送"
  - checkpoint: "0034"
    result: "认证页玻璃态接入主页共享动态光场与 GlassPanel，移除重复网格；主题切换边框插值保护已补齐；定向 Flutter 测试、flutter analyze 与 git diff --check 通过，Windows Release 实机视觉/DPI 待验收"
  - checkpoint: "0035"
    result: "玻璃态标准二级弹层改为高可见度深蓝紫表面、浅描边与独立阴影；11 项定向 Flutter 测试、flutter analyze、git diff --check 和 Windows Release 构建通过，已启动 PID 29328"
  - checkpoint: "0036"
    result: "今日计划编辑器改为固定可见48段昼夜时间轴，补齐中英文并修复选时后直接保存；玻璃态通用操作色改为蓝紫系；29项Flutter测试、flutter analyze、git diff --check和Windows Release构建通过，已启动PID 23016"
  - checkpoint: "0037"
    result: "今日计划新增循环浅色渐变、等量联动小时间条动画和已有时段首尾拖动；相邻计划自动钳制且占用段不触发新建；30项Flutter测试、flutter analyze、git diff --check和Windows Release构建通过，已启动PID 29920"
  - checkpoint: "0038"
    result: "统一主题化窗口控件并新增大中小原生尺寸预设与边缘缩放光标；统计中心内卡跟随主题且工具栏固定；计划页补齐真实周计划与长期日期路线；32项Flutter测试、analyze、diff检查和Windows Release构建通过，已启动PID 4052"
  - checkpoint: "0039"
    result: "尺寸入口由单按钮弹出菜单改为顶部常驻三圆环，圆环从左到右递减并直接对应Large/Medium/Small；32项Flutter测试、analyze、diff检查和Windows Release构建通过，已启动PID 5952"
  - checkpoint: "0040"
    result: "完成无需登录离线资料、登录后确认导入、四主题每日艺术标语、长计划月历、超长计划年历和八方向原生缩放的详细规划；同步覆盖现行冲突文档，代码未修改也未开始"
  - checkpoint: "0041"
    result: "离线 SQLite/outbox/本地统计与登录确认导入、四主题 4×7 标语、短/月/年计划、日模板、年度区间和 Windows sizing loop 已落地；Flutter 49 项、Maven 36 项、analyze、diff 检查和 Windows Release 构建通过，已启动 PID 25640；真实拖边/DPI 与同步 HTTP 回放待验收"
  - checkpoint: "0042"
    result: "用户确认普通边框拖动和离线模式可用；离线设置只开放本机安全分区并持久化桌面偏好，认证页顶部/品牌区拖窗命中已纠正；Flutter 51 项、Maven 36 项、analyze、diff 检查和 Windows Release 构建通过，已启动 PID 8228"
  - checkpoint: "0043"
    result: "实现提交 99a6d75 已推送 origin/main；v0.0.1-preview.1 GitHub 预发布已创建，Windows x64 ZIP（14,717,177 bytes，SHA256 7833EC35...8115）上传完成"
  - checkpoint: "0044"
    result: "用户确认认证页拖窗可用；Windows 1.0.0+1 安装器与便携包通过构建、哈希和安装/启动/卸载验证；v1.0.0 正式 GitHub Release 已发布并上传 3 个资产"
  - checkpoint: "0045"
    result: "关闭后驻留托盘、显示/设置/暂停继续/退出菜单与在线离线真实暂停已实现；Flutter 54 项、Maven 39 项、analyze、Windows Release 和关闭/恢复/右键菜单运行态探针通过；白色折页前进箭头 Logo 候选稿待用户确认后转 ICO"
  - checkpoint: "0046"
    result: "用户指定新的银灰字母 I、圆点、环线与 INNOCENCE 字标 Logo，并明确保留白色圆角底板；原图已无损归档为 innocence-logo-v1-selected.png，SHA-256 与来源一致，尚未替换 ICO。"
  - checkpoint: "0047"
    result: "按用户纠正，仅保留白色圆角底板及内部品牌内容，移除外围画布并输出 1254×1254 ARGB 抠图母版；四角 alpha=0、中心 alpha=255、圆角含多级抗锯齿，内部抽样 RGB 与源图一致。"
  - checkpoint: "0048"
    result: "修正 Logo 抠图右边界：删除误收入的 x=1166–1199 外围画布，底板有效左右边界收敛为 x=89..1165；右侧 x=1166 起 alpha=0，圆角仍保留多级抗锯齿。"
  - checkpoint: "0049"
    result: "正式 Logo 已转换为含 16/20/24/32/40/48/64/128/256 九档的 Windows ICO；16–48 使用同源放大主标，64–256 保留完整字标；Release 构建成功且从 EXE 提取的新图标为 32×32、角点透明，根 README 已展示 Logo 并同步 GitHub。"
  - checkpoint: "0050"
    result: "新增完整英文 README_EN.md；中英文 README 均展示正式 Logo、双语切换和六枚一致徽章。许可证按仓库真实 LICENSE 使用 AGPL-3.0，技术栈徽章使用 Flutter、Dart >=3.4、Java 21、Spring Boot 3.3.2 与 Windows/Android，未采用不准确的 MIT/Python 示例。"
  - checkpoint: "0051"
    result: "Windows 1.0.1+2 安装器与便携包通过 analyze、54 项 Flutter 测试、39 项 Maven 测试、哈希及安装/启动/卸载验证；v1.0.1 正式 GitHub Release 已发布，3 个公开资产均为 uploaded 且 HTTP 200。"
  - checkpoint: "0052"
    result: "主题二由纯白极简完整替换为柔彩编辑式看板，覆盖认证、Canvas、首页、设置、二级页、Focus Orb 与共享控件；完整提示词和正式 HTML 基准已归档，flutter analyze、56 项测试、diff 检查与 Windows Release 构建通过。"
  - checkpoint: "0053"
    result: "短任务草稿可直接存档且失败后可保留内容重试，长任务可新建/编辑/删除及批量套用存档，超长任务独立按年内 12 个月展示多子任务、完成确认与动态跨度色条；Hero 双色块动效同步 HTML；Flutter 60 项、Maven 41 项及 Windows Release 构建通过。"
  - checkpoint: "0054"
    result: "首页今日计划完成率由当日完成比例计算且离线统计同步刷新；今日页增加本月超长任务分页；年度任务独立进度支持 +10/+5/+1 与直接完成，月份跨度条无缝循环并与 12 月列对齐，Hero 方块动效更显著；Flutter 63 项、Maven 43 项、analyze 与 Windows Release 构建通过。"
  - checkpoint: "0055"
    result: "年度色条改为紫/橙/蓝/绿/珊瑚红/金黄/青七色，按钮与灰槽/激活条共用 12 列几何；年度页月份导航改为可交互的吸顶 Sliver。主要 UI 改动后 flutter analyze 通过；新部件测试、Maven 回归与 Release 构建受自动授权用量限制未运行，不能标记验收完成。"
  - checkpoint: "0056"
    result: "补齐上轮未执行的验证：年度部件定向测试通过，Flutter 全套 63/63、Maven 全套 44/44、flutter analyze 和 Windows Release 构建通过；本轮临时 MySQL 容器已停止并移除，数据卷保留；不同 DPI 的实际视觉/动效仍待人工验收。"
  - checkpoint: "0057"
    result: "用户将年度任务的独立进度条合并进月份脉冲框：外框精确表示月份，0–100% 控制内部填充，0% 空框、100% 满框；首页本月预览共用组件，+10/−10、+5/−5、+1/−1 双向钳制且完成后可回退。年度定向测试、Flutter 全套 63 项、analyze 与 Windows Release 构建通过；服务端未变更，上轮 Maven 44 项通过。"
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
  - id: DEC-0014
    decision: "用户确认 Windows 页面清单、6+2 导航分组、Small 四项主导航、跨尺寸优先级与组件接口；G00.5 通过，进入 P01"
  - id: DEC-0015
    decision: "认证页四主题必须使用独立品牌字与艺术装置；纯白保持克制，侘寂强调残缺墨印，中世纪现代允许高饱和几何色块拼接，玻璃态强调发光层叠和轨道"
  - id: DEC-0016
    decision: "侘寂背景使用纸纤维、亚麻编织、轻微刷痕与手写信封气质；辅助色以棕色和深米色为主，移除不协调的橙色与绿色；本决策覆盖既有侘寂色板冲突项"
  - id: DEC-0017
    decision: "设置页和 Focus Orb 的所有颜色/UI 必须绑定当前四主题；删除独立桌面特效及其全局毛玻璃计划规定；Orb 回归 72×72 圆形进度环草图，覆盖 0013 的 88×88 方形实现"
  - id: DEC-0018
    decision: "Focus Orb 禁止在小窗口中显示 Tooltip 或透明外圈；主界面必须跟随设置页的全局主题切换；旧窗口尺寸策略已由 DEC-0020 覆盖。"
  - id: DEC-0019
    decision: "玻璃态恢复提示词和示例 HTML 的动态背景、漂浮光团、微粒、Hover 上浮与发光；覆盖全局禁用循环运动/持续发光和 Large 材质降级规则。Canvas 彻底无非客户区，主题作为本地视觉偏好切换时不调用服务端外观接口。"
  - id: DEC-0020
    decision: "Windows Canvas 首次按当前工作区约 84%×82% 居中打开；之后跨设置页、Focus Orb 和应用重启记忆用户调整的尺寸与位置。此决策覆盖固定 920×760 / 1240×780 和不跨启动恢复的旧约束。"
  - id: DEC-0021
    decision: "共享页面表面必须跟随当前四主题；玻璃态统一使用深色半透明蓝紫表面、浅色描边和模糊发光，禁止 lightStyle 强制白卡、嵌套空状态使用不透明近黑底或页面控件复用旧浅色固定色。"
  - id: DEC-0022
    decision: "备忘录新建与编辑采用响应式桌面大面板，最大约 820px 宽并按窗口高度限制滚动；小窗口自动收缩，不改变数据契约。"
  - id: DEC-0023
    decision: "今日计划选时采用固定可见的48段昼夜阶梯时间轴，中央12:00最高并配置太阳、两端月亮和时间标记；选时后无需额外填写即可保存，编辑器完整覆盖中英文。玻璃态通用主操作使用蓝紫主题色，绿色仅表达成功。本决策覆盖四列滚动网格、基础选时需扩大窗口和通用薄荷绿操作色的旧要求。"
  - id: DEC-0024
    decision: "今日计划按计划分配稳定的循环浅色渐变，计划卡时间右侧显示颜色一致、数量等于半小时格数且等高的小时间条，并在范围变化时从零动画增长。点击已有时段只激活并允许拖动首尾，边界不得越过其他计划；新建只能从空白时段开始。本决策覆盖单一选中色、占用段可新建和已有范围不可拖动的旧要求。"
  - id: DEC-0025
    decision: "认证、Canvas和二级页统一主题化窗口控件；顶部提供Large/Medium/Small一键尺寸预设，边缘显式显示缩放光标；统计中心固定工具栏且内卡跟随主题；计划页的短/长/超长均为可操作视图，MVP超长计划复用日期持久化而不新增planType=ultra。本决策覆盖对应冲突旧方案。"
  - id: DEC-0026
    decision: "Large/Medium/Small尺寸预设必须在顶部以从左到右逐级缩小的三个圆环常驻显示并直接点击，不得收进单按钮、弹出菜单或下拉列表；本决策覆盖DEC-0025中未限定的菜单实现和检查点0038的尺寸菜单。"
  - id: DEC-0027
    decision: "Windows 新增无需登录的本机离线资料，登录后先预览目标账号并确认导入；首页四主题各 7 条艺术标语按日稳定轮换；计划层级改为短=日、长=月、超长=年，旧周能力仅兼容；边框缩放改用 Flutter 八方向命中层触发原生 sizing loop 并以 Release 真实拖动验收。本决策覆盖 DEC-0025 中周/逐周计划语义及旧缩放完成假设。"
  - id: DEC-0028
    decision: "离线模式允许进入系统设置，但只展示语言、本机资料、桌面体验、外观和本机操作；需要联网的隐私、通知、设备会话、后台和账号注销不向离线用户开放。Windows 认证页顶部安全条和无按钮品牌区必须可拖动窗口。"
  - id: DEC-0029
    decision: "Windows 第一版正式版本号采用 1.0.0；同时提供每用户安装器、便携 ZIP 和 SHA256 清单。没有 Authenticode 证书时允许发布，但必须明确披露 SmartScreen 未知发布者风险。"
  - id: DEC-0030
    decision: "Windows 关闭按钮默认隐藏到系统托盘；托盘第一版提供显示主界面、设置、暂停/继续当前计时和退出，离线模式可进入分级设置。Logo 采用白色占多数的简约现代先锋方向，以折页/前进箭头平衡学习的文静感和向前冲动感；候选稿确认前不覆盖正式 ICO。"
  - id: DEC-0031
    decision: "Windows 第一版品牌 Logo 改用用户提供的银灰字母 I、右上圆点、环线、INNOCENCE 字标和下方短横方案，并保留原始白色圆角底板、外围留白与阴影；本决策覆盖 DEC-0030 的折页/前进箭头候选方向。"
  - id: DEC-0032
    decision: "Logo 的完整边界是白色圆角底板：保留底板及内部银灰字母 I、圆点、环线、INNOCENCE 字标和短横，只删除底板以外的外围画布并设为真实透明；本决策覆盖 DEC-0031 中保留外围留白与外部阴影的部分。"
  - id: DEC-0033
    decision: "修正后的白色圆角底板 Logo 作为 Windows 正式品牌图标，并展示在 GitHub 根 README；ICO 的 16–48 像素条目允许使用同源放大的 I、圆点与环线构图保证托盘辨识度，64–256 保留完整字标。"
  - id: DEC-0034
    decision: "GitHub 同时维护中文 README.md 与英文 README_EN.md，两者展示相同 Logo、语言切换和项目徽章；徽章必须反映仓库真实状态，因此许可证使用 AGPL-3.0，技术栈使用 Flutter/Dart/Java/Spring Boot，而不采用示例中的 MIT/Python。"
  - id: DEC-0035
    decision: "主题二正式由纯白极简替换为柔彩编辑式看板（Soft Spectrum Editorial），默认使用灰白纸面、薰衣草紫与珊瑚粉，完整覆盖认证、Canvas Shell、主界面、设置、二级页、Focus Orb 和共享控件；内部 minimalism 枚举与存储值仅为兼容保留。本决策覆盖 DEC-0009 与 DEC-0015 的主题二部分。"
  - id: DEC-0036
    decision: "短任务当前安排可单独保存为任务存档；长任务月历提供显式存档区以新建和直接套用存档；超长任务独立于长任务，以年内 12 个月、可编辑月份跨度及脉冲色条、多子任务与逐项确认/编辑/删除呈现；柔彩首页 Hero 背景及两个色块持续缓动，减少动画偏好时静止。与旧计划冲突处以本决策为准。"
  - id: DEC-0037
    decision: "首页完成率明确采用今日计划完成比例，统计页仍按 7/30 天汇总且离线写入后刷新；今日计划可切换浏览本月独立超长任务；年度任务另存 0–100% 任务级进度并允许 +10/+5/+1 或直接完成，子任务状态独立；月份跨度条参考蓝紫 Ultra 充能动态，首尾无缝循环且与 12 月导航列对齐；柔彩 Hero 两方块缩短周期并扩大幅度。本决策覆盖 DEC-0036 中低速方块及未定义任务级进度的部分。"
  - id: DEC-0038
    decision: "年度任务脉冲条须提供鲜明且易区分的七色可选项，旧 accent/warm/cool/neutral 键保留并映射为紫/橙/蓝/绿，新增 coral/gold/cyan；流光使用任务本色，月份导航、灰色槽位和激活跨度条必须共用 12 列位置公式并保持同高同圆角；年度页滚动时 1–12 月导航吸顶且可继续筛选。本决策覆盖 DEC-0037 中统一蓝紫混色的视觉限定。"
  - id: DEC-0039
    decision: "年度任务删除独立线性进度条，以月份跨度完整外框和 progressPercent 驱动的内填充组成唯一脉冲充能组件；0% 为空框、进度变化平滑增减、100% 满框，七色和吸顶刻度保持。按钮改为 +10/−10、+5/−5、+1/−1 成对控制并保留直接完成，100% 可减量回退；本月预览复用充能组件，子任务状态独立。此决策覆盖 DEC-0037 的双进度条呈现和仅增量操作，也将 DEC-0038 的全跨度彩色条收敛为全跨度描边框。"
unfinished:
  - id: TODO-005
    priority: P0
    item: "执行 Windows Large/Medium/Small/Focus Orb 在 100%/125%/150% DPI 的实机验收；150% DPI 启动窗口已验证为 920×760，flutter analyze、22 项 Flutter 测试、25 项 Maven 测试和 Windows Release 构建已通过"
    gate: G01
  - id: TODO-006
    priority: P1
    item: "在 Windows Release 实机验证资料页文件选择器、multipart 调用、头像展示与资料刷新；源码、插件注册、客户端负向测试和服务端 HTTP 矩阵已完成"
    gate: G01
  - id: TODO-007
    priority: P0
    item: "在 Windows Release 实机视觉检查重写后的语言/登录页四套艺术字、左下装置、最小化与非强制置顶；自动化与 Release 构建已通过"
    gate: G01
  - id: TODO-011
    priority: P0
    item: "用户已确认普通 Canvas 边框拖动可用；仍需 100%/125%/150% DPI 八方向完整矩阵后才能关闭跨 DPI 验收"
    gate: G05/G06
  - id: TODO-012
    priority: P0
    item: "使用真实登录会话回放离线 import-preview/import，覆盖 keep_server、overwrite、重复 operationId、断线重试和 targetUserNo 不匹配"
    gate: G01/G02
  - id: TODO-014
    priority: P1
    item: "为后续 Windows Release 配置可信 Authenticode 代码签名证书；v1.0.1 当前为 NotSigned，发布说明已披露 SmartScreen 风险"
    gate: G06
  - id: TODO-016
    priority: P1
    item: "使用真实登录会话回放 U24/U25 pause/resume，并人工点击托盘设置、暂停/继续和退出；当前单元测试、Release 编译、关闭/恢复和右键菜单出现已验证"
    gate: G01/G02
next_actions:
  - id: NEXT-ANNUAL-RULER-VISUAL-QA
    action: "在 Windows Release 人工检查 0% 空框、各进度比例与 100% 满框的实际视觉、七色色样、月份槽位贴合、滚动吸顶和双向按钮的 Large/Medium/Small、多 DPI 状态；自动化测试和构建已通过"
    inputs: ["client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe", "client/flutter_app/test/features/home/adaptive_annual_progress_test.dart"]
  - id: NEXT-ANNUAL-PROGRESS-VISUAL-QA
    action: "在 Windows Release 人工检查首页今日完成率、本月超长任务分页、年度进度按钮、12 月几何对齐与无缝充能色条，并覆盖 Large/Medium/Small 和多 DPI"
    inputs: ["client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe", "docs/design/templates/soft-spectrum-dashboard-preview.html"]
  - id: NEXT-TASK-ARCHIVE-ANNUAL-VISUAL-QA
    action: "在 Windows Release 人工检查短任务存档、长任务批量套用、年度 12 个月切换与子任务操作、柔彩动效及 100%/125%/150% DPI 各尺寸布局"
    inputs: ["client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe", "docs/design/templates/soft-spectrum-dashboard-preview.html"]
  - id: NEXT-THEME-02-VISUAL-QA
    action: "在 Windows Release 对柔彩主题执行 Large/Medium/Small/Focus Orb 与设置页的 100%/125%/150% DPI 人工视觉验收"
    inputs: ["client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe", "docs/design/templates/soft-spectrum-dashboard-preview.html"]
  - id: NEXT-001
    action: "使用真实登录会话回放 U24/U25 与离线同步，并人工完成托盘菜单所有命令的端到端验收"
    inputs: ["docs/06-contract-inventory.md", "server/innocence-server", "client/flutter_app/build/windows/x64/runner/Release/innocence_flutter.exe"]
  - id: NEXT-002
    action: "继续 v1.0.1 的 100%/125%/150% DPI 矩阵，并在下一次 Windows 发布前配置 Authenticode 代码签名"
    inputs: ["https://github.com/2877905731/Innocence/releases/tag/v1.0.1", "client/flutter_app/windows/package_release.ps1"]
required_reads:
  - AGENTS.md
  - docs/08-project-profile.md
  - docs/03-execution-plan.md
  - docs/07-dataflow-and-module-map.md
  - docs/06-contract-inventory.md
  - docs/planning/Innocence-Windows自适应桌面体验.md
  - docs/planning/Innocence-Windows信息架构与组件体系.md
  - docs/planning/Innocence-离线模式主题标语与年月计划实施规划.md
  - progress/INDEX.md

backend_checkpoint:
  sequence: "0045"
  status: complete
  result: "新增在线专注 pause/resume、暂停秒数持久化与离线有效时长导入；39 项 Maven 测试和 Spring local 上下文通过。"
  next_actions:
    - "使用合成登录会话完成 U14/U15/U24/U25 真实 HTTP 回放，覆盖幂等、冲突策略、暂停恢复和目标账号不匹配。"
    - "完成 Windows 八方向真实拖边和 DPI 矩阵。"
