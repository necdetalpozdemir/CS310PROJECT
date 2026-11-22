import 'package:flutter/material.dart';

import '../../data/habit_data.dart';
import '../../models/habit.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/date_labels.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/month_calendar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/stat_tile.dart';
import 'add_edit_habit_screen.dart';

/// One habit in depth: streaks, this month's calendar,
/// "Mark today as done", edit (pen) and delete.
///
/// Opened with Navigator.push from a card on Today or My Habits.
/// If the habit is deleted here, the screen pops with the habit's old
/// index (an int), so the caller can offer Undo.
class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({super.key, required this.habit});

  final Habit habit;

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  // Short name, so we don't have to write widget.habit everywhere.
  Habit get _habit => widget.habit;

  /// Days of this month that are done, as day numbers for MonthCalendar.
  Set<int> _doneDaysIn(DateTime month) => {
    for (final date in _habit.completedDates)
      if (date.year == month.year && date.month == month.month) date.day,
  };

  /// Done scheduled days / scheduled days this month, up to today.
  /// Today only counts once it is done, like the streak.
  int _monthPercent(DateTime today) {
    final firstOfMonth = DateTime(today.year, today.month, 1);
    final start = _habit.createdAt.isAfter(firstOfMonth)
        ? _habit.createdAt
        : firstOfMonth;

    var scheduled = 0;
    var done = 0;
    for (
      var day = start;
      !day.isAfter(today);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      if (!_habit.isScheduledOn(day)) continue;
      if (_habit.isDoneOn(day)) {
        scheduled++;
        done++;
      } else if (day != today) {
        scheduled++;
      }
    }
    return scheduled == 0 ? 0 : (done * 100 / scheduled).round();
  }

  void _toggleToday() {
    setState(() => HabitData.toggleDone(_habit, DateTime.now()));
  }

  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditHabitScreen(habit: _habit)),
    );
    // The form changed the same Habit object, so a rebuild shows the edits.
    if (mounted) setState(() {});
  }

  Future<void> _delete() async {
    final streak = _habit.currentStreak;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete "${_habit.name}"?',
      message: streak > 0
          ? 'This habit and its $streak-day streak will be removed.'
          : 'This habit will be removed.',
      confirmLabel: 'Delete',
      icon: Icons.delete_outline,
    );
    if (!confirmed || !mounted) return;

    final index = HabitData.remove(_habit);
    // This screen closes now, so it can't offer Undo itself.
    // It returns the old position instead; the screen we go back to
    // shows the Undo snackbar and can rebuild its own list.
    Navigator.pop(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final today = Habit.dateOnly(DateTime.now());
    final doneToday = _habit.isDoneOn(today);
    final scheduledToday = _habit.isScheduledOn(today);

    return Scaffold(
      appBar: AppBar(
        title: Text(_habit.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Edit habit',
            color: AppColors.primary,
            icon: const Icon(Icons.edit_outlined),
            onPressed: _edit,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // The content scrolls; the two buttons stay at the bottom.
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPadding,
                children: [
                  _Header(habit: _habit),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          value: '${_habit.currentStreak}',
                          label: 'current streak',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: StatTile(
                          value: '${_habit.bestStreak}',
                          label: 'longest streak',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: StatTile(
                          value: '${_monthPercent(today)}%',
                          label: 'this month',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(DateLabels.month(today), style: AppTextStyles.subtitle),
                  const SizedBox(height: AppSpacing.md),
                  MonthCalendar(
                    month: today,
                    doneDays: _doneDaysIn(today),
                    today: today,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: !scheduledToday
                        ? 'Not scheduled today'
                        : doneToday
                        ? 'Done today · tap to undo'
                        : 'Mark today as done',
                    icon: doneToday ? Icons.undo : Icons.check,
                    variant: doneToday
                        ? ButtonVariant.outlined
                        : ButtonVariant.filled,
                    // null disables the button on days the habit isn't planned.
                    onPressed: scheduledToday ? _toggleToday : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PrimaryButton(
                    label: 'Delete habit',
                    icon: Icons.delete_outline,
                    variant: ButtonVariant.danger,
                    onPressed: _delete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon, name and "Mon–Fri · since 1 Oct" at the top of the screen.
class _Header extends StatelessWidget {
  const _Header({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    // "· goal 60 minutes"; the unit is optional, so it may be just "· goal 60".
    final unit = habit.goalUnit == null ? '' : ' ${habit.goalUnit}';
    final goal = habit.dailyGoal == null
        ? ''
        : ' · goal ${habit.dailyGoal}$unit';

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: habit.color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Icon(habit.icon, color: habit.color, size: 28),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(habit.name, style: AppTextStyles.title),
              const SizedBox(height: 2),
              Text(
                '${habit.frequencyLabel} · since '
                '${DateLabels.dayMonth(habit.createdAt)}$goal',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
