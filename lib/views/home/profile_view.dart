import 'dart:io';

import 'package:cafeine_me_up/models/auth_response.dart';
import 'package:cafeine_me_up/models/database_response.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/storage_response.dart';
import 'package:cafeine_me_up/models/user.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/services/http_service.dart';
import 'package:cafeine_me_up/services/storage_service.dart';
import 'package:cafeine_me_up/utils/validators.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _auth = AuthService();
  final HttpService _httpService = HttpService();
  final StorageService _storageService = StorageService();

  final _editKey = GlobalKey<FormState>();

  bool _editingName = false;
  bool _editingEmail = false;
  bool _waitingForResponse = false;

  String _newDisplayName = '';
  String _newEmail = '';

  File _newAvatar;

  ErrorMessage _error;

  List<Widget> _createColumn(
      BuildContext context, User user, UserData userData) {
    List<Widget> widgets = <Widget>[];

    if (user == null || userData == null) {
      return widgets;
    }

    final TextTheme textTheme = Theme.of(context).textTheme;


    if (_editingName) {
      widgets.add(Form(
        key: _editKey,
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
          textColor: textTheme.display2.color,
        ),
        FlatButton.icon(
          icon: Icon(Icons.done),
          label: Text('Confirm'),
          onPressed: () => _confirmEditName(userData.uid),
          textColor: textTheme.display2.color,
        )
      ]));
    } else {
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '${userData.displayName}',
            style: textTheme.headline,
          ),
          FlatButton.icon(
            icon: Icon(Icons.edit),
            label: Text('Edit', style: textTheme.display2),
            onPressed: _editName,
            textColor: textTheme.display2.color,
          )
        ],
      ));
    }

    widgets.add(SizedBox(height: 35));

    ImageProvider imgProvider;
    if (_newAvatar != null) {
      imgProvider = FileImage(_newAvatar);
    } else if (userData.avatar != '') {
      imgProvider = NetworkImage(userData.avatar);
    } else {
      imgProvider = AssetImage('images/generic_avatar.png');
    }

    widgets.add(CircleAvatar(
        radius: 96,
        backgroundColor: Theme.of(context).accentColor,
        backgroundImage: imgProvider));

    if (_newAvatar != null) {
      widgets.add(
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FlatButton.icon(
            icon: Icon(Icons.cancel),
            label: Text("Cancel"),
            textColor: textTheme.display2.color,
            onPressed: () {
              setState(() {
                _newAvatar = null;
              });
            }),
        FlatButton.icon(
            icon: Icon(Icons.done),
            label: Text("Confirm"),
            textColor: textTheme.display2.color,
            onPressed: () {
              _confirmNewAvatar(userData.uid);
            })
      ]));
    } else {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.delete,
              ),
              label: Text('Remove'),
              textColor: textTheme.display2.color,
              onPressed: () => _showConfirmRemoveAvatarDialog(user.uid),
            ),
            FlatButton.icon(
              icon: Icon(
                Icons.camera_alt,
              ),
              label: Text('Change'),
              textColor: textTheme.display2.color,
              onPressed: _showSelectAvatarSourceDialog,
            ),
          ],
        ),
      );
    }

    if (_editingEmail) {
      widgets.add(Form(
        key: _editKey,
        child: TextFormField(
          initialValue: user.email,
          decoration: InputDecoration(
            labelText: 'E-mail',
            prefixIcon: Icon(Icons.email),
          ),
          validator: validateEmail,
          onChanged: (value) {
            setState(() => _newEmail = value);
          },
        ),
      ));
      widgets.add(
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        FlatButton.icon(
          icon: Icon(Icons.cancel),
          label: Text('Cancel'),
          onPressed: _cancelEditEmail,
          textColor: textTheme.display2.color,
        ),
        FlatButton.icon(
          icon: Icon(Icons.done),
          label: Text('Confirm'),
          onPressed: () => _confirmEditEmail(),
          textColor: textTheme.display2.color,
        )
      ]));
    } else {
      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'E-mail: ${user.email}',
            style: textTheme.display2,
          ),
          FlatButton.icon(
            icon: Icon(Icons.edit),
            label: Text('Edit'),
            onPressed: _editEmail,
            textColor: textTheme.display2.color,
          )
        ],
      ));

      widgets.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'User status: ${user.verified ? 'Verified' : 'Not verified'}',
            style: textTheme.display2,
          ),
          user.verified
              ? new SizedBox()
              : FlatButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('Resend'),
                  onPressed: () => _resendVerificationEmail(),
                  textColor: textTheme.display2.color,
                )
        ],
      ));
    }

    if (_error != null) {
      widgets.add(Text(
        _error.message,
        style: TextStyle(color: Theme.of(context).errorColor, fontSize: 14),
      ));
    }

    widgets.addAll(<Widget>[
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton.icon(
            icon: Icon(Icons.delete),
            label: Text('Delete account'),
            onPressed: () => _showDeleteAccountDialog(context),
            textColor: Theme.of(context).secondaryHeaderColor,
          ),
          SizedBox(
            width: 20,
          ),
          RaisedButton.icon(
            icon: Icon(Icons.exit_to_app),
            label: Text('Sign Out'),
            onPressed: () async {
              Navigator.popUntil(context, (route) => route.isFirst);
              AuthService().signOut();
            },
            textColor: Theme.of(context).secondaryHeaderColor,
          ),
        ],
      )
    ]);
    return widgets;
  }

  void _showSelectAvatarSourceDialog() {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("Select source"),
            content: Text(
                "Do you want to select image from Gallery or take a new image with Camera?"),
            actions: <Widget>[
              FlatButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(dialogContext)),
              FlatButton(
                  child: Text("Camera"),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _selectNewAvatar(ImageSource.camera);
                  }),
              FlatButton(
                child: Text("Gallery"),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _selectNewAvatar(ImageSource.gallery);
                },
              )
            ],
          );
        });
  }

  void _selectNewAvatar(ImageSource source) async {
    File img = await ImagePicker.pickImage(
        source: source, maxWidth: 256, maxHeight: 256);
    if (img != null) {
      setState(() {
        _newAvatar = img;
      });
    }
  }

  void _confirmNewAvatar(String uid) async {
    setState(() {
      _error = null;
      _waitingForResponse = true;
    });

    StorageResponse storageResp =
        await _storageService.uploadAvatar(uid: uid, avatar: _newAvatar);
    if (storageResp.errorMessage != null) {
      setState(() {
        _newAvatar = null;
        _error = storageResp.errorMessage;
        _waitingForResponse = false;
      });

      return;
    }

    DatabaseResponse dbResp = await _databaseService.updateUserData(uid,
        avatar: storageResp.downloadUrl);
    setState(() {
      _newAvatar = null;
      _waitingForResponse = false;
      _error = dbResp.errorMessage;
    });
  }

  void _showConfirmRemoveAvatarDialog(String uid) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("Remove Avatar"),
            content: Text(
                "Do you want to remove your current Avatar? This action cannot be undone"),
            actions: <Widget>[
              FlatButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(dialogContext)),
              FlatButton(
                child: Text("Confirm"),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _removeAvatar(uid);
                },
              )
            ],
          );
        });
  }

  void _removeAvatar(String uid) async {
    setState(() {
      _waitingForResponse = true;
      _error = null;
      _newAvatar = null;
    });

    DatabaseResponse resp =
        await _databaseService.updateUserData(uid, avatar: '');

    setState(() {
      _waitingForResponse = false;
      _error = resp.errorMessage;
    });
  }

  void _editName() {
    setState(() {
      _error = null;
      _editingName = true;
      _editingEmail = false;
    });
  }

  void _confirmEditName(String uid) {
    if (!_editKey.currentState.validate()) {
      return;
    }

    _databaseService.updateUserData(uid, displayName: _newDisplayName);
    setState(() {
      _editingName = false;
      _newDisplayName = '';
    });
  }

  void _cancelEditName() {
    setState(() {
      _editingName = false;
      _newDisplayName = '';
    });
  }

  void _editEmail() {
    setState(() {
      _error = null;
      _editingEmail = true;
      _editingName = false;
    });
  }

  void _cancelEditEmail() {
    setState(() {
      _error = null;
      _editingEmail = false;
    });
  }

  void _confirmEditEmail() async {
    if (!_editKey.currentState.validate()) {
      return;
    }

    AuthResponse response = await _auth.updateEmail(_newEmail);
    setState(() {
      _error = response.errorMessage;
      if (response.errorMessage != null) {
        _editingName = false;
        _newEmail = '';
      }
    });
  }

  void _resendVerificationEmail() async {
    AuthResponse response = await _auth.resendVerificationEmail();
    setState(() {
      _error = response.errorMessage;
    });
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("Delete account"),
            content: Text("Are you sure you want to delete your account?"),
            actions: <Widget>[
              FlatButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(dialogContext)),
              FlatButton(
                child: Text("Delete"),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _confirmDeleteAccount(context);
                },
              )
            ],
          );
        });
  }

  void _confirmDeleteAccount(BuildContext context) async {
    setState(() {
      _error = null;
      _editingName = false;
      _editingEmail = false;
      _waitingForResponse = true;
    });

    ErrorMessage error = await _httpService.deleteUser();
    if (error != null) {
      setState(() {
        _waitingForResponse = false;
        _error = error;
      });
    } else {
      Navigator.popUntil(context, (route) => route.isFirst);
      AuthService().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
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
              automaticallyImplyLeading: false,
              title: Text('Profile'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              child: _waitingForResponse
                  ? Padding(
                      padding: EdgeInsets.only(top: 100), child: Loading())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _createColumn(context, user, userData),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
