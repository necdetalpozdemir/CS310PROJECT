import 'package:flutter/material.dart';

import '../../data/habit_data.dart';
import '../../models/habit.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/date_labels.dart';
import '../../widgets/month_calendar.dart';
import '../../widgets/stat_tile.dart';
import '../../widgets/week_bar_chart.dart';

enum _Week { thisWeek, lastWeek }

/// How many habits were planned and how many were done on one day.
class _DayCount {
  const _DayCount(this.scheduled, this.done);

  final int scheduled;
  final int done;

  /// null when nothing was planned, so the day isn't shown as 0%.
  double? get ratio => scheduled == 0 ? null : done / scheduled;
}

/// Overall progress across all habits: a week switch, the weekly
/// completion rate, a per-day bar chart and this month's calendar.
/// Everything is calculated from check-ins, nothing is stored.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  _Week _week = _Week.thisWeek;

  /// Counts the habits that existed and were scheduled on [day].
  _DayCount _countFor(DateTime day) {
    var scheduled = 0;
    var done = 0;
    for (final habit in HabitData.habits) {
      if (day.isBefore(habit.createdAt) || !habit.isScheduledOn(day)) continue;
      scheduled++;
      if (habit.isDoneOn(day)) done++;
    }
    return _DayCount(scheduled, done);
  }

  /// Like [_countFor], but null for days after [today].
  _DayCount? _countIfPast(DateTime day, DateTime today) =>
      day.isAfter(today) ? null : _countFor(day);

  @override
  Widget build(BuildContext context) {
    final today = Habit.dateOnly(DateTime.now());
    // weekday: Monday = 1, so this goes back to this week's Monday.
    final thisMonday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );
    final monday = _week == _Week.thisWeek
        ? thisMonday
        : DateTime(thisMonday.year, thisMonday.month, thisMonday.day - 7);

    // One entry per weekday; null for days that haven't come yet.
    final week = <_DayCount?>[
      for (var i = 0; i < 7; i++)
        _countIfPast(
          DateTime(monday.year, monday.month, monday.day + i),
          today,
        ),
    ];

    var weekScheduled = 0;
    var weekDone = 0;
    for (final day in week.whereType<_DayCount>()) {
      weekScheduled += day.scheduled;
      weekDone += day.done;
    }
    final weekPercent = weekScheduled == 0
        ? 0
        : (weekDone * 100 / weekScheduled).round();

    // Calendar: every past day of this month, all done or partly done.
    final allDone = <int>{};
    final partlyDone = <int>{};
    for (var d = 1; d <= today.day; d++) {
      final count = _countFor(DateTime(today.year, today.month, d));
      if (count.done == 0) continue;
      (count.done == count.scheduled ? allDone : partlyDone).add(d);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          SegmentedButton<_Week>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Week.thisWeek, label: Text('This week')),
              ButtonSegment(value: _Week.lastWeek, label: Text('Last week')),
            ],
            selected: {_week},
            onSelectionChanged: (selection) =>
                setState(() => _week = selection.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: '$weekPercent%',
                  label: 'weekly completion',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: StatTile(
                  value: '$weekDone/$weekScheduled',
                  label: 'check-ins done',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          WeekBarChart(
            values: [
              for (final day in week) day == null ? null : (day.ratio ?? 0),
            ],
            highlightIndex: _week == _Week.thisWeek ? today.weekday - 1 : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Calendar · ${DateLabels.month(today)}',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: AppSpacing.md),
          MonthCalendar(
            month: today,
            doneDays: allDone,
            partialDays: partlyDone,
            today: today,
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            children: [
              _LegendDot(color: AppColors.success, label: 'all done'),
              SizedBox(width: AppSpacing.lg),
              _LegendDot(color: AppColors.successLight, label: 'partly done'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
