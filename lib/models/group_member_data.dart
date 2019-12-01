import 'package:cafeine_me_up/models/user_data.dart';

class GroupMemberData {
  String groupId;
  int role;
  UserData userData;

  GroupMemberData({this.groupId, this.role, this.userData});
}