import 'package:cafeine_me_up/models/auth_response.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:flutter/material.dart';

class SignInView extends StatefulWidget {
  final Function toggleAuthView;

  SignInView({this.toggleAuthView});

  @override
  _SignInViewState createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _email = '';
  String _password = '';

  ErrorMessage _error;

  Future _registerUser() async {
    AuthResponse resp = await _authService.signIn(_email, _password);
    setState(() {
      _error = resp.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In to Cafeine me up!'),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Register'),
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
                    labelText: 'Email',
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
                SizedBox(height: 50),
                RaisedButton(
                  child: Text('Sign In'),
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
