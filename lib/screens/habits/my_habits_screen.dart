import 'package:flutter/material.dart';

import '../../data/habit_data.dart';
import '../../models/habit.dart';
import '../../routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/habit_card.dart';
import 'add_edit_habit_screen.dart';
import 'habit_detail_screen.dart';

enum _HabitFilter { all, daily, weekly }

/// Every habit of the user as a list of cards, with filters,
/// edit (pen), delete (trash) and Undo.
class MyHabitsScreen extends StatefulWidget {
  const MyHabitsScreen({super.key});

  @override
  State<MyHabitsScreen> createState() => _MyHabitsScreenState();
}

class _MyHabitsScreenState extends State<MyHabitsScreen> {
  _HabitFilter _filter = _HabitFilter.all;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _undoBar;

  @override
  void dispose() {
    // Undo is only offered while the user stays on this screen.
    _undoBar?.close();
    super.dispose();
  }

  List<Habit> get _visibleHabits => switch (_filter) {
    _HabitFilter.all => HabitData.habits,
    _HabitFilter.daily =>
      HabitData.habits.where((habit) => habit.isEveryDay).toList(),
    _HabitFilter.weekly =>
      HabitData.habits.where((habit) => !habit.isEveryDay).toList(),
  };

  Future<void> _addHabit() async {
    await Navigator.pushNamed(context, AppRoutes.addHabit);
    if (mounted) setState(() {});
  }

  Future<void> _editHabit(Habit habit) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditHabitScreen(habit: habit)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openDetail(Habit habit) async {
    // Habit Detail returns the habit's old index if it was deleted there.
    final removedAt = await Navigator.push<int>(
      context,
      MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
    );
    if (!mounted) return;
    setState(() {});
    if (removedAt != null) _showUndo(habit, removedAt);
  }

  // Lifts the snackbar above the floating "+" button.
  EdgeInsets get _snackBarMargin =>
      const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 80);

  Future<void> _deleteHabit(Habit habit) async {
    final streak = habit.currentStreak;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete "${habit.name}"?',
      message: streak > 0
          ? "This habit and its $streak-day streak will be removed. "
                "This can't be undone after you leave the screen."
          : "This habit will be removed. "
                "This can't be undone after you leave the screen.",
      confirmLabel: 'Delete',
      icon: Icons.delete_outline,
    );
    if (!confirmed || !mounted) return;

    late final int index;
    setState(() => index = HabitData.remove(habit));
    _showUndo(habit, index);
  }

  /// Shows '"Gym" removed' with an UNDO button that puts the habit back.
  void _showUndo(Habit habit, int index) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    final bar = messenger.showSnackBar(
      SnackBar(
        content: Text(
          '"${habit.name}" removed',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        margin: _snackBarMargin,
        duration: const Duration(seconds: 5),
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
    bar.closed.then((_) {
      if (identical(_undoBar, bar)) _undoBar = null;
    });
  }

  String _filterLabel(_HabitFilter filter) => switch (filter) {
    _HabitFilter.all => 'All (${HabitData.habits.length})',
    _HabitFilter.daily => 'Daily',
    _HabitFilter.weekly => 'Weekly',
  };

  @override
  Widget build(BuildContext context) {
    final habits = _visibleHabits;

    return Scaffold(
      appBar: AppBar(title: const Text('My Habits')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add habit',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xs,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (final filter in _HabitFilter.values)
                    ChoiceChip(
                      label: Text(_filterLabel(filter)),
                      selected: _filter == filter,
                      showCheckmark: false,
                      selectedColor: AppColors.primaryLight,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: habits.isEmpty
                ? _EmptyState(hasAnyHabit: HabitData.habits.isNotEmpty)
                : ListView.separated(
                    padding: AppSpacing.listPadding,
                    itemCount: habits.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final habit = habits[index];
                      return HabitCard(
                        key: ValueKey(habit.id),
                        habit: habit,
                        subtitle:
                            '${habit.frequencyLabel} · best ${habit.bestStreak}',
                        onTap: () => _openDetail(habit),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit ${habit.name}',
                              color: AppColors.primary,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _editHabit(habit),
                            ),
                            IconButton(
                              tooltip: 'Delete ${habit.name}',
                              color: AppColors.danger,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteHabit(habit),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasAnyHabit});

  final bool hasAnyHabit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Text(
          hasAnyHabit
              ? 'No habits match this filter.'
              : 'No habits yet. Tap + to add your first one.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
