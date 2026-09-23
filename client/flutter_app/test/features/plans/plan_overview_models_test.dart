import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/features/plans/domain/models/annual_plan_overview.dart';
import 'package:innocence_flutter/features/plans/domain/models/month_plan_overview.dart';

void main() {
  test(
      'month overview keeps all day summaries and returns an empty missing day',
      () {
    final overview = MonthPlanOverview.fromJson({
      'month': '2028-02',
      'days': List.generate(29, (index) {
        final day = index + 1;
        return {
          'planDate': '2028-02-${day.toString().padLeft(2, '0')}',
          'hasPlan': day == 29,
          'planName': day == 29 ? 'Leap day' : '',
          'completedCount': day == 29 ? 1 : 0,
          'totalCount': day == 29 ? 2 : 0,
          'totalPlannedMinutes': day == 29 ? 60 : 0,
          'templateApplied': day == 29,
        };
      }),
    });

    expect(overview.days, hasLength(29));
    expect(overview.dayFor('2028-02-29').planName, 'Leap day');
    expect(overview.dayFor('2028-03-01').hasPlan, isFalse);
    expect(overview.plannedDayCount, 1);
  });

  test('annual overview always exposes twelve months and overlapping segments',
      () {
    final overview = AnnualPlanOverview.fromJson({
      'year': 2028,
      'months': [
        {
          'month': 2,
          'plannedDayCount': 4,
          'completedTaskCount': 3,
          'totalTaskCount': 5,
          'totalPlannedMinutes': 300,
        },
      ],
      'segments': [
        {
          'id': '1',
          'clientEntityId': 'spring',
          'year': 2028,
          'title': 'Spring foundation',
          'startMonth': 2,
          'endMonth': 5,
          'colorKey': 'warm',
          'sortOrder': 0,
          'note': '',
          'progressPercent': 35,
          'revision': 1,
          'updateTime': '',
          'subtasks': [
            {
              'id': '11',
              'title': 'Draft outline',
              'detail': 'Cover the first milestone',
              'completed': true,
              'sortOrder': 0,
            },
            {
              'id': '12',
              'title': 'Review outline',
              'detail': '',
              'completed': false,
              'sortOrder': 1,
            },
          ],
        },
        {
          'id': '2',
          'clientEntityId': 'exam',
          'year': 2028,
          'title': 'Exam season',
          'startMonth': 4,
          'endMonth': 6,
          'colorKey': 'cool',
          'sortOrder': 1,
          'note': '',
          'revision': 1,
          'updateTime': '',
        },
      ],
    });

    expect(overview.months, hasLength(12));
    expect(overview.monthAt(2).plannedDayCount, 4);
    expect(overview.monthAt(1).totalTaskCount, 0);
    expect(overview.segments, hasLength(2));
    expect(overview.segments.first.completedSubtaskCount, 1);
    expect(overview.segments.first.completionRatio, 0.5);
    expect(overview.segments.first.progressPercent, 35);
    expect(overview.segments.first.adjustProgress(10).progressPercent, 45);
    expect(overview.segments.first.adjustProgress(100).progressPercent, 100);
    expect(overview.segments.first.adjustProgress(100).isCompleted, isTrue);
    expect(overview.segments.first.adjustProgress(-5).progressPercent, 30);
    expect(overview.segments.first.adjustProgress(-100).progressPercent, 0);
    expect(overview.segments.first.adjustProgress(-100).isCompleted, isFalse);
    expect(overview.segments.last.progressPercent, 0);
    expect(overview.segments.first.toSaveJson()['progressPercent'], 35);
    expect(overview.segments.first.toSaveJson()['subtasks'], hasLength(2));
    expect(
      overview.segments.where(
        (segment) => segment.startMonth <= 4 && segment.endMonth >= 4,
      ),
      hasLength(2),
    );
  });
}
