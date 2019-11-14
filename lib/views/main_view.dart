import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/views/auth/auth_view.dart';
import 'package:cafeine_me_up/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    return user != null
        ? StreamProvider<UserData>.value(
            value: DatabaseService().userData(user.uid), child: HomeView())
        : AuthView();
  }
}
