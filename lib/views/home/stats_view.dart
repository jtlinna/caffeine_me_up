import 'package:cafeine_me_up/constants/drink_type.dart';
import 'package:cafeine_me_up/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserData userData = Provider.of<UserData>(context);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(top: 25),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50), topRight: Radius.circular(50)),
            color: Theme.of(context).backgroundColor),
        child: Column(
          children: <Widget>[
            AppBar(
              centerTitle: true,
              title: Text('Stats'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
            ),
            SizedBox(height: 50),
            Text(
              'Lifetime consumption',
              style: Theme.of(context).textTheme.headline,
            ),
            SizedBox(height: 35,),
            Expanded(
              child: ListView.builder(
                itemCount: userData.lifetimeConsumptions.length,
                itemBuilder: (context, index) {
                  MapEntry<int, int> entry =
                      userData.lifetimeConsumptions.entries.elementAt(index);
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 96,
                            height: 96,
                            child:
                                Image.asset(DrinkType.getImagePath(entry.key)),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
