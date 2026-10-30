---
schema_version: 1
document_type: checkpoint
sequence: "0139"
created_at: "2026-10-31T01:10:27+08:00"
phase: P01
type: DONE
status: complete
title: "Android原液态玻璃恢复版1.3.1公开，原签名联网APK两资产核对通过"
objective: "按0137用户纠正完成Android恢复与原证书联网修正版发布"
source_commit: "0c4d332e80cf7ae29dc5c92439840c31d31f5bcd"
completed:
  - fact: "Android v1.3.1+13正式公开，latest=v1.3.1。"
    evidence: "Release#429289413；源码0c4d332e80cf7ae29dc5c92439840c31d31f5bcd和注释标签精确同步。"
  - fact: "恢复Android原背景模糊、椭圆、逻辑纹理上限与采样，侘寂字体代码和资产保留。"
    evidence: "原175338f源码golden：误改版38.95%/146483像素差异，恢复后逐像素通过；Android7项、鸿蒙3项通过。"
  - fact: "原签名联网APK与发布资产核对完成。"
    evidence: "81022823bytes/SHA321d197f70283f5ebee643fe01dceeea26cf634498004e2f2a4ab32a2eb1f4e0；原证书c3921809…、版本13/1.3.1、非debug/INTERNET/五字体许可CRC及三ABI生产HTTPS通过；两资产远端摘要/正文/匿名HEAD200长度一致。"
  - fact: "发行门禁及范围准确记录。"
    evidence: "源码分析无问题，全量233通过/6平台跳过，离线4/联网2；Android发行构建127.1秒。未操作实体设备、服务器或重建Windows/鸿蒙发行；原联网/数据/签名规则保持。"
changed_files:
  - path: "CHANGELOG.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "README.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "README_EN.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "client/flutter_app/lib/core/widgets/glass_motion_backdrop.dart"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "client/flutter_app/pubspec.yaml"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "client/flutter_app/test/core/widgets/android_glass_original_test.dart"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "client/flutter_app/test/core/widgets/glass_refraction_test.dart"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "client/flutter_app/test/core/widgets/goldens/android_glass_pre_0118.png"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "docs/03-execution-plan.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "docs/releases/v1.3.1.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "progress/0000__AI-RESUME.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "progress/0137__20261031__P01__CORRECTION__android-glass-original-scope-restored.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "progress/0138__20261031__P01__CORRECTION__harmony-glass-regression-count.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "progress/0139__20261031__P01__DONE__android-glass-restored-v131-published.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
  - path: "progress/INDEX.md"
    change: "本轮Android原视觉恢复/回归/发行说明及实际公开记录，具体差异见源码提交。"
evidence:
  - command: "git show 4417cdf^ 原玻璃源码生成golden；修复前后Android像素比较"
    result: "基线411×915/202801bytes；修复前38.95%不同，恢复后完全一致。源golden SHA35c9629e53cfcf1e0cd17b031d12687aae8c8f9e6e4de4a4483dcc3a32ee2953；非业务图像。"
  - command: "Android目标玻璃/字体回归；鸿蒙目标glass_refraction_test"
    result: "7项/3项通过，0138已更正0137计数误记，未修改旧检查点。"
  - command: "android/package_release.ps1 -Edition Online；verify_apk.py"
    result: "分析无问题、233通过/6跳过、离线4/联网2；127.1秒构建，原证书/版本/网络/CRC/字体/生产地址核对通过。"
  - command: "git push --atomic main refs/tags/v1.3.1；release131.py publish/check"
    result: "精确源码与标签同步；草稿两资产SHA/大小齐备后公开，匿名下载200及长度/正文/摘要一致，latest=v1.3.1。"
compatibility_and_security:
  contract_impact: "Android视觉恢复及版本递增；HTTPS与API契约沿1.3.0。Windows/鸿蒙已发布包沿原版本。"
  tenant_impact: "不改SQLite/主题偏好、账号会话、权限或导入语义；原正式证书支持保资料覆盖。"
  sensitive_data: "公开仅APK和SHA256SUMS；私有签名凭据和宿主运行产物不入Git；golden仅作为合成回归输入。"
risks_or_blockers:
  - "宿主像素对照不替代实体Android GPU、持续性能与OEM矩阵；原G01设备门禁保持。"
next_actions:
  - id: NEXT-001
    action: "交付Android联网APK，用户覆盖正式旧版后验收玻璃恢复和侘寂字体；保留已有资料及当前服务。"
    inputs: [docs/releases/v1.3.1.md]
---
