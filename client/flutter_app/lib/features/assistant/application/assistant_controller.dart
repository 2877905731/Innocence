import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/local/offline_store.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/domain/models/app_session.dart';
import '../../plans/domain/models/today_plan.dart';
import '../data/assistant_api.dart';
import '../domain/assistant_models.dart';
import '../domain/local_planner.dart';

class AssistantController extends ChangeNotifier {
  AssistantController(
      {required this.identity,
      required this.owner,
      required this.offline,
      required this.session,
      required this.loadPlan,
      required this.refresh,
      required this.store,
      required this.api}) {
    _owner = owner();
    useCloud = cloudAllowed;
    identity.addListener(_identityChanged);
  }
  final Listenable identity;
  final String? Function() owner;
  final bool Function() offline;
  final AppSession? Function() session;
  final Future<TodayPlan?> Function(String) loadPlan;
  final Future<void> Function(String) refresh;
  final OfflineStore store;
  final AssistantApi api;
  String? _owner;
  int _epoch = 0;
  bool _disposed = false;
  bool busy = false, useCloud = false;
  String instruction = '',
      planDate = TodayPlan.empty().planDate,
      start = '18:00',
      end = '22:00',
      timeZone = 'Asia/Shanghai';
  String? message, selectedId, pendingRequestId, pendingOperationId;
  Map<String, dynamic>? _pendingBody;
  String? _pendingPath;
  String? _directCommand;
  AssistantProposal? proposal;
  AssistantValidation? validation;
  AssistantExecution? execution;
  TodayPlan? snapshot;
  List<AssistantTask> editedItems = [];
  bool _modelProposal = false;
  bool get cloudAllowed => !offline() && session() != null;
  bool get resultPending => pendingOperationId != null;
  AssistantCandidate? get selected =>
      proposal?.candidates.where((c) => c.id == selectedId).firstOrNull;
  void _identityChanged() {
    if (owner() == _owner) return;
    // Preserve uncertain operation IDs, but revoke unexecuted direct intent on sign-out.
    _directCommand = null;
    if (_owner != null) {
      unawaited(_persist(_owner!).catchError((Object _) {}));
    }
    _owner = owner();
    _epoch++;
    busy = false;
    useCloud = cloudAllowed;
    instruction = '';
    message = null;
    proposal = null;
    validation = null;
    execution = null;
    snapshot = null;
    selectedId = null;
    editedItems = [];
    pendingRequestId = null;
    pendingOperationId = null;
    _pendingBody = null;
    _pendingPath = null;
    _directCommand = null;
    notifyListeners();
  }

