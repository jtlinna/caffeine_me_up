import 'package:cafeine_me_up/models/drink_data.dart';
import 'package:cafeine_me_up/models/group_tuple.dart';
import 'package:flutter/material.dart';

class UserData {
  String uid;
  String displayName;
  String avatar;
  List<DrinkData> consumedDrinks;
  DrinkData lastConsumedDrink;
  Map<int, int> lifetimeConsumptions;
  List<GroupTuple> groups;
  
  UserData({@required this.uid, this.displayName, this.avatar, this.consumedDrinks, this.lastConsumedDrink, this.lifetimeConsumptions, this.groups});
  @override
  String toString() => 'UID $uid - Display name $displayName - Avatar $avatar - Consumed drinks $consumedDrinks - Last consumed drink $lastConsumedDrink - Lifetime consumptions $lifetimeConsumptions - Groups $groups';
}
