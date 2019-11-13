import 'package:cafeine_me_up/models/auth_response.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  final Function toggleAuthView;

  SignUpView({this.toggleAuthView});

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _displayName;
  String _email = '';
  String _password = '';

  ErrorMessage _error;

  Future _registerUser() async {
    AuthResponse resp =
        await _authService.signUp(_displayName, _email, _password);
    setState(() {
      _error = resp.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up to Cafeine me up!'),
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
                  decoration: InputDecoration(
                    labelText: 'Display name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    setState(() => _displayName = value);
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                  ),
                  onChanged: (value) {
                    setState(() => _email = value);
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Password', prefixIcon: Icon(Icons.edit)),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() => _password = value);
                  },
                ),
                SizedBox(height: 25),
                RaisedButton(
                  child: Text('Sign Up'),
                  onPressed: () async => _registerUser(),
                ),
                SizedBox(height: 12.0),
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
