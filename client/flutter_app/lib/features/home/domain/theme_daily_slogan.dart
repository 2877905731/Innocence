import 'package:innocence_flutter/app/app_visual_theme.dart';

class ThemeDailySlogan {
  const ThemeDailySlogan({
    required this.dayIndex,
    required this.titleZh,
    required this.titleEn,
    required this.subtitleZh,
    required this.subtitleEn,
  });

  final int dayIndex;
  final String titleZh;
  final String titleEn;
  final String subtitleZh;
  final String subtitleEn;

  String title({required bool isChinese}) => isChinese ? titleZh : titleEn;

  String subtitle({required bool isChinese}) =>
      isChinese ? subtitleZh : subtitleEn;
}

class ThemeDailySlogans {
  const ThemeDailySlogans._();

  static ThemeDailySlogan resolve({
    required AppVisualTheme theme,
    required DateTime localDate,
  }) {
    final pool = _pools[theme]!;
    final stableDay = DateTime.utc(
          localDate.year,
          localDate.month,
          localDate.day,
        ).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    return pool[stableDay % pool.length];
  }

  static List<ThemeDailySlogan> poolFor(AppVisualTheme theme) =>
      List.unmodifiable(_pools[theme]!);

  static const _wabiSubtitleZh = '给重要的事，留一块安静的位置。';
  static const _wabiSubtitleEn = 'Leave quiet room for what matters.';
  static const _softSpectrumSubtitleZh = '让计划、专注与进度，在柔和色彩里清晰推进。';
  static const _softSpectrumSubtitleEn =
      'Let plans, focus, and progress move clearly through soft color.';
  static const _midCenturySubtitleZh = '让计划、专注和进度组成今天的好设计。';
  static const _midCenturySubtitleEn =
      'Let plans, focus and progress shape the day.';
  static const _glassSubtitleZh = '计划、专注与记录，在同一条光轨上推进。';
  static const _glassSubtitleEn =
      'Plans, focus and records move on one luminous track.';

