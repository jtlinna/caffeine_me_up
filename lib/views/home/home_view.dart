import 'package:cafeine_me_up/cards/home_card.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/views/home/consume_drink_view.dart';
import 'package:cafeine_me_up/views/home/groups/groups_view.dart';
import 'package:cafeine_me_up/views/home/home_scaffold.dart';
import 'package:cafeine_me_up/views/home/stats_view.dart';
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

    void _openView(Widget widget) {
      Navigator.push(
          context,
          PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
            return StreamProvider<UserData>.value(
                value: DatabaseService().userData(userData.uid), child: widget);
          }, transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
            Offset begin = Offset(1.0, 0.0);
            Offset end = Offset.zero;
            Curve curve = Curves.ease;

            Animatable<Offset> tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          }));
    }

    return HomeScaffold(
        title: 'Home',
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
                        onPressed: () => _openView(ConsumeDrinkView())),
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
                      onPressed: () => _openView(GroupsView())),
                  SizedBox(
                    width: 20,
                  ),
                  HomeCard(
                      image: 'images/stats.png',
                      label: 'Stats',
                      onPressed: () => _openView(StatsView())),
                ],
              )
            ],
          ),
        ));
  }
}
