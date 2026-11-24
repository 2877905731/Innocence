---
schema_version: 1
document_type: checkpoint
project_name: Innocence
sequence: "0163"
created_at: "2026-11-24T23:27:29+08:00"
phase: P01
type: DONE
status: complete
title: "1.3.5三端任务排序正式公开，生产排序后端与在线更新目录上线"
objective: "执行用户“直接重新编译并发布”指令，完成原签名正式构建、生产升级、三端应用内更新及GitHub公开发行。"
completed:
  - fact: "三端1.3.5+17已本机正式编译：Windows安装器/便携ZIP、Android原证书联网APK、鸿蒙未签名ARM64联网Release/AOT。Windows安装器资源版本1.3.5.17；130个Dart和5个ArkTS副本逐字节一致。"
    evidence: "build/qa/v1.3.5/release-gates.json与public-artifacts-verified.json；原APK指纹c3921809…；HAP官方验签确认无签名块，三端生产地址/字体许可/CRC/版本/摘要通过。"
  - fact: "生产已部署排序后端，源4f057c9029efb2eff1444a0c6d7fdc2351e4908b，JAR9e96111d5f9a3b6ebdb0bfef185c51899eb9a6a3f01ead3aa6a029181874b336；无SQL结构迁移，未重初始化或导入真实账号资料。"
    evidence: "升级前私有备份/opt/innocence/backups/pre-online-20261124151911及隔离MySQL恢复通过；候选/运行JAR、配置清单、Nginx及可信HTTPS健康UP一致。服务器只包装本机JAR与发布/传输，没有在服务器编译应用。"
  - fact: "真实生产HTTPS用隔离账号验证日任务、年度任务及子任务排序，ID/时段/时长/完成/月份/颜色/进度保持；三类设备会话读取顺序一致。认证、租户、权限、字段、重复/不完整ID和陈旧版本拒绝通过。"
    evidence: "PRODUCTION_PLAN_SORTING_AND_THREE_PLATFORM_READS_PASS；两临时账号及其合成资料、临时管理员授权均已清理。用户真实任务未改。generation_failure不适用，本功能不调用模型。"
  - fact: "三平台1.3.5+17安装/导出包已通过真实后台上传发布，build16可见17、build17无更高更新；鉴权完整下载SHA、Range206、匿名/错误平台/未发布/下架拦截通过，旧build16包保留。"
    evidence: "build/deployment/plan-order-20261124/production-safe.json；temporary_admin_grant_removed和synthetic_accounts_cleaned均true。"
  - fact: "GitHub v1.3.5与v1.3.5-harmonyos.1已公开，latest=v1.3.5；双注释标签固定同一源4f057c9。七资产远端摘要/大小、匿名完整下载SHA及发行正文精确核对通过。"
    evidence: "主Release#456938945，鸿蒙#456942292；build/qa/v1.3.5/public-download-checks.json，7次匿名GET200且流式摘要一致。"
  - fact: "实查服务器注册开关为开启，保留该现状，未按旧0154/0155历史记录强制关闭；生产健康UP，临时授权不存在。公开发行不代表设备已经覆盖。"
    evidence: "registration_enabled=true/registration_setting_preserved=true；resources-safe.json磁盘余22143389696字节、MemAvailable 952744KiB。本人鸿蒙仍沿0156的1.3.4；0161实况窗申请处理中，无新增权益通过证据。"
changed_files:
  - path: client/flutter_app/pubspec.yaml
    change: "1.3.5+17，三端正式包共用版本。"
  - path: docs/releases/v1.3.5.md
    change: "Windows/Android公开发行正文及下载/升级边界。"
  - path: docs/releases/v1.3.5-harmonyos.1.md
    change: "鸿蒙公开未签名HAP正文、签名覆盖和设备边界。"
  - path: docs/development/计划手动排序.md
    change: "补充实际部署与公开发布状态和验证边界。"
  - path: docs/03-execution-plan.md
    change: "排序轨道更新为生产上线与三端公开。"
  - path: docs/06-contract-inventory.md
    change: "排序接口生产HTTPS证据状态。"
  - path: docs/07-dataflow-and-module-map.md
    change: "更新生产排序数据流与实体边界。"
  - path: progress/0000__AI-RESUME.md
    change: "当前1.3.5公开/线上基线、原签名更正、注册实况与未完门禁。"
  - path: progress/INDEX.md
    change: "按序追加0162和0163，保留并行0161审核提交记录。"
