import 'package:cafeine_me_up/views/home/groups/create_group_view.dart';
import 'package:cafeine_me_up/views/home/groups/my_groups_view.dart';
import 'package:cafeine_me_up/views/home/groups/search_groups_view.dart';
import 'package:cafeine_me_up/views/home/home_scaffold.dart';
import 'package:flutter/material.dart';

class GroupsView extends StatefulWidget {
  @override
  _GroupsViewState createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  final _tabs = [
    BottomNavigationBarItem(icon: Icon(Icons.group), title: Text('My groups')),
    BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('Search')),
    BottomNavigationBarItem(icon: Icon(Icons.group_add), title: Text('Create'))
  ];

  List<Widget> _tabOptions;

  void _openMyGroups() {
    setState(() {
      _currentTab = 0;
    });
  }

  int _currentTab = 0;
  @override
  void initState() {
    super.initState();
    _tabOptions = [
      MyGroupsView(),
      SearchGroupsView(),
      CreateGroupView(openMyGroupsCallback: _openMyGroups)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      title: 'Groups',
      body: _tabOptions[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).accentColor,
          currentIndex: _currentTab,
          onTap: (index) => setState(() => _currentTab = index),
          items: _tabs),
    );
  }
}
