import 'package:cafeine_me_up/views/home/home_scaffold.dart';
import 'package:flutter/material.dart';

class GroupsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
        title: 'Groups',
        body: Container(
            color: Theme.of(context).backgroundColor,
            child: Center(child: Text('Groups view'))));
  }
}
