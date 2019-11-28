import 'package:cafeine_me_up/cards/lifetime_consumption_card.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/views/home/home_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserData userData = Provider.of<UserData>(context);

    return HomeScaffold(
        title: 'Stats',
        body: Container(
          color: Theme.of(context).backgroundColor,
          padding: EdgeInsets.only(top: 25),
          child: Column(
            children: <Widget>[
              Text(
                'Lifetime consumption',
                style: Theme.of(context).textTheme.headline,
              ),
              SizedBox(
                height: 35,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: userData.lifetimeConsumptions.length,
                  itemBuilder: (context, index) {
                    return LifetimeConsumptionCard(
                        entry: userData.lifetimeConsumptions.entries
                            .elementAt(index));
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
