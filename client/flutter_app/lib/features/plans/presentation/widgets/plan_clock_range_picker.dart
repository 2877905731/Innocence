import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';

@immutable
class PlanClockBlock {
  const PlanClockBlock({
    required this.startSlot,
    required this.endSlot,
    required this.color,
  });

  final int startSlot;
  final int endSlot;
  final Color color;
}

/// A single-day clock: midnight starts at the top and noon at the bottom.
/// Endpoints remain in the existing half-hour, [0, 48] plan contract.
class PlanClockRangePicker extends StatefulWidget {
  const PlanClockRangePicker({
    super.key,
    required this.blocks,
    required this.activeIndex,
    required this.pendingStartSlot,
    required this.isChinese,
    required this.onTapBoundary,
    required this.onResize,
    required this.onStartNew,
    this.enabled = true,
  });

  final List<PlanClockBlock> blocks;
  final int? activeIndex;
  final int? pendingStartSlot;
  final bool isChinese;
  final ValueChanged<int> onTapBoundary;
  final void Function(int index, int startSlot, int endSlot) onResize;
  final VoidCallback onStartNew;
  final bool enabled;

  @override
  State<PlanClockRangePicker> createState() => _PlanClockRangePickerState();
}

class _PlanClockRangePickerState extends State<PlanClockRangePicker> {
  bool? _dragStart;
  int? _dragIndex;
  double _lastPosition = 0;
  double _unwrappedPosition = 0;
  int _originalStart = 0;
  int _originalEnd = 0;
  String? _timeError;

  String _text(String zh, String en) => widget.isChinese ? zh : en;

  PlanClockBlock? get _active =>
      widget.activeIndex == null ? null : widget.blocks[widget.activeIndex!];

  double _position(Offset point, double diameter) {
    final delta = point - Offset(diameter / 2, diameter / 2);
    return ((math.atan2(delta.dy, delta.dx) + math.pi / 2) % (2 * math.pi)) /
        (2 * math.pi) *
        48;
  }

  void _beginDrag(Offset point, double diameter) {
    _dragStart = null;
    _dragIndex = null;
    final active = _active;
    if (!widget.enabled || active == null) return;
    final radius = _clockRadius(diameter);
    final startPoint = _clockPoint(diameter, radius + 10, active.startSlot);
    final endPoint = _clockPoint(diameter, radius - 10, active.endSlot);
    final startDistance = (point - startPoint).distance;
    final endDistance = (point - endPoint).distance;
    if (math.min(startDistance, endDistance) > 28) return;
    _dragStart = startDistance <= endDistance;
    _dragIndex = widget.activeIndex;
    _originalStart = active.startSlot;
    _originalEnd = active.endSlot;
    _lastPosition = _position(point, diameter);
    _unwrappedPosition =
        (_dragStart! ? active.startSlot : active.endSlot).toDouble();
  }

  void _updateDrag(Offset point, double diameter) {
    if (_dragIndex == null || _dragStart == null || !widget.enabled) return;
    final position = _position(point, diameter);
    // Unwrap each movement, so dragging through 00:00 cannot jump to noon
    // or resize a late-night block into a whole-day block.
    var delta = position - _lastPosition;
    if (delta > 24) delta -= 48;
    if (delta < -24) delta += 48;
    _unwrappedPosition += delta;
    _lastPosition = position;
    final boundary = _unwrappedPosition.round().clamp(0, 48).toInt();
    widget.onResize(
      _dragIndex!,
      _dragStart! ? boundary : _originalStart,
      _dragStart! ? _originalEnd : boundary,
    );
  }

  void _endDrag() {
    _dragStart = null;
    _dragIndex = null;
  }

