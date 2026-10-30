---
schema_version: 1
document_type: checkpoint
sequence: "0137"
created_at: "2026-10-31T01:00:00+08:00"
phase: P01
type: CORRECTION
status: complete
title: "纠正0118共享玻璃修正范围，恢复Android原光束并保留侘寂字体"
objective: "按用户新纠正恢复Android已认可的液态玻璃，仅重发Android联网包"
completed:
  - fact: "用户明确Android玻璃原本没有问题，只有侘寂问题；要求改回并重新发布Android。"
    evidence: "本轮原文已归档至UI设计规划；原0118反馈的玻璃边缘仅针对鸿蒙，旧检查点保持不可变。"
  - fact: "0118提交4417cdf共享修改了GlassMotionBackdrop的模糊/羽化、DPR纹理与重采样；本次按Android能力分支恢复175338f原渲染。"
    evidence: "git diff 4417cdf^ 4417cdf；Android使用原ImageFilter.blur/椭圆/1440逻辑上限/low，Windows与鸿蒙原有羽化保持。"
  - fact: "旧源码对照证明误改差异，恢复后像素一致；侘寂字体与非Android纹理专项通过。"
    evidence: "对照源4417cdf^；修复前38.95%/146483像素不同，恢复后golden通过；Android玻璃/字体7项，鸿蒙玻璃4项通过。"
changed_files:
  - path: client/flutter_app/lib/core/widgets/glass_motion_backdrop.dart
    change: "平台隔离Android原模糊、纹理与绘制方式。"
  - path: client/flutter_app/test/core/widgets/android_glass_original_test.dart
    change: "误改前真实源码渲染对照回归。"
  - path: client/flutter_app/test/core/widgets/goldens/android_glass_pre_0118.png
    change: "175338f原Android光束对照图。"
  - path: client/flutter_app/test/core/widgets/glass_refraction_test.dart
    change: "分别核对Android原纹理和其他平台密度纹理。"
  - path: client/flutter_app/pubspec.yaml
    change: "递增至1.3.1+13。"
  - path: docs/planning/Innocence-UI设计规划.md
    change: "原文归档与视觉范围纠正。"
  - path: docs/releases/v1.3.1.md
    change: "Android修正版发行范围。"
  - path: progress/0137__20261031__P01__CORRECTION__android-glass-original-scope-restored.md
    change: "追加纠正记录，不修改0118。"
  - path: progress/0000__AI-RESUME.md
    change: "当前目标切为Android修正版发布。"
  - path: progress/INDEX.md
    change: "升序追加0137。"
evidence:
  - command: "旧源码宿主Android渲染；新golden修复前后运行；Android玻璃/字体专项；鸿蒙玻璃专项"
    result: "基线411×915；修复前像素不一致，恢复后golden一致；Android7项、鸿蒙4项通过。正式APK正在构建，尚未公开新发行。"
compatibility_and_security:
  contract_impact: "仅视觉与Android版本，生产HTTPS和原联网权限保留。"
  tenant_impact: "不改业务、缓存格式、主题偏好或登录/导入规则。"
  sensitive_data: "仅合成光场，无账号或业务图像；构建及比较产物在忽略目录，原签名凭据不入Git。"
risks_or_blockers:
  - "APK构建/核验/公开尚待完成；宿主像素对照不替代实体GPU和性能验收。"
next_actions:
  - id: NEXT-001
    action: "完成原证书联网APK及全量门禁，核对字体/地址/权限/CRC后提交匹配源码标签并公开Android Release。"
    inputs: [docs/releases/v1.3.1.md]
---
