import 'package:cafeine_me_up/constants/drink_type.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupMemberProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    UserData userData = Provider.of<UserData>(context);
    MapEntry mostConsumedDrinkData;
    if (userData.lifetimeConsumptions != null) {
      userData.lifetimeConsumptions.forEach((type, amount) {
        if (amount > 0 &&
            (mostConsumedDrinkData == null ||
                mostConsumedDrinkData.value < amount)) {
          mostConsumedDrinkData = MapEntry(type, amount);
        }
      });
    }

    Widget mostConsumedDrink = mostConsumedDrinkData != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Most consumed drink:',
                style: theme.textTheme.display2,
              ),
              SizedBox(width: 5),
              SizedBox(
                width: 48,
                height: 48,
                child: Image.asset(
                    DrinkType.getImagePath(mostConsumedDrinkData.key)),
              ),
              SizedBox(width: 5),
              Text(
                '${mostConsumedDrinkData.value}',
                style: theme.textTheme.display2,
              )
            ],
          )
        : Align(
            child: Text(
              'Most consumed drink: None',
              style: theme.textTheme.display2,
            ),
            alignment: Alignment.center);

    Widget lastConsumedDrink = userData.lastConsumedDrink != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Last consumed drink:',
                style: theme.textTheme.display2,
              ),
              SizedBox(width: 5),
              SizedBox(
                width: 48,
                height: 48,
                child: Image.asset(
                    DrinkType.getImagePath(userData.lastConsumedDrink.type)),
              ),
            ],
          )
        : Align(
            child: Text(
              'Last consumed drink: None',
              style: theme.textTheme.display2,
            ),
            alignment: Alignment.center);

    return Container(
      color: theme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Align(
            child: Text('${userData.displayName}',
                style: theme.textTheme.headline),
            alignment: Alignment.center,
          ),
          SizedBox(
            height: 35,
          ),
          Align(
            child: CircleAvatar(
                radius: 96,
                backgroundColor: theme.accentColor,
                backgroundImage: userData.avatar == ''
                    ? AssetImage('images/generic_avatar.png')
                    : NetworkImage(userData.avatar)),
            alignment: Alignment.center,
          ),
          SizedBox(
            height: 35,
          ),
          mostConsumedDrink,
          SizedBox(
            height: 35,
          ),
          lastConsumedDrink
        ],
      ),
    );
  }
}
