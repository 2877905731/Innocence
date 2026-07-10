import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/surface_palette.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/secondary_page_scaffold.dart';
import 'package:innocence_flutter/features/admin/domain/models/admin_report_models.dart';

class AdminAnnouncementPage extends StatefulWidget {
  const AdminAnnouncementPage({
    super.key,
    required this.onLoadAnnouncements,
    required this.onCreateAnnouncement,
    required this.onDeleteAnnouncement,
  });

  final Future<List<AdminAnnouncementItem>> Function({int limit})
      onLoadAnnouncements;
  final Future<AdminAnnouncementActionResult?> Function({
    required String title,
    required String content,
  }) onCreateAnnouncement;
  final Future<AdminAnnouncementActionResult?> Function(int announcementId)
      onDeleteAnnouncement;

  @override
  State<AdminAnnouncementPage> createState() => _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends State<AdminAnnouncementPage> {
  List<AdminAnnouncementItem> _items = const [];
  bool _isLoading = true;

  bool get _isChinese => isChineseLocale(context);

  String _text(String zh, String en) => _isChinese ? zh : en;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final items = await widget.onLoadAnnouncements(limit: 50);
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createAnnouncement() async {
    final draft = await showDialog<_AnnouncementDraft>(
      context: context,
      builder: (context) => _CreateAnnouncementDialog(isChinese: _isChinese),
    );
    if (draft == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final result = await widget.onCreateAnnouncement(
        title: draft.title,
        content: draft.content,
      );
      if (!mounted) {
        return;
      }
      if (result != null && result.message.trim().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
      await _refresh();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAnnouncement(AdminAnnouncementItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_text('删除公告', 'Delete announcement')),
        content: Text(
          _text(
            '确认删除“${item.title.isEmpty ? '这条公告' : item.title}”吗？此操作会对所有接收者生效。',
            'Delete "${item.title.isEmpty ? 'this announcement' : item.title}" for all recipients?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_text('取消', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_text('删除', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final result = await widget.onDeleteAnnouncement(item.announcementId);
      if (!mounted) {
        return;
      }
      if (result != null && result.message.trim().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
      await _refresh();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryPageScaffold(
      backLabel: _text('返回', 'Back'),
      title: _text('公告管理', 'Announcement management'),
      description: _text(
        '发布系统公告、查看近期发送记录，并在需要时删除公告。',
        'Publish project-level system updates, review recent sends, and delete announcements when needed.',
      ),
      headerActions: [
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _refresh,
          icon: _isLoading
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded),
          label: Text(_text('刷新', 'Refresh')),
        ),
        FilledButton.icon(
          onPressed: _isLoading ? null : _createAnnouncement,
          icon: const Icon(Icons.campaign_rounded),
          label: Text(_text('发布公告', 'Publish')),
        ),
      ],
      children: [
        GlassPanel(
          lightStyle: true,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              _text(
                '只有开启系统公告的活跃用户会收到新广播。',
                'Only active users with system announcements enabled will receive new broadcasts.',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (_items.isEmpty)
          GlassPanel(
            lightStyle: true,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _isLoading
                    ? _text('正在加载公告...', 'Loading announcements...')
                    : _text('当前还没有已发布公告。', 'No announcements have been published yet.'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GlassPanel(
                lightStyle: true,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _AdminTag(
                                label: _text(
                                  '${item.recipientCount} 位接收者',
                                  '${item.recipientCount} recipients',
                                ),
                              ),
                              _AdminTag(
                                label: item.createTime.isEmpty
                                    ? _text('时间未知', 'Unknown time')
                                    : item.createTime,
                              ),
                            ],
                          ),
                          FilledButton.tonalIcon(
                            onPressed: _isLoading
                                ? null
                                : () async => _deleteAnnouncement(item),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text(_text('删除', 'Delete')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.title.isEmpty
                            ? _text('未命名公告', 'Untitled announcement')
                            : item.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: SurfacePalette.ink,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.content.isEmpty
                            ? _text('暂无内容。', 'No content.')
                            : item.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AnnouncementDraft {
  const _AnnouncementDraft({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;
}

class _CreateAnnouncementDialog extends StatefulWidget {
  const _CreateAnnouncementDialog({required this.isChinese});

  final bool isChinese;

  @override
  State<_CreateAnnouncementDialog> createState() =>
      _CreateAnnouncementDialogState();
}

class _CreateAnnouncementDialogState extends State<_CreateAnnouncementDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  String? _message;

  String _text(String zh, String en) => widget.isChinese ? zh : en;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      setState(() {
        _message = _text(
          '发布前请同时填写标题和内容。',
          'Enter both a title and content before publishing.',
        );
      });
      return;
    }
    Navigator.of(context).pop(
      _AnnouncementDraft(
        title: title,
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_text('发布公告', 'Publish announcement')),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                maxLength: 64,
                decoration: InputDecoration(
                  labelText: _text('标题', 'Title'),
                  hintText: _text('简短公告标题', 'Short broadcast title'),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contentController,
                maxLength: 255,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: _text('内容', 'Content'),
                  hintText: _text(
                    '希望所有用户现在知道什么？',
                    'What should all users know right now?',
                  ),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SurfacePalette.ink,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_text('取消', 'Cancel')),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(_text('发布', 'Publish')),
        ),
      ],
    );
  }
}

class _AdminTag extends StatelessWidget {
  const _AdminTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: SurfacePalette.softSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SurfacePalette.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: SurfacePalette.ink,
            ),
      ),
    );
  }
}
