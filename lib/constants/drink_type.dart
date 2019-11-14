class DrinkType {
  static const int Coffee = 1;
  static const int Tea = 2;

  static String asString(int type) {
    switch (type) {
      case Coffee:
        return 'Coffee';
      case Tea:
        return 'Tea';
      default:
        return 'Unknown';
    }
  }

  static String getImagePath(int type) {
    switch (type) {
      case Coffee:
        return 'images/coffee.png';
      case Tea:
        return 'images/tea.png';
      default:
        return '';
    }
  }
}
