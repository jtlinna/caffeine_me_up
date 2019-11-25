class UserRole {
  static const int Owner = 1;
  static const int Admin = 2;
  static const int Member = 3;

  static String asString(int type) {
    switch (type) {
      case Owner:
        return 'Owner';
      case Admin:
        return 'Admin';
      case Member:
        return 'Member';
      default:
        return 'Unknown';
    }
  }
}
