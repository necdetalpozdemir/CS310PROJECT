/// Short date texts used on Today, Habit Detail and Progress.
/// Written by hand because the project has no intl package.
class DateLabels {
  DateLabels._();

  static const List<String> weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// "Nov"
  static String shortMonth(DateTime date) =>
      months[date.month - 1].substring(0, 3);

  /// "November"
  static String month(DateTime date) => months[date.month - 1];

  /// "22 Nov"
  static String dayMonth(DateTime date) => '${date.day} ${shortMonth(date)}';

  /// "Sun, 22 Nov"
  static String weekdayDayMonth(DateTime date) =>
      '${weekdays[date.weekday - 1]}, ${dayMonth(date)}';
}
