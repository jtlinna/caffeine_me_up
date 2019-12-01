import 'package:cafeine_me_up/constants/user_role.dart';
import 'package:cafeine_me_up/models/group_data.dart';
import 'package:cafeine_me_up/models/group_tuple.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/views/home/groups/group_details_view.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyGroupsView extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();
  @override
  Widget build(BuildContext context) {
    void _viewGroup(UserData userData, GroupTuple group) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
            return MultiProvider(providers: [
              StreamProvider<GroupData>.value(
                  value: _databaseService.groupData(group.id)),
              StreamProvider<UserData>.value(
                  value: _databaseService.userData(userData.uid))
            ], child: GroupDetailsView());
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

    UserData user = Provider.of<UserData>(context);
    ThemeData theme = Theme.of(context);
    return Container(
        color: Theme.of(context).backgroundColor,
        child: user == null
            ? Loading()
            : user.groups == null || user.groups.length == 0
                ? Center(
                    child: Text("You don't belong to any groups"),
                  )
                : ListView.builder(
                    itemCount: user.groups.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(user.groups[index].name,
                                        style: theme.textTheme.display2),
                                    Text(
                                        UserRole.asString(
                                            user.groups[index].role),
                                        style: theme.textTheme.display1)
                                  ],
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.center,
                                  child: RaisedButton(
                                    child: Text('View'),
                                    onPressed: () =>
                                        _viewGroup(user, user.groups[index]),
                                  ),
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
