---
schema_version: 1
document_type: checkpoint
sequence: "0122"
created_at: "2026-10-30T02:29:34+08:00"
phase: P01
type: DONE
status: complete
title: "单设备Release签名HAP验签、离线资源核对与临时入口选择"
objective: "完成同密钥的个人单设备Release候选，并明确网页入口准备范围；本检查点不计公网部署或实体覆盖完成。"
completed:
  - fact: "独立app-release签名配置引用已验证CER/P7B、沿用原密钥及编码密码字段，原Debug配置未变，仓库源signingConfigs保持空。"
    evidence: "prepare_release_signing.cjs exit0；release-signing-configuration-readiness.json"
  - fact: "ARM64 Release/AOT HAP构建成功，Hvigor167.3秒，含依赖解析的成功包装流程222.4秒。版本1.2.5+10，53297721字节，SHA256 059af0066d95618d3c6cdf633c69555dccf4edf114b224771ce6b431078e93a1。"
    evidence: "run_release_build.py exit0；self-use/20261029/release-build-result.json及私有签名HAP"
  - fact: "官方verify-app/codesign/摘要/权限签名通过；CRC、内嵌Profile逐字节、签名链公钥匹配；三份AArch64 ELF、五字体许可资产及119份Dart源文件逐字节核对通过。平板/debug=false，无INTERNET，仅PUBLISH_AGENT_REMINDER。"
    evidence: "verify_signed_hap.py exit0；signed-hap-readiness.json与仅状态的hap-verification.sanitized.log"
  - fact: "Profile实际app-distribution-type为internaltesting，完整单设备集合与原Profile一致。旧0111本机候选debug=true，新包false；app-identifier变化继续明确保留，未安装或卸载实体应用。"
    evidence: "verify_profile_identity.py及verify_signed_hap.py输出仅布尔/计数/枚举，无原始设备标识"
  - fact: "用户原文：没有，准备临时入口。授权准备临时HTTPS方案，不是对外共享含设备Profile的安装包。实际公网入口尚未创建或开放。"
    evidence: "人类对request_user_input_async HTTPS地址问题的回复；准备与实际开放权限分开"
  - fact: "通过浏览器读取华为2026-10-13指南，确认同域HTTPS、HEAD、Range与用户点击Deeplink规范，并记录当前文档企业开发者限制。官方链接的描述签名工具已固定仓库c71aa1afd261b8921a2062e478ba86641c0e646c，仅F盘。"
    evidence: "华为doccenter-submission内测指南；Gitee官方链接仓库HEAD及README，manifest工具JAR SHA2569196039a61b6df1e9cedfece5377f5031d7dac48ad76a210ba3f08d96203dd63"
changed_files:
  - path: "client/flutter_app/harmonyos/INSTALL.zh-CN.md"
    change: "签名候选/实际验签、Debug覆盖差异及临时网页入口边界"
  - path: "progress/0000__AI-RESUME.md"
    change: "0122签名包就绪与临时入口准备续接"
  - path: "progress/INDEX.md"
    change: "追加0122"
  - path: "progress/0122__20261030__P01__DONE__harmonyos-self-use-signed-hap-and-temporary-entry-plan.md"
    change: "本机签名候选独立证据和用户入口选择"
evidence:
  - command: "Node prepare_release_signing.cjs；Python run_release_build.py调用现有PowerShell7/harmonyos.ps1 -Action build -BuildMode release"
    result: "配置exit0；初次WindowsPowerShell5因UTF8编码未进入编译，改用现有PowerShell7后build exit0/Hvigor167.3秒/包装222.4秒；无业务源码修改"
  - command: "官方hap-sign-tool.jar verify-app与Python verify_signed_hap.py"
    result: "exit0；四验签标志、CRC、精确Profile/签名链公钥、三ARM64 ELF/五字体许可/119 Dart/离线权限通过；首版辅助校验漏遍历字体子目录，修正辅助遍历后全部通过，未重建产品"
  - command: "cua_repl读取官方业务介绍/测试流程/构建Deeplink文档；git只读获取官方链接的manifest工具"
    result: "确认store://enterprise/manifest?url=HTTPS描述地址、同域名/非IP/HEAD/Range；当前企业限制与实机安装仍待核对。Git仅该外部工具固定浅克隆，无项目远端修改"
compatibility_and_security:
  contract_impact: "none；版本/业务/数据契约保持，个人包沿用1.2.5+10"
  tenant_impact: "none；未读取真实业务数据库或操作平板资料"
  sensitive_data: "原私钥未导出；个人CER/Profile/HAP/编码配置仅F盘忽略目录。首次直接SDK验签在工具输出含证书主体元数据，随后改为捕获仅输出通过标志，主体不写入项目记录；后续不保存原始SDK stdout或明文密码，不上传私钥/密码"
risks_or_blockers:
  - "安装描述尚未签名、临时公网入口尚未开放，用户只同意准备；真实浏览器安装未验证"
  - "官方当前指南注明企业开发者限制；当前账号类型未读取，已签发Profile不能代替网页安装资格和实机结果"
  - "旧Debug/new Release状态及app-identifier不同，不能保证直接覆盖或资料保留；不卸载试错，不改签名Profile或开启debug来规避"
  - "TIMER/代理权益、实体画面性能和整体H5/G01仍待；认证失败、租户不匹配、权限拒绝、缺字段、生成失败业务负向本轮未执行"
next_actions:
  - id: NEXT-HARMONYOS-SELF-USE-WEB
    action: "按用户临时入口选择完成本机manifest签名/安装页及HEAD/Range/负向校验；先本机预览或不含安装文件的健康入口，实际链接/文件/期限可审阅后再取得对外共享确认。私人密钥不上传，核对企业资格、实机安装和保资料迁移，不重问已完成签发/构建授权"
    inputs: ["client/flutter_app/build/harmonyos-h0/self-use/20261029/signed-hap-readiness.json", "client/flutter_app/build/harmonyos-h0/tools/internal-testing-c71aa1a/README.md", "client/flutter_app/harmonyos/INSTALL.zh-CN.md"]
---
