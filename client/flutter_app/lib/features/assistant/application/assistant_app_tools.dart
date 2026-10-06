import 'dart:convert';
import '../../../app/session_controller.dart';
import '../../../core/local/offline_store.dart';
import '../../memos/domain/models/memo_overview.dart';
import '../../plans/domain/models/today_plan.dart';
import '../../plans/domain/models/annual_plan_overview.dart';
import '../data/assistant_api.dart';
import '../data/chat_provider.dart';
import '../domain/assistant_models.dart';
import 'chat_tools.dart';

class AssistantAppTools implements ChatToolHost {
  int _generation = 0;
  @override
  void cancel() {
    _generation++;
  }

  AssistantAppTools(
      {required this.session,
      required this.store,
      required this.refresh,
      AssistantApi? api})
      : api = api ?? AssistantApi();
  final SessionController session;
  final OfflineStore store;
  final Future<void> Function(String) refresh;
  final AssistantApi api;
  Future<void> Function(String)? navigate, setTheme, setLanguage;
  String? get owner => session.isOffline
      ? session.localOwnerScope
      : session.session == null
          ? null
          : 'user:${session.session!.userId}';
  @override
  List<Map<String, dynamic>> get definitions => [
        chatTool('read_software',
            '按需读取当前身份的软件数据。date用于日/月/年度（YYYY-MM-DD/YYYY-MM/YYYY）。', {
          'resource': {
            'type': 'string',
            'enum': [
              'day',
              'month',
              'year',
              'templates',
              'memos',
              'focus',
              'stats',
              'settings',
              'notifications',
              'companions'
            ]
          },
          'date': chatString
        },
            required: [
              'resource'
            ]),
        chatTool(
            'add_day_tasks', '向明确日期新增安排，保留所有原任务。先读取该日；时间用0..48的半小时刻度。确认后保存。', {
          'date': chatString,
          'timeZone': chatString,
          'tasks': {
            'type': 'array',
            'maxItems': 48,
            'items': {
              'type': 'object',
              'properties': {
                'title': chatString,
                'startSlot': chatInteger,
                'endSlot': chatInteger
              },
              'required': ['title', 'startSlot', 'endSlot'],
              'additionalProperties': false
            }
          }
        }),
        chatTool('query_plan_execution', '查询新增/撤销的真实结果；超时后使用原ID查询，不能重复新增。',
            {'executionId': chatString}),
        chatTool('undo_plan_execution', '撤销指定助手执行，后续修改或专注会阻止撤销。',
            {'executionId': chatString}),
        chatTool('save_task_archive', '将指定日期的现有任务保存为可复用存档。',
            {'date': chatString, 'name': chatString}),
        chatTool('create_memo', '新增本人备忘录。',
            {'title': chatString, 'content': chatString}),
        chatTool('update_memo', '更新指定备忘录标题和正文，保留检查项。', {
          'memoId': chatInteger,
          'title': chatString,
          'content': chatString
        }),
        chatTool('delete_memo', '删除指定本人备忘录，需要确认。', {'memoId': chatInteger}),
        chatTool(
            'save_annual_task', '新建或修改独立年度任务。id为空表示新建；不改变进度；subtasks只用于新任务。', {
          'id': chatString,
          'year': chatInteger,
          'title': chatString,
          'startMonth': chatInteger,
          'endMonth': chatInteger,
          'note': chatString,
          'subtasks': {'type': 'array', 'maxItems': 40, 'items': chatString}
        }),
        chatTool('delete_annual_task', '删除指定年度任务，须先读取并确认。',
            {'year': chatInteger, 'id': chatString}),
        chatTool('control_focus', '开始/暂停或继续/结束本人专注。开始使用minutes和taskName。', {
          'action': {
            'type': 'string',
            'enum': ['start', 'toggle_pause', 'finish']
          },
          'minutes': chatInteger,
          'taskName': chatString
        }),
        chatTool('open_page', '选择软件页面。', {
          'page': {
            'type': 'string',
            'enum': [
              'home',
              'plans',
              'focus',
              'companions',
              'inbox',
              'stats',
              'memos',
              'settings'
            ]
          }
        }),
        chatTool('change_theme', '切换软件视觉主题。', {
          'theme': {
            'type': 'string',
            'enum': ['minimalism', 'glass', 'wabi_sabi', 'mid_century']
          }
        }),
        chatTool('change_language', '切换软件语言。', {
          'language': {
            'type': 'string',
            'enum': ['zh', 'en']
          }
        }),
      ];
  void _check(String own) {
    if (owner != own) throw const FormatException('当前身份已变化，操作取消。');
    if (session.isBusy) throw const FormatException('软件正在处理其他操作，请稍后重试。');
  }

