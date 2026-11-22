import 'package:flutter/material.dart';

import '../../data/habit_data.dart';
import '../../data/user_session.dart';
import '../../models/habit.dart';
import '../../routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/date_labels.dart';
import '../../widgets/habit_card.dart';
import '../habits/habit_detail_screen.dart';

/// Home screen: a greeting, today's completion bar and only the habits
/// scheduled for today. Tapping the circle checks a habit off in one tap.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _undoBar;

  String get _greeting {
    final hour = DateTime.now().hour;
    final firstName = UserSession.displayName.split(' ').first;
    if (hour < 12) return 'Good morning, $firstName';
    if (hour < 18) return 'Good afternoon, $firstName';
    return 'Good evening, $firstName';
  }

  void _toggle(Habit habit) {
    // The data changes first, then setState tells Flutter to call build again.
    setState(() => HabitData.toggleDone(habit, DateTime.now()));
  }

  Future<void> _addHabit() async {
    await Navigator.pushNamed(context, AppRoutes.addHabit);
    // A new habit may be scheduled for today, so rebuild when we come back.
    if (mounted) setState(() {});
  }

  Future<void> _openDetail(Habit habit) async {
    // Habit Detail returns the habit's old index if it was deleted there.
    final removedAt = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
    );
    if (!mounted) return;
    // The habit may have been checked off, edited or deleted there.
    setState(() {});
    if (removedAt != null) _showUndo(habit, removedAt);
  }

  /// Same Undo snackbar as on My Habits.
  void _showUndo(Habit habit, int index) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final bar = messenger.showSnackBar(
      SnackBar(
        content: Text(
          '"${habit.name}" removed',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Lifts the snackbar above the floating "+" button.
        margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 80),
        duration: const Duration(seconds: 5),
        // Without this, a SnackBar with an action stays until it is tapped.
        persist: false,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            HabitData.restore(habit, index);
            if (mounted) setState(() {});
          },
        ),
      ),
    );
    _undoBar = bar;
    // Forget the bar once it is gone, so dispose doesn't close it twice.
    bar.closed.then((_) {
      if (identical(_undoBar, bar)) _undoBar = null;
    });
  }

  @override
  void dispose() {
    // Like My Habits: Undo is only offered while the user stays here.
    _undoBar?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final habits = HabitData.habits
        .where((habit) => habit.isScheduledOn(today))
        .toList();
    final doneCount = habits.where((habit) => habit.isDoneOn(today)).length;
    final ratio = habits.isEmpty ? 0.0 : doneCount / habits.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: Center(
              child: Text(
                DateLabels.weekdayDayMonth(today),
                style: AppTextStyles.caption,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add habit',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
      // One ListView for the whole page, so it scrolls on small phones.
      body: ListView(
        padding: AppSpacing.listPadding,
        children: [
          Text(_greeting, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$doneCount of ${habits.length} done',
                  style: AppTextStyles.caption,
                ),
              ),
              Text('${(ratio * 100).round()}%', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              color: AppColors.primary,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _QuoteBox(text: 'Small steps every day.'),
          const SizedBox(height: AppSpacing.lg),
          if (habits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxl),
              child: Text(
                'Nothing scheduled for today.\nTap + to add a habit.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          for (final habit in habits) ...[
            _buildHabitCard(habit, today),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit, DateTime today) {
    final streak = habit.currentStreak;
    final done = habit.isDoneOn(today);

    return HabitCard(
      key: ValueKey(habit.id),
      habit: habit,
      subtitle: streak > 0 ? '$streak-day streak' : 'Start a streak today',
      subtitleIcon: streak > 0 ? Icons.local_fire_department : null,
      onTap: () => _openDetail(habit),
      trailing: IconButton(
        tooltip: done ? 'Mark as not done' : 'Mark as done',
        onPressed: () => _toggle(habit),
        icon: Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? AppColors.success : AppColors.textHint,
          size: 30,
        ),
      ),
    );
  }
}

/// The motivational line under the progress bar, with a blue bar on the left.
class _QuoteBox extends StatelessWidget {
  const _QuoteBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    // A one-sided Border can't have a borderRadius, so the corners are
    // rounded by clipping instead.
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          border: const Border(
            left: BorderSide(color: AppColors.primary, width: 3),
          ),
        ),
        child: Text(
          '"$text"',
          style: AppTextStyles.body.copyWith(
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
