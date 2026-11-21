import 'package:flutter/material.dart';

import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/habits/add_edit_habit_screen.dart';
import 'screens/main_shell.dart';
import 'screens/profile/change_password_screen.dart';

/// Named routes of the app. Screens that need data (Habit Detail,
/// Edit Habit, Icon Picker) are opened with Navigator.push instead.
class AppRoutes {
  AppRoutes._();

  static const String welcome = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String addHabit = '/add-habit';
  static const String changePassword = '/change-password';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomeScreen(),
        login: (context) => const LoginScreen(),
        signUp: (context) => const SignUpScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        home: (context) => const MainShell(),
        addHabit: (context) => const AddEditHabitScreen(),
        changePassword: (context) => const ChangePasswordScreen(),
      };
}
