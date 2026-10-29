---
schema_version: 1
document_type: checkpoint
sequence: "0124"
created_at: "2026-10-30T03:34:50+08:00"
phase: P01
type: DONE
status: complete
title: "用户确认后临时自用入口开放30分钟与外部下载校验"
objective: "按具体链接/4文件/单设备范围开放临时下载，并核对公网下载；不计实体安装或覆盖完成。"
completed:
  - fact: "人类回复确认开放30分钟；当前域名/随机路径与上一轮展示完全一致，未扩大文件或设备范围。"
    evidence: "request_user_input_async问题的用户直接回复；publish_temporary_install.py检查完整链接相同后执行"
  - fact: "北京时间2026-10-30 03:31:50至04:01:50，精确1800秒。开放标记绑定run_id/origin/HAP及4文件摘要，拒绝静默续期；服务到期关闭，隧道随服务结束退出。"
    evidence: "self-use/20261030/publish-approval.json和publication-readiness.json；server-readiness.json published=true"
  - fact: "7项外部HTTPS校验通过：健康开放状态、安装页/描述/图标精确字节摘要、HAP HEAD53297721bytes/空正文、前32和后16字节Range206/Content-Range/实际字节。"
    evidence: "publish_temporary_install.py exit0；publication-readiness.json passed=7，HAP沿0122 SHA059af006…"
  - fact: "浏览器读取公网安装页、版本/单设备提示与正确store Deeplink；未点击桌面系统安装。截图接口两次失败，未取得新公网截图，旧本机预览不记为公网截图。"
    evidence: "cua_repl.getTab4 AXWebArea及安装链接；getScreenshot/screenshot均Unable to capture screenshot"
changed_files:
  - path: "client/flutter_app/harmonyos/INSTALL.zh-CN.md"
    change: "记录具体授权窗口、外部校验与实体安装边界"
  - path: "progress/0000__AI-RESUME.md"
    change: "0124已开放及到期状态/真机反馈续接"
  - path: "progress/INDEX.md"
    change: "追加0124"
  - path: "progress/0124__20261030__P01__DONE__harmonyos-temporary-download-opened-with-consent.md"
    change: "具体人类授权/外部下载里程碑，保留失败截图和未验实体事项"
evidence:
  - command: "Python publish_temporary_install.py"
    result: "exit0；先验同一确认链接/4文件完整摘要/健康关闭，再原子写入1800秒标记；外部7项PASS，未扩展时长或公开私钥密码"
  - command: "cua_repl公网安装页goto/getTab AX读取；getScreenshot和screenshot"
    result: "首次组合调用超时，恢复只观察到已导航；公网页面/Deeplink可读。两次截图失败后停止截图重试；实体安装未执行"
  - command: "Java21/SnakeYAML2.5 VerifyPublishedInstallerDocuments.java；git diff --check"
    result: "exit0/PASS：4文档严格UTF8字节回转、3无重复键YAML、0124/0125指针、INDEX升序/路径及changed_files；diff --check通过"
compatibility_and_security:
  contract_impact: "none；HAP/版本/包名/业务数据保持0122"
  tenant_impact: "none；未操作真实平板或业务数据库"
  sensitive_data: "经具体确认将含设备Profile/证书信息的HAP通过同一Cloudflare入口临时分发，仅1台授权设备；链接持有者能下载。私钥/密码/独立Profile不共享。完整域名/随机路径及授权记录只在F盘忽略目录，不写Git，未改GitHub"
risks_or_blockers:
  - "实际平板点击/下载/安装/旧Debug覆盖/资料恢复尚无反馈；官方企业资格和账号类型仍待确认"
  - "到期时间04:01:50为历史授权窗口，续接时必须读当前时间/服务状态；未获新授权不续期，不重建后自动公开新域名"
  - "公网截图接口失败；页面与三小文件字节、HAP部分下载已独立通过，不据此声称完整HAP公网下载或实体安装通过"
  - "TIMER/代理权益、真机视觉性能和H5/G01继续待；业务认证/租户/权限/缺字段/生成失败负向本轮未执行"
next_actions:
  - id: NEXT-HARMONYOS-BROWSER-INSTALL-FEEDBACK
    action: "将当前链接和04:01:50截止交付用户，在登记平板华为浏览器点击后按实际提示处理，保留旧应用和资料；若已到期先核对服务已关闭，不自动续期。下载失败按具体HTTP/网络证据定位，安装失败按原始错误定位，不能绕过签名/Profile/资格检查或卸载试错"
    inputs: ["client/flutter_app/build/harmonyos-h0/self-use/20261030/publication-readiness.json", "client/flutter_app/build/harmonyos-h0/self-use/20261030/server-readiness.json", "client/flutter_app/harmonyos/INSTALL.zh-CN.md"]
---
