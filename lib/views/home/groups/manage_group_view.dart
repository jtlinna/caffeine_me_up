import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/group_data.dart';
import 'package:cafeine_me_up/services/http_service.dart';
import 'package:cafeine_me_up/utils/validators.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ManageGroupView extends StatefulWidget {
  @override
  _ManageGroupViewState createState() => _ManageGroupViewState();
}

class _ManageGroupViewState extends State<ManageGroupView> {
  final _formKey = GlobalKey<FormState>();
  final HttpService _httpService = HttpService();

  String _email = '';

  bool _loading = false;
  String _message = '';
  bool _isErrorMessage = false;

  Future _inviteUser(String groupId) async {
    setState(() {
      _message = null;
    });

    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    ErrorMessage resp =
        await _httpService.inviteUser(email: _email, groupId: groupId);
    setState(() {
      _loading = false;
      _email = '';
      _message = resp != null ? resp.message : 'Invitation sent';
      _isErrorMessage = resp != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupData = Provider.of<GroupData>(context);
    return _loading
        ? Loading()
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 50),
            color: Theme.of(context).backgroundColor,
            child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      initialValue: _email,
                      decoration: InputDecoration(
                        labelText: 'Invite user',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: validateEmail,
                      onChanged: (value) {
                        setState(() => _email = value);
                      },
                    ),
                    SizedBox(height: 10),
                    RaisedButton(
                      child: Text('Invite'),
                      onPressed: () async => _inviteUser(groupData.groupId),
                    ),
                    SizedBox(height: _message != null ? 12.0 : 0.0),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _isErrorMessage
                                ? Theme.of(context).errorColor
                                : Theme.of(context).textTheme.display1.color,
                            fontSize: 14),
                      ),
                    )
                  ],
                )),
          );
  }
}
