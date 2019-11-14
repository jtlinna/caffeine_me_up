import 'package:cafeine_me_up/models/auth_response.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:cafeine_me_up/utils/validators.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  final Function toggleAuthView;

  SignUpView({this.toggleAuthView});

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final AuthService _authService = AuthService();

  final _formKey = GlobalKey<FormState>();

  String _displayName = '';
  String _email = '';
  String _password = '';

  bool _loading = false;
  ErrorMessage _error;

  Future _signUp() async {
    setState(() {
      _error = null;
    });

    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    AuthResponse resp =
        await _authService.signUp(_displayName, _email, _password);
    if (resp.errorMessage != null) {
      setState(() {
        _loading = false;
        _error = resp.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text('Sign Up'),
              actions: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.person),
                  label: Text('Sign In'),
                  onPressed: () => widget.toggleAuthView(),
                  textColor: Theme.of(context).secondaryHeaderColor,
                )
              ],
            ),
            body: Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              color: Theme.of(context).backgroundColor,
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        initialValue: _displayName,
                        decoration: InputDecoration(
                          labelText: 'Display name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: validateDisplayName,
                        onChanged: (value) {
                          setState(() => _displayName = value);
                        },
                      ),
                      TextFormField(
                        initialValue: _email,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: validateEmail,
                        onChanged: (value) {
                          setState(() => _email = value);
                        },
                      ),
                      TextFormField(
                        initialValue: _password,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.edit)),
                        obscureText: true,
                        validator: validatePassword,
                        onChanged: (value) {
                          setState(() => _password = value);
                        },
                      ),
                      SizedBox(height: 10),
                      RaisedButton(
                        child: Text('Sign Up'),
                        onPressed: () async => _signUp(),
                      ),
                      SizedBox(height: _error != null ? 12.0 : 0.0),
                      Text(
                        _error != null ? _error.message : '',
                        style: TextStyle(
                            color: Theme.of(context).errorColor, fontSize: 14),
                      )
                    ],
                  )),
            ),
          );
  }
}
