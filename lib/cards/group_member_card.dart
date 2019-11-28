import 'package:cafeine_me_up/constants/user_role.dart';
import 'package:cafeine_me_up/models/group_member_data.dart';
import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/views/home/groups/group_member_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupMemberCard extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();
  final GroupMemberData groupMember;

  GroupMemberCard({this.groupMember});

  @override
  Widget build(BuildContext context) {
    void _viewMember() {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
            return MultiProvider(providers: [
              StreamProvider<User>.value(value: _authService.currentUser),
              StreamProvider<UserData>.value(
                  value: _databaseService.userData(groupMember.userData.uid))
            ], child: GroupMemberView());
          }, transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
            Offset begin = Offset(1.0, 0.0);
            Offset end = Offset.zero;
            Curve curve = Curves.ease;

            Animatable<Offset> tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          }));
    }

    ThemeData theme = Theme.of(context);
    return Card(
      color: theme.accentColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: <Widget>[
            CircleAvatar(
                radius: 24,
                backgroundColor: theme.backgroundColor,
                backgroundImage: groupMember.userData.avatar == ''
                    ? AssetImage('images/generic_avatar.png')
                    : NetworkImage(groupMember.userData.avatar)),
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
                  onPressed: () => _viewMember(),
                ))
          ],
        ),
      ),
    );
  }
}
