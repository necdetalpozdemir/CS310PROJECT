import 'package:flutter/material.dart';

import 'routes.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MyHabitsApp());
}

class MyHabitsApp extends StatelessWidget {
  const MyHabitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyHabits',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
