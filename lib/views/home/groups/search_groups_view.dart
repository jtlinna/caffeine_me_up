import 'package:flutter/material.dart';

class SearchGroupsView extends StatefulWidget {
  @override
  _SearchGroupsViewState createState() => _SearchGroupsViewState();
}

class _SearchGroupsViewState extends State<SearchGroupsView> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: Center(child: Text('Search groups')));
  }
}