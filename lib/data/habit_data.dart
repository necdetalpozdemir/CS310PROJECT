import 'package:flutter/material.dart';

import '../models/habit.dart';
import '../utils/app_colors.dart';
import 'user_session.dart';

/// The user's habits for Step 2, kept in memory.
/// Every screen reads and changes habits through this class.
/// In Step 3 these methods will talk to Firestore.
class HabitData {
  HabitData._();

  /// Icons offered by the Add / Edit Habit form.
  static const List<IconData> icons = [
    Icons.water_drop_outlined,
    Icons.menu_book_outlined,
    Icons.directions_walk,
    Icons.self_improvement,
    Icons.fitness_center,
    Icons.bedtime_outlined,
  ];

  static const Set<int> everyDay = {1, 2, 3, 4, 5, 6, 7};

  static final List<Habit> habits = _placeholderHabits();

  static String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  static void add(Habit habit) {
    habits.add(habit);
    _updateProfileStats();
  }

  /// Call after changing the fields of an existing habit.
  static void saved() => _updateProfileStats();

  /// Removes the habit and returns its position, so Undo can put it back.
  static int remove(Habit habit) {
    final index = habits.indexOf(habit);
    habits.removeAt(index);
    _updateProfileStats();
    return index;
  }

  static void restore(Habit habit, int index) {
    habits.insert(index.clamp(0, habits.length), habit);
    _updateProfileStats();
  }

  /// Checks a habit off for [date], or removes the check if it is already done.
  static void toggleDone(Habit habit, DateTime date) {
    final day = Habit.dateOnly(date);
    if (!habit.completedDates.remove(day)) {
      habit.completedDates.add(day);
    }
    _updateProfileStats();
  }

  // Keeps the numbers on the Profile screen correct.
  static void _updateProfileStats() {
    UserSession.habitCount = habits.length;
    UserSession.bestStreak = habits.fold(
      0,
      (best, habit) => habit.bestStreak > best ? habit.bestStreak : best,
    );
  }

  static List<Habit> _placeholderHabits() => [
    _sample(
      id: '1',
      name: 'Drink 2 L of water',
      goal: 2,
      icon: Icons.water_drop_outlined,
      color: AppColors.habitColors[0],
      days: everyDay,
      streak: 5,
      best: 9,
    ),
    _sample(
      id: '2',
      name: 'Study for 1 hour',
      goal: 60,
      icon: Icons.menu_book_outlined,
      color: AppColors.habitColors[4],
      days: const {1, 2, 3, 4, 5},
      streak: 12,
      best: 14,
    ),
    _sample(
      id: '3',
      name: 'Walk 20 minutes',
      goal: 20,
      icon: Icons.directions_walk,
      color: AppColors.habitColors[1],
      days: everyDay,
      streak: 2,
      best: 6,
      doneToday: false,
    ),
    _sample(
      id: '4',
      name: 'Meditate 10 minutes',
      goal: 10,
      icon: Icons.self_improvement,
      color: AppColors.habitColors[2],
      days: everyDay,
      streak: 0,
      best: 0,
      doneToday: false,
    ),
    _sample(
      id: '5',
      name: 'Gym',
      icon: Icons.fitness_center,
      color: AppColors.habitColors[3],
      days: const {1, 3, 5},
      streak: 4,
      best: 4,
      doneToday: false,
    ),
  ];

  /// Builds a habit whose check-in history produces the given streaks,
  /// relative to today, so the demo data never goes stale.
  static Habit _sample({
    required String id,
    required String name,
    required IconData icon,
    required Color color,
    required Set<int> days,
    required int streak,
    required int best,
    int? goal,
    bool doneToday = true,
  }) {
    final today = Habit.dateOnly(DateTime.now());

    // Scheduled days from newest to oldest. An unfinished today is skipped.
    final scheduled = <DateTime>[];
    for (
      var back = doneToday ? 0 : 1;
      scheduled.length < streak + best + 1;
      back++
    ) {
      final day = DateTime(today.year, today.month, today.day - back);
      if (days.contains(day.weekday)) scheduled.add(day);
    }

    final completed = <DateTime>{...scheduled.take(streak)};
    // An older, longer run, separated from the current streak by a missed day.
    if (best > streak) {
      completed.addAll(scheduled.skip(streak + 1).take(best));
    }

    return Habit(
      id: id,
      name: name,
      dailyGoal: goal,
      icon: icon,
      color: color,
      days: days,
      createdAt: completed.isEmpty
          ? today
          : completed.reduce((a, b) => a.isBefore(b) ? a : b),
      completedDates: completed,
    );
  }
}
