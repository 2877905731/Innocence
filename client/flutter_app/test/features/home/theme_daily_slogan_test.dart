import 'package:flutter_test/flutter_test.dart';
import 'package:innocence_flutter/app/app_visual_theme.dart';
import 'package:innocence_flutter/features/home/domain/theme_daily_slogan.dart';

void main() {
  test('each visual theme has seven complete daily slogans', () {
    for (final theme in AppVisualTheme.values) {
      final pool = ThemeDailySlogans.poolFor(theme);
      expect(pool, hasLength(7));
      expect(pool.map((item) => item.dayIndex),
          orderedEquals([1, 2, 3, 4, 5, 6, 7]));
      for (final item in pool) {
        expect(item.titleZh.trim(), isNotEmpty);
        expect(item.titleEn.trim(), isNotEmpty);
        expect(item.subtitleZh.trim(), isNotEmpty);
        expect(item.subtitleEn.trim(), isNotEmpty);
      }
    }
  });

  test('selection is stable for a date and advances daily', () {
    const theme = AppVisualTheme.glass;
    final firstDate = DateTime(2026, 9, 8, 8, 30);
    final sameDate = DateTime(2026, 9, 8, 23, 59);
    final nextDate = DateTime(2026, 9, 9, 0, 1);

    final first = ThemeDailySlogans.resolve(
      theme: theme,
      localDate: firstDate,
    );
    final same = ThemeDailySlogans.resolve(
      theme: theme,
      localDate: sameDate,
    );
    final next = ThemeDailySlogans.resolve(
      theme: theme,
      localDate: nextDate,
    );

    expect(same.dayIndex, first.dayIndex);
    expect(next.dayIndex, first.dayIndex == 7 ? 1 : first.dayIndex + 1);
  });

  test('theme switch keeps the same daily sequence position', () {
    final date = DateTime(2026, 12, 24);
    final indexes = AppVisualTheme.values
        .map(
          (theme) => ThemeDailySlogans.resolve(
            theme: theme,
            localDate: date,
          ).dayIndex,
        )
        .toSet();

    expect(indexes, hasLength(1));
  });
}
