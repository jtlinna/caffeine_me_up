import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/views/home/profile_view.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  HomeScaffold({this.title, this.body});

  @override
  Widget build(BuildContext context) {
    final UserData userData = Provider.of<UserData>(context);
    void _showProfile() {
      showModalBottomSheet(
          context: context,
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
            body: body);
  }
}
