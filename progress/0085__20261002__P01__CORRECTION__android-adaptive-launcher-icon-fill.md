---
schema_version: 1
document_type: checkpoint
sequence: "0085"
created_at: "2026-10-02T21:05:53+08:00"
phase: P01
type: CORRECTION
status: complete
title: "Android自适应启动图标留白与填充比例纠正"
objective: "修正用户所述‘安卓端应用图标太小了，没办法覆盖完全’，保留选定品牌图案并产出可覆盖安装的本地签名APK。"
completed:
  - fact: "API26+自适应前景增加四边-20%比例inset，绘制宽高放大1.4倍，补偿前景图片已有的透明留白与系统外层预留区。"
    evidence: "mipmap-anydpi-v26/ic_launcher.xml；Release APK编译XML的TYPE_FRACTION=6，有符号值=-0.200000047683716。"
  - fact: "原前景PNG、正式抠图母版、旧版密度图标与WindowsICO保持不变；字母/圆点/环线/英文品牌字标与短横保留。"
    evidence: "前景SHA256 67161FCF77B25FC4B55AB50957BAFFECB9EDBDF0C85B0D89C49D8CD1AE03E2A8；母版SHA256 1DB3D73496A8A396A9C8CD7D08F09AEAB3A7B1393D958B4067A436FE6F3988DD；git diff仅XML与文档。"
  - fact: "生成包含0084纠正的独立本地签名离线APK，沿用v1.2.0+5与发行证书。"
    evidence: "build/verification/20261002-fixes/Innocence-20261002-icon-fix-android-offline.apk；62476992 bytes；SHA256 8473d9f0d412156fd3359203252f584c2a7d7eb38f9996e1ec76f67763015622。"
  - fact: "API36隔离模拟器覆盖安装成功；Pixel Launcher应用列表与系统应用信息页的圆形图标主体放大，完整字标/短横可见；冷启动恢复本机资料和1项计划。"
    evidence: "F:/AndroidSdk-Innocence/captures/20261002-fixes/icon-drawer-before.png、icon-drawer-after.png、icon-settings-after.png、icon-cold-start.png及对应UI XML。"
changed_files:
  - path: "client/flutter_app/android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml"
    change: "自适应前景按-20%比例inset扩大构图，并注明已有留白与不同图标尺寸适配原因。"
  - path: "docs/design/logo/README.md"
    change: "记录Android自适应资源构图、原图摘要及验证范围。"
  - path: "docs/planning/Innocence-UI设计规划.md"
    change: "存档用户原文和图标填充实现边界。"
  - path: "progress/0000__AI-RESUME.md"
    change: "记录0085状态、最新APK及实体设备后续动作。"
  - path: "progress/INDEX.md"
    change: "按递增顺序追加0085索引。"
  - path: "progress/0085__20261002__P01__CORRECTION__android-adaptive-launcher-icon-fill.md"
    change: "本不可变检查点。"
evidence:
  - command: "flutter build apk --release --no-pub --dart-define=INNOCENCE_OFFLINE_ONLY=true（既有发行凭据只在进程环境注入；kotlin.incremental=false）"
    result: "exit0；assembleRelease 43.5秒；59.6MB APK构建成功。未重新执行Dart测试：本次仅Android资源布局，0084的99项全量/8项离线专项不计作本次新跑结果。"
  - command: "apksigner verify --verbose --print-certs build/verification/20261002-fixes/Innocence-20261002-icon-fix-android-offline.apk"
    result: "Verifies；v2=true；一个签名者；证书SHA256 c39218092db96b3c4085b0853bb781399b7d4fe1747a9d1032844b8154c05837，与正式发行相同。"
  - command: "aapt2 dump resources APK；aapt2 dump xmltree --file res/BW.xml APK；PowerShell读取压缩包编译XML的android:inset类型/有符号Complex值"
    result: "API26+图标资源映射res/BW.xml；AAPT文本把负fraction显示为1.800000%，直接解码有符号值PASS=-0.200000047683716、TYPE_FRACTION=6，且设备实际渲染符合放大效果。"
  - command: "adb -s emulator-5562 install -r APK；input keyevent/swipe；uiautomator dump；screencap/pull；am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:com.innocence.app.innocence_flutter"
    result: "覆盖安装Success；应用列表Innocence bounds=[293,1370][540,1685]；安装前后截图及系统应用信息页截图可核对同一图标的放大与完整字标。仅使用本任务创建的隔离userdata.img。"
  - command: "adb -s emulator-5562 shell am force-stop com.innocence.app.innocence_flutter；am start -W -n com.innocence.app.innocence_flutter/.MainActivity；uiautomator dump；dumpsys package"
    result: "Status ok；LaunchState COLD；TotalTime2380ms；显示‘已恢复本机资料，1项变更仅保存在此设备’、每日标语和今日计划0/1；versionCode5/versionName1.2.0。"
  - command: "Get-FileHash -Algorithm SHA256 APK/前景PNG/母版；git diff --check"
    result: "APK摘要如上；原图摘要不变；diff检查无空白错误。"
compatibility_and_security:
  contract_impact: "none；仅Android自适应图标布局，不改变Dart业务、接口或持久化。"
  tenant_impact: "none；只覆盖本任务隔离模拟器APK，无真实账号读写；冷启动保留原隔离本机资料。"
  sensitive_data: "发行凭据不写入源码、日志或Git；产物仅放ignored build目录。版本1.2.0+5与applicationId/发行密钥不变；未改公开Release、标签或远端Git。"
risks_or_blockers:
  - "只核对API36 Pixel Launcher圆形蒙版及系统信息页；实体手机/OEM蒙版与Android24/25运行未验收，旧版密度资源保持原有字节。"
  - "0084的实体手机/Vulkan光场与Windows多DPI验证仍待补，不因本图标纠正宣布P01/G01全面通过。"
next_actions:
  - id: NEXT-0085-PHYSICAL-DEVICE
    action: "用户实体手机覆盖安装最新icon-fix本地APK，核对桌面大小与OEM裁切，并复验0084光场/圆盘；若另行发行须递增版本号和versionCode并保留签名。"
    inputs: ["client/flutter_app/build/verification/20261002-fixes/Innocence-20261002-icon-fix-android-offline.apk"]
---

# 检查点说明

用户需求原文已保存到UI设计规划。此次只改变系统自适应资源对既有前景的构图，不重新生成品牌图片。

参考Android官方的[自适应图标层尺寸与安全区说明](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive?hl=en)，以及[AOSP InsetDrawable的fraction解析与bounds计算](https://raw.githubusercontent.com/aosp-mirror/platform_frameworks_base/master/graphics/java/android/graphics/drawable/InsetDrawable.java)。负fraction在本次APK编译和API36实际资源加载中均可用。
