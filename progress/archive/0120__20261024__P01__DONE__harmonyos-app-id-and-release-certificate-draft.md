---
schema_version: 1
document_type: checkpoint
sequence: "0120"
created_at: "2026-10-24T22:17:05+08:00"
phase: P01
type: DONE
status: complete
title: "鸿蒙同包名APP ID创建、指定设备选项核对与发布证书草稿"
objective: "继续用户准备的控制台新建应用，完成可独立核对的应用登记与签名申请准备；不把草稿或选项可见计为证书签发/网页安装完成。"
completed:
  - fact: "用户原文：我已经在内置浏览器里面准备好了新建应用程序；随后要求继续。在该表单提交并核对Innocence应用及项目创建成功。"
    evidence: "cua_repl页面操作与应用详情限定字段读取；build/qa/harmony-self-use/app-id-created.jpg"
  - fact: "APP ID为6917619921714239020，包名com.innocence.tablet.innocence_flutter，设备平板，语言简体中文，所属项目Innocence，版本状态准备提交。未上架或申请实况窗/代理提醒权益。"
    evidence: "控制台应用详情及无凭据截图；包名与现有工程一致"
  - fact: "证书页仅有一张已于2026-10-21失效的调试证书；Profile列表0条。添加Profile表单可选指定设备发布，选中后有选择设备字段，但未提交Profile。"
    evidence: "cua_repl证书/Profile页面实际UI；选项可见不能等同最终签发资格"
  - fact: "现有CSR自签名有效，公钥匹配旧证书链中的一张签名证书。复用510字节公开请求文件，未新建或导出私钥；CSR及元数据只存F盘忽略目录。"
    evidence: "本机verify_existing_csr.py读取CSR及证书链，通过cryptography验证；build/harmonyos-h0/self-use/20261024/csr-readiness.json"
  - fact: "已填发布证书草稿名称Innocence-self-use-release及发布证书类型；CSR尚未上传、证书尚未提交/签发，已请求对上传具体CSR至华为开发者中心并申请该证书的当次确认。"
    evidence: "build/qa/harmony-self-use/release-certificate-draft.jpg；request_user_input_async具体问题"
changed_files:
  - path: "client/flutter_app/harmonyos/INSTALL.zh-CN.md"
    change: "补实际APP ID/包名/控制台选项与证书草稿及未完成边界"
  - path: "progress/0000__AI-RESUME.md"
    change: "0120当前状态、具体待确认项及同包名AGC应用续接点"
  - path: "progress/INDEX.md"
    change: "追加0120"
  - path: "progress/0120__20261024__P01__DONE__harmonyos-app-id-and-release-certificate-draft.md"
    change: "应用登记与CSR准备的独立证据，保留未签发范围"
evidence:
  - command: "cua_repl在用户准备的华为控制台填写同包名/项目并提交，随后仅读应用必要字段"
    result: "应用创建成功；APP ID/平板/包名/项目匹配，版本准备提交；截图不含个人页头和凭据"
  - command: "cua_repl检查证书和Profile列表，选择发布证书草稿及指定设备发布Profile选项"
    result: "旧证书1张失效/Profile0；指定设备发布选项可选且显示设备字段；两项申请均未提交"
  - command: "Python prepare_csr.py尝试用已有配置密码生成CSR"
    result: "keytool拒绝，keystore password was incorrect；未破解密码或覆盖密钥。改用已有CSR，不把配置中的编码密码当成可用CLI密码"
  - command: "Python verify_existing_csr.py使用cryptography校验已有CSR签名，并与旧PEM证书链逐张比较公钥"
    result: "签名有效/公钥匹配；复制510字节CSR到F盘self-use/20261024；metadata uploaded=false/new_private_key_created=false。平台CSR格式验证和签发未执行"
  - command: "Java VerifyHarmonyAppDocuments校验四个变更文档的严格UTF8/YAML/索引/引用；git diff --check"
    result: "exit0；四文档UTF8字节往返、三YAML无重复键、0120/0121指针、索引顺序和引用路径通过；diff空白检查通过。CSR及两张截图均被Git忽略；无业务源码或二进制修改，沿用0118候选证据"
compatibility_and_security:
  contract_impact: "none；不改版本、业务接口或数据契约"
  tenant_impact: "none；未访问真实业务资料或改动平板数据"
  sensitive_data: "私钥/密码/设备标识未输出到仓库；仅公开CSR复制到F盘忽略目录。创建后首次全量页面读取曾在工具输出出现控制台客户端密钥，已停止全量读取，后续字段及截图避开凭据；未把凭据写入文件、Git或再次复述，未代改凭据"
risks_or_blockers:
  - "等待对具体CSR上传与发布证书申请的当次确认；新发布凭据按浏览器安全敏感访问规则确认。实名认证结果未读取，不能由APP ID创建推断"
  - "CSR复用与公钥一致不证明私钥CLI已可用，也不保证调试至发布覆盖兼容；后续签名仍需官方工具配置及实际验签/保资料覆盖"
  - "发布证书/Profile/设备范围、签名Release HAP/签名安装描述/HTTPS入口及真实平板安装未完成；实况窗和后台代理权益未申请"
  - "认证失败、租户不匹配、权限拒绝、缺字段和生成失败业务负向本轮未执行；本轮证据仅应用登记和签名准备，不封闭H5/G01"
next_actions:
  - id: NEXT-HARMONYOS-SELF-USE-SIGNING
    action: "收到具体确认后，读取浏览器文件上传文档并上传F盘该CSR到华为，提交发布证书申请并核对结果；再按本人平板范围办理指定设备Profile，核对身份/验签/覆盖和网页安装。个人材料不传GitHub；协议/实名由用户本人处理"
    inputs: ["client/flutter_app/harmonyos/INSTALL.zh-CN.md", "client/flutter_app/build/harmonyos-h0/self-use/20261024/csr-readiness.json", "client/flutter_app/build/qa/harmony-self-use/release-certificate-draft.jpg"]
---
