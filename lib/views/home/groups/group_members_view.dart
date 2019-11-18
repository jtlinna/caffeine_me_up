import 'package:cafeine_me_up/constants/user_role.dart';
import 'package:cafeine_me_up/models/group_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupMembersView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    GroupData group = Provider.of<GroupData>(context);
    print(group);
    ThemeData theme = Theme.of(context);
    return Container(
        color: Theme.of(context).backgroundColor,
        child: ListView.builder(
          itemCount: group.members.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
              child: Card(
                color: theme.accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
                          Text(group.members[index].userData.displayName,
                              style: theme.textTheme.display2),
                          Text(UserRole.asString(group.members[index].role),
                              style: theme.textTheme.display1)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }
}
