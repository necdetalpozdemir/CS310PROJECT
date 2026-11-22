import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myhabits/data/habit_data.dart';
import 'package:myhabits/data/user_session.dart';
import 'package:myhabits/routes.dart';
import 'package:myhabits/screens/auth/signup_screen.dart';
import 'package:myhabits/screens/habits/add_edit_habit_screen.dart';
import 'package:myhabits/screens/habits/my_habits_screen.dart';
import 'package:myhabits/screens/main_shell.dart';
import 'package:myhabits/utils/app_theme.dart';

Widget _app(Widget home) => MaterialApp(
  theme: AppTheme.light,
  routes: {
    for (final entry in AppRoutes.routes.entries)
      if (entry.key != AppRoutes.welcome) entry.key: entry.value,
  },
  home: home,
);

void main() {
  test('placeholder habits have the streaks from the wireframes', () {
    final byName = {for (final h in HabitData.habits) h.name: h};
    expect(byName['Drink 2 L of water']!.currentStreak, 5);
    expect(byName['Drink 2 L of water']!.bestStreak, 9);
    expect(byName['Study for 1 hour']!.currentStreak, 12);
    expect(byName['Study for 1 hour']!.bestStreak, 14);
    expect(byName['Walk 20 minutes']!.bestStreak, 6);
    expect(byName['Meditate 10 minutes']!.bestStreak, 0);
    expect(byName['Gym']!.bestStreak, 4);
    expect(byName['Study for 1 hour']!.frequencyLabel, 'Mon–Fri');
    expect(byName['Gym']!.frequencyLabel, 'Mon · Wed · Fri');
  });

  testWidgets('delete asks first and Undo restores the habit', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const MyHabitsScreen()));
    final before = HabitData.habits.length;

    await tester.tap(find.byTooltip('Delete Gym'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(HabitData.habits.length, before);

    await tester.tap(find.byTooltip('Delete Gym'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(HabitData.habits.length, before - 1);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(HabitData.habits.length, before);
    expect(HabitData.habits.last.name, 'Gym');
  });

  testWidgets('form shows inline errors and edit is pre-filled', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const AddEditHabitScreen()));
    await tester.enterText(find.byType(TextFormField).at(1), 'abc');
    await tester.tap(find.text('Save habit'));
    await tester.pump();
    expect(find.text('Please enter a habit name'), findsOneWidget);
    expect(find.text('Goal must be a number'), findsOneWidget);
    expect(find.text('Select at least one day'), findsOneWidget);

    final habit = HabitData.habits[1];
    await tester.pumpWidget(
      _app(AddEditHabitScreen(key: UniqueKey(), habit: habit)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Edit habit'), findsOneWidget);
    expect(find.text('Study for 1 hour'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('minutes'), findsOneWidget);
    expect(find.text('Save changes'), findsOneWidget);
  });

  testWidgets('sign up validates every field', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const SignUpScreen()));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(1), 'alp@');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret2');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pump();

    expect(find.text('Please enter your display name'), findsOneWidget);
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(find.text('Please agree to the terms to continue'), findsOneWidget);
  });

  testWidgets('valid sign up saves the user and opens Today', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(const SignUpScreen()));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ayse');
    await tester.enterText(fields.at(1), 'ayse@mail.com');
    await tester.enterText(fields.at(2), 'secret1');
    await tester.enterText(fields.at(3), 'secret1');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(UserSession.displayName, 'Ayse');
    expect(UserSession.email, 'ayse@mail.com');
  });
}
