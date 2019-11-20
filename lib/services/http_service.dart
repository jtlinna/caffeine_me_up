import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cloud_functions/cloud_functions.dart';

class HttpService {
  final HttpsCallable _inviteUserHandle = CloudFunctions(region: 'europe-west2')
      .getHttpsCallable(functionName: 'inviteUser');

  Future<ErrorMessage> inviteUser({String email, String groupId}) async {
    try {
      HttpsCallableResult result =
          await _inviteUserHandle.call({'email': email, 'groupId': groupId});
      print('Got result : ${result.data}');
      switch (result.data['status']) {
        case 0:
          return null;
        case -1:
          return new ErrorMessage(message: 'No user found with e-mail $email');
        case -2:
          return new ErrorMessage(
              message: 'Only admins are allowed to invite new users');
        case -3:
          return new ErrorMessage(message: 'User already in the group');
        case -4:
          return new ErrorMessage(
              message: 'User $email has already been invited to this group');
        default:
          return new ErrorMessage(message: 'Something went wrong');
      }
    } on CloudFunctionsException catch (e) {
      print(
          'Got error: Code ${e.code} -- Msg ${e.message} -- Details ${e.details}');
      return new ErrorMessage(message: 'Something went wrong');
    } catch (e) {
      print('Got error: $e');
      return new ErrorMessage(message: 'Something went wrong');
    }
  }
}
