import 'package:cafeine_me_up/models/user_data.dart';

class User {
  String uid;
  String email;
  bool verified;
  UserData userData;

  User({this.uid, this.email, this.verified, this.userData});

  @override
  String toString() => '$uid - Email $email (verified $verified) : $userData';
}
