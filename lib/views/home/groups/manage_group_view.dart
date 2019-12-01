import 'package:cafeine_me_up/constants/user_role.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/group_data.dart';
import 'package:cafeine_me_up/models/group_member_data.dart';
import 'package:cafeine_me_up/services/http_service.dart';
import 'package:cafeine_me_up/utils/validators.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageGroupView extends StatefulWidget {
  final Function openDefaultTabCallback;

  ManageGroupView({this.openDefaultTabCallback});

  @override
  _ManageGroupViewState createState() => _ManageGroupViewState();
}

class _ManageGroupViewState extends State<ManageGroupView> {
  final _editKey = GlobalKey<FormState>();
  final HttpService _httpService = HttpService();

  String _newGroupName = '';
  bool _editingName = false;
  GroupMemberData _selectedNewOwner;

  bool _loading = false;
  ErrorMessage _error;

  void _editName() {
    setState(() {
      _editingName = true;
    });
  }

  void _confirmEditName(String groupId) async {
    if (!_editKey.currentState.validate()) {
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    ErrorMessage error = await _httpService.updateGroupData(
        groupId: groupId, groupName: _newGroupName);
    setState(() {
      _editingName = false;
      _newGroupName = '';
      _error = error;
      _loading = false;
    });
  }

  void _cancelEditName() {
    setState(() {
      _editingName = false;
      _newGroupName = '';
    });
  }

  void _showTransferOwnershipDialog(
      {GroupData groupData, GroupMemberData groupMemberData}) {
    if (groupMemberData == null) {
      return;
    }

    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("Transfer ${groupData.groupName}'s Ownership"),
            content: Text(
                "Do you want to transfer ${groupData.groupName}'s ownership to ${groupMemberData.userData.displayName}?"),
            actions: <Widget>[
              FlatButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(dialogContext)),
              FlatButton(
                child: Text("Transfer"),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _confirmTransferGroupOwnership(
                      groupData: groupData, groupMemberData: groupMemberData);
                },
              )
            ],
          );
        });
  }

  void _confirmTransferGroupOwnership(
      {GroupData groupData, GroupMemberData groupMemberData}) async {
    setState(() {
      _editingName = false;
      _error = null;
      _loading = true;
    });

    ErrorMessage error = await _httpService.transferGroupOwnership(
        groupId: groupData.groupId,
        groupMemberId: groupMemberData.userData.uid,
        groupMemberName: groupMemberData.userData.displayName);

    if (error == null) {
      widget.openDefaultTabCallback();
      return;
    }

    setState(() {
      _loading = false;
      _error = error;
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

    List<DropdownMenuItem<GroupMemberData>> memberDropdownItems =
        new List<DropdownMenuItem<GroupMemberData>>();
    groupData.members.forEach((member) {
      if (member.role == UserRole.Owner) {
        return;
      }

      memberDropdownItems.add(DropdownMenuItem<GroupMemberData>(
          child: Row(
            children: <Widget>[
              CircleAvatar(
                radius: 12,
                backgroundColor: Theme.of(context).accentColor,
                backgroundImage: member.userData.avatar == ''
                    ? AssetImage('images/generic_avatar.png')
                    : NetworkImage(member.userData.avatar),
              ),
              SizedBox(
                width: 20,
              ),
              Text(member.userData.displayName),
            ],
          ),
          value: member));
    });

    if (memberDropdownItems.length > 0) {
      widgets.addAll(<Widget>[
        SizedBox(
          height: 25.0,
        ),
        Text(
          'Transfer ownership:',
          style: textTheme.display2,
        ),
        DropdownButtonFormField<GroupMemberData>(
          items: memberDropdownItems,
          value: _selectedNewOwner ?? memberDropdownItems[0].value,
          onChanged: (value) => setState(() {
            _selectedNewOwner = value;
          }),
        ),
        RaisedButton(
          child: Text('Transfer'),
          onPressed: () => _showTransferOwnershipDialog(
              groupData: groupData,
              groupMemberData:
                  _selectedNewOwner ?? memberDropdownItems[0].value),
        )
      ]);
    }

    if (_error != null) {
      widgets.addAll(<Widget>[
        SizedBox(height: 12.0),
        Text(
          _error.message,
          style: TextStyle(color: Theme.of(context).errorColor, fontSize: 14),
          textAlign: TextAlign.center,
        )
      ]);
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final groupData = Provider.of<GroupData>(context);
    ThemeData theme = Theme.of(context);
    return _loading
        ? Loading()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
            color: theme.backgroundColor,
            child: Theme(
                data: theme.copyWith(canvasColor: theme.backgroundColor),
                child: Column(children: _createColumn(context, groupData))));
  }
}
