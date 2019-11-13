import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:cafeine_me_up/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().currentUser,
      child: MaterialApp(
        title: 'Caffeine me up!',
        theme: ThemeData(
            primaryColor: Colors.brown[500],
            backgroundColor: Colors.brown[100],
            buttonColor: Color(0xFF794853),
            errorColor: Colors.red),
        home: MainView(),
      ),
    );
  }
}
