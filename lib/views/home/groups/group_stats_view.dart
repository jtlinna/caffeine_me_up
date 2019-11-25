import 'package:cafeine_me_up/constants/drink_type.dart';
import 'package:cafeine_me_up/models/group_data.dart';
import 'package:cafeine_me_up/views/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupStatsView extends StatefulWidget {
  @override
  _GroupStatsViewState createState() => _GroupStatsViewState();
}

class _MemberStatData {
  String displayName;
  int lifetimeConsumptions;

  _MemberStatData({this.displayName, this.lifetimeConsumptions});
}

class _GroupStatsViewState extends State<GroupStatsView> {
  final List<int> _drinkOptions = [
    DrinkType.Coffee,
    DrinkType.Tea,
    DrinkType.All
  ];
  int _selectedDrinkType = DrinkType.Coffee;

  @override
  Widget build(BuildContext context) {
    GroupData groupData = Provider.of<GroupData>(context);
    if (groupData == null) {
      return Loading();
    }

    ThemeData theme = Theme.of(context);
    List<_MemberStatData> statList = groupData.members.map((member) {
      int lifetimeConsumptions;
      if (_selectedDrinkType == DrinkType.All) {
        lifetimeConsumptions = 0;
        member.userData.lifetimeConsumptions
            .forEach((_, consumption) => lifetimeConsumptions += consumption);
      } else {
        lifetimeConsumptions =
            member.userData.lifetimeConsumptions[_selectedDrinkType] ?? 0;
      }
      return _MemberStatData(
          displayName: member.userData.displayName,
          lifetimeConsumptions: lifetimeConsumptions);
    }).toList();
    statList.sort(
        (m1, m2) => m2.lifetimeConsumptions.compareTo(m1.lifetimeConsumptions));
    return Container(
        color: Theme.of(context).backgroundColor,
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: theme.backgroundColor),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 25),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField<int>(
                  items: _drinkOptions.map((type) {
                    return DropdownMenuItem<int>(
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Image.asset(DrinkType.getImagePath(type)),
                            ),
                            SizedBox(
                              width: 10,
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
                SizedBox(
                  height: 25,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: statList.length,
                    itemBuilder: (context, index) {
                      _MemberStatData stat = statList[index];
                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
                        child: Card(
                          color: theme.accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: Row(
                              children: <Widget>[
                                Text('${index + 1}.',
                                    style: theme.textTheme.display2),
                                SizedBox(
                                  width: 20,
                                ),
                                Text('${stat.displayName}',
                                    style: theme.textTheme.display2),
                                Spacer(),
                                Text('${stat.lifetimeConsumptions}',
                                    style: theme.textTheme.display2),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
