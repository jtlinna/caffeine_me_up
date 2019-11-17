class UserRole {
  static const int Admin = 1;
  static const int Member = 2;

  static String asString(int type) {
    switch (type) {
      case Admin:
        return 'Admin';
      case Member:
        return 'Member';
      default:
        return 'Unknown';
    }
  }
}