  Widget _boundaryControl(bool start, PlanClockBlock active) {
    final value = start ? active.startSlot : active.endSlot;
    final label = _text(start ? '开始' : '结束', start ? 'Start' : 'End');
    void change(int delta) => widget.onResize(
          widget.activeIndex!,
          start ? value + delta : active.startSlot,
          start ? active.endSlot : value + delta,
        );
    return Semantics(
      label: '$label ${TodayPlan.slotLabel(value)}',
      child: Column(
        children: [
          Text('$label ${TodayPlan.slotLabel(value)}',
              style: Theme.of(context).textTheme.titleSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: ValueKey('plan-clock-${start ? 'start' : 'end'}-earlier'),
                tooltip: _text('$label提前半小时', '$label 30 minutes earlier'),
                onPressed: widget.enabled ? () => change(-1) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              IconButton(
                key: ValueKey('plan-clock-${start ? 'start' : 'end'}-later'),
                tooltip: _text('$label推迟半小时', '$label 30 minutes later'),
                onPressed: widget.enabled ? () => change(1) : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    final pending = widget.pendingStartSlot;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(_text('24 小时圆盘', '24-hour clock'),
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          _text('点选开始与结束；选中已有时段可拖动圆点。',
              'Tap start and end; drag the handles of a selected block.'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, constraints) {
          final diameter = math.min(constraints.maxWidth, 344.0);
          return Center(
            child: SizedBox.square(
              dimension: diameter,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        gestureSettings:
                            const DeviceGestureSettings(touchSlop: 6),
                      ),
                      child: GestureDetector(
                        key: const ValueKey('today-plan-clock-face'),
                        onTapUp: !widget.enabled
                            ? null
                            : (details) => widget.onTapBoundary(
                                _position(details.localPosition, diameter)
                                        .round() %
                                    48),
                        onPanDown: active == null || !widget.enabled
                            ? null
                            : (details) =>
                                _beginDrag(details.localPosition, diameter),
                        onPanUpdate: active == null || !widget.enabled
                            ? null
                            : (details) =>
                                _updateDrag(details.localPosition, diameter),
                        onPanEnd: (_) => _endDrag(),
                        onPanCancel: _endDrag,
                        child: CustomPaint(
                          painter: _ClockPainter(
                            diameter: diameter,
                            blocks: widget.blocks,
                            activeIndex: widget.activeIndex,
                            pending: pending,
                            scheme: scheme,
                            textDirection: Directionality.of(context),
                            fontFamily: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.fontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: IgnorePointer(
                      child: SizedBox(
                        width: diameter * 0.48,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              pending != null && pending < 12 ||
                                      active != null && active.startSlot < 12
                                  ? Icons.nightlight_round
                                  : Icons.schedule_rounded,
                              color: scheme.primary,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                pending != null
                                    ? '${TodayPlan.slotLabel(pending)} →'
                                    : active == null
                                        ? _text('选择时间段', 'Select a range')
                                        : '${TodayPlan.slotLabel(active.startSlot)}\n${TodayPlan.slotLabel(active.endSlot)}',
                                key: const ValueKey('plan-clock-selection'),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pending != null
                                  ? _text('请选择结束时间', 'Choose the end')
                                  : active == null
                                      ? _text('每格 30 分钟', '30-minute steps')
                                      : _text(
                                          '${(active.endSlot - active.startSlot) * 30} 分钟',
                                          '${(active.endSlot - active.startSlot) * 30} min'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        if (active != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _boundaryControl(true, active)),
            Expanded(child: _boundaryControl(false, active)),
          ]),
          TextButton.icon(
            onPressed: widget.enabled ? widget.onStartNew : null,
            icon: const Icon(Icons.add_rounded),
            label: Text(_text('新增时间段', 'Add a time block')),
          ),
        ] else ...[
          const SizedBox(height: 8),
          // A standard Material picker also provides keyboard and screen-reader
          // access to every half-hour boundary without 48 tiny touch targets.
          TextButton.icon(
            key: const ValueKey('plan-clock-accessible-time'),
            onPressed: !widget.enabled
                ? null
                : () async {
                    final time = await showTimePicker(
                      context: context,
                      initialEntryMode: TimePickerEntryMode.input,
                      initialTime: TimeOfDay(
                          hour: (pending ?? 0) ~/ 2,
                          minute: (pending ?? 0).isEven ? 0 : 30),
                      builder: (context, child) => MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      ),
                    );
                    if (time != null && mounted) {
                      final minutes = time.hour * 60 + time.minute;
                      if (minutes % 30 != 0) {
                        if (!context.mounted) return;
                        setState(() => _timeError =
                            _text('请选择整点或半点。', 'Choose an hour or half-hour.'));
                        return;
                      }
                      setState(() => _timeError = null);
                      widget.onTapBoundary(minutes ~/ 30);
                    }
                  },
            icon: const Icon(Icons.access_time_rounded),
            label: Text(_text(pending == null ? '选择开始时间' : '选择结束时间',
                pending == null ? 'Choose start time' : 'Choose end time')),
          ),
        ],
        if (_timeError != null)
          Semantics(
            liveRegion: true,
            child: Text(_timeError!, style: TextStyle(color: scheme.error)),
          ),
        Text(
          _text('当天 00:00–24:00；凌晨在圆盘上方。',
              'Same day, 00:00–24:00; midnight is at the top.'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

double _clockRadius(double diameter) => diameter / 2 - 36;

Offset _clockPoint(double diameter, double radius, num slot) {
  final angle = slot / 48 * 2 * math.pi - math.pi / 2;
  return Offset(diameter / 2 + math.cos(angle) * radius,
      diameter / 2 + math.sin(angle) * radius);
}

class _ClockPainter extends CustomPainter {
  const _ClockPainter({
    required this.diameter,
    required this.blocks,
    required this.activeIndex,
    required this.pending,
    required this.scheme,
    required this.textDirection,
    required this.fontFamily,
  });

  final List<PlanClockBlock> blocks;
  final double diameter;
  final int? activeIndex;
  final int? pending;
  final ColorScheme scheme;
  final TextDirection textDirection;
  final String? fontFamily;

  @override
  bool hitTest(Offset position) {
    final distance = (position - Offset(diameter / 2, diameter / 2)).distance;
    final radius = _clockRadius(diameter);
    return distance >= radius - 28 && distance <= radius + 24;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final diameter = size.width;
    final radius = _clockRadius(diameter);
    final center = Offset(diameter / 2, diameter / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    for (var slot = 0; slot < 48; slot++) {
      var color = scheme.onSurface.withValues(alpha: 0.10);
      for (var index = 0; index < blocks.length; index++) {
        final block = blocks[index];
        if (slot >= block.startSlot && slot < block.endSlot) {
          color =
              block.color.withValues(alpha: index == activeIndex ? 1 : 0.65);
          break;
        }
      }
      if (slot == pending) color = scheme.primary;
      paint.color = color;
      canvas.drawArc(rect, slot / 48 * math.pi * 2 - math.pi / 2 + 0.012,
          math.pi * 2 / 48 - 0.024, false, paint);
      final tickPaint = Paint()
        ..color = scheme.onSurface.withValues(alpha: slot.isEven ? 0.6 : 0.3)
        ..strokeWidth = slot.isEven ? 1.5 : 1;
      canvas.drawLine(
          _clockPoint(diameter, radius - 16, slot),
          _clockPoint(diameter, radius - (slot.isEven ? 23 : 20), slot),
          tickPaint);
    }
    for (var hour = 0; hour < 24; hour += 3) {
      final label = TextPainter(
        text: TextSpan(
          text: hour == 0 ? '00/24' : hour.toString().padLeft(2, '0'),
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 12,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: textDirection,
      )..layout();
      final point = _clockPoint(diameter, radius + 26, hour * 2);
      label.paint(canvas, point - Offset(label.width / 2, label.height / 2));
    }
    if (activeIndex != null) {
      final active = blocks[activeIndex!];
      for (final start in [true, false]) {
        final point = _clockPoint(diameter, radius + (start ? 10 : -10),
            start ? active.startSlot : active.endSlot);
        canvas.drawCircle(point, 10, Paint()..color = scheme.surface);
        canvas.drawCircle(
            point,
            10,
            Paint()
              ..color = scheme.primary
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3);
        canvas.drawCircle(point, 3, Paint()..color = scheme.primary);
      }
    }
  }

  @override
  bool shouldRepaint(_ClockPainter oldDelegate) =>
      blocks != oldDelegate.blocks ||
      activeIndex != oldDelegate.activeIndex ||
      pending != oldDelegate.pending ||
      scheme != oldDelegate.scheme ||
      diameter != oldDelegate.diameter ||
      textDirection != oldDelegate.textDirection ||
      fontFamily != oldDelegate.fontFamily;
}
