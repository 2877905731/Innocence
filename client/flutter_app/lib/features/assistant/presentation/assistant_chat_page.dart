import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/app_language.dart';
import '../../../app/app_visual_theme.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/themed_dialog.dart';
import '../application/chat_controller.dart';
import '../data/chat_discovery.dart';

class AssistantChatPage extends StatefulWidget {
  const AssistantChatPage(
      {super.key,
      required this.controller,
      required this.language,
      required this.visualTheme,
      this.onOpenPlanner});
  final AssistantChatController controller;
  final AppLanguage language;
  final AppVisualTheme visualTheme;
  final Future<void> Function()? onOpenPlanner;
  @override
  State<AssistantChatPage> createState() => _AssistantChatPageState();
}

class _AssistantChatPageState extends State<AssistantChatPage> {
  late final TextEditingController _input;
  final _scroll = ScrollController();
  int _count = 0;
  String? _owner;
  AssistantChatController get c => widget.controller;
  String t(String zh, String en) => widget.language.isChinese ? zh : en;
  @override
  void initState() {
    super.initState();
    _owner = c.owner();
    _input = TextEditingController(text: c.draft);
    c.addListener(_changed);
    unawaited(c.initialize());
  }

  void _changed() {
    if (_owner != c.owner()) {
      _owner = c.owner();
      _input.text = c.draft;
    }
    if (_count != c.entries.length) {
      _count = c.entries.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) {
          unawaited(_scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut));
        }
      });
    }
  }

  @override
  void dispose() {
    c.removeListener(_changed);
    c.draft = _input.text;
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final value = _input.text;
    if (value.trim().isEmpty || c.busy || c.configuring) return;
    if (c.connection != null && !c.offlineOnly) _input.clear();
    unawaited(c.send(value));
  }

  Future<void> _settings() async {
    await showThemedDialog<void>(
        context: context,
        builder: (_) =>
            _ChatSettings(controller: c, isChinese: widget.language.isChinese));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: c,
      builder: (context, _) {
        final theme = Theme.of(context);
        final visual = theme.extension<AppVisualThemeMarker>()?.visualTheme ??
            widget.visualTheme;
        return Scaffold(
          appBar: AppBar(title: Text(t('智能助手', 'Assistant')), actions: [
            IconButton(
                key: const ValueKey('chat-settings'),
                tooltip: t('模型设置', 'Model settings'),
                onPressed: c.busy ? null : _settings,
                icon: const Icon(Icons.tune_rounded)),
            PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'planner') {
                    await widget.onOpenPlanner?.call();
                    return;
                  }
                  if (value == 'new') {
                    if (!context.mounted) return;
                    final yes = await showThemedDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                                title: Text(t('开始新对话', 'New conversation')),
                                content: Text(t('清除当前对话记录，保留模型配置。',
                                    'Clear this conversation and keep model settings.')),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(t('取消', 'Cancel'))),
                                  FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(t('新对话', 'New chat')))
                                ]));
                    if (yes == true) {
                      await c.clearHistory();
                    }
                  }
                },
                itemBuilder: (_) => [
                      PopupMenuItem(
                          value: 'new',
                          enabled: !c.busy,
                          child: Text(t('新对话', 'New chat'))),
                      if (widget.onOpenPlanner != null)
                        PopupMenuItem(
                            value: 'planner',
                            child: Text(t('本地排程工具', 'Local planner')))
                    ])
          ]),
          body: SafeArea(
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(children: [
                        Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  ChoiceChip(
                                      label: Text(t('聊天', 'Chat')),
                                      selected: !c.agentMode,
                                      onSelected: c.busy
                                          ? null
                                          : (_) => c.setAgentMode(false)),
                                  ChoiceChip(
                                      label: Text(t('操控软件', 'Control app')),
                                      selected: c.agentMode,
                                      onSelected: c.busy
                                          ? null
                                          : (_) => c.setAgentMode(true)),
                                  Text(
                                      c.connection == null
                                          ? t('未连接模型', 'Model not configured')
                                          : c.connection!.model,
                                      style: theme.textTheme.bodySmall),
                                ])),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Text(
                                c.offlineOnly
                                    ? t('当前为离线专用构建，可使用本地排程工具。',
                                        'Offline build: use the local planner.')
                                    : c.agentMode
                                        ? t('对话与按需读取的软件资料发送至你的模型服务；软件变更先展示确认。',
                                            'Messages and requested app data go to your model service. Review changes before execution.')
                                        : t('仅发送对话内容，不调用软件功能。',
                                            'Send conversation only; app tools are disabled.'),
                                style: theme.textTheme.bodySmall)),
                        Expanded(
                            child: c.entries.isEmpty
                                ? SingleChildScrollView(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.auto_awesome_outlined,
                                              size: 40,
                                              color: theme.colorScheme.primary),
                                          const SizedBox(height: 16),
                                          Text(
                                              t('把想做的事告诉我',
                                                  'Tell me what you want to do'),
                                              style: theme
                                                  .textTheme.headlineSmall),
                                          const SizedBox(height: 8),
                                          Text(t('用对话规划一天，整理备忘录，拆解年度任务，或开始专注。',
                                              'Plan your day, organize memos, break down annual goals, or start focus.')),
                                          const SizedBox(height: 20),
                                          for (final example in [
                                            t('看看我今天的安排，帮我规划明天的学习计划',
                                                'Review today and plan my study schedule for tomorrow'),
                                            t('把这周的学习目标整理成备忘录',
                                                'Save this week’s study goals as a memo'),
                                            t('帮我把年度目标拆成几个子任务',
                                                'Break my annual goal into subtasks')
                                          ])
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: ActionChip(
                                                    label: Text(example,
                                                        maxLines: 3),
                                                    onPressed: () {
                                                      _input.text = example;
                                                      c.draft = example;
                                                    })),
                                          if (c.connection == null)
                                            FilledButton.icon(
                                                onPressed: _settings,
                                                icon: const Icon(
                                                    Icons.key_outlined),
                                                label: Text(t('配置我的 API Key',
                                                    'Set up my API Key'))),
                                        ]))
                                : ListView.builder(
                                    controller: _scroll,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    itemCount: c.entries.length,
                                    itemBuilder: (_, index) {
                                      final entry = c.entries[index],
                                          user = entry.role == 'user',
                                          action = entry.role == 'action';
                                      return Align(
                                          alignment: user
                                              ? Alignment.centerRight
                                              : Alignment.centerLeft,
                                          child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 14),
                                              constraints: const BoxConstraints(
                                                  maxWidth: 820),
                                              child: GlassPanel(
                                                  frosted: visual ==
                                                      AppVisualTheme.glass,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            user
                                                                ? t('你', 'You')
                                                                : action
                                                                    ? t('软件操作',
                                                                        'App action')
                                                                    : t('助手',
                                                                        'Assistant'),
                                                            style: theme
                                                                .textTheme
                                                                .labelMedium),
                                                        const SizedBox(
                                                            height: 6),
                                                        action
                                                            ? ExpansionTile(
                                                                tilePadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                title: Text(
                                                                    entry.text
                                                                        .split(
                                                                            '\n')
                                                                        .first,
                                                                    maxLines: 3),
                                                                children: [
                                                                    SelectableText(
                                                                        entry
                                                                            .text)
                                                                  ])
                                                            : SelectableText(
                                                                entry.text),
                                                      ]))));
                                    })),
                        if (c.error != null)
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: Semantics(
                                  liveRegion: true,
                                  child: Text(c.error!,
                                      style: TextStyle(
                                          color: theme.colorScheme.error)))),
                        if (c.pending != null)
                          Flexible(
                              child: SingleChildScrollView(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: GlassPanel(
                                      frosted: true,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                                t('确认这次软件操作',
                                                    'Review this app action'),
                                                style: theme
                                                    .textTheme.titleMedium),
                                            const SizedBox(height: 8),
                                            SelectableText(
                                                c.pending!.tool.summary),
                                            const SizedBox(height: 12),
                                            Wrap(spacing: 12, children: [
                                              OutlinedButton(
                                                  key: const ValueKey(
                                                      'chat-decline'),
                                                  onPressed: () =>
                                                      c.decide(false),
                                                  child:
                                                      Text(t('取消', 'Cancel'))),
                                              FilledButton(
                                                  key: const ValueKey(
                                                      'chat-approve'),
                                                  onPressed: () =>
                                                      c.decide(true),
                                                  child: Text(
                                                      t('确认执行', 'Execute')))
                                            ])
                                          ])))),
                        if (c.busy && c.pending == null)
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2)),
                                    const SizedBox(width: 8),
                                    Text(t('助手正在处理…', 'Working…'))
                                  ])),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                      child: TextField(
                                          key: const ValueKey('chat-input'),
                                          controller: _input,
                                          minLines: 1,
                                          maxLines: 5,
                                          enabled: !c.busy && !c.configuring,
                                          onChanged: (value) => c.draft = value,
                                          decoration: InputDecoration(
                                              hintText: t('说说你的目标，或告诉我需要操作什么…',
                                                  'Describe your goal or app action…'),
                                              border:
                                                  const OutlineInputBorder()))),
                                  const SizedBox(width: 8),
                                  IconButton.filled(
                                      key: const ValueKey('chat-send'),
                                      tooltip: c.busy
                                          ? t('停止', 'Stop')
                                          : t('发送', 'Send'),
                                      onPressed: c.configuring
                                          ? null
                                          : c.busy
                                              ? c.stop
                                              : _send,
                                      icon: Icon(c.busy
                                          ? Icons.stop_rounded
                                          : Icons.arrow_upward_rounded)),
                                ])),
                      ])))),
        );
      });
}

