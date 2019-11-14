import 'package:cafeine_me_up/models/drink_data.dart';
import 'package:flutter/material.dart';

class UserData {
  String uid;
  String displayName;
  List<DrinkData> consumedDrinks;
  DrinkData lastConsumedDrink;
  Map<int, int> lifetimeConsumptions;

  UserData({@required this.uid, this.displayName, this.consumedDrinks, this.lastConsumedDrink, this.lifetimeConsumptions});

  @override
  String toString() => 'UID $uid - Display name $displayName - Consumed drinks $consumedDrinks - Last consumed drink $lastConsumedDrink - Lifetime consumptions $lifetimeConsumptions';
}
