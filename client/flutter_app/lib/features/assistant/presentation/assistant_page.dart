import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/app_language.dart';
import '../../../app/app_visual_theme.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/secondary_page_scaffold.dart';
import '../../../core/widgets/themed_dialog.dart';
import '../application/assistant_controller.dart';
import '../domain/assistant_models.dart';
import '../../plans/domain/models/today_plan.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage(
      {super.key,
      required this.controller,
      required this.language,
      required this.visualTheme});
  final AssistantController controller;
  final AppLanguage language;
  final AppVisualTheme visualTheme;
  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final _scaffold = GlobalKey<ScaffoldState>();
  late final TextEditingController _instruction, _date, _start, _end, _zone;
  String? _owner;
  AssistantController get c => widget.controller;
  String t(String zh, String en) => widget.language.isChinese ? zh : en;
  @override
  void initState() {
    super.initState();
    _owner = c.owner();
    _instruction = TextEditingController(text: c.instruction);
    _date = TextEditingController(text: c.planDate);
    _start = TextEditingController(text: c.start);
    _end = TextEditingController(text: c.end);
    _zone = TextEditingController(text: c.timeZone);
    c.addListener(_identity);
    unawaited(c.restore().then((_) {
      if (mounted) {
        _instruction.text = c.instruction;
        _date.text = c.planDate;
        _start.text = c.start;
        _end.text = c.end;
        _zone.text = c.timeZone;
      }
    }));
  }

  void _identity() {
    if (_owner != c.owner()) {
      _owner = c.owner();
      _instruction.text = c.instruction;
      _date.text = c.planDate;
      _start.text = c.start;
      _end.text = c.end;
      _zone.text = c.timeZone;
    }
  }

  @override
  void dispose() {
    c.removeListener(_identity);
    unawaited(c.saveDraft().catchError((Object _) {}));
    for (final field in [_instruction, _date, _start, _end, _zone]) {
      field.dispose();
    }
    super.dispose();
  }

  void _detail(double width) {
    if (width >= 640) {
      _scaffold.currentState?.openEndDrawer();
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (context) =>
            SecondaryPageScaffold(
                title: t('计划详情', 'Plan details'),
                description:
                    t('审阅新增与保留的安排', 'Review additions and existing tasks'),
                backLabel: t('返回', 'Back'),
                visualTheme: widget.visualTheme,
                pinHeader: true,
                children: [
                  AssistantDetails(controller: c, language: widget.language)
                ])));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: c,
      builder: (context, _) => LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final composer = GlassPanel(
                frosted: true,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(t('安排一天，从说清目标开始', 'Plan a day with a clear goal'),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(c.cloudAllowed && c.useCloud
                          ? t('云端 AI：理解自然语言并提出计划',
                              'Cloud AI: interpret your request and propose plans')
                          : t('离线排程：按任务、时长与可用时段生成方案',
                              'Offline scheduling: tasks, durations and available hours')),
                      if (c.cloudAllowed)
                        SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(t('使用云端 AI', 'Use cloud AI')),
                            subtitle: Text(t('指令与当日任务将发送到已配置的模型服务',
                                'Your instruction and day tasks go to the configured model service')),
                            value: c.useCloud,
                            onChanged: c.busy || c.resultPending
                                ? null
                                : (value) =>
                                    setState(() => c.useCloud = value)),
                      const SizedBox(height: 16),
                      TextField(
                          key: const ValueKey('assistant-date'),
                          controller: _date,
                          enabled: !c.busy,
                          decoration: InputDecoration(
                              labelText:
                                  t('目标日期 · YYYY-MM-DD', 'Date · YYYY-MM-DD')),
                          onChanged: (v) => c.planDate = v),
                      const SizedBox(height: 12),
                      Wrap(spacing: 12, runSpacing: 12, children: [
                        SizedBox(
                            width: 138,
                            child: TextField(
                                controller: _start,
                                enabled: !c.busy,
                                decoration:
                                    InputDecoration(labelText: t('开始', 'From')),
                                onChanged: (v) => c.start = v)),
                        SizedBox(
                            width: 138,
                            child: TextField(
                                controller: _end,
                                enabled: !c.busy,
                                decoration: InputDecoration(
                                    labelText: t(
                                        '结束 · 含24:00', 'Until · up to 24:00')),
                                onChanged: (v) => c.end = v)),
                      ]),
                      if (c.useCloud && c.cloudAllowed) ...[
                        const SizedBox(height: 12),
                        TextField(
                            controller: _zone,
                            enabled: !c.busy,
                            decoration: InputDecoration(
                                labelText: t('时区', 'Time zone')),
                            onChanged: (v) => c.timeZone = v)
                      ],
                      const SizedBox(height: 16),
                      TextField(
                          key: const ValueKey('assistant-instruction'),
                          controller: _instruction,
                          enabled: !c.busy,
                          minLines: 4,
                          maxLines: 8,
                          maxLength: 2000,
                          decoration: InputDecoration(
                              labelText: t('任务指令', 'Planning request'),
                              hintText: c.useCloud
                                  ? t('明晚复习英语和数学，优先数学，中间留休息时间',
                                      'Review English and maths, prioritize maths and allow breaks')
                                  : t('英语 60分钟；数学 90分钟',
                                      'English 60 min; Maths 90 min')),
                          onChanged: (v) => c.instruction = v),
                      Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(t(
                              '普通请求先预览。明确指令“直接新增 YYYY-MM-DD 18:00-19:00 英语，保留已有任务”会校验后立即保存。',
                              'Requests are previewed first. The exact Chinese command “直接新增 YYYY-MM-DD 18:00-19:00 English，保留已有任务” validates and saves immediately.'))),
                      if (c.busy)
                        const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: LinearProgressIndicator()),
                      if (c.message != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Semantics(
                                liveRegion: true, child: Text(c.message!))),
                      if (c.resultPending || c.pendingRequestId != null)
                        OutlinedButton.icon(
                            onPressed: c.busy ? null : c.resolve,
                            icon: const Icon(Icons.sync),
                            label: Text(t('查询本次结果', 'Check this request'))),
                    ]));
            final preview = GlassPanel(
                frosted: true,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(t('计划提案', 'Proposed plans'),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      if (c.proposal == null)
                        Text(t('填写任务后，比较节奏、休息和容量，再应用到日计划。',
                            'Enter tasks, compare pace, breaks and capacity, then apply to your day.')),
                      if (c.proposal != null) ...[
                        Text(
                            '${c.proposal!.planDate} · ${c.proposal!.timeZone == 'device-local' ? t('本机时区', 'Device time zone') : c.proposal!.timeZone}'),
                        const SizedBox(height: 8),
                        for (final question in c.proposal!.questions)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(question)),
                        if (c.proposal!.status == 'no_solution')
                          Text(t('可用时间不足，请减少任务或扩大时段。',
                              'Insufficient time. Reduce tasks or expand the window.')),
                        for (final assumption in c.proposal!.assumptions)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(assumption,
                                  style:
                                      Theme.of(context).textTheme.bodySmall)),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: 8, children: [
                          for (final candidate in c.proposal!.candidates)
                            ChoiceChip(
                                label: Text('${switch (candidate.intensity) {
                                  'conservative' => t('保守', 'Relaxed'),
                                  'compact' => t('紧凑', 'Compact'),
                                  _ => t('平衡', 'Balanced')
                                }} · ${candidate.items.length}'),
                                selected: c.selectedId == candidate.id,
                                onSelected: c.busy || c.resultPending
                                    ? null
                                    : (_) => c.select(candidate.id))
                        ]),
                        if (c.selected != null) ...[
                          const SizedBox(height: 12),
                          Text(c.selected!.explanation),
                          if (width < 1100)
                            Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: FilledButton.tonalIcon(
                                    onPressed: () => _detail(width),
                                    icon: const Icon(Icons.fact_check_outlined),
                                    label: Text(t('审阅与编辑详情',
                                        'Review and edit details')))),
                          if (width >= 1100) ...[
                            const SizedBox(height: 16),
                            AssistantDetails(
                                controller: c, language: widget.language)
                          ],
                        ],
                      ],
                    ]));
            return Scaffold(
                resizeToAvoidBottomInset: false,
                bottomNavigationBar: SafeArea(
                    top: false,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20,
                            MediaQuery.viewInsetsOf(context).bottom + 8),
                        child: FilledButton.icon(
                            key: const ValueKey('assistant-generate'),
                            onPressed: c.busy ||
                                    c.resultPending ||
                                    c.pendingRequestId != null
                                ? null
                                : c.generate,
                            icon: const Icon(Icons.auto_awesome_outlined),
                            label: Text(
                                t('规划 / 处理指令', 'Plan / process request'))))),
                key: _scaffold,
                endDrawer: Drawer(
                    width: 600,
                    child: SafeArea(
                        child: ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                          Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  tooltip: t('关闭详情', 'Close details'),
                                  icon: const Icon(Icons.close),
                                  onPressed: () =>
                                      Navigator.of(context).pop())),
                          AssistantDetails(
                              controller: c, language: widget.language)
                        ]))),
                body: SecondaryPageScaffold(
                    resizeToAvoidBottomInset: false,
                    title: t('智能助手', 'Planning assistant'),
                    description: t('提出方案，审阅后应用到当前安排',
                        'Propose, review and apply to your current schedule'),
                    backLabel: t('返回', 'Back'),
                    visualTheme: widget.visualTheme,
                    pinHeader: true,
                    children: width >= 1100
                        ? [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 380, child: composer),
                                  const SizedBox(width: 20),
                                  Expanded(child: preview)
                                ])
                          ]
                        : [composer, const SizedBox(height: 20), preview]));
          }));
}

