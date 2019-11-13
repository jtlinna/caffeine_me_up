import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/user.dart';

class AuthResponse {
  User user;
  ErrorMessage errorMessage;

  AuthResponse({this.user, this.errorMessage});

  @override
  String toString() =>
      'User $user - Error ${errorMessage != null ? errorMessage.message : 'N/A'}';
}
