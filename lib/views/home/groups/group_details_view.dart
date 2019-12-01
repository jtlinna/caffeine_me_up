import 'package:cafeine_me_up/constants/user_role.dart';
import 'package:cafeine_me_up/models/group_data.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/views/home/groups/group_members_view.dart';
import 'package:cafeine_me_up/views/home/groups/group_stats_view.dart';
import 'package:cafeine_me_up/views/home/groups/invite_user_view.dart';
import 'package:cafeine_me_up/views/home/groups/manage_group_members_view.dart';
import 'package:cafeine_me_up/views/home/groups/manage_group_view.dart';
import 'package:cafeine_me_up/views/home/home_scaffold.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupDetailsView extends StatefulWidget {
  @override
  _GroupDetailsViewState createState() => _GroupDetailsViewState();
}

class _GroupDetailsViewState extends State<GroupDetailsView> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    GroupData groupData = Provider.of<GroupData>(context);
    if (groupData == null) {
      return new HomeScaffold(title: '', body: Loading());
    }

    UserData userData = Provider.of<UserData>(context);
    int groupIdx =
        userData.groups.indexWhere((group) => group.id == groupData.groupId);

    bool isOwner = groupIdx >= 0
        ? userData.groups[groupIdx].role == UserRole.Owner
        : false;

    bool isAdmin = groupIdx >= 0
        ? userData.groups[groupIdx].role == UserRole.Admin
        : false;

    List<Widget> tabOptions = [GroupMembersView(), GroupStatsView()];

    List<BottomNavigationBarItem> tabs = [
      BottomNavigationBarItem(icon: Icon(Icons.group), title: Text('Group\nMembers', textAlign: TextAlign.center,)),
      BottomNavigationBarItem(
          icon: Icon(Icons.show_chart), title: Text('Group\nStats', textAlign: TextAlign.center))
    ];

    if (isOwner || isAdmin) {
      tabOptions.add(InviteUserView());
      tabs.add(BottomNavigationBarItem(
          icon: Icon(Icons.group_add), title: Text('Invite\nMembers', textAlign: TextAlign.center)));
    }

    if (isOwner) {
      tabOptions.addAll([ManageGroupView(), ManageGroupMembersView()]);
      tabs.addAll([
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), title: Text('Manage\nGroup', textAlign: TextAlign.center)),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings), title: Text('Manage\nMembers', textAlign: TextAlign.center))
      ]);
    }

    return HomeScaffold(
      title: groupData.groupName,
      body: tabOptions[_currentTab],
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).accentColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentTab,
          onTap: (index) => setState(() => _currentTab = index),
          items: tabs),
    );
  }
}
