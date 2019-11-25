import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/views/home/profile_view.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScaffold extends StatelessWidget {
  final AuthService _auth = AuthService();

  final String title;
  final Widget body;
  final BottomNavigationBar bottomNavigationBar;

  HomeScaffold({this.title, this.body, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) {
    final UserData userData = Provider.of<UserData>(context);
    void _showProfile() {
      _auth.refreshCurrentUser();
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => StreamProvider<UserData>.value(
              value: DatabaseService().userData(userData.uid),
              child: ProfileView()));
    }

    return userData == null
        ? Loading()
        : Scaffold(
            appBar: AppBar(title: Text(title), actions: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.person),
                label: Text('Profile'),
                onPressed: _showProfile,
                textColor: Theme.of(context).secondaryHeaderColor,
              )
            ]),
            body: body,
            bottomNavigationBar: bottomNavigationBar);
  }
}
