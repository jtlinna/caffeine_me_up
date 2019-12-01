import 'package:cafeine_me_up/constants/user_role.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/group_member_data.dart';
import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/services/http_service.dart';
import 'package:cafeine_me_up/views/home/groups/group_member_view.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupMemberCard extends StatefulWidget {
  final GroupMemberData groupMember;
  final managingMember;

  GroupMemberCard({@required this.groupMember, @required this.managingMember});

  @override
  _GroupMemberCardState createState() => _GroupMemberCardState();
}

class _GroupMemberCardState extends State<GroupMemberCard> {
  final HttpService _httpService = HttpService();
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  final _memberRoleOptions = [UserRole.Admin, UserRole.Member];

  int _currentRole;
  bool _waitingForResponse = false;

  void _updateMemberRole(int role) async {
    if (role == _currentRole) {
      return;
    }

    setState(() {
      _currentRole = role;
      _waitingForResponse = true;
    });

    ErrorMessage error = await _httpService.updateGroupMemberRole(
        groupId: widget.groupMember.groupId,
        groupMemberId: widget.groupMember.userData.uid,
        role: role);

    setState(() {
      _waitingForResponse = false;
      if (error != null) {
        _currentRole = widget.groupMember.role;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentRole = widget.groupMember.role;
  }

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
                  value: _databaseService
                      .userData(widget.groupMember.userData.uid))
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
    List<Widget> rowWidgets = [
      CircleAvatar(
          radius: 24,
          backgroundColor: theme.backgroundColor,
          backgroundImage: widget.groupMember.userData.avatar == ''
              ? AssetImage('images/generic_avatar.png')
              : NetworkImage(widget.groupMember.userData.avatar)),
      SizedBox(
        width: 20,
      )
    ];
    if (_waitingForResponse) {
      rowWidgets.addAll(<Widget>[
        Text(widget.groupMember.userData.displayName,
            style: theme.textTheme.display2),
        Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Loading(
            size: 24.0,
            color: theme.accentColor,
          ),
        )
      ]);
    } else if (widget.managingMember) {
      rowWidgets.addAll(<Widget>[
        Text(widget.groupMember.userData.displayName,
            style: theme.textTheme.display2),
        Spacer(),
        Container(
          width: 80,
          height: 50,
          child: DropdownButtonFormField<int>(
              value: _currentRole,
              items: _memberRoleOptions.map(
                (role) {
                  return DropdownMenuItem<int>(
                      child: Text(
                        UserRole.asString(role),
                        style: theme.textTheme.display2,
                      ),
                      value: role);
                },
              ).toList(),
              onChanged: (value) => _updateMemberRole(value)),
        ),
        SizedBox(
            width: 36,
            height: 36,
            child: FlatButton(
              textColor: theme.textTheme.display2.color,
              child: Icon(Icons.delete),
              onPressed: () => null,
            ))
      ]);
    } else {
      rowWidgets.addAll(<Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(widget.groupMember.userData.displayName,
                style: theme.textTheme.display2),
            Text(UserRole.asString(widget.groupMember.role),
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
      ]);
    }

    return Card(
      color: theme.accentColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Theme(
        data: theme.copyWith(canvasColor: theme.accentColor),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: rowWidgets,
          ),
        ),
      ),
    );
  }
}