  static const Map<AppVisualTheme, List<ThemeDailySlogan>> _pools = {
    AppVisualTheme.wabiSabi: [
      ThemeDailySlogan(
          dayIndex: 1,
          titleZh: 'Begin with quiet.',
          titleEn: 'Begin with quiet.',
          subtitleZh: _wabiSubtitleZh,
          subtitleEn: _wabiSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 2,
          titleZh: 'One thing. Fully here.',
          titleEn: 'One thing. Fully here.',
          subtitleZh: _wabiSubtitleZh,
          subtitleEn: _wabiSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 3,
          titleZh: 'Leave room for the day.',
          titleEn: 'Leave room for the day.',
          subtitleZh: _wabiSubtitleZh,
          subtitleEn: _wabiSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 4,
          titleZh: 'Slow is still forward.',
          titleEn: 'Slow is still forward.',
          subtitleZh: _wabiSubtitleZh,
          subtitleEn: _wabiSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 5,
          titleZh: 'Make space for what matters.',
          titleEn: 'Make space for what matters.',
          subtitleZh: _wabiSubtitleZh,
          subtitleEn: _wabiSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 6,
          titleZh: 'Let the noise fall away.',
          titleEn: 'Let the noise fall away.',
          subtitleZh: _wabiSubtitleZh,
          subtitleEn: _wabiSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 7,
          titleZh: 'A gentle start is enough.',
          titleEn: 'A gentle start is enough.',
          subtitleZh: _wabiSubtitleZh,
          subtitleEn: _wabiSubtitleEn),
    ],
    AppVisualTheme.minimalism: [
      ThemeDailySlogan(
          dayIndex: 1,
          titleZh: '把今天，完成得漂亮。',
          titleEn: 'Make today beautifully complete.',
          subtitleZh: _softSpectrumSubtitleZh,
          subtitleEn: _softSpectrumSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 2,
          titleZh: '让进度，在细节里发光。',
          titleEn: 'Let progress glow in the details.',
          subtitleZh: _softSpectrumSubtitleZh,
          subtitleEn: _softSpectrumSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 3,
          titleZh: '清晰计划，也保留一点颜色。',
          titleEn: 'Plan clearly. Leave room for color.',
          subtitleZh: _softSpectrumSubtitleZh,
          subtitleEn: _softSpectrumSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 4,
          titleZh: '向前一点，就是今日亮点。',
          titleEn: 'One step forward brightens the day.',
          subtitleZh: _softSpectrumSubtitleZh,
          subtitleEn: _softSpectrumSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 5,
          titleZh: '把重要的事，排成好看的节奏。',
          titleEn: 'Give what matters a beautiful rhythm.',
          subtitleZh: _softSpectrumSubtitleZh,
          subtitleEn: _softSpectrumSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 6,
          titleZh: '今天的积累，正在变得可见。',
          titleEn: 'Today’s progress is becoming visible.',
          subtitleZh: _softSpectrumSubtitleZh,
          subtitleEn: _softSpectrumSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 7,
          titleZh: '轻一点开始，稳一点完成。',
          titleEn: 'Start lightly. Finish steadily.',
          subtitleZh: _softSpectrumSubtitleZh,
          subtitleEn: _softSpectrumSubtitleEn),
    ],
    AppVisualTheme.midCentury: [
      ThemeDailySlogan(
          dayIndex: 1,
          titleZh: '把今天，设计得有趣一点。',
          titleEn: 'Design a brighter day.',
          subtitleZh: _midCenturySubtitleZh,
          subtitleEn: _midCenturySubtitleEn),
      ThemeDailySlogan(
          dayIndex: 2,
          titleZh: '好状态，从一个大胆开场开始。',
          titleEn: 'A good day starts boldly.',
          subtitleZh: _midCenturySubtitleZh,
          subtitleEn: _midCenturySubtitleEn),
      ThemeDailySlogan(
          dayIndex: 3,
          titleZh: '让计划有形，让进度有色。',
          titleEn: 'Give plans shape and progress color.',
          subtitleZh: _midCenturySubtitleZh,
          subtitleEn: _midCenturySubtitleEn),
      ThemeDailySlogan(
          dayIndex: 4,
          titleZh: '今天也值得一场漂亮推进。',
          titleEn: 'Today deserves a beautiful move forward.',
          subtitleZh: _midCenturySubtitleZh,
          subtitleEn: _midCenturySubtitleEn),
      ThemeDailySlogan(
          dayIndex: 5,
          titleZh: '给目标一条明快的轨道。',
          titleEn: 'Put your goal on a bright track.',
          subtitleZh: _midCenturySubtitleZh,
          subtitleEn: _midCenturySubtitleEn),
      ThemeDailySlogan(
          dayIndex: 6,
          titleZh: '把灵感排进时间表。',
          titleEn: 'Put inspiration on the schedule.',
          subtitleZh: _midCenturySubtitleZh,
          subtitleEn: _midCenturySubtitleEn),
      ThemeDailySlogan(
          dayIndex: 7,
          titleZh: '向前一点，就是好日子。',
          titleEn: 'One step forward makes a good day.',
          subtitleZh: _midCenturySubtitleZh,
          subtitleEn: _midCenturySubtitleEn),
    ],
    AppVisualTheme.glass: [
      ThemeDailySlogan(
          dayIndex: 1,
          titleZh: '进入今日轨道。',
          titleEn: 'Enter today’s orbit.',
          subtitleZh: _glassSubtitleZh,
          subtitleEn: _glassSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 2,
          titleZh: '让此刻聚焦，让进度发光。',
          titleEn: 'Focus the moment. Light the progress.',
          subtitleZh: _glassSubtitleZh,
          subtitleEn: _glassSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 3,
          titleZh: '点亮下一步。',
          titleEn: 'Light up the next step.',
          subtitleZh: _glassSubtitleZh,
          subtitleEn: _glassSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 4,
          titleZh: '把今天调到清晰频道。',
          titleEn: 'Tune today into focus.',
          subtitleZh: _glassSubtitleZh,
          subtitleEn: _glassSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 5,
          titleZh: '目标已上线，行动开始同步。',
          titleEn: 'Goal online. Action in sync.',
          subtitleZh: _glassSubtitleZh,
          subtitleEn: _glassSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 6,
          titleZh: '在光的层次里，看见推进。',
          titleEn: 'See progress through layers of light.',
          subtitleZh: _glassSubtitleZh,
          subtitleEn: _glassSubtitleEn),
      ThemeDailySlogan(
          dayIndex: 7,
          titleZh: '连接当下，抵达下一刻。',
          titleEn: 'Connect now. Reach what comes next.',
          subtitleZh: _glassSubtitleZh,
          subtitleEn: _glassSubtitleEn),
    ],
  };
}
