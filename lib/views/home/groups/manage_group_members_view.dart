import 'package:cafeine_me_up/cards/group_member_card.dart';
import 'package:cafeine_me_up/constants/user_role.dart';
import 'package:cafeine_me_up/models/group_data.dart';
import 'package:cafeine_me_up/models/group_member_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageGroupMembersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupData group = Provider.of<GroupData>(context);
    List<GroupMemberData> members = group.members.where((member) => member.role != UserRole.Owner).toList();
    return Container(
        color: Theme.of(context).backgroundColor,
        child: ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              child: GroupMemberCard(groupMember: members[index], managingMember: true,),
            );
          },
        ));
  }
}