class _ChatSettings extends StatefulWidget {
  const _ChatSettings({required this.controller, required this.isChinese});
  final AssistantChatController controller;
  final bool isChinese;
  @override
  State<_ChatSettings> createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<_ChatSettings> {
  late final TextEditingController _endpoint, _model, _key;
  late String? _owner;
  String _protocol = 'auto';
  bool _showKey = false, _advanced = false;
  int _revision = 0;
  ChatModelCatalog? _catalog;
  String? _selection, _status;
  String t(String zh, String en) => widget.isChinese ? zh : en;
  AssistantChatController get c => widget.controller;
  @override
  void initState() {
    super.initState();
    _owner = c.owner();
    var address = c.connection?.endpoint ?? '';
    if (address.isNotEmpty) {
      try {
        address = ChatServiceAddress.parse(address).base.toString();
      } on FormatException {/* Keep the user value for correction. */}
    }
    _endpoint = TextEditingController(text: address);
    _model = TextEditingController(text: c.connection?.model ?? '');
    _selection = c.connection?.model;
    _key = TextEditingController();
    _endpoint.addListener(_inputsChanged);
    _key.addListener(_inputsChanged);
    c.addListener(_identity);
  }

  bool get _canReuseKey {
    final saved = c.connection;
    if (saved == null) return false;
    try {
      return ChatServiceAddress.parse(_endpoint.text).base.origin ==
          ChatServiceAddress.parse(saved.endpoint).base.origin;
    } on FormatException {
      return false;
    }
  }

  String get _keyValue => _key.text.trim().isNotEmpty
      ? _key.text.trim()
      : _canReuseKey
          ? c.connection!.apiKey
          : '';
  void _inputsChanged() {
    if (!mounted) return;
    setState(() {
      _revision++;
      _catalog = null;
      _selection = null;
      _model.clear();
      _status = null;
    });
  }

  void _identity() {
    if (_owner != c.owner()) {
      _catalog = null;
      _key.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> _discover() async {
    final revision = _revision;
    final catalog = await c.discoverModels(_endpoint.text.trim(), _keyValue);
    if (!mounted || _owner != c.owner() || revision != _revision) return;
    setState(() {
      _catalog = catalog;
      if (catalog != null) {
        final previous = c.connection?.model;
        _selection = catalog.models.any((m) => m.id == previous)
            ? previous
            : catalog.models.length == 1
                ? catalog.models.single.id
                : null;
        _model.text = _selection ?? '';
        _status = catalog.models.length.toString() +
            t(' 个模型已获取，请选择后连接。', ' models found. Select one to connect.');
      }
    });
  }

  Future<void> _connect() async {
    String? preferred;
    try {
      preferred = ChatServiceAddress.parse(_endpoint.text).protocolHint ??
          (_canReuseKey ? c.connection?.protocol : null);
    } on FormatException {/* The controller reports invalid addresses. */}
    final ok = await c.connectService(
        _catalog?.base.toString() ?? _endpoint.text.trim(),
        _keyValue,
        _model.text.trim(),
        protocol: _protocol,
        preferredProtocol: preferred);
    if (mounted && ok && _owner == c.owner()) Navigator.pop(context);
  }

  void _close() {
    if (c.configuring) c.stop();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    c.removeListener(_identity);
    _endpoint.removeListener(_inputsChanged);
    _key.removeListener(_inputsChanged);
    if (c.configuring && _owner == c.owner()) c.stop();
    _catalog = null;
    _endpoint.dispose();
    _model.dispose();
    _key.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: c,
      builder: (_, __) => PopScope(
            canPop: !c.configuring,
            child: AlertDialog(
              title: Text(t('连接 AI 服务', 'Connect AI service')),
              content: SizedBox(
                width: 540,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(t('填写服务地址和密钥，获取模型后选择即可。',
                          'Enter the service address and key, then choose a discovered model.')),
                      const SizedBox(height: 16),
                      TextField(
                        key: const ValueKey('chat-endpoint'),
                        controller: _endpoint,
                        enabled: !c.configuring,
                        autocorrect: false,
                        keyboardType: TextInputType.url,
                        decoration: InputDecoration(
                            labelText: t('服务地址', 'Service address'),
                            hintText: 'https://api.deepseek.com',
                            helperText: t('支持服务根地址、/v1 地址或完整接口地址',
                                'Service base, /v1 address or full endpoint')),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('chat-key'),
                        controller: _key,
                        enabled: !c.configuring,
                        obscureText: !_showKey,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          labelText: 'API Key',
                          hintText: _canReuseKey
                              ? t('已保存；留空保留当前密钥',
                                  'Saved; leave blank to keep key')
                              : t('仅在本机加密保存', 'Encrypted on this device'),
                          suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _showKey = !_showKey),
                              icon: Icon(_showKey
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const ValueKey('chat-discover-models'),
                        onPressed: c.configuring ? null : _discover,
                        icon: const Icon(Icons.travel_explore),
                        label: Text(t(
                            _catalog == null ? '获取可用模型' : '刷新模型列表',
                            _catalog == null
                                ? 'Find available models'
                                : 'Refresh models')),
                      ),
                      if (_status != null) ...[
                        const SizedBox(height: 8),
                        Text(_status!),
                      ],
                      if (_catalog != null) ...[
                        const SizedBox(height: 12),
                        InputDecorator(
                          decoration: InputDecoration(
                              labelText: t('选择模型', 'Choose model')),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              key: const ValueKey('chat-model-picker'),
                              value: _selection,
                              isExpanded: true,
                              itemHeight: null,
                              hint: Text(t('请选择一个模型', 'Select a model')),
                              items: _catalog!.models
                                  .map((model) => DropdownMenuItem(
                                      value: model.id,
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          child: Text(model.label,
                                              maxLines: 2,
                                              overflow:
                                                  TextOverflow.ellipsis))))
                                  .toList(),
                              selectedItemBuilder: (_) => _catalog!.models
                                  .map((model) => Text(model.id,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis))
                                  .toList(),
                              onChanged: c.configuring
                                  ? null
                                  : (value) => setState(() {
                                        _selection = value;
                                        _model.text = value ?? '';
                                      }),
                            ),
                          ),
                        ),
                      ] else if (_selection != null) ...[
                        const SizedBox(height: 8),
                        Text(t('当前模型：', 'Current model: ') + _selection!),
                      ],
                      const SizedBox(height: 8),
                      TextButton.icon(
                        key: const ValueKey('chat-advanced'),
                        onPressed: c.configuring
                            ? null
                            : () => setState(() => _advanced = !_advanced),
                        icon: Icon(
                            _advanced ? Icons.expand_less : Icons.expand_more),
                        label: Text(t('高级设置', 'Advanced settings')),
                      ),
                      if (_advanced) ...[
                        Text(t('服务不提供模型列表时，可手动填写模型。协议默认自动识别。',
                            'Enter a model manually if discovery is unavailable. Protocol detection is automatic.')),
                        const SizedBox(height: 12),
                        TextField(
                          key: const ValueKey('chat-model'),
                          controller: _model,
                          enabled: !c.configuring,
                          onChanged: (_) => setState(() {
                            _selection = _catalog?.models
                                        .any((m) => m.id == _model.text) ==
                                    true
                                ? _model.text
                                : null;
                          }),
                          decoration: InputDecoration(
                              labelText: t('手动模型名', 'Manual model name')),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _protocol,
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                                value: 'auto',
                                child: Text(
                                    t('自动识别（推荐）', 'Automatic (recommended)'))),
                            const DropdownMenuItem(
                                value: 'chat', child: Text('Chat Completions')),
                            const DropdownMenuItem(
                                value: 'responses', child: Text('Responses')),
                          ],
                          onChanged: c.configuring
                              ? null
                              : (value) => setState(() => _protocol = value!),
                          decoration:
                              InputDecoration(labelText: t('接口协议', 'Protocol')),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(t('获取模型仅查询列表；保存并连接会发送简短验证请求。密钥按当前资料加密保存在本机。',
                          'Discovery only lists models. Connect sends a short validation request. The key is encrypted for this profile.')),
                      if (c.error != null) ...[
                        const SizedBox(height: 12),
                        Text(c.error!),
                      ],
                      if (c.configuring) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(),
                        Text(t('正在检测服务，关闭可取消。',
                            'Checking service; close to cancel.')),
                      ],
                      if (c.connection != null)
                        TextButton(
                          onPressed: c.configuring
                              ? null
                              : () async {
                                  await c.forgetConnection();
                                  if (mounted) {
                                    _key.clear();
                                    setState(() {
                                      _selection = null;
                                      _model.clear();
                                    });
                                  }
                                },
                          child: Text(t('移除已保存连接', 'Remove saved connection')),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: _close,
                    child: Text(t(c.configuring ? '取消' : '关闭',
                        c.configuring ? 'Cancel' : 'Close'))),
                FilledButton(
                  key: const ValueKey('chat-save-connection'),
                  onPressed: c.configuring || _model.text.trim().isEmpty
                      ? null
                      : _connect,
                  child: Text(t('保存并连接', 'Save and connect')),
                ),
              ],
            ),
          ));
}
