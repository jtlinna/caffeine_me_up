import 'package:cafeine_me_up/models/group_data.dart';
import 'package:cafeine_me_up/views/home/home_scaffold.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupDetailsView extends StatefulWidget {
  @override
  _GroupDetailsViewState createState() => _GroupDetailsViewState();
}

class _GroupDetailsViewState extends State<GroupDetailsView> {
  @override
  Widget build(BuildContext context) {
    GroupData groupData = Provider.of<GroupData>(context);
    if (groupData == null) {
      return new HomeScaffold(title: '', body: Loading());
    }
    return HomeScaffold(
        title: groupData.groupName,
        body: Container(
            color: Theme.of(context).backgroundColor,
            child: Center(child: Text('Group details'))));
  }
}
