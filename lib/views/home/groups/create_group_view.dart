import 'package:cafeine_me_up/models/database_response.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/utils/validators.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupView extends StatefulWidget {
  final Function openMyGroupsCallback;

  CreateGroupView({this.openMyGroupsCallback});

  @override
  _CreateGroupViewState createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();

  String _groupName = '';
  bool _isPrivate = false;
  ErrorMessage _error;
  bool _creatingGroup = false;

  void _createGroup(UserData creator) async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      _creatingGroup = true;
    });

    DatabaseResponse resp =
        await _databaseService.createGroup(creator, _groupName, _isPrivate);
    if (resp.errorMessage == null) {
      widget.openMyGroupsCallback();
      return;
    }

    setState(() {
      _creatingGroup = false;
      _error = resp.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = Provider.of<UserData>(context);
    final User user = Provider.of<User>(context);

    if (!user.verified) {
      return Container(
          color: Theme.of(context).backgroundColor,
          child: Center(
            child: Text(
                'Please verify your user account in order to create groups'),
          ));
    }

    return _creatingGroup
        ? Loading()
        : Container(
            color: Theme.of(context).backgroundColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Group name',
                        prefixIcon: Icon(Icons.group),
                      ),
                      validator: validateGroupName,
                      onChanged: (value) {
                        setState(() => _groupName = value);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Private'),
                      Switch(
                        value: _isPrivate,
                        onChanged: (value) =>
                            setState(() => _isPrivate = value),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  RaisedButton(
                    child: Text('Create'),
                    onPressed: () async => _createGroup(userData),
                  ),
                  SizedBox(height: _error != null ? 12.0 : 0.0),
                  Text(
                    _error != null ? _error.message : '',
                    style: TextStyle(
                        color: Theme.of(context).errorColor, fontSize: 14),
                  )
                ],
              ),
            ));
  }
}
