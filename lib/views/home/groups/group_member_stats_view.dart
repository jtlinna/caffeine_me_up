import 'package:cafeine_me_up/cards/lifetime_consumption_card.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupMemberStatsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserData userData = Provider.of<UserData>(context);
    ThemeData theme = Theme.of(context);

    return Container(
      color: theme.backgroundColor,
      padding: EdgeInsets.only(top: 25),
      child: Column(
        children: <Widget>[
          Text(
            'Lifetime consumption',
            style: theme.textTheme.headline,
          ),
          SizedBox(
            height: 35,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: userData.lifetimeConsumptions.length,
              itemBuilder: (context, index) {
                return LifetimeConsumptionCard(
                    entry:
                        userData.lifetimeConsumptions.entries.elementAt(index));
              },
            ),
          ),
        ],
      ),
    );
  }
}