  void _schema(dynamic value, Map schema) {
    final type = schema['type'];
    if ((type == 'string' && value is! String) ||
        (type == 'integer' && value is! int) ||
        (type == 'object' && value is! Map) ||
        (type == 'array' && value is! List)) {
      throw const FormatException('工具字段缺失或类型无效。');
    }
    if (schema['enum'] is List && !(schema['enum'] as List).contains(value)) {
      throw const FormatException('工具选项无效。');
    }
    if (value is String && value.runes.length > 12000) {
      throw const FormatException('工具文本过长。');
    }
    if (type == 'object') {
      final props = schema['properties'] as Map;
      if ((value as Map).keys.any((k) => !props.containsKey(k)) ||
          (schema['required'] as List).any((k) => !value.containsKey(k))) {
        throw const FormatException('工具包含未知字段或缺少必要字段。');
      }
      for (final key in value.keys) {
        _schema(value[key], props[key] as Map);
      }
    }
    if (type == 'array') {
      if ((value as List).length > (schema['maxItems'] as int? ?? 100)) {
        throw const FormatException('工具条目过多。');
      }
      for (final item in value) {
        _schema(item, schema['items'] as Map);
      }
    }
  }

  Map<String, dynamic> _plan(TodayPlan p) => {
        'date': p.planDate,
        'revision': p.dayRevision,
        'name': p.planName,
        'items': p.items
            .map((i) => {
                  'id': i.id,
                  'title': i.title,
                  'startSlot': i.startSlot,
                  'endSlot': i.endSlot,
                  'completed': i.completed,
                  'actualMinutes': i.actualMinutes,
                  'plannedMinutes': i.plannedMinutes
                })
            .toList()
      };
  Future<TodayPlan> _loadDay(String date) async {
    final parsed = DateTime.tryParse(date);
    if (parsed == null ||
        date !=
            '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}') {
      throw const FormatException('日期格式无效。');
    }
    final value = await session.loadPlanByDate(date);
    if (value == null) throw const FormatException('读取日计划失败，请检查登录状态。');
    return value;
  }

