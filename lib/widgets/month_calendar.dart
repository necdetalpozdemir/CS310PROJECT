import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

/// A 7-column month grid (Monday first).
///
/// - days in [doneDays] are filled dark green
/// - days in [partialDays] are filled light green
/// - [today] gets an outline
///
/// Used on Habit Detail (one habit) and Progress (all habits).
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    this.doneDays = const {},
    this.partialDays = const {},
    this.today,
    this.doneColor = AppColors.success,
    this.partialColor = AppColors.successLight,
  });

  /// Any date inside the month to show; only year and month are used.
  final DateTime month;

  /// Day numbers (1–31) where everything was done.
  final Set<int> doneDays;

  /// Day numbers (1–31) where only some habits were done.
  final Set<int> partialDays;

  /// Pass DateTime.now() to outline today. Ignored if it is in another month.
  final DateTime? today;

  final Color doneColor;
  final Color partialColor;

  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    // DateTime(year, month + 1, 0) is the last day of `month`.
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // weekday: Monday = 1 ... Sunday = 7, so Monday needs 0 empty cells.
    final leadingBlanks = DateTime(month.year, month.month, 1).weekday - 1;
    final totalCells = leadingBlanks + daysInMonth;

    final todayDay = (today != null &&
            today!.year == month.year &&
            today!.month == month.month)
        ? today!.day
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Weekday header row.
        Row(
          children: [
            for (final d in _weekdays)
              Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: AppTextStyles.caption,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        // The day grid. shrinkWrap + no scrolling so it can live inside
        // a parent ListView / SingleChildScrollView without errors.
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalCells,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: AppSpacing.xs + 2,
            crossAxisSpacing: AppSpacing.xs + 2,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks) return const SizedBox.shrink();
            final day = index - leadingBlanks + 1;
            return _DayCell(
              day: day,
              isDone: doneDays.contains(day),
              isPartial: partialDays.contains(day),
              isToday: day == todayDay,
              doneColor: doneColor,
              partialColor: partialColor,
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isDone,
    required this.isPartial,
    required this.isToday,
    required this.doneColor,
    required this.partialColor,
  });

  final int day;
  final bool isDone;
  final bool isPartial;
  final bool isToday;
  final Color doneColor;
  final Color partialColor;

  @override
  Widget build(BuildContext context) {
    final Color background = isDone
        ? doneColor
        : isPartial
            ? partialColor
            : AppColors.surface;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        // Today: blue outline. Other days: thin grey border like the wireframe.
        border: isToday
            ? Border.all(color: AppColors.primary, width: 2)
            : Border.all(color: AppColors.border),
      ),
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 12,
          color: isDone ? Colors.white : AppColors.textPrimary,
          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
