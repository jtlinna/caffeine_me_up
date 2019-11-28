import 'package:cafeine_me_up/constants/user_role.dart';
import 'package:cafeine_me_up/models/group_member_data.dart';
import 'package:flutter/material.dart';

class GroupMemberCard extends StatelessWidget {
  final GroupMemberData groupMember;

  GroupMemberCard({this.groupMember});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Card(
      color: theme.accentColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.group,
              color: theme.textTheme.display1.color,
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(groupMember.userData.displayName,
                    style: theme.textTheme.display2),
                Text(UserRole.asString(groupMember.role),
                    style: theme.textTheme.display1)
              ],
            ),
            Spacer(),
            Align(
                alignment: Alignment.center,
                child: RaisedButton(
                  child: Text('View'),
                  onPressed: () {},
                ))
          ],
        ),
      ),
    );
  }
}
