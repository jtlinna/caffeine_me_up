import 'package:cafeine_me_up/constants/drink_type.dart';
import 'package:cafeine_me_up/models/drink_data.dart';
import 'package:cafeine_me_up/models/error_message.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:cafeine_me_up/services/database_service.dart';
import 'package:cafeine_me_up/utils/formatters.dart';
import 'package:cafeine_me_up/views/home/home_scaffold.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConsumeDrinkView extends StatefulWidget {
  @override
  _ConsumeDrinkViewState createState() => _ConsumeDrinkViewState();
}

class _ConsumeDrinkViewState extends State<ConsumeDrinkView> {
  final DatabaseService _databaseService = DatabaseService();
  final List<int> _drinkOptions = [DrinkType.Coffee, DrinkType.Tea];
  final Duration _minInterval = Duration(minutes: 10);

  int _selectedDrinkType;
  ErrorMessage _error;

  Future _consumeDrink(UserData userData) async {
    print(
        'User ${userData.displayName} would consume ${DrinkType.asString(_selectedDrinkType)}');
    DateTime now = DateTime.now();
    if (userData.lastConsumedDrink != null) {
      DateTime allowedConsumeTime =
          userData.lastConsumedDrink.consumedAt.add(_minInterval);

      if (now.isBefore(allowedConsumeTime)) {
        setState(() {
          _error = new ErrorMessage(message: 'Too soon');
        });

        return;
      }
    }

    setState(() {
      _error = null;
    });

    DrinkData drink = new DrinkData(type: _selectedDrinkType, consumedAt: now);
    userData.consumedDrinks.add(drink);
    userData.lastConsumedDrink = drink;
    userData.lifetimeConsumptions[_selectedDrinkType]++;

    _databaseService.updateUserData(userData.uid,
        consumedDrinks: userData.consumedDrinks,
        lastConsumedDrink: drink,
        lifetimeConsumptions: userData.lifetimeConsumptions);
  }

  @override
  Widget build(BuildContext context) {
    final UserData userData = Provider.of<UserData>(context);
    if(userData == null) {
      return Loading();
    }

    String lastDrinkConsumedAt = userData.lastConsumedDrink != null
        ? 'Consumed at ${formatDateTime(userData.lastConsumedDrink.consumedAt)}'
        : null;
    String lastConsumedDrinkImagePath = userData.lastConsumedDrink != null
        ? DrinkType.getImagePath(userData.lastConsumedDrink.type)
        : null;

    final ThemeData theme = Theme.of(context);

    if (_selectedDrinkType == null) {
      _selectedDrinkType = userData.lastConsumedDrink != null
          ? userData.lastConsumedDrink.type
          : DrinkType.Coffee;
    }

    return HomeScaffold(
      title: "Consume drink",
      body: Container(
        color: Theme.of(context).backgroundColor,
        padding: EdgeInsets.only(top: 25),
        child: Column(
          children: <Widget>[
            SizedBox(height: 50),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('Last consumed drink',
                        style: theme.textTheme.display3),
                    lastConsumedDrinkImagePath != null
                        ? SizedBox(
                            width: 128,
                            height: 128,
                            child: Image.asset(lastConsumedDrinkImagePath))
                        : new Text(
                            'None',
                            style: theme.textTheme.display2,
                          ),
                    lastDrinkConsumedAt != null
                        ? Text('$lastDrinkConsumedAt',
                            style: theme.textTheme.display1
                                .copyWith(fontStyle: FontStyle.italic))
                        : new Container(
                            width: 0,
                            height: 0,
                          ),
                    SizedBox(
                      height: 25,
                    ),
                    Theme(
                      data: Theme.of(context)
                          .copyWith(canvasColor: theme.backgroundColor),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: DropdownButtonFormField<int>(
                          items: _drinkOptions.map((type) {
                            return DropdownMenuItem<int>(
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Image.asset(
                                          DrinkType.getImagePath(type)),
                                    ),
                                    Text(DrinkType.asString(type),
                                        style: theme.textTheme.display2),
                                  ],
                                ),
                                value: type);
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedDrinkType = value),
                          value: _selectedDrinkType,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    RaisedButton(
                      child: Text('Consume'),
                      onPressed: () async => _consumeDrink(userData),
                    ),
                    SizedBox(height: _error != null ? 12.0 : 0.0),
                    Text(
                      _error != null ? _error.message : '',
                      style: TextStyle(color: theme.errorColor, fontSize: 14),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
