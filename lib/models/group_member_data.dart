import 'package:cafeine_me_up/models/user_data.dart';

class GroupMemberData {
  String groupId;
  String groupName;
  int role;
  UserData userData;

  GroupMemberData({this.groupId, this.groupName, this.role, this.userData});
}