  @override
  Future<PreparedChatTool> prepare(ChatToolCall call) async {
    final generation = _generation;
    void check(String own) {
      if (generation != _generation) {
        throw const FormatException('操作已停止，未开始后续动作。');
      }
      _check(own);
    }

    final own = owner;
    if (own == null) throw const FormatException('请先登录或进入本机资料。');
    check(own);
    final definition = definitions
        .where((d) => (d['function'] as Map)['name'] == call.name)
        .firstOrNull;
    if (definition == null) throw const FormatException('此功能尚未开放给助手，未执行。');
    _schema(
        call.arguments, (definition['function'] as Map)['parameters'] as Map);
    final a = call.arguments;
    Future<Map<String, dynamic>> guarded(
        Future<Map<String, dynamic>> Function() f) async {
      check(own);
      final result = await f();
      check(own);
      return result;
    }

    PreparedChatTool action(
            String summary, Future<Map<String, dynamic>> Function() f,
            {bool confirm = true}) =>
        PreparedChatTool(
            summary: summary, confirm: confirm, execute: () => guarded(f));
    switch (call.name) {
      case 'read_software':
        return action('读取 ${a['resource']}', () => _read(a), confirm: false);
      case 'open_page':
      case 'change_theme':
      case 'change_language':
        final callback = call.name == 'open_page'
            ? navigate
            : call.name == 'change_theme'
                ? setTheme
                : setLanguage;
        if (callback == null) throw const FormatException('当前窗口功能不可用。');
        final value = a.values.single as String;
        return action('${call.name}：$value', () async {
          await callback(value);
          return {'ok': true, 'selected': value};
        }, confirm: call.name != 'open_page');
      case 'add_day_tasks':
        final date = a['date'] as String;
        final snapshot = await _loadDay(date);
        check(own);
        final tasks = (a['tasks'] as List)
            .map((v) => AssistantTask(
                assistantId(),
                (v as Map)['title'] as String,
                v['startSlot'] as int,
                v['endSlot'] as int))
            .toList();
        if (tasks.isEmpty) throw const FormatException('请提供需要新增的任务。');
        final conflicts = assistantConflicts(tasks, snapshot);
        if (conflicts.isNotEmpty) throw FormatException(conflicts.join('\n'));
        final requestId = assistantId(), operationId = assistantId();
        return action(
            '新增到 $date（保留原任务）\n${tasks.map((t) => '${t.timeLabel} ${t.title}').join('\n')}\n执行ID：$operationId',
            () async {
          final latest = await _loadDay(date);
          check(own);
          if (latest.dayRevision != snapshot.dayRevision) {
            throw const FormatException('计划已变化，请重新规划。');
          }
          AssistantProposal proposal;
          final auth = session.session;
          if (session.isOffline) {
            assistantDate(date);
            proposal = AssistantProposal(
                id: requestId,
                revision: 1,
                status: 'ready',
                planDate: date,
                timeZone: 'device-local',
                sourceRevision: snapshot.dayRevision,
                expiresAt:
                    DateTime.now().toUtc().add(const Duration(minutes: 30)),
                questions: [],
                assumptions: [],
                candidates: [
                  AssistantCandidate(assistantId(), 'balanced', tasks, '聊天提案')
                ]);
            await store.saveAssistantProposal(own, proposal);
          } else {
            if (auth == null) throw const FormatException('登录会话已失效。');
            final result = await api.call(auth, 'client-proposals', body: {
              'clientRequestId': requestId,
              'planDate': date,
              'timeZone': a['timeZone'],
              'sourceDayRevision': snapshot.dayRevision,
              'items': tasks.map((t) => t.toJson()).toList()
            });
            proposal = AssistantProposal.fromJson(
                Map<String, dynamic>.from(result['proposal'] as Map));
          }
          check(own);
          final candidate = proposal.candidates.single;
          final validation = session.isOffline
              ? await store.validateAssistant(own, proposal.id, 1, candidate.id)
              : AssistantValidation.fromJson(await api.call(
                  auth!, 'proposals/${proposal.id}/validate',
                  body: {'proposalRevision': 1, 'candidateId': candidate.id}));
          if (!validation.canExecute) {
            throw FormatException(validation.conflicts.join('\n'));
          }
          check(own);
          AssistantExecution execution;
          try {
            execution = session.isOffline
                ? await store.applyAssistant(own, proposal.id, 1, candidate.id,
                    validation.id, operationId)
                : AssistantExecution.fromJson(await api
                    .call(auth!, 'proposals/${proposal.id}/execute', body: {
                    'operationId': operationId,
                    'proposalRevision': 1,
                    'candidateId': candidate.id,
                    'validationId': validation.id,
                    'authorizationKind': 'preview_apply'
                  }));
          } catch (_) {
            return {
              'ok': false,
              'reason': 'RESULT_UNKNOWN',
              'executionId': operationId,
              'message': '查询此执行ID确认结果，不得重复新增。'
            };
          }
          check(own);
          await refresh(date);
          return {'ok': execution.status == 'committed', ...execution.toJson()};
        });
      case 'query_plan_execution':
      case 'undo_plan_execution':
        final id = a['executionId'] as String;
        final auth = session.session;
        final execution = session.isOffline
            ? await store.assistantExecution(own, id)
            : AssistantExecution.fromJson(
                await api.call(auth!, 'executions/$id'));
        check(own);
        if (execution == null) throw const FormatException('当前身份没有该执行记录。');
        if (call.name == 'query_plan_execution') {
          return action(
              '查询执行 $id', () async => {'ok': true, ...execution.toJson()},
              confirm: false);
        }
        if (!execution.undoEligibility) {
          throw const FormatException('此操作已不能撤销。');
        }
        final undoId = assistantId();
        return action('撤销 $id 在 ${execution.planDate} 新增的任务', () async {
          final result = session.isOffline
              ? await store.undoAssistant(
                  own, id, execution.afterRevision, undoId)
              : AssistantExecution.fromJson(await api.call(
                  auth!, 'executions/$id/undo', body: {
                  'operationId': undoId,
                  'expectedAfterRevision': execution.afterRevision
                }));
          check(own);
          await refresh(execution.planDate);
          return {'ok': result.status == 'committed', ...result.toJson()};
        });
      case 'save_task_archive':
        final plan = await _loadDay(a['date'] as String);
        check(own);
        return action(
            '保存存档「${a['name']}」：${plan.planDate}，${plan.items.length}项',
            () async {
          final latest = await _loadDay(plan.planDate);
          check(own);
          if (latest.dayRevision != plan.dayRevision) {
            throw const FormatException('计划已变化，请重试。');
          }
          final ok =
              await session.savePlanAsWeeklyTemplate(a['name'] as String, plan);
          return {'ok': ok};
        });
      case 'create_memo':
      case 'update_memo':
      case 'delete_memo':
        final id = a['memoId'] as int?;
        final old = id == null ? null : await session.loadMemoDetail(id);
        check(own);
        if (id != null && old == null) {
          throw const FormatException('当前身份下备忘录不存在。');
        }
        final title = a['title'] as String? ?? old!.title;
        final content = a['content'] as String? ?? old!.content;
        if (title.trim().isEmpty ||
            title.runes.length > 120 ||
            content.runes.length > 10000) {
          throw const FormatException('备忘录标题或内容无效。');
        }
        final draft = MemoCardModel(
            memoId: id ?? 0,
            title: title,
            content: content,
            totalItemCount: old?.totalItemCount ?? 0,
            checkedItemCount: old?.checkedItemCount ?? 0,
            updateTime: '',
            checkItems: old?.checkItems ?? []);
        return action(
            '${call.name}：$title\n${call.name == 'delete_memo' ? '删除此备忘录和检查项' : content}',
            () async {
          if (id != null) {
            final current = await session.loadMemoDetail(id);
            check(own);
            if (current == null ||
                jsonEncode(current.toSaveJson()) !=
                    jsonEncode(old!.toSaveJson())) {
              throw const FormatException('备忘录已变化，请重新读取。');
            }
          }
          if (call.name == 'delete_memo') {
            final result = await session.deleteMemo(id!);
            return {
              'ok': result != null && !result.items.any((m) => m.memoId == id)
            };
          }
          final beforeIds =
              session.memoOverview.items.map((m) => m.memoId).toSet();
          final result = id == null
              ? await session.createMemo(draft)
              : await session.updateMemo(id, draft);
          final saved = result?.items
              .where((m) =>
                  m.title == title &&
                  m.content == content &&
                  (id == null ? !beforeIds.contains(m.memoId) : m.memoId == id))
              .firstOrNull;
          return {'ok': saved != null, 'memoId': saved?.memoId};
        });
      case 'save_annual_task':
      case 'delete_annual_task':
        final year = a['year'] as int, id = a['id'] as String;
        if (year < 1 || year > 9999) throw const FormatException('年份无效。');
        await session.loadAnnualOverview(year);
        check(own);
        if (session.bannerMessage != null ||
            session.annualPlanOverview.year != year) {
          throw const FormatException('年度资料读取失败。');
        }
        final old = session.annualPlanOverview.segments
            .where((s) => s.id == id)
            .firstOrNull;
        if (id.isNotEmpty && old == null) {
          throw const FormatException('年度任务不存在。');
        }
        final deleting = call.name == 'delete_annual_task';
        if (deleting && old == null) throw const FormatException('删除需要指定任务ID。');
        final start = a['startMonth'] as int? ?? old!.startMonth,
            end = a['endMonth'] as int? ?? old!.endMonth;
        final title = a['title'] as String? ?? old!.title;
        if (start < 1 ||
            end > 12 ||
            start > end ||
            title.trim().isEmpty ||
            title.runes.length > 120) {
          throw const FormatException('年度任务跨度或标题无效。');
        }
        final uid = old?.clientEntityId ?? assistantId();
        final subtasks = a['subtasks'] as List? ?? [];
        if (old != null && subtasks.isNotEmpty) {
          throw const FormatException('现有年度任务的子任务保留；新增子任务请在年度页编辑。');
        }
        final draft = AnnualPlanSegment(
            id: old?.id ?? uid,
            clientEntityId: uid,
            year: year,
            title: title,
            startMonth: start,
            endMonth: end,
            colorKey: old?.colorKey ?? 'accent',
            sortOrder:
                old?.sortOrder ?? session.annualPlanOverview.segments.length,
            note: a['note'] as String? ?? old!.note,
            progressPercent: old?.progressPercent ?? 0,
            revision: old?.revision ?? 0,
            updateTime: old?.updateTime ?? '',
            subtasks: old?.subtasks ??
                [
                  for (var i = 0; i < subtasks.length; i++)
                    AnnualPlanSubtask(
                        id: assistantId(),
                        title: subtasks[i] as String,
                        detail: '',
                        completed: false,
                        sortOrder: i)
                ]);
        return action(
            '${deleting ? '删除' : '保存'}年度任务：$year $title，$start–$end月\n${draft.note}\n${draft.subtasks.map((s) => s.title).join('\n')}',
            () async {
          await session.loadAnnualOverview(year);
          check(own);
          if (session.bannerMessage != null ||
              session.annualPlanOverview.year != year) {
            throw const FormatException('年度资料读取失败，未保存。');
          }
          final current = session.annualPlanOverview.segments
              .where((s) => s.id == id)
              .firstOrNull;
          if (old != null &&
              (current == null || current.revision != old.revision)) {
            throw const FormatException('年度任务已变化，请重试。');
          }
          if (deleting) {
            await session.deleteAnnualSegment(old!);
            return {
              'ok': !session.annualPlanOverview.segments.any((s) => s.id == id)
            };
          }
          final ok = await session.saveAnnualSegment(draft);
          return {'ok': ok, 'clientEntityId': uid};
        });
      case 'control_focus':
        final old = session.focusSession;
        final kind = a['action'] as String, minutes = a['minutes'] as int;
        if (kind == 'start' && (old.active || minutes < 1 || minutes > 1440)) {
          throw const FormatException('已有专注或时长不在1–1440分钟范围。');
        }
        if (kind != 'start' && !old.active) {
          throw const FormatException('当前没有进行中的专注。');
        }
        return action('专注 $kind：${a['taskName']}，$minutes 分钟', () async {
          if (session.focusSession.sessionId != old.sessionId ||
              session.focusSession.active != old.active ||
              session.focusSession.paused != old.paused) {
            throw const FormatException('专注状态已变化。');
          }
          if (kind == 'start') {
            await session.startFocusSession(
                endTime: DateTime.now().add(Duration(minutes: minutes)),
                taskName: a['taskName'] as String);
          } else if (kind == 'finish') {
            await session.finishFocusSession();
          } else {
            await session.toggleFocusPause();
          }
          final current = session.focusSession;
          return {
            'ok': kind == 'start'
                ? current.active && current.sessionId != old.sessionId
                : kind == 'finish'
                    ? !current.active
                    : current.paused != old.paused,
            'active': current.active,
            'paused': current.paused
          };
        });
    }
    throw const FormatException('工具尚未实现，未执行。');
  }

