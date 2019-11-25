final RegExp _nameRegex = RegExp(r"^[a-zA-Z0-9 ]*$");

final int _minDisplayNameLength = 4;
final int _maxDisplayNameLength = 15;

final RegExp _emailRegex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

final int _minPasswordLength = 8;

final int _minGroupNameLength = 4;
final int _maxGroupNameLength = 20;

String validateDisplayName(String value) {
  if (value.length < _minDisplayNameLength) {
    return 'Display name must be longer than $_minDisplayNameLength characters';
  }

  if (value.length > _maxDisplayNameLength) {
    return 'Display name cannot exceed $_maxDisplayNameLength characters';
  }

  if (!_nameRegex.hasMatch(value)) {
    return 'Display name can only contain alphanumeric characters';
  }

  return null;
}

String validateGroupName(String value) {
  if (value.length < _minGroupNameLength) {
    return 'Group name must be longer than $_minGroupNameLength characters';
  }

  if (value.length > _maxGroupNameLength) {
    return 'Group name cannot exceed $_maxGroupNameLength characters';
  }

  if (!_nameRegex.hasMatch(value)) {
    return 'Group name can only contain alphanumeric characters';
  }

  return null;
}

String validateEmail(String value) {
  if (value.length == 0 || !_emailRegex.hasMatch(value)) {
    return 'Invalid e-mail address';
  }

  return null;
}

String validatePassword(String password) {
  return password.length < _minPasswordLength
      ? 'Password must be at least $_minPasswordLength characters long'
      : null;
}
