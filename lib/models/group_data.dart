import 'package:cafeine_me_up/models/group_member_data.dart';
import 'package:flutter/material.dart';

class GroupData {
  String groupId;
  String groupName;
  bool isPrivate;
  List<GroupMemberData> members;

  GroupData(
      {@required this.groupId, this.groupName, this.isPrivate, this.members});
  @override
  String toString() =>
      'GroupData $groupId -- Group name $groupName -- Is private $isPrivate -- Members $members';
}
