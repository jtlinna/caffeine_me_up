import 'package:cafeine_me_up/cards/home_card.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/views/home/consume_drink_view.dart';
import 'package:cafeine_me_up/views/home/groups_view.dart';
import 'package:cafeine_me_up/views/home/profile_view.dart';
import 'package:cafeine_me_up/views/home/stats_view.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final UserData userData = Provider.of<UserData>(context);

    Widget _buildModalBottomSheet(BuildContext context, Widget widget) {
      return StreamProvider<UserData>.value(
          value: DatabaseService().userData(userData.uid), child: widget);
    }

    void _showProfile() {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => _buildModalBottomSheet(context, ProfileView()));
    }

    void _showConsume() {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              _buildModalBottomSheet(context, ConsumeDrinkView()));
    }

    void _showGroups() {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              _buildModalBottomSheet(context, GroupsView()));
    }

    void _showStats() {
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) =>
              _buildModalBottomSheet(context, StatsView()));
    }

    return userData == null
        ? Loading()
        : Scaffold(
            appBar: AppBar(title: Text('Home'), actions: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.person),
                label: Text('Profile'),
                onPressed: _showProfile,
                textColor: Theme.of(context).secondaryHeaderColor,
              )
            ]),
            body: Container(
              color: Theme.of(context).backgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        HomeCard(
                            image: 'images/coffee.png',
                            label: 'Consume',
                            onPressed: _showConsume),
                      ]),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      HomeCard(
                          image: 'images/group.png',
                          label: 'Groups',
                          onPressed: _showGroups),
                      SizedBox(
                        width: 20,
                      ),
                      HomeCard(
                          image: 'images/stats.png',
                          label: 'Stats',
                          onPressed: _showStats),
                    ],
                  )
                ],
              ),
            ));
  }
}
