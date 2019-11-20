import 'package:cafeine_me_up/constants/group_invitation_status.dart';
import 'package:cafeine_me_up/models/group_invitation.dart';
import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupInvitationsView extends StatefulWidget {
  @override
  _GroupInvitationsViewState createState() => _GroupInvitationsViewState();
}

class _GroupInvitationsViewState extends State<GroupInvitationsView> {
  final DatabaseService _databaseService = DatabaseService();

  void _rejectInvitation(User user, GroupInvitation invitation) async {
    _databaseService.updateGroupInvitationStatus(uid: user.uid, groupId: invitation.groupId, newStatus: GroupInvitationStatus.Rejected);
  }

  void _acceptInvitation(User user, GroupInvitation invitation) async {
    _databaseService.updateGroupInvitationStatus(uid: user.uid, groupId: invitation.groupId, newStatus: GroupInvitationStatus.Accepted);
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    if (user == null) {
      return Loading();
    }

    ThemeData theme = Theme.of(context);
    return StreamBuilder<List<GroupInvitation>>(
        stream: DatabaseService().groupInvitations(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Loading();
          }

          List<GroupInvitation> invitations = snapshot.data;
          return Container(
              color: Theme.of(context).backgroundColor,
              child: invitations.length == 0
                  ? Center(child: Text('No open group invitations'))
                  : ListView.builder(
                      itemCount: invitations.length,
                      itemBuilder: (context, index) {
                        GroupInvitation invitation = invitations[index];
                        return Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2.5),
                          child: Card(
                            color: theme.accentColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(invitation.groupName,
                                          style: theme.textTheme.display2),
                                    ],
                                  ),
                                  Spacer(),
                                  FlatButton.icon(
                                    textColor: theme.textTheme.display1.color,
                                      icon: Icon(Icons.cancel),
                                      label: Text('Reject'),
                                      onPressed: () async =>
                                          _rejectInvitation(user, invitation)),
                                  FlatButton.icon(
                                    textColor: theme.textTheme.display1.color,
                                      icon: Icon(Icons.check),
                                      label: Text('Accept'),
                                      onPressed: () async =>
                                          _acceptInvitation(user, invitation))
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ));
        });
  }
}
