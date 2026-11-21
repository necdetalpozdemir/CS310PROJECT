/// The logged-in user's placeholder information for Step 2.
/// In Step 3 these values will come from Firebase Authentication
/// and the Firestore `users` collection.
class UserSession {
  UserSession._();

  static String displayName = 'Alp';
  static String email = 'alp.ozdemir@sabanciuniv.edu';

  /// Network image used as the profile picture.
  static const String avatarUrl =
      'https://ui-avatars.com/api/?name=My+Habits&size=256&background=3B6FD8&color=ffffff&bold=true';

  // Placeholder statistics shown on the Profile screen. In Step 3 they will
  // be calculated from the user's habits and check-ins in Firestore.
  static int habitCount = 5;
  static int bestStreak = 14;
}
