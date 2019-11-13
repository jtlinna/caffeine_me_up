import 'package:cafeine_me_up/models/error_message.dart';

class DatabaseResponse {
  dynamic data;
  ErrorMessage errorMessage;

  DatabaseResponse({this.data, this.errorMessage});
}
