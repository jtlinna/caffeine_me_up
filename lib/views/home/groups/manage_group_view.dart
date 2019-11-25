import 'package:cafeine_me_up/models/group_data.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/utils/validators.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageGroupView extends StatefulWidget {
  @override
  _ManageGroupViewState createState() => _ManageGroupViewState();
}

class _ManageGroupViewState extends State<ManageGroupView> {
  final _editKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();

  String _newGroupName = '';
  bool _editingName = false;

  bool _loading = false;

  void _editName() {
    setState(() {
      _editingName = true;
    });
  }

  void _confirmEditName(String groupId) {
    if (!_editKey.currentState.validate()) {
      return;
    }

    _databaseService.updateGroupData(
        groupId: groupId, groupName: _newGroupName);
    setState(() {
      _editingName = false;
      _newGroupName = '';
    });
  }

  void _cancelEditName() {
    setState(() {
      _editingName = false;
      _newGroupName = '';
    });
  }

  List<Widget> _createColumn(BuildContext context, GroupData groupData) {
    List<Widget> widgets = new List<Widget>();

    TextTheme textTheme = Theme.of(context).textTheme;

    if (_editingName) {
      widgets.add(Form(
        key: _editKey,
        child: TextFormField(
          initialValue: groupData.groupName,
          decoration: InputDecoration(
            labelText: 'Group name',
            prefixIcon: Icon(Icons.group),
          ),
          validator: validateGroupName,
          onChanged: (value) {
            setState(() => _newGroupName = value);
          },
        ),
      ));
      widgets.add(
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FlatButton.icon(
          icon: Icon(Icons.cancel),
          label: Text('Cancel'),
          onPressed: _cancelEditName,
          textColor: textTheme.display2.color,
        ),
        FlatButton.icon(
          icon: Icon(Icons.done),
          label: Text('Confirm'),
          onPressed: () => _confirmEditName(groupData.groupId),
          textColor: textTheme.display2.color,
        )
      ]));
    } else {
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Group name: ${groupData.groupName}',
            style: textTheme.display2,
          ),
          FlatButton.icon(
            icon: Icon(Icons.edit),
            label: Text('Edit'),
            onPressed: _editName,
            textColor: textTheme.display2.color,
          )
        ],
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final groupData = Provider.of<GroupData>(context);
    return _loading
        ? Loading()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
            color: Theme.of(context).backgroundColor,
            child: Column(children: _createColumn(context, groupData)));
  }
}
