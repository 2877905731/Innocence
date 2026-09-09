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
          'colorKey': 'spring',
          'sortOrder': 0,
          'note': '',
          'revision': 1,
          'updateTime': '',
        },
        {
          'id': '2',
          'clientEntityId': 'exam',
          'year': 2028,
          'title': 'Exam season',
          'startMonth': 4,
          'endMonth': 6,
          'colorKey': 'summer',
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
    expect(
      overview.segments.where(
        (segment) => segment.startMonth <= 4 && segment.endMonth >= 4,
      ),
      hasLength(2),
    );
  });
}
