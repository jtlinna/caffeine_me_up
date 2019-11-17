import 'package:flutter/material.dart';

class CreateGroupView extends StatefulWidget {
  @override
  _CreateGroupViewState createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: Center(child: Text('Create group')));
  }
}