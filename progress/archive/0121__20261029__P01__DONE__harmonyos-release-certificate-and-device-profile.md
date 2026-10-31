---
schema_version: 1
document_type: checkpoint
sequence: "0121"
created_at: "2026-10-29T15:36:28+08:00"
phase: P01
type: DONE
status: complete
title: "个人发布证书、单设备指定发布Profile签发与官方验证"
objective: "执行已具体确认的CSR上传/发布证书及单设备Profile申请，核对本机材料；本检查点只完成签名材料，不将网页安装或保资料升级标为完成。"
completed:
  - fact: "用户明确回复确认上传CSR并申请发布证书；已在华为控制台上传原510字节CSR并申请Innocence-self-use-release。最终证书列表新增1张生效发布证书，有效至2029-10-24。"
    evidence: "人类对request_user_input_async的回复；控制台列表；build/qa/harmony-self-use/release-certificate-issued.jpg"
  - fact: "浏览器下载接口未返回文件，用户手动提供D盘CER；保留原件并按字节复制到F盘。2910字节/3张证书链，唯一签名证书公钥匹配原CSR，当前有效；未创建或导出私钥。"
    evidence: "verify_release_certificate.py exit0；self-use/20261024/release-certificate-readiness.json"
  - fact: "用户明确回复确认创建这份单设备Profile。2026-10-29恢复会话后，控制台主账号显示已认证；同名Profile原为0条。恢复同一应用/证书/设备，提交前名称/包名/类型/证书/设备数五项均匹配具体确认。"
    evidence: "人类对具体Profile问题的回复；cua_repl五项布尔核对全true；未代填实名资料"
  - fact: "Innocence-self-use-tablet-release实际创建成功，证书指纹自动关联应用；列表生效/指定设备发布/包名匹配，有效至2027-04-29。"
    evidence: "控制台成功提示及唯一记录；build/qa/harmony-self-use/profile-created-20261029.jpg"
  - fact: "用户手动下载P7B后，4164字节文件按字节复制F盘。官方verify-profile返回成功，verifiedPassed=true；完整设备集合与旧调试Profile精确匹配1台，包名/开发者标识及签名公钥匹配，内嵌证书与下载证书链中的签名证书完全相同。"
    evidence: "hap-sign-tool.jar verify-profile exit0；verify_profile_identity.py exit0；self-use/20261029/profile-readiness.json"
  - fact: "应用标识差异没有静默消除：新Profile app-identifier为当前登记APP ID，与旧调试Profile不同。控制台设备类型显示手机，但完整设备ID集合已与旧平板Profile在内存精确匹配；不输出真实ID。"
    evidence: "profile-readiness.json只保存差异布尔值和计数，原始签名Profile保持不变"
changed_files:
  - path: "client/flutter_app/harmonyos/INSTALL.zh-CN.md"
    change: "更新真实签发/验证结果、私有材料及覆盖兼容性未完成边界"
  - path: "progress/0000__AI-RESUME.md"
    change: "0121材料就绪状态与无需重复确认的签名构建续接点"
  - path: "progress/INDEX.md"
    change: "追加0121"
  - path: "progress/0121__20261029__P01__DONE__harmonyos-release-certificate-and-device-profile.md"
    change: "证书与指定设备Profile的独立签发证据"
evidence:
  - command: "cua_repl执行具体确认的CSR上传、发布证书申请及指定设备Profile添加"
    result: "证书生效/2029-10-24；Profile添加成功、指纹自动关联、生效/2027-04-29；没有额外设备或ACL申请"
  - command: "Python verify_release_certificate.py解析用户下载证书、匹配CSR公钥及字节复制"
    result: "exit0；2910bytes/3证书/有效，SHA256 2c06254badd2e78fcbcbde5c677f5fe3a1016d758479bb0dd80316f09dcc7121"
  - command: "hap-sign-tool.jar verify-profile -inFile F盘单设备P7B -outFile F盘profile-sdk-verification.json"
    result: "exit0，verify-profile success；结果verifiedPassed=true，含设备内容的完整结果仅保存在F盘忽略目录"
  - command: "Python verify_profile_identity.py核对SDK结果、新旧Profile及发布证书"
    result: "exit0；4164bytes/SHA256 e509314c84cf18110a487915d36c7c4fa7ce2ef089093521234975d590c8802e；1设备精确匹配/包名/公钥/开发者标识/内嵌证书/有效期通过，app-identifier差异明确标记需复核"
  - command: "Java VerifyReleaseMaterialDocuments及git diff --check"
    result: "exit0；四文档严格UTF8字节往返、三YAML无重复键、0121/0122指针、索引顺序和引用路径通过；空白检查通过"
compatibility_and_security:
  contract_impact: "none；未改变业务/数据/版本契约，仅账号侧签名材料及本机文档"
  tenant_impact: "none；未读取真实业务数据库、安装或卸载平板应用"
  sensitive_data: "原始私钥未导出；CER/P7B及含设备内容的SDK验证结果仅F盘忽略目录。设备在内存完整比对，常规输出只含布尔/计数/有效期/文件摘要，不记录真实UDID或主体信息；未推送GitHub或部署"
risks_or_blockers:
  - "本检查点无签名HAP、安装描述/HTTPS或真实安装完成证据；旧Profile已过期，不用它继续签包"
  - "app-identifier与旧Profile不同；Debug至Release还可能有debug字段一致性要求，不能由公钥相同推断覆盖成功或资料保留，不卸载试错"
  - "原私钥存在但编码配置不等同可用CLI明文密码；后续使用官方构建签名流程，不破解/导出密码"
  - "TIMER/后台代理提醒权益未申请；认证失败、租户不匹配、权限拒绝、缺字段和生成失败业务负向本轮未执行，G01不封板"
next_actions:
  - id: NEXT-HARMONYOS-SELF-USE-SIGNING
    action: "使用原密钥、24日发布证书和29日单设备Profile在独立app-release配置并构建，官方验签与离线/源码/资源核验后再准备网页安装描述/HTTPS；明确app-identifier与debug覆盖限制，个人材料不公开，已执行的两项具体确认不重复询问"
    inputs: ["client/flutter_app/harmonyos/INSTALL.zh-CN.md", "client/flutter_app/build/harmonyos-h0/self-use/20261029/profile-readiness.json", "client/flutter_app/tool/harmonyos.ps1"]
---
