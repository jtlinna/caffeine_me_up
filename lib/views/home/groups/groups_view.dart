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

  final _tabOptions = [MyGroupsView(), SearchGroupsView(), CreateGroupView()];

  int _currentTab = 0;
  @override
  Widget build(BuildContext context) {
    return HomeScaffold(
      title: 'Groups',
      body: _tabOptions[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).accentColor,
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: _tabs
      ),
    );
  }
}
