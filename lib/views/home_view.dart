import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    return Scaffold(
        appBar: AppBar(title: Text('Caffeine me up!'), actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.exit_to_app),
            label: Text('Sign Out'),
            onPressed: () async => AuthService().signOut(),
            textColor: Theme.of(context).secondaryHeaderColor,
          )
        ]),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 50),
          color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Welcome ${user.userData.displayName}!',
                style: TextStyle(fontSize: 27.0),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ));
  }
}
