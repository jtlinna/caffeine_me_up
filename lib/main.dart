import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:cafeine_me_up/views/main_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData template = Theme.of(context);
    return StreamProvider<User>.value(
      value: AuthService().currentUser,
      child: MaterialApp(
        title: 'Caffeine me up!',
        theme: ThemeData(
            canvasColor: Colors.transparent,
            primaryColor: Colors.brown[500],
            backgroundColor: Colors.brown[100],
            errorColor: Colors.red[700],
            accentColor: Colors.brown[300],
            buttonTheme: template.buttonTheme.copyWith(
                buttonColor: Color(0xFFE24E42),
                textTheme: ButtonTextTheme.primary),
            textTheme: template.textTheme.copyWith(
              display1: TextStyle(fontSize: 12, color: Colors.brown[600]),
              display2: TextStyle(fontSize: 16, color: Colors.brown[600]),
              display3: TextStyle(fontSize: 24, color: Colors.brown[600]),
              display4: TextStyle(fontSize: 32, color: Colors.brown[600]),
              overline: TextStyle(fontSize: 12, color: Colors.brown[600])
            )),
        home: MainView(),
      ),
    );
  }
}
