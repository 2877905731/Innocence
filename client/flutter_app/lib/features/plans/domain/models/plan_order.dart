import 'annual_plan_overview.dart';
import 'today_plan.dart';

typedef SavePlanOrder = Future<bool> Function(PlanOrder order);

class PlanOrderItem {
  const PlanOrderItem(this.id, this.title, {this.detail = '', this.revision});
  final String id;
  final String title;
  final String detail;
  final int? revision;
  Map<String, dynamic> toJson() => {
        'id': id,
        if (revision != null) 'revision': revision,
      };
}

class PlanOrder {
  const PlanOrder(
      {required this.scope,
      required this.items,
      this.planDate,
      this.year,
      this.segmentId,
      this.baseRevision});
  final String scope;
  final List<PlanOrderItem> items;
  final String? planDate;
  final int? year;
  final String? segmentId;
  final int? baseRevision;

  factory PlanOrder.today(TodayPlan plan) => PlanOrder(
          scope: 'today',
          planDate: plan.planDate,
          baseRevision: plan.dayRevision,
          items: [
            for (final item in plan.items)
              PlanOrderItem('${item.id}', item.title,
                  detail: item.hasSchedule ? item.scheduleLabel : '')
          ]);
  factory PlanOrder.annual(AnnualPlanOverview overview) =>
      PlanOrder(scope: 'annual', year: overview.year, items: [
        for (final item in overview.segments)
          PlanOrderItem(item.id, item.title,
              detail:
                  '${item.startMonth}–${item.endMonth} · ${item.progressPercent}%',
              revision: item.revision)
      ]);
  factory PlanOrder.subtasks(AnnualPlanSegment segment) => PlanOrder(
          scope: 'subtasks',
          segmentId: segment.id,
          year: segment.year,
          baseRevision: segment.revision,
          items: [
            for (final item in segment.subtasks)
              PlanOrderItem(item.id, item.title, detail: item.detail)
          ]);
  PlanOrder withItems(List<PlanOrderItem> items) => PlanOrder(
      scope: scope,
      items: items,
      planDate: planDate,
      year: year,
      segmentId: segmentId,
      baseRevision: baseRevision);
  Map<String, dynamic> toJson() => {
        'scope': scope,
        if (planDate != null) 'planDate': planDate,
        if (year != null) 'year': year,
        if (segmentId != null) 'segmentId': segmentId,
        if (baseRevision != null) 'baseRevision': baseRevision,
        'items': items.map((item) => item.toJson()).toList(),
      };
}