  Future<void> restore() async {
    final own = owner();
    final epoch = _epoch;
    if (own == null || busy || proposal != null || resultPending) return;
    try {
      final data = await store.loadAssistantRecovery(own);
      if (data == null || !_current(own, epoch)) return;
      instruction = data['instruction'] as String? ?? '';
      planDate = data['planDate'] as String? ?? planDate;
      start = data['start'] as String? ?? start;
      end = data['end'] as String? ?? end;
      timeZone = data['timeZone'] as String? ?? timeZone;
      _modelProposal = data['model'] as bool? ?? false;
      _directCommand = data['directCommand'] as String?;
      proposal = data['proposal'] == null
          ? null
          : AssistantProposal.fromJson(
              Map<String, dynamic>.from(data['proposal'] as Map));
      execution = data['execution'] == null
          ? null
          : AssistantExecution.fromJson(
              Map<String, dynamic>.from(data['execution'] as Map));
      selectedId = data['selectedId'] as String?;
      editedItems = (data['editedItems'] as List? ?? [])
          .map((v) =>
              AssistantTask.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList();
      pendingRequestId = data['pendingRequestId'] as String?;
      pendingOperationId = data['pendingOperationId'] as String?;
      _pendingPath = data['pendingPath'] as String?;
      _pendingBody = data['pendingBody'] == null
          ? null
          : Map<String, dynamic>.from(data['pendingBody'] as Map);
      if (resultPending || pendingRequestId != null) {
        message =
            '已恢复待确认操作，请查询结果 / Pending operation restored; check its result.';
      }
      if (proposal != null) {
        final plan = await loadPlan(proposal!.planDate);
        if (!_current(own, epoch)) return;
        snapshot = plan;
      }
      if (_current(own, epoch)) notifyListeners();
    } catch (_) {
      if (_current(own, epoch)) {
        message = '助手草稿未能恢复 / Could not restore assistant draft.';
        notifyListeners();
      }
    }
  }

  Future<void> saveDraft() async {
    final own = owner();
    if (own != null) await _persist(own);
  }

  Future<void> _persist(String own) => store.saveAssistantRecovery(own, {
        'instruction': instruction,
        'planDate': planDate,
        'start': start,
        'end': end,
        'timeZone': timeZone,
        'model': _modelProposal,
        'directCommand': _directCommand,
        'proposal': proposal?.toJson(),
        'execution': execution?.toJson(),
        'selectedId': selectedId,
        'editedItems': editedItems.map((i) => i.toJson()).toList(),
        'pendingRequestId': pendingRequestId,
        'pendingOperationId': pendingOperationId,
        'pendingBody': _pendingBody,
        'pendingPath': _pendingPath,
      });
  bool _current(String own, int epoch) =>
      !_disposed && own == owner() && epoch == _epoch;
  Future<void> _run(Future<void> Function(String, int) action) async {
    if (busy) return;
    final own = owner();
    if (own == null) {
      message = '请先进入账号或本机资料 / Open an account or local profile.';
      notifyListeners();
      return;
    }
    final epoch = _epoch;
    busy = true;
    message = null;
    notifyListeners();
    try {
      await action(own, epoch);
    } catch (error) {
      if (_current(own, epoch)) {
        message = error is ApiException
            ? error.message
            : error is FormatException
                ? error.message
                : error is TimeoutException
                    ? '响应超时，请查询本次结果 / Timed out; check this request.'
                    : '操作未完成，请查询结果或重试 / Operation incomplete; check its result.';
      }
    } finally {
      if (_current(own, epoch)) {
        try {
          await _persist(own);
        } catch (_) {}
        if (_current(own, epoch)) {
          busy = false;
          notifyListeners();
        }
      }
    }
  }

  Future<void> generate() => _run((own, epoch) async {
        if (resultPending || pendingRequestId != null) {
          throw const FormatException(
              '请先查询待确认结果 / Resolve the pending request first.');
        }
        if (useCloud && cloudAllowed) {
          final parsed = DateTime.tryParse(planDate);
          if (parsed == null ||
              parsed.toIso8601String().substring(0, 10) != planDate) {
            throw const FormatException('日期格式须为YYYY-MM-DD / Use YYYY-MM-DD.');
          }
        } else {
          assistantDate(planDate);
        }
        final begin = assistantSlot(start),
            finish = assistantSlot(end, end: true);
        if (begin >= finish ||
            instruction.trim().isEmpty ||
            instruction.runes.length > 2000) {
          throw const FormatException(
              '请输入任务与有效时间范围 / Enter tasks and a valid window.');
        }
        final plan = await loadPlan(planDate);
        if (!_current(own, epoch)) return;
        if (plan == null) {
          throw const FormatException('未取得当前安排 / Current plan unavailable.');
        }
        snapshot = plan;
        final direct = assistantDirect(instruction, planDate);
        _directCommand = direct == null ? null : instruction;
        final sentInstruction = direct != null
            ? instruction
            : '$instruction\n可用时段 / Available window: $start-$end；仅新增，保留已有任务 / Add only, keep existing tasks.';
        if (sentInstruction.runes.length > 2000) {
          throw const FormatException(
              '指令加上时段说明超过2000字，请缩短 / Shorten the request including its time constraints.');
        }
        if (useCloud && cloudAllowed) {
          final id = assistantId();
          pendingRequestId = id;
          await _persist(own);
          if (!_current(own, epoch)) return;
          final data = await api.call(session()!, 'proposals', body: {
            'clientRequestId': id,
            'instruction': sentInstruction,
            'planDate': planDate,
            'timeZone': timeZone,
            'generationMode': 'model',
            'requestedExecutionMode': direct == null ? 'suggest' : 'direct_add'
          });
          if (!_current(own, epoch)) return;
          _acceptGeneration(data);
          await _attemptDirect(own, epoch);
        } else {
          if (!offline()) {
            throw const FormatException(
                '离线排程用于本机资料；当前账号请使用云端 AI / Offline scheduling requires an on-device profile.');
          }
          final generated =
              LocalPlanner().generate(plan, instruction, begin, finish);
          await store.saveAssistantProposal(own, generated);
          if (!_current(own, epoch)) return;
          _setProposal(generated, false);
          await _attemptDirect(own, epoch);
        }
      });
  Future<void> _attemptDirect(String own, int epoch) async {
    final p = proposal, command = _directCommand;
    if (command == null ||
        p == null ||
        p.status != 'ready' ||
        pendingRequestId != null) {
      return;
    }
    if (command != instruction) {
      _directCommand = null;
      return;
    }
    final direct = assistantDirect(command, p.planDate);
    if (direct == null) return;
    final candidate = p.candidates
        .where((c) =>
            c.items.length == 1 &&
            c.items.single.title == direct.title &&
            c.items.single.startSlot == direct.start &&
            c.items.single.endSlot == direct.end)
        .firstOrNull;
    _directCommand = null;
    if (candidate == null) {
      message =
          '提案超出直接新增指令，请审阅后应用 / Review the proposal; it differs from the direct command.';
      return;
    }
    selectedId = candidate.id;
    editedItems = List.of(candidate.items);
    final v = _modelProposal
        ? AssistantValidation.fromJson(await api.call(
            session()!, 'proposals/${p.id}/validate', body: {
            'proposalRevision': p.revision,
            'candidateId': candidate.id
          }))
        : await store.validateAssistant(own, p.id, p.revision, candidate.id);
    if (!_current(own, epoch)) return;
    validation = v;
    if (!v.canExecute) {
      message = v.conflicts.join('\n');
      return;
    }
    pendingOperationId = assistantId();
    _pendingPath = 'proposals/${p.id}/execute';
    _pendingBody = {
      'operationId': pendingOperationId,
      'proposalRevision': v.revision,
      'candidateId': candidate.id,
      'validationId': v.id,
      'authorizationKind': 'direct_add'
    };
    await _persist(own);
    if (!_current(own, epoch)) return;
    final result = await _sendOperation(own);
    if (_current(own, epoch)) await _acceptExecution(result, own, epoch);
  }

  void _acceptGeneration(Map<String, dynamic> data) {
    if (data['requestStatus'] == 'complete' && data['proposal'] is Map) {
      _setProposal(
          AssistantProposal.fromJson(
              Map<String, dynamic>.from(data['proposal'] as Map)),
          true);
      pendingRequestId = null;
    } else if (data['requestStatus'] == 'failed') {
      _directCommand = null;
      pendingRequestId = null;
      message =
          '${(data['failure'] as Map?)?['message'] ?? '生成失败 / Generation failed'}';
    } else {
      message = '生成结果待确认 / Generation result pending.';
    }
  }

  void _setProposal(AssistantProposal value, bool model) {
    proposal = value;
    _modelProposal = model;
    validation = null;
    execution = null;
    selectedId = null;
    editedItems = [];
    if (value.candidates.isNotEmpty) {
      select(value.candidates
          .firstWhere((c) => c.intensity == 'balanced',
              orElse: () => value.candidates.first)
          .id);
    }
  }

  void select(String id) {
    if (busy && selectedId != null || resultPending) return;
    selectedId = id;
    editedItems = List.of(selected?.items ?? []);
    validation = null;
    notifyListeners();
  }

  void updateItems(List<AssistantTask> items) {
    if (busy || resultPending) return;
    editedItems = List.of(items);
    validation = null;
    notifyListeners();
  }

  Future<void> validate() => _run((own, epoch) async {
        final p = proposal, c = selected;
        if (p == null || c == null || resultPending) return;
        final edited = editedItems.map((i) => i.toJson()).toList();
        final v = _modelProposal
            ? AssistantValidation.fromJson(await api.call(
                session()!, 'proposals/${p.id}/validate', body: {
                'proposalRevision': p.revision,
                'candidateId': c.id,
                'editedItems': edited
              }))
            : await store.validateAssistant(own, p.id, p.revision, c.id,
                edited: editedItems);
        if (!_current(own, epoch)) return;
        validation = v;
        final json = p.toJson();
        json['proposalRevision'] = v.revision;
        json['candidates'] = p.candidates
            .map((candidate) => candidate.id == c.id
                ? AssistantCandidate(c.id, c.intensity, v.items, c.explanation)
                    .toJson()
                : candidate.toJson())
            .toList();
        proposal = AssistantProposal.fromJson(json);
        editedItems = List.of(v.items);
        message = v.canExecute
            ? '校验通过，请审阅新增任务后应用 / Validated. Review additions before applying.'
            : v.conflicts.join('\n');
      });
  Future<void> apply() => _run((own, epoch) async {
        final p = proposal, c = selected, v = validation;
        if (p == null ||
            c == null ||
            v == null ||
            !v.canExecute ||
            resultPending) {
          return;
        }
        pendingOperationId = assistantId();
        _pendingPath = 'proposals/${p.id}/execute';
        _pendingBody = {
          'operationId': pendingOperationId,
          'proposalRevision': v.revision,
          'candidateId': c.id,
          'validationId': v.id,
          'authorizationKind': 'preview_apply'
        };
        await _persist(own);
        if (!_current(own, epoch)) return;
        final e = await _sendOperation(own);
        if (!_current(own, epoch)) return;
        await _acceptExecution(e, own, epoch);
      });
  Future<AssistantExecution> _sendOperation(String own) async {
    if (_modelProposal) {
      return AssistantExecution.fromJson(
          await api.call(session()!, _pendingPath!, body: _pendingBody));
    }
    final body = _pendingBody!;
    if (_pendingPath!.endsWith('/undo')) {
      return store.undoAssistant(own, _pendingPath!.split('/')[1],
          body['expectedAfterRevision'] as int, body['operationId'] as String);
    }
    return store.applyAssistant(
        own,
        _pendingPath!.split('/')[1],
        body['proposalRevision'] as int,
        body['candidateId'] as String,
        body['validationId'] as String,
        body['operationId'] as String);
  }

  Future<void> _acceptExecution(
      AssistantExecution e, String own, int epoch) async {
    execution = e;
    if (e.status == 'prepared') {
      message = '保存结果待确认 / Save result pending.';
      return;
    }
    pendingOperationId = null;
    _pendingPath = null;
    _pendingBody = null;
    validation = null;
    message = e.status == 'committed'
        ? (e.undoOf == null
            ? '已保存 ${e.changes.length} 项新增任务 / Additions saved.'
            : '已撤销本次新增 / Additions undone.')
        : '执行已拒绝，任务未改变 / Execution rejected.';
    if (e.status == 'committed') {
      try {
        await refresh(e.planDate);
      } catch (_) {
        if (_current(own, epoch)) {
          message = '已保存，请刷新安排查看结果 / Saved; refresh the plan to view changes.';
        }
      }
    }
  }

  Future<void> resolve() => _run((own, epoch) async {
        if (pendingRequestId != null) {
          Map<String, dynamic> data;
          try {
            data = await api.call(session()!, 'requests/$pendingRequestId');
          } on ApiException catch (error) {
            if (error.statusCode != 404) rethrow;
            pendingRequestId = null;
            message =
                '请求未登记，可修改后重新生成 / Request was not registered; revise and retry.';
            return;
          }
          if (_current(own, epoch)) {
            _acceptGeneration(data);
            await _attemptDirect(own, epoch);
          }
          return;
        }
        final id = pendingOperationId;
        if (id == null) return;
        AssistantExecution? e;
        try {
          e = _modelProposal
              ? AssistantExecution.fromJson(
                  await api.call(session()!, 'executions/$id'))
              : await store.assistantExecution(own, id);
        } on ApiException catch (error) {
          if (error.statusCode != 404) rethrow;
        }
        if (!_current(own, epoch)) return;
        if (e == null || e.status == 'prepared') e = await _sendOperation(own);
        if (_current(own, epoch)) await _acceptExecution(e, own, epoch);
      });
  Future<void> undo() => _run((own, epoch) async {
        final e = execution;
        if (e == null || !e.undoEligibility || resultPending) return;
        pendingOperationId = assistantId();
        _pendingPath = 'executions/${e.id}/undo';
        _pendingBody = {
          'operationId': pendingOperationId,
          'expectedAfterRevision': e.afterRevision
        };
        await _persist(own);
        if (!_current(own, epoch)) return;
        final result = await _sendOperation(own);
        if (_current(own, epoch)) await _acceptExecution(result, own, epoch);
      });
  @override
  void dispose() {
    _disposed = true;
    identity.removeListener(_identityChanged);
    super.dispose();
  }
}