class AssistantDetails extends StatelessWidget {
  const AssistantDetails(
      {super.key, required this.controller, required this.language});
  final AssistantController controller;
  final AppLanguage language;
  String t(String zh, String en) => language.isChinese ? zh : en;
  Future<void> _edit(BuildContext context, int index) async {
    final task = controller.editedItems[index];
    final title = TextEditingController(text: task.title),
        start =
            TextEditingController(text: TodayPlan.slotLabel(task.startSlot)),
        end = TextEditingController(text: TodayPlan.slotLabel(task.endSlot));
    String? error;
    final result = await showThemedDialog<AssistantTask>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
                    title: Text(t('编辑新增任务', 'Edit addition')),
                    content: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                          controller: title,
                          maxLength: 120,
                          decoration:
                              InputDecoration(labelText: t('任务', 'Task'))),
                      TextField(
                          controller: start,
                          decoration:
                              InputDecoration(labelText: t('开始', 'From'))),
                      TextField(
                          controller: end,
                          decoration: InputDecoration(
                              labelText:
                                  t('结束 · HH:00/30', 'Until · HH:00/30'))),
                      if (error != null) Text(error!),
                    ])),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(t('取消', 'Cancel'))),
                      FilledButton(
                          onPressed: () {
                            try {
                              final from = assistantSlot(start.text),
                                  until = assistantSlot(end.text, end: true);
                              if (title.text.trim().isEmpty ||
                                  title.text.runes.length > 120 ||
                                  from >= until) {
                                throw FormatException(
                                    t('请检查任务与时段', 'Check task and time'));
                              }
                              Navigator.of(context).pop(AssistantTask(
                                  task.id, title.text.trim(), from, until));
                            } on FormatException catch (e) {
                              setState(() => error = e.message);
                            }
                          },
                          child: Text(t('保存草稿', 'Save draft')))
                    ])));
    // The route transition still owns the fields until the next frame.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    title.dispose();
    start.dispose();
    end.dispose();
    if (result != null) {
      final items = List.of(controller.editedItems);
      if (index < items.length && items[index].id == task.id) {
        items[index] = result;
        controller.updateItems(items);
      }
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final c = controller;
        return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t('本次新增', 'Additions'),
                  style: Theme.of(context).textTheme.titleLarge),
              if (c.editedItems.isEmpty)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(t('没有新增任务', 'No additions'))),
              for (var i = 0; i < c.editedItems.length; i++)
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text(
                              '${c.editedItems[i].timeLabel}  ${c.editedItems[i].title}'),
                          Wrap(children: [
                            IconButton(
                                tooltip: t('编辑', 'Edit'),
                                onPressed: c.busy || c.resultPending
                                    ? null
                                    : () => _edit(context, i),
                                icon: const Icon(Icons.edit_outlined)),
                            IconButton(
                                tooltip: t('移除新增', 'Remove addition'),
                                onPressed: c.busy || c.resultPending
                                    ? null
                                    : () {
                                        final items = List.of(c.editedItems)
                                          ..removeAt(i);
                                        c.updateItems(items);
                                      },
                                icon: const Icon(Icons.remove_circle_outline))
                          ]),
                        ])),
              const Divider(height: 32),
              Text(t('已有任务 · 全部保留', 'Existing tasks · preserved'),
                  style: Theme.of(context).textTheme.titleMedium),
              for (final item in c.snapshot?.items ?? <TodayPlanItem>[])
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                        '${item.hasSchedule ? item.scheduleLabel : t('未定时', 'Flexible')}  ${item.title}${item.completed ? t(' · 已完成', ' · Done') : ''}')),
              const SizedBox(height: 20),
              Wrap(spacing: 12, runSpacing: 12, children: [
                OutlinedButton.icon(
                    key: const ValueKey('assistant-validate'),
                    onPressed: c.selected == null || c.busy || c.resultPending
                        ? null
                        : c.validate,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(t('校验安排', 'Validate plan'))),
                FilledButton.icon(
                    key: const ValueKey('assistant-apply'),
                    onPressed: c.validation?.canExecute != true ||
                            c.busy ||
                            c.resultPending
                        ? null
                        : c.apply,
                    icon: const Icon(Icons.playlist_add_check),
                    label: Text(t('应用本次新增', 'Apply additions'))),
                if (c.execution?.undoEligibility == true)
                  TextButton.icon(
                      key: const ValueKey('assistant-undo'),
                      onPressed: c.busy || c.resultPending ? null : c.undo,
                      icon: const Icon(Icons.undo),
                      label: Text(t('撤销本次新增', 'Undo additions'))),
              ]),
              if (c.message != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child:
                        Semantics(liveRegion: true, child: Text(c.message!))),
              if (c.resultPending)
                OutlinedButton(
                    onPressed: c.busy ? null : c.resolve,
                    child: Text(t('查询保存结果', 'Check save result'))),
              const SizedBox(height: 12),
              Text(
                  t('应用后会保存到日计划；后续修改、完成或专注可能使撤销不可用。',
                      'Applying saves to your day plan. Later edits, completion or focus can prevent undo.'),
                  style: Theme.of(context).textTheme.bodySmall),
            ]);
      });
}