evidence:
  - command: "windows/package_release.ps1 -SkipVerification；android/package_release.ps1 -Edition Online -SkipVerification -SigningDirectory <原材料目录>；tool/harmonyos.ps1 -Action build -BuildMode release -Edition Online -Unsigned"
    result: "三端正式构建退出0；Windows Flutter66.3秒/Inno43.375秒、APK190.7秒、鸿蒙281.3秒。复用0160相同应用源码278通过/6条件跳过、排序3/显式鸿蒙9证据；本轮只调整版本与发行文档。"
  - command: "dart analyze lib test；显式Offline/Online define分别运行test/app/offline_release_test.dart与online_release_test.dart"
    result: "分析无问题；离线4项与联网2项通过，均退出0。"
  - command: "mvn -q clean verify；npm run build；python infra/deploy/package.py"
    result: "后端干净构建131项0失败/错误/跳过；后台TypeScript/Vite构建通过；27文件/41673116字节安全部署压缩包，开发配置剔除/CRC/逐项内容和摘要通过。"
  - command: "python client/flutter_app/build/qa/v1.3.5/verify_public_artifacts.py；Windows VersionInfo读取"
    result: "原APK证书/非Debug/三ABI与联网权限、未签名ARM64HAP/平板/AOT、130Dart/5ArkTS/字体许可/生产地址/CRC/版本/摘要通过；安装器1.3.5.17。"
  - command: "SSH执行python3 -u /opt/innocence/plan-order-20261124/deploy.py；只读复核运行JAR、catalog、nginx -t、HTTPS健康及授权文件"
    result: "备份隔离恢复、生产排序/三类会话/负向、后台上传发布、三平台完整鉴权下载SHA/Range及临时授权/账号清理通过，退出0；注册开启保持不变。"
  - command: "使用当前系统代理临时覆盖Git进程代理，push main与两个原子注释标签；python client/flutter_app/build/qa/release135.py stage/publish"
    result: "源码与双标签成功推送；两Release七个白名单资产全部摘要验证后公开，旧资产与旧标签未覆盖。Git原配置指向不可达旧代理，本轮没有持久修改用户代理配置。"
  - command: "python client/flutter_app/build/qa/v1.3.5/verify_downloads.py"
    result: "退出0，7次匿名完整GET200/长度/流式SHA256通过；小文本精确字节、双正文精确一致、注释标签同源、latest=v1.3.5。"
compatibility_and_security:
  contract_impact: "PUT /plans/reorder已上线，旧保存/读取/计时/更新契约保留；无SQL结构迁移。正式客户端从build16升17，Android原证书不变。"
  tenant_impact: "排序身份来自Bearer；仅隔离合成账号用于生产验证并清理；离线导入仍须预览与目标账号确认，真实任务与本机资料未迁移。"
  sensitive_data: "凭据仅本机解锁及构建进程环境；原.env与管理员名单留服务器；公开白名单仅七资产，无个人Profile/证书/设备标识/签名包。"
risks_or_blockers:
  - "Windows仍无Authenticode；本轮没有覆盖或启动用户设备应用，完整实体触控/多DPI/OEM/安装/同步/真实模型门禁继续开放，P01/G01不因此关闭。"
  - "鸿蒙公开HAP需接收者有效证书和设备Profile经电脑签名覆盖，不能直接安装；本人设备仍1.3.4，实况窗0161处理中不等于获批。"
next_actions:
  - id: NEXT-PLAN-ORDER-RUNTIME
    action: "沿公开1.3.5/后端实况收集三端实际排序、触控及跨设备反馈；公开发行已完成，不重复部署或发布。设备升级仅按用户具体指令保资料覆盖，不重建真实任务验证。"
    inputs: [docs/releases/v1.3.5.md, docs/releases/v1.3.5-harmonyos.1.md, docs/development/计划手动排序.md]
---
