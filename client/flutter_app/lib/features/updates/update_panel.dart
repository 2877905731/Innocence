import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'update_controller.dart';

class UpdatePanel extends StatelessWidget {
  const UpdatePanel({super.key, required this.controller});
  final UpdateController controller;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final c = controller, item = c.release;
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('软件更新', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(c.currentVersion.isEmpty
                  ? '登录在线账号后，检查并下载最新版本。'
                  : '当前版本 ${c.currentVersion}'),
              const SizedBox(height: 12),
              Wrap(spacing: 12, runSpacing: 12, children: [
                OutlinedButton.icon(
                    onPressed: c.busy ? null : c.check,
                    icon: const Icon(Icons.system_update_alt),
                    label: const Text('检查更新')),
                if (item != null && !c.verified)
                  FilledButton(
                      onPressed: c.busy ? null : c.download,
                      child: const Text('下载更新')),
                if (item != null && item.manual && c.verified)
                  OutlinedButton(
                      onPressed: c.busy
                          ? null
                          : () async {
                              try {
                                final location = await getSaveLocation(
                                    suggestedName:
                                        'Innocence-${item.version}-unsigned.hap');
                                if (location != null) {
                                  await c.exportManual(location.path);
                                }
                              } catch (_) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              '当前系统无法导出，请在电脑下载发行包并签名覆盖。')));
                                }
                              }
                            },
                      child: const Text('导出 HAP 到文件')),
                if (item != null && c.verified && !item.manual)
                  FilledButton(
                      onPressed: c.busy
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                          title: const Text('安装更新'),
                                          content: Text(item.platform ==
                                                  'windows'
                                              ? '将打开 Innocence 安装器。请按提示关闭应用并覆盖安装，原有资料会保留。'
                                              : '将打开系统安装器，请确认后覆盖安装，原有资料会保留。'),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('稍后')),
                                            FilledButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('开始安装'))
                                          ]));
                              if (confirmed == true) await c.install();
                            },
                      child: const Text('安装更新')),
              ]),
              if (item != null) ...[
                const SizedBox(height: 16),
                Text(
                    '发现 ${item.version} · ${(item.size / 1048576).toStringAsFixed(1)} MiB',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                SelectableText(item.notes),
                if (item.manual)
                  const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                          '此鸿蒙开发版需使用电脑和有效设备签名覆盖安装。当前安装资格不支持通用的应用内安装；请勿卸载原应用或清除资料。')),
              ],
              if (c.busy)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: LinearProgressIndicator(
                        value:
                            c.progress > 0 && !c.verified ? c.progress : null)),
              if (c.message != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Semantics(
                        liveRegion: true,
                        child: Text(c.message!,
                            key: const ValueKey('update-message')))),
            ]);
      });
}
