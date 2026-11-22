/// The logged-in user's placeholder information for Step 2.
/// In Step 3 these values will come from Firebase Authentication
/// and the Firestore `users` collection.
class UserSession {
  UserSession._();

  static String _displayName = '';
  static String email = '';

  /// The name typed on Sign Up or with "Edit display name".
  /// Log In has no name field, so after Log In the name is made from the
  /// email instead, e.g. "yusuf.arif@sabanciuniv.edu" -> "Yusuf Arif".
  static String get displayName =>
      _displayName.isNotEmpty ? _displayName : nameFromEmail(email);

  static set displayName(String value) => _displayName = value.trim();

  /// Called by the Log In screen with the email the user typed.
  static void logIn(String newEmail) {
    email = newEmail.trim();
    _displayName = '';
  }

  /// "alp.ozdemir@sabanciuniv.edu" -> "Alp Ozdemir".
  static String nameFromEmail(String email) {
    final localPart = email.split('@').first;
    final words = localPart
        .split(RegExp(r'[._\-]+'))
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1));
    final name = words.join(' ');
    return name.isEmpty ? 'MyHabits user' : name;
  }

  /// Network image used as the profile picture. The ui-avatars service
  /// draws the initials of the name, e.g. "Yusuf Arif" -> "YA", so the
  /// picture changes automatically when the display name changes.
  static String get avatarUrl =>
      'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}'
      '&size=256&background=3B6FD8&color=ffffff&bold=true';

  // Placeholder statistics shown on the Profile screen. In Step 3 they will
  // be calculated from the user's habits and check-ins in Firestore.
  static int habitCount = 5;
  static int bestStreak = 14;
}
