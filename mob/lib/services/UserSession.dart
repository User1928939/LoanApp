class UserSession {
  static int? id;
  static String? email;

  static bool get isLoggedIn => id != null && email != null;

  static void clear() {
    id = null;
    email = null;
  }
}
