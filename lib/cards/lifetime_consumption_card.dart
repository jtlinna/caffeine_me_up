import 'package:cafeine_me_up/constants/drink_type.dart';
import 'package:flutter/material.dart';

class LifetimeConsumptionCard extends StatelessWidget {
  final MapEntry<int, int> entry;

  LifetimeConsumptionCard({this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            borderRadius: BorderRadius.circular(25)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 96,
              height: 96,
              child: Image.asset(DrinkType.getImagePath(entry.key)),
            ),
            SizedBox(
              width: 25,
            ),
            Text('${entry.value}',
                style: Theme.of(context)
                    .textTheme
                    .display3
                    .copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
