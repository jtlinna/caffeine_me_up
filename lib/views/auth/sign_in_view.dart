import 'package:cafeine_me_up/models/auth_response.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/services/auth_service.dart';
import 'package:cafeine_me_up/utils/validators.dart';
import 'package:cafeine_me_up/views/loading.dart';
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

  bool _loading = false;
  ErrorMessage _error;

  Future _signIn() async {
    setState(() {
      _error = null;
    });

    if (!_formKey.currentState.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    AuthResponse resp = await _authService.signIn(_email, _password);
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
                        initialValue: _email,
                        decoration: InputDecoration(
                          labelText: 'Email',
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
                        child: Text('Sign In'),
                        onPressed: () async => _signIn(),
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
