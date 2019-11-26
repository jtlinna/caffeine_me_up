import 'package:cafeine_me_up/models/group_member_data.dart';
import 'package:flutter/material.dart';

class GroupData {
  String groupId;
  String groupName;
  List<GroupMemberData> members;

  GroupData(
      {@required this.groupId, this.groupName, this.members});
  @override
  String toString() =>
      'GroupData $groupId -- Group name $groupName --  Members $members';
}
