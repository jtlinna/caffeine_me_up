import 'package:cafeine_me_up/models/user_data.dart';

class GroupData {
  String groupId;
  String groupName;
  bool isPrivate;
  List<UserData> members;

  GroupData(
      {groupId, this.groupName, this.isPrivate, this.members});
  @override
  String toString() =>
      'GroupData $groupId -- Group name $groupName -- Is private $isPrivate -- Members $members';
}
