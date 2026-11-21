# MyHabits

MyHabits is a mobile habit tracker built with Flutter. Users create daily habits such as "drink 2 L of water" or "study for 1 hour", check them off with one tap, and follow their streaks and weekly progress.

## Group 21

- Necdet Alp Özdemir – 33900
- Kerem Şahinoğlu – 35842
- Yusuf Arif Özkuttaş – 32097

## Requirements

- Flutter **3.47.9** (stable channel)
- iOS Simulator (Xcode) or Android emulator

## How to run

```bash
git clone https://github.com/necdetalpozdemir/CS310PROJECT.git
cd CS310PROJECT
flutter pub get
flutter run
```

Login and sign-up are UI only in Step 2: any valid email and a password with at least 6 characters open the app. All habits are placeholder data; Firebase Authentication and Cloud Firestore will be added in Step 3.

## Project structure

```
lib/
  main.dart            app entry point (theme + named routes)
  routes.dart          named routes
  utils/               shared colors, text styles, spacing, theme, validators
  models/              Habit model class
  data/                placeholder data (replaced by Firebase in Step 3)
  widgets/             reusable widgets (HabitCard, StatTile, PrimaryButton, ...)
  screens/
    auth/              Welcome, Log In, Sign Up, Forgot Password
    today/             Today (home) and Habit Detail
    habits/            My Habits, Add / Edit Habit
    progress/          Progress
    profile/           Profile & Settings, Change Password
assets/
  images/              local images (app logo, Welcome illustration)
  fonts/               Inter font (custom font, OFL licence)
```
