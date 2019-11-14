import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final DatabaseService _databaseService = DatabaseService();

  final _nameKey = GlobalKey<FormState>();

  bool _editingName = false;

  String _newDisplayName = '';

  List<Widget> _createColumn(UserData userData) {
    List<Widget> widgets = <Widget>[];

    if (_editingName) {
      widgets.add(Form(
        key: _nameKey,
        child: TextFormField(
          initialValue: userData.displayName,
          decoration: InputDecoration(
            labelText: 'Display name',
            prefixIcon: Icon(Icons.person),
          ),
          validator: validateDisplayName,
          onChanged: (value) {
            setState(() => _newDisplayName = value);
          },
        ),
      ));
      widgets.add(
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FlatButton.icon(
          icon: Icon(Icons.cancel),
          label: Text('Cancel'),
          onPressed: _cancelEditName,
          textColor: Colors.brown[600],
        ),
        FlatButton.icon(
          icon: Icon(Icons.done),
          label: Text('Confirm'),
          onPressed: () => _confirmEditName(userData.uid),
          textColor: Colors.brown[600],
        )
      ]));
    } else {
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Display name: ${userData.displayName}',
            style: TextStyle(fontSize: 16, color: Colors.brown[600]),
          ),
          FlatButton.icon(
            icon: Icon(Icons.edit),
            label: Text('Edit'),
            onPressed: _editName,
            textColor: Colors.brown[600],
          )
        ],
      ));
    }

    widgets.addAll(<Widget>[
      SizedBox(height: 10),
      RaisedButton.icon(
        icon: Icon(Icons.exit_to_app),
        label: Text('Sign Out'),
        onPressed: () async => AuthService().signOut(),
        textColor: Theme.of(context).secondaryHeaderColor,
      )
    ]);
    return widgets;
  }

  void _editName() {
    setState(() {
      _editingName = true;
    });
  }

  void _cancelEditName() {
    setState(() {
      _editingName = false;
      _newDisplayName = '';
    });
  }

  void _confirmEditName(String uid) {
    if (!_nameKey.currentState.validate()) {
      return;
    }

    _databaseService.updateUserData(uid, displayName: _newDisplayName);
    setState(() {
      _editingName = false;
      _newDisplayName = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = Provider.of<UserData>(context);
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(top: 25),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Theme.of(context).backgroundColor),
        child: Column(
          children: <Widget>[
            AppBar(
              centerTitle: true,
              title: Text('Profile'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _createColumn(userData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
