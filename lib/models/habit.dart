import 'package:flutter/material.dart';

/// One habit of the user.
///
/// Streaks are calculated from [completedDates], so they are never stored
/// separately and cannot get out of sync. In Step 3 this class will be
/// saved to and loaded from Firestore.
class Habit {
  Habit({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required Set<int> days,
    required DateTime createdAt,
    this.dailyGoal,
    this.goalUnit,
    Set<DateTime>? completedDates,
  }) : days = {...days},
       createdAt = dateOnly(createdAt),
       completedDates = {...?completedDates?.map(dateOnly)};

  final String id;
  String name;
  IconData icon;
  Color color;

  /// Optional daily target, e.g. 60 for "Study for 60 minutes".
  int? dailyGoal;

  /// Unit shown next to the goal, e.g. "minutes".
  String? goalUnit;

  /// Scheduled weekdays: DateTime.monday (1) ... DateTime.sunday (7).
  Set<int> days;

  final DateTime createdAt;

  /// Days on which the habit was checked off (time part removed).
  final Set<DateTime> completedDates;

  static const List<String> weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Removes the time, so two moments on the same day compare as equal.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool get isEveryDay => days.length == 7;

  bool isScheduledOn(DateTime date) => days.contains(date.weekday);

  bool isDoneOn(DateTime date) => completedDates.contains(dateOnly(date));

  /// Short text for the schedule: "Every day", "Mon–Fri", "Mon · Wed · Fri".
  String get frequencyLabel {
    if (isEveryDay) return 'Every day';

    final sorted = days.toList()..sort();
    final isRange = sorted.last - sorted.first == sorted.length - 1;
    if (isRange && sorted.length >= 3) {
      return '${weekdayNames[sorted.first - 1]}–'
          '${weekdayNames[sorted.last - 1]}';
    }
    return sorted.map((day) => weekdayNames[day - 1]).join(' · ');
  }

  /// Scheduled days in a row that were completed, counting back from today.
  /// Today does not break the streak until the day is over.
  int get currentStreak {
    final today = dateOnly(DateTime.now());
    var streak = 0;

    for (
      var day = today;
      !day.isBefore(createdAt);
      day = DateTime(day.year, day.month, day.day - 1)
    ) {
      if (!isScheduledOn(day)) continue;
      if (isDoneOn(day)) {
        streak++;
      } else if (day != today) {
        break;
      }
    }
    return streak;
  }

  /// The longest streak this habit has ever reached.
  int get bestStreak {
    final today = dateOnly(DateTime.now());
    var best = 0;
    var running = 0;

    for (
      var day = createdAt;
      !day.isAfter(today);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      if (!isScheduledOn(day)) continue;
      if (isDoneOn(day)) {
        running++;
        if (running > best) best = running;
      } else if (day != today) {
        running = 0;
      }
    }
    return best;
  }
}