  Future<Map<String, dynamic>> _read(Map<String, dynamic> a) async {
    final now = DateTime.now();
    final date = a['date'] as String? ?? session.todayPlan.planDate;
    switch (a['resource']) {
      case 'day':
        return {'ok': true, ..._plan(await _loadDay(date))};
      case 'month':
        final month = date.length >= 7 ? date.substring(0, 7) : date;
        if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month)) {
          throw const FormatException('月份无效。');
        }
        await session.loadMonthOverview(month);
        final value = session.monthPlanOverview;
        if (session.bannerMessage != null || value.month != month) {
          throw const FormatException('月计划读取失败。');
        }
        return {
          'ok': value.month == month,
          'month': value.month,
          'days': value.days
              .map((d) => {
                    'date': d.planDate,
                    'tasks': d.totalCount,
                    'completed': d.completedCount,
                    'minutes': d.totalPlannedMinutes
                  })
              .toList()
        };
      case 'year':
        final year =
            int.tryParse(date.length >= 4 ? date.substring(0, 4) : date) ??
                now.year;
        await session.loadAnnualOverview(year);
        if (session.bannerMessage != null ||
            session.annualPlanOverview.year != year) {
          throw const FormatException('年度资料读取失败。');
        }
        return {
          'ok': session.annualPlanOverview.year == year,
          'year': year,
          'tasks': session.annualPlanOverview.segments
              .map((s) => {
                    'id': s.id,
                    'title': s.title,
                    'startMonth': s.startMonth,
                    'endMonth': s.endMonth,
                    'progressPercent': s.progressPercent,
                    'note': s.note,
                    'subtasks': s.subtasks
                        .map(
                            (t) => {'title': t.title, 'completed': t.completed})
                        .toList()
                  })
              .toList()
        };
      case 'templates':
        return {
          'ok': true,
          'archives': session.weeklyTemplates
              .map((t) => {
                    'id': t.id,
                    'name': t.templateName,
                    'tasks': t.items
                        .map((i) => {
                              'title': i.title,
                              'startSlot': i.startSlot,
                              'endSlot': i.endSlot,
                              'plannedMinutes': i.plannedMinutes
                            })
                        .toList()
                  })
              .toList()
        };
      case 'memos':
        final value = await session.loadMemoOverview();
        return {
          'ok': value != null,
          'memos': value?.items
              .map((m) => {
                    'id': m.memoId,
                    'title': m.title,
                    'content': m.content,
                    'checked': m.checkedItemCount,
                    'items': m.totalItemCount
                  })
              .toList()
        };
      case 'focus':
        final f = session.focusSession;
        return {
          'ok': true,
          'active': f.active,
          'paused': f.paused,
          'taskName': f.taskName,
          'remainingSeconds': f.remainingSeconds,
          'sessionId': f.sessionId
        };
      case 'stats':
        final s = await session.loadStatsOverview();
        return {
          'ok': s != null,
          'rangeDays': s?.rangeDays,
          'studyMinutes': s?.totalStudyDurationMinutes,
          'activePlanDays': s?.activePlanDays,
          'planCompletionRate': s?.planCompletionRate
        };
      case 'settings':
        final w = session.settingOverview.widgetSetting;
        return {
          'ok': true,
          'showPlan': w.showPlan,
          'showTimer': w.showTimer,
          'showMemo': w.showMemo
        };
      case 'notifications':
        return {
          'ok': true,
          'unreadCount': session.notificationOverview.unreadCount,
          'message': '正文请在收件箱查看。'
        };
      case 'companions':
        return {
          'ok': true,
          'friendCount': session.friendOverview.friendCount,
          'inTeam': session.teamOverview.inTeam
        };
    }
    throw const FormatException('读取范围无效。');
  }
}
