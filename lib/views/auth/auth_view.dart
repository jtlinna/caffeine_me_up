import 'package:cafeine_me_up/views/auth/sign_up_view.dart';
import 'package:cafeine_me_up/views/auth/sign_in_view.dart';
import 'package:flutter/material.dart';

class AuthView extends StatefulWidget {
  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool _showSignIn = true;

  void _toggleAuthView() => setState(() => _showSignIn = !_showSignIn);

  @override
  Widget build(BuildContext context) {
    return _showSignIn
        ? SignInView(toggleAuthView: _toggleAuthView)
        : SignUpView(toggleAuthView: _toggleAuthView);
  }
}
