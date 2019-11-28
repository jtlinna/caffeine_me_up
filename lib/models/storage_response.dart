import 'package:cafeine_me_up/models/error_message.dart';

class StorageResponse {
  String downloadUrl;
  ErrorMessage errorMessage;

  StorageResponse({this.downloadUrl, this.errorMessage});
}
