import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/views/home/groups/group_member_profile_view.dart';
import 'package:cafeine_me_up/views/home/groups/group_member_stats_view.dart';
import 'package:cafeine_me_up/views/home/home_scaffold.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupMemberView extends StatefulWidget {
  @override
  _GroupMemberViewState createState() => _GroupMemberViewState();
}

class _GroupMemberViewState extends State<GroupMemberView> {
  final _tabs = [
    BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Profile')),
    BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('Stats'))
  ];

  final _tabOptions = [GroupMemberProfileView(), GroupMemberStatsView()];

  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);

    final _headers = userData == null
        ? ['', '']
        : [
            '${userData.displayName}\'s profile',
            '${userData.displayName}\'s stats'
          ];

    return HomeScaffold(
      title: _headers[_currentTab],
      body: userData == null ? Loading() : _tabOptions[_currentTab],
      bottomNavigationBar: userData == null
          ? null
          : BottomNavigationBar(
              backgroundColor: Theme.of(context).accentColor,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentTab,
              onTap: (index) => setState(() => _currentTab = index),
              items: _tabs,
            ),
    );
  }
}